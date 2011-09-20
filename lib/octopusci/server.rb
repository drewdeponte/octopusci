require 'bundler/setup'
require 'sinatra/base'
require 'multi_json'
require 'erb'
require 'octopusci'

module Octopusci
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{dir}/server/views"
    set :public, "#{dir}/server/public"
    set :static, true
    
    def initialize
      if Octopusci::CONFIG.has_key?('stages')
        Octopusci::StageLocker.load(Octopusci::CONFIG['stages'])
      end
      
      super
    end
    
    get '/' do
      @jobs = ::Job.order('jobs.created_at DESC').limit(20)
      erb :index
    end
    
    get '/:repo_name/:branch_name' do
      @page_logo = "#{params[:repo_name]} / #{params[:branch_name]}"
      @jobs = ::Job.where(:repo_name => params[:repo_name], :ref => "refs/heads/#{params[:branch_name]}").order('jobs.created_at DESC').limit(20)
      erb :index
    end
    
    get '/:project_name/:branch_name/manbuild' do
      github_payload = {}
      # q_name = params[:project_name] + '-' + params[:branch_name]
      # puts "#{q_name} - Queue Size: #{Resque.size(q_name)}"
      # Resque.push(q_name, :class => 'Octopusci::Job', :args => ['/tmp/pusci_cmds.sh', github_payload])
      # Use redis to store 'payload:foo' as the git

      Octopusci::Queue.enqueue('MyTestJob', params[:project_name], params[:branch_name], github_payload)
    end

    post '/github-build' do
      if params['payload'].nil?
        raise "No payload paramater found, it is a required parameter."
      end
      github_payload = Octopusci::Helpers.decode(params["payload"])
            
      # Make sure that the request is for a project Octopusci knows about
      proj_info = Octopusci::Helpers.get_project_info(github_payload["repository"]["name"], github_payload["repository"]["owner"]["name"])
      if proj_info.nil?
        return 404
      end
      
      branch_name = github_payload["ref"].gsub(/refs\/heads\//, '')
      
      # Queue the job appropriately
      Octopusci::Queue.enqueue(proj_info['job_klass'], github_payload["repository"]["name"], branch_name, github_payload, proj_info)
    end
        
  end
end