require 'spec_helper'

describe "Octopusci" do
  it "should  say 'Hello RSpec!' when it receives the greet() message" do
    greeting = Octopusci.greet()
    greeting.should == "Hello RSpec!"
  end
end