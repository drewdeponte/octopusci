require 'spec_helper'

describe Octopusci::Notifier do
  before(:each) do
      Octopusci::Notifier.delivery_method = :test
      Octopusci::Notifier.perform_deliveries = true
      Octopusci::Notifier.deliveries = []
  end
  
  describe "#job_complete" do
    it "should send a multi-part email with the text version containing job status" do
      mail = Octopusci::Notifier.job_complete('joe@example.com', 'my output', 'my status').deliver()
      
      Octopusci::Notifier.deliveries.size.should == 1
      mail.parts[0].body.should =~ /my output/
    end
    
    it "should send a multi-part email with the html version containing job status" do
      mail = Octopusci::Notifier.job_complete('joe@example.com', 'my output', 'my status').deliver()
      
      Octopusci::Notifier.deliveries.size.should == 1
      mail.parts[1].body.should =~ /my output/      
    end
  end
end