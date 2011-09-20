module Octopusci
  module Helpers
    # Take the github payload hash and translate it to the Job model's attrs
    # so that we can easily use the github payload hash to update_attributes
    # on the Job mode.l
    def self.gh_payload_to_job_attrs(gh_pl)
      attrs = {}
            
      # ref
      attrs[:ref] = gh_pl["ref"]
      # compare
      attrs[:compare] = gh_pl["compare"]
      # repo_name
      attrs[:repo_name] = gh_pl["repository"]["name"]
      # repo_owner_name
      attrs[:repo_owner_name] = gh_pl["repository"]["owner"]["name"]
      # repo_owner_email
      attrs[:repo_owner_email] = gh_pl["repository"]["owner"]["email"]
      # repo_pushed_at
      attrs[:repo_pushed_at] = gh_pl["repository"]["pushed_at"]
      # repo_created_at
      attrs[:repo_created_at] = gh_pl["repository"]["created_at"]
      # repo_desc
      attrs[:repo_desc] = gh_pl["repository"]["description"]
      # repo_url
      attrs[:repo_url] = gh_pl["repository"]["url"]
      # before_commit
      attrs[:before_commit] = gh_pl["before"]
      # forced
      attrs[:forced] = gh_pl["forced"]
      # after_commit
      attrs[:after_commit] = gh_pl["after"]
      
      attrs[:payload] = gh_pl
      
      return attrs
    end
    
    # Get the information specified in the config about this project. If
    # project info can't be found for the given project_name and project_owner
    # this method returns nil. Otherwise, this project returns a hash of the
    # project info that it found in the config.
    def self.get_project_info(project_name, project_owner)
      Octopusci::CONFIG["projects"].each do |proj|
        if (proj['name'] == project_name) && (proj['owner'] == project_owner)
          return proj
        end
      end
      return nil
    end
    
    def self.decode(str)
      ::MultiJson.decode(str)
    end
    
    def self.encode(str)
      ::MultiJson.encode(str)
    end
  end
end