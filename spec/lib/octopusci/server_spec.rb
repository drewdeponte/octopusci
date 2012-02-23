require 'spec_helper'

describe "Octopusci::Server" do
  before(:all) do
    @github_test_payload = '{"base_ref":null,"ref":"refs/heads/master","commits":[{"message":"shit son","removed":[],"modified":["test.txt"],"added":[],"author":{"username":"cyphactor","email":"cyphactor@gmail.com","name":"Andrew De Ponte"},"distinct":true,"timestamp":"2011-09-06T22:01:12-07:00","id":"d7f49d93ee8fbce466c23c4e8a6bcbe8cab88a57","url":"https://github.com/cyphactor/temp_pusci_test/commit/d7f49d93ee8fbce466c23c4e8a6bcbe8cab88a57"},{"message":"again broham","removed":[],"modified":["test.txt"],"added":[],"author":{"username":"cyphactor","email":"cyphactor@gmail.com","name":"Andrew De Ponte"},"distinct":true,"timestamp":"2011-09-06T23:01:07-07:00","id":"60ae8e76469931b3e879d594099b0f4ac6f5cb99","url":"https://github.com/cyphactor/temp_pusci_test/commit/60ae8e76469931b3e879d594099b0f4ac6f5cb99"},{"message":"again broham","removed":[],"modified":["test.txt"],"added":[],"author":{"username":"cyphactor","email":"cyphactor@gmail.com","name":"Andrew De Ponte"},"distinct":true,"timestamp":"2011-09-06T23:03:16-07:00","id":"dd6e7913cc12937db88e469684e8698f8eee8c14","url":"https://github.com/cyphactor/temp_pusci_test/commit/dd6e7913cc12937db88e469684e8698f8eee8c14"}],"created":false,"before":"e5a1385fd8654c46d2b52d90c1ba31c865493602","repository":{"created_at":"2011/09/02 12:40:14 -0700","open_issues":0,"forks":1,"description":"Temp repo for testing pusci as I dev it","has_wiki":true,"fork":false,"watchers":1,"has_downloads":true,"homepage":"","has_issues":true,"private":false,"size":116,"owner":{"email":"cyphactor@gmail.com","name":"cyphactor"},"name":"temp_pusci_test","pushed_at":"2011/09/06 23:03:21 -0700","url":"https://github.com/cyphactor/temp_pusci_test"},"pusher":{"name":"none"},"forced":false,"after":"dd6e7913cc12937db88e469684e8698f8eee8c14","deleted":false,"compare":"https://github.com/cyphactor/temp_pusci_test/compare/e5a1385...dd6e791"}'
    @github_real_payload = '{"created":false,"ref":"refs/heads/master","compare":"https://github.com/cyphactor/temp_pusci_test/compare/dd6e791...23485e0","repository":{"owner":{"email":"cyphactor@gmail.com","name":"cyphactor"},"has_downloads":true,"pushed_at":"2011/09/09 08:27:00 -0700","has_wiki":true,"url":"https://github.com/cyphactor/temp_pusci_test","size":116,"fork":false,"watchers":1,"has_issues":true,"name":"temp_pusci_test","created_at":"2011/09/02 12:40:14 -0700","open_issues":0,"private":false,"homepage":"","description":"Temp repo for testing pusci as I dev it","forks":1},"before":"dd6e7913cc12937db88e469684e8698f8eee8c14","forced":false,"after":"23485e00f329d7db02bc7b8c51ef11025046bd95","commits":[{"added":[],"removed":[],"timestamp":"2011-09-09T08:26:49-07:00","message":"Woot woot a nother push","modified":["test.txt"],"url":"https://github.com/cyphactor/temp_pusci_test/commit/23485e00f329d7db02bc7b8c51ef11025046bd95","distinct":true,"id":"23485e00f329d7db02bc7b8c51ef11025046bd95","author":{"username":"cyphactor","email":"cyphactor@gmail.com","name":"Andrew De Ponte"}}],"pusher":{"email":"cyphactor@gmail.com","name":"cyphactor"},"deleted":false,"base_ref":null}'
  end
    
  describe "POST /github-build" do
    it "should parse the github payload using JSON" do
      parsed_github_payload = Octopusci::Helpers.decode(@github_test_payload)
      Octopusci::Helpers.should_receive(:decode).with(@github_test_payload).and_return(parsed_github_payload)
      Octopusci::Queue.stub(:enqueue) # stub this out so test doesn't actually enqueue a job
      post '/github-build', :payload => @github_test_payload
    end
    
    it "should return 404 if the request is for a non-managed project" do
      Octopusci::Helpers.should_receive(:get_project_info).with("temp_pusci_test", "cyphactor").and_return(nil)
      post '/github-build', :payload => @github_test_payload
      last_response.status.should == 404
    end
    
    it "should enqueue a job if the request is for a managed project" do
      test_proj_info = { 'name' => 'temp_pusc_test', 'owner' => 'cyphactor', 'job_klass' => 'MyTestJob' }
      Octopusci::Helpers.stub(:get_project_info).and_return(test_proj_info)
      Octopusci::RepoStore.stub(:add)
      Octopusci::Queue.should_receive(:enqueue).with(test_proj_info['job_klass'], "temp_pusci_test", "master", Octopusci::Helpers.decode(@github_test_payload), test_proj_info)
      post '/github-build', :payload => @github_test_payload
      last_response.status.should == 200
    end
  end

  describe "GET /" do
    it "should get the 20 most recently queued jobs" do
      Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
      Octopusci::JobStore.should_receive(:list).with(0, 20).and_return([])
      get '/'
      last_response.status.should == 200
    end
  end

  describe "GET /:owner/:repo_name/:branch_name/jobs" do
    it "should get the 20 most recently queue jobs for the provided repo_name, branch_name combo" do
      Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
      Octopusci::JobStore.should_receive(:list_repo_branch).with('baz-owner', 'foo-repo', 'bar-branch', 0, 20).and_return([])
      get '/baz-owner/foo-repo/bar-branch/jobs'
      last_response.status.should == 200
    end
  end

  describe "job specific" do

    before(:each) do
      @job_id = "234"
      @job = { 'id' => @job_id, 'status' => 'pending',
          'payload' => { 'repository' => { 'url' => 'http://somewhere.com' }, 'pusher' => { 'email' => 'bob@example.com' } },
          'repo_name' => 'bar', 'branch_name' => 'foo', 'created_at' => Time.now, 'started_at' => Time.now,
          'ended_at' => Time.now + 1000, 'compare' => 'http://compareurl.com', 'stage' => 'test_a', 'ref' => 'refs/heads/foo' }
    end

    describe "GET /jobs/:job_id" do
      it "should get the job specified by :job_id" do
        Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
        Octopusci::JobStore.should_receive(:get).with(@job_id).and_return(@job)
        get "/jobs/#{@job_id}"
        last_response.status.should == 200
      end
    end

    describe "GET /jobs/:job_id/output" do
      it "should get the job specified by :job_id" do
        Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
        Octopusci::JobStore.should_receive(:get).with(@job_id).and_return(@job)
        get "/jobs/#{@job_id}/output"
        last_response.status.should == 200
      end
    end

    describe "GET /jobs/:job_id/silent_output" do
      it "should get the job specified by :job_id" do
        Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
        Octopusci::JobStore.should_receive(:get).with(@job_id).and_return(@job)
        get "/jobs/#{@job_id}/silent_output"
        last_response.status.should == 200
      end

      it "should return the log output for the job identified by :job_id" do
        Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
        Octopusci::JobStore.stub(:get).with(@job_id).and_return(@job)
        Octopusci::IO.any_instance.stub(:read_all_log).and_return("log output")
        get "/jobs/#{@job_id}/silent_output"
        last_response.body.should == "log output"
      end
    end

    describe "GET /jobs/:job_id/status" do
      it "should get the job specified by :job_id" do
        Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
        Octopusci::JobStore.should_receive(:get).with(@job_id).and_return(@job)
        get "/jobs/#{@job_id}/status"
        last_response.status.should == 200
      end

      it "should return the status of the current status of the job identified by :job_id" do
        Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
        Octopusci::JobStore.stub(:get).with(@job_id).and_return(@job)
        get "/jobs/#{@job_id}/status"
        last_response.body.should == "pending"
      end
    end

    describe "GET /jobs/:job_id/ajax_summary" do
      it "should get the job specified by :job_id" do
        Octopusci::Server.any_instance.stub(:authorized?).and_return(true)
        Octopusci::JobStore.should_receive(:get).with(@job_id).and_return(@job)
        get "/jobs/#{@job_id}/ajax_summary"
        last_response.status.should == 200
      end
    end
    
  end
end