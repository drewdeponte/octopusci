#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'git'

get '/hi' do
  "Hello World!"
end

