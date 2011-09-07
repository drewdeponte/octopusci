#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'
require 'resque'

class DrewSleep
  def self.perform()
    sleep 600
  end
end

# f = File.open('/tmp/pusci_cmds.sh', 'w')
# f.write("""#!/bin/bash
# echo 'foo bar titty'
# """)
# f.chmod(0775)
# f.close()
# 
# output = IO.popen('/tmp/pusci_cmds.sh')
# puts output.read
# 
# exit

get '/:project_name/:branch_name/manbuild' do
  q_name = params[:project_name] + '-' + params[:branch_name]
  puts "#{q_name} - Queue Size: #{Resque.size(q_name)}"
  Resque.push(q_name, :class => 'DrewSleep', :args => [])
end

post '/:project_name/build' do
  proj_name = params[:project_name]
  payload = params[:payload]
  
  PROJECTS.each do |proj|
    if (proj_name == proj[:name])
      # Create project branch queue hash if it doesn't exist yet
      if !PROJECT_QUEUES.has_key?(proj_name)
        PROJECT_QUEUES[proj_name] = {}
      end
      
      ref = payload["ref"]
      
      # Create branch specific queue if it doesn't already exist
      if !PROJECT_QUEUES[proj_name].has_key?(ref)
        PROJECT_QUEUES[proj_name][ref] = []
      end
      
      # Append job to this branches queue
      PROJECT_QUEUES[proj_name][ref].push(1)
      
      # Fetch the latest from the repo and checkout the ref
      
      # Run the build commands
      
      # Notify about the results
      
      puts "------------ BUILDING -------------"    
      puts "Project Name: #{params[:project_name]}"
      puts "Project Queue: #{PROJECT_QUEUES[proj_name].inspect}"
      puts "Payload: #{JSON.parse(params[:payload]).inspect}"
      break
    end
  end
end

