require 'spec_helper'

describe "Octopusci::RepoStore" do

  describe "#add" do
    it "should add the repo info to redis" do
      Octopusci::RepoStore.redis.stub(:set)
      Octopusci::RepoStore.redis.should_receive(:sadd).with("octopusci:repolist", "octopusci:repolist:owner-repo")
      Octopusci::RepoStore.add("repo", "owner")
    end

    it "should add the repo key to redis" do
      info = {
        :owner => "owner",
        :name => "repo",
        :branch => 'master'
      }

      Octopusci::RepoStore.redis.should_receive(:set).with("octopusci:repolist:owner-repo", YAML.dump(info))
      Octopusci::RepoStore.redis.stub(:sadd)
      Octopusci::RepoStore.add("repo", "owner")
    end
  end

  describe "#get" do
    it "" do

    end
  end

end