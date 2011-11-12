require 'spec_helper'

describe "Octopusci::StageLocker" do
  describe "#load" do
    it "should clear the pool of stages" do
      @mock_redis.stub(:rpush)
      Octopusci::StageLocker.should_receive(:clear)
      Octopusci::StageLocker.load(['a', 'b', 'c'])
    end

    it "should push each of the provided stages into the stage pool" do
      Octopusci::StageLocker.stub(:clear)
      Octopusci::StageLocker.should_receive(:push).with('a')
      Octopusci::StageLocker.should_receive(:push).with('b')
      Octopusci::StageLocker.should_receive(:push).with('c')
      Octopusci::StageLocker.load(['a', 'b', 'c'])
    end
  end

  describe "#exists?" do
    it "should check if the redis key exists for the stage locker" do
      @mock_redis.should_receive(:exists).with('octopusci:stagelocker')    
      Octopusci::StageLocker.exists?
    end

    it "should return fales if the stage locker key does not exists in redis" do
      @mock_redis.stub(:exists).and_return(false)
      Octopusci::StageLocker.exists?.should == false
    end

    it "should return true if the stage locker key exists in redis" do
      @mock_redis.stub(:exists).and_return(true)
      Octopusci::StageLocker.exists?.should == true
    end
  end

  describe "#empty?" do
    it "should return true if exists? returns false" do
      Octopusci::StageLocker.stub(:exists?).and_return(false)
      Octopusci::StageLocker.empty?.should == true
    end

    it "should return false if exists? returns true" do
      Octopusci::StageLocker.stub(:exists?).and_return(true)
      Octopusci::StageLocker.empty?.should == false
    end
  end

  describe "#clear" do
    it "should clear all of the stages out of the stage locker" do
      r = mock('redis')
      Octopusci::StageLocker.stub(:redis).and_return(r)
      r.should_receive(:del).with('octopusci:stagelocker')
      Octopusci::StageLocker.clear
    end
  end

  describe "#pop" do
    it "should pop the left most stage out of the stage locker" do
      r = mock('redis')
      Octopusci::StageLocker.stub(:redis).and_return(r)
      r.should_receive(:lpop).with('octopusci:stagelocker')
      Octopusci::StageLocker.pop
    end
  end

  describe "#rem" do
    it "should remove the provided stage from the stage locker pool" do
      r = mock('redis')
      Octopusci::StageLocker.stub(:redis).and_return(r)
      r.should_receive(:lrem).with('octopusci:stagelocker', 1, 'a')
      Octopusci::StageLocker.rem('a')
    end
  end

  describe "#push" do
    it "should append the provided stage to the right of the stage locker" do
      r = mock('redis')
      Octopusci::StageLocker.stub(:redis).and_return(r)
      r.should_receive(:rpush).with('octopusci:stagelocker', 'a')
      Octopusci::StageLocker.push('a')
    end
  end

  describe "#stages" do
    it "should return the defined stages from the configuration" do
      Octopusci::Config.should_receive(:[]).with('stages').and_return(['a', 'b', 'c', 'd'])
      Octopusci::StageLocker.stages.should == ['a', 'b', 'c', 'd']
    end
  end

  describe "#pool" do
    it "should return the pool of stages" do
      r = stub('redis').as_null_object
      Octopusci::StageLocker.stub(:redis).and_return(r)
      r.stub(:peek).and_return(['stage_a', 'stage_b', 'stage_c'])
      Octopusci::StageLocker.pool.should == ['stage_a', 'stage_b', 'stage_c']
    end

    it "should get the size of the current pool stored in redis" do
      r = mock('redis').as_null_object
      Octopusci::StageLocker.stub(:redis).and_return(r)
      r.should_receive(:size).with('octopusci:stagelocker')
      Octopusci::StageLocker.pool
    end

    it "should get the current pool of stages stored in redis" do
      r = mock('redis')
      Octopusci::StageLocker.stub(:redis).and_return(r)
      r.stub(:size).and_return(4)
      r.should_receive(:peek).with('octopusci:stagelocker', 0, 4)
      Octopusci::StageLocker.pool
    end
  end

  describe "#redis" do
    it "should return redis instance provided by resqueue" do
      r = stub('redis')
      Resque.should_receive(:redis).and_return(r)
      Octopusci::StageLocker.redis.should == r
    end
  end
end