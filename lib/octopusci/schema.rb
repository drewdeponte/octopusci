require 'active_record'

class Job < ActiveRecord::Base
  serialize :payload
  
  def branch_name
    self.ref.gsub(/refs\/heads\//, '')
  end
end