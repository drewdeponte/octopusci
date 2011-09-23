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
    
    before do
      ActiveRecord::Base.verify_active_connections!
    end
    
    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)        
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ Octopusci::CONFIG['http_basic']['username'], Octopusci::CONFIG['http_basic']['password'] ]
      end
    end
    
    get '/' do
      protected!
      @jobs = ::Job.order('jobs.created_at DESC').limit(20)
      erb :index
    end
    
    get '/:repo_name/:branch_name' do
      protected!
      @page_logo = "#{params[:repo_name]} / #{params[:branch_name]}"
      @jobs = ::Job.where(:repo_name => params[:repo_name], :ref => "refs/heads/#{params[:branch_name]}").order('jobs.created_at DESC').limit(20)
      erb :index
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
      
      if github_payload["ref"] =~ /refs\/heads\//
        branch_name = github_payload["ref"].gsub(/refs\/heads\//, '')
      
        # Queue the job appropriately
        Octopusci::Queue.enqueue(proj_info['job_klass'], github_payload["repository"]["name"], branch_name, github_payload, proj_info)
      else
        return 200
      end
    end
        
  end
end