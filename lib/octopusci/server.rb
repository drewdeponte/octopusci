require 'bundler/setup'
require 'sinatra/base'
require 'json'
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
    
    
    get '/test' do
      erb :hello_world
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
      github_payload = JSON.parse(params[:payload])

      repository_name = github_payload["repository"]["name"]
      branch_name = github_payload["ref"].gsub(/refs\/heads\//, '')

      q_name = "#{repository_name}-#{branch_name}"

      Octopusci::CONFIG["projects"].each do |proj|
        if (proj['name'] == repository_name) # TODO: Add checking for project owner as well so that it won't build other peoples repos.
          # Append job to this branches queue
          Resque.push(q_name, :class => 'DrewSleep', :args => ['/tmp/pusci_cmds.sh', github_payload])
          break
        end
      end
    end
  end
end