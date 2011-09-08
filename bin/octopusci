#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'
require 'resque'

require File.expand_path('../lib/notifier.rb', __FILE__)

PROJECTS = [
  {
    :name => 'temp_pusci_test'
  }
]


class DrewSleep
  def self.perform(payload)
    # Fetch the latest from the repo and checkout the ref
    
    # Run the build commands
    f = File.open('/tmp/pusci_cmds.sh', 'w')
    f.write("""#!/bin/bash
    echo 'foo bar titty'
    exit 0
    """)
    f.chmod(0775)
    f.close()

    cmd_output = `/tmp/pusci_cmds.sh`
    cmd_status = $?
    
    # Notify about the results
    Notifier.job_complete('cyphactor@gmail.com', cmd_output, cmd_status, payload).deliver 
  end
end

get '/:project_name/:branch_name/manbuild' do
  q_name = params[:project_name] + '-' + params[:branch_name]
  puts "#{q_name} - Queue Size: #{Resque.size(q_name)}"
  Resque.push(q_name, :class => 'DrewSleep', :args => [])
end

post '/github-build' do
  payload = JSON.parse(params[:payload])
  
  repository_name = payload["repository"]["name"]
  branch_name = payload["ref"].gsub(/refs\/heads\//, '')
    
  q_name = "#{repository_name}-#{branch_name}"
  
  repository_url = payload["repository"]["url"]
  compare_url = payload["compare"]
  
  pusher_name = payload["pusher"]["name"]
  pusher_email = payload["pusher"]["email"]

  puts "------------ BUILDING -------------"
  puts "repository_name: #{repository_name}"
  puts "branch_name: #{branch_name}"
  puts "repository_url: #{repository_url}"
  puts "compare_url: #{compare_url}"
  puts "pusher_name: #{pusher_name}"
  puts "pusher_email: #{pusher_email}"
  puts "Payload: "
  puts payload.inspect
  
  PROJECTS.each do |proj|
    if (proj[:name] == repository_name)
      # Append job to this branches queue
      Resque.push(q_name, :class => 'DrewSleep', :args => [])
      break
    end
  end
end

