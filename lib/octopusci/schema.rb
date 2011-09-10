require 'active_record'

class Job < ActiveRecord::Base
  serialize :payload
end