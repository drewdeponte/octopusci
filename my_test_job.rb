class MyTestJob < Octopusci::Job
  def self.run(github_payload, stage)
    sleep 600
    # # Notify about the results
    Octopusci::Notifier.job_complete('cyphactor@gmail.com', 'aeuaoeua output', 'test status', github_payload).deliver
  end
end