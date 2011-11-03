require 'spec_helper'

describe Octopusci::Notifier do
  before(:each) do
      Octopusci::Notifier.delivery_method = :test
      Octopusci::Notifier.perform_deliveries = true
      Octopusci::Notifier.deliveries = []
  end
  
  describe "#job_complete" do
  end
end