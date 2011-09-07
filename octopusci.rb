#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'
require 'resque'

# require 'grit'
# 
# include Grit
# 
# gritty = Grit::Git.new('/tmp/filling-in')
# gritty.clone({:quiet => false, :verbose => true, :progress => true}, "git://github.com/cyphactor/temp_pusci_test.git", "/tmp/temp_pusci_test")
# puts gritty.heads
# 
# exit

PROJECTS = [
  {
    :name => "temp_pusci_test",
    :workspace_path => "/Users/adeponte/.pusci/"
  }
]

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

PROJECT_QUEUES = {}

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

