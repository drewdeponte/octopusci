require 'sinatra/base'
require 'multi_json'
require 'erb'
require 'octopusci'

module Octopusci
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{dir}/server/views"
    set :public_folder, "#{dir}/server/public"
    set :static, true
    
    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)        
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ Octopusci::Config['http_basic']['username'], Octopusci::Config['http_basic']['password'] ]
      end
    end
    
    get '/' do
      protected!
      @jobs = Octopusci::JobStore.list(0, 20)
      erb :index
    end

    get '/:repo_name/:branch_name/jobs' do
      protected!
      @page_logo = "#{params[:repo_name]} / #{params[:branch_name]}"
      @jobs = Octopusci::JobStore.list_repo_branch(params[:repo_name], params[:branch_name], 0, 20)
      erb :index
    end
    
    get '/jobs/:job_id' do
      protected!
      @job = Octopusci::JobStore.get(params[:job_id])
      erb :job
    end
    
    get '/jobs/:job_id/output' do
      protected!
      @job = Octopusci::JobStore.get(params[:job_id])
      content_type('text/plain')
      return Octopusci::IO.new(@job).read_all_out_as_html
    end

    get '/jobs/:job_id/silent_output' do
      protected!
      @job = Octopusci::JobStore.get(params[:job_id])
      content_type('text/plain')
      return Octopusci::IO.new(@job).read_all_log_as_html
    end

    get '/jobs/:job_id/status' do
      protected!
      @job = Octopusci::JobStore.get(params[:job_id])
      content_type('text/plain')
      return @job['status']
    end
    
    get '/jobs/:job_id/ajax_summary' do
      protected!
      @job = Octopusci::JobStore.get(params[:job_id])
      erb :job_summary, :layout => false, :locals => { :j => @job }
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

      if (github_payload["ref"] =~ /refs\/heads\//) && (github_payload["deleted"] != true)
        branch_name = github_payload["ref"].gsub(/refs\/heads\//, '')
      
        # Queue the job appropriately
        Octopusci::Queue.enqueue(proj_info['job_klass'], github_payload["repository"]["name"], branch_name, github_payload, proj_info)
        return 200
      else
        return 200
      end
    end

  end
end