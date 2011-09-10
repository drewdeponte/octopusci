class Init < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :ref
      t.string :compare
      t.string :repo_name
      t.string :repo_owner_name
      t.string :repo_owner_email
      t.timestamp :repo_pushed_at
      t.timestamp :repo_created_at
      t.text :repo_desc
      t.string :repo_url
      t.string :before_commit
      t.boolean :forced
      t.string :after_commit
      t.boolean :running
      t.boolean :successful
      t.text :output
      t.timestamps
      t.timestamp :started_at
      t.timestamp :ended_at
      t.text :payload
    end
  end

  def self.down
    drop_table :jobs
  end
end
