require 'spec_helper'

describe "Octopusci" do
  it "should  say 'Hello RSpec!' when it receives the greet() message" do
    greeting = Octopusci.greet()
    greeting.should == "Hello RSpec!"
  end
  
  it "should load the test page" do
    get '/test'
    puts last_response.inspect
    last_response.should be_ok
  end
end