#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'git'

post '/:proj_name/build' do
  puts params.inspect
end

