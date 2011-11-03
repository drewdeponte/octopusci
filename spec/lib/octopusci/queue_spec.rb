require 'spec_helper'

describe "Octopusci::Queueu" do
  describe "#enqueue" do
    it "should prepend the job to the job store if a matching job doesn't already exist" do
      proj_info = { :some => 'proj_info' }
      github_payload = { :some => 'github_payload' }
      @mock_redis.stub(:set)
      Resque.stub(:push)
      Octopusci::Helpers.stub(:gh_payload_to_job_attrs).and_return({})
      Octopusci::Queue.stub(:lismember).and_return(false)
      Octopusci::JobStore.should_receive(:prepend)
      Octopusci::Queue.enqueue('SomeTestJobKlass', 'repo-name', 'branch-name', github_payload, proj_info)
    end

    it "should store the github payload for the job if a matching job doesn't already exist" do
      r = mock('redis')
      proj_info = { :some => 'proj_info' }
      github_payload = { :some => 'github_payload' }
      Resque.stub(:push)
      Octopusci::JobStore.stub(:prepend)
      Octopusci::Queue.stub(:redis).and_return(r)
      Octopusci::Helpers.stub(:gh_payload_to_job_attrs).and_return({})
      Octopusci::Queue.stub(:lismember).and_return(false)
      r.should_receive(:set)
      Octopusci::Queue.enqueue('SomeTestJobKlass', 'repo-name', 'branch-name', github_payload, proj_info)
    end

    it "should enque the job in the octopusci Resque queue if a matching job doesn't already exist" do
      proj_info = { :some => 'proj_info' }
      github_payload = { :some => 'github_payload' }
      Octopusci::JobStore.stub(:prepend)
      @mock_redis.stub(:set)
      Octopusci::Helpers.stub(:gh_payload_to_job_attrs).and_return({})
      Octopusci::Queue.stub(:lismember).and_return(false)
      Resque.should_receive(:push)
      Octopusci::Queue.enqueue('SomeTestJobKlass', 'repo-name', 'branch-name', github_payload, proj_info)
    end

    it "should store the github payload if a matching job already exists" do
      proj_info = { :some => 'proj_info' }
      github_payload = { :some => 'github_payload' }
      r = mock('redis')
      Octopusci::JobStore.stub(:list_repo_branch).and_return([])
      Octopusci::Queue.stub(:lismember).and_return(true)
      Octopusci::Queue.stub(:redis).and_return(r)
      r.should_receive(:set).with(Octopusci::Queue.github_payload_key('repo-name', 'branch-name'), Resque::encode(github_payload))
      Octopusci::Queue.enqueue('SomeTestJobKlass', 'repo-name', 'branch-name', github_payload, proj_info)
    end

    it "should get the most recent job for the provided repo and branch combo if a matching job already exists" do
      proj_info = { :some => 'proj_info' }
      github_payload = { :some => 'github_payload' }
      @mock_redis.stub(:set)
      Octopusci::Queue.stub(:lismember).and_return(true)
      Octopusci::JobStore.should_receive(:list_repo_branch).with('repo-name', 'branch-name', 0, 1).and_return([])
      Octopusci::Queue.enqueue('SomeTestJobKlass', 'repo-name', 'branch-name', github_payload, proj_info)      
    end

    it "should update the job record with the new data from the github payload if a matching job already exists" do
      proj_info = { :some => 'proj_info' }
      github_payload = { :some => 'github_payload' }
      @mock_redis.stub(:set)
      Octopusci::Queue.stub(:lismember).and_return(true)
      Octopusci::Helpers.stub(:gh_payload_to_job_attrs).and_return(github_payload)
      Octopusci::JobStore.stub(:list_repo_branch).and_return([ { 'id' => 23 }.merge(github_payload) ])
      Octopusci::JobStore.should_receive(:set).with(23, { 'id' => 23 }.merge(github_payload))
      Octopusci::Queue.enqueue('SomeTestJobKlass', 'repo-name', 'branch-name', github_payload, proj_info)
    end

  end

  describe "#lismember" do
    it "should get the size of the provided queue" do
      @mock_redis.stub(:lrange)
      Resque.should_receive(:size).with("test:queue").and_return(0)
      Octopusci::Queue.lismember("test:queue", { :test => 'foo' })
    end

    it "should get the entire list of queued jobs" do
      Resque.stub(:size).and_return(2)
      Resque.should_receive(:peek).with("test:queue", 0, 2)
      Octopusci::Queue.lismember("test:queue", { :test => 'foo' })
    end

    it "should return true if the provided item exists in the queue identified by the provided queue name" do
      Resque.stub(:size).and_return(2)
      Resque.stub(:peek).and_return([ { :test => 'foo' }, { :hoopty => 'bar' } ])
      Octopusci::Queue.lismember("test:queue", { :hoopty => 'bar' }).should == true
    end

    it "should return false if the provided item does NOT exist in the queue identified by the given queue name" do
      Resque.stub(:size).and_return(2)
      Resque.stub(:peek).and_return([ { :test => 'foo' }, { :hoopty => 'bar' } ])
      Octopusci::Queue.lismember("test:queue", { :jack => 'crack' }).should == false
    end
  end

  describe "#github_payload" do
    it "should get the currently stored github_payload for a given repository and branch" do
      r = mock('redis')
      r.should_receive(:get).with(Octopusci::Queue.github_payload_key('my-repo', 'my-branch')).and_return({ :my => 'git', :hub => 'payload' })
      Resque.should_receive(:decode).with({ :my => 'git', :hub => 'payload' })
      Octopusci::Queue.stub(:redis).and_return(r)
      Octopusci::Queue.github_payload('my-repo', 'my-branch')
    end

    it "should return nil if there is no github_payload for a given repository and branch" do
      r = mock('redis')
      r.should_receive(:get).with(Octopusci::Queue.github_payload_key('my-repo', 'my-branch')).and_return(nil)
      Octopusci::Queue.stub(:redis).and_return(r)
      Octopusci::Queue.github_payload('my-repo', 'my-branch').should be_nil
    end
  end

  describe "#github_payload_key" do
    it "should return the key of where the github payload would be stored for a given repository and branch" do
      Octopusci::Queue.github_payload_key("jackie-repo", "brown-branch").should == "octopusci:github_payload:jackie-repo:brown-branch"
    end
  end

end
