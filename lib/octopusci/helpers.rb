module Octopusci
  module Helpers
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
      
      return attrs
    end
  end
end