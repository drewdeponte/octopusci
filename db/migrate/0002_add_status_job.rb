class AddStatusJob < ActiveRecord::Migration
  def self.up    
    add_column(:jobs, :status, :string)
    add_column(:jobs, :stage, :string)
    add_column(:jobs, :output_file_path, :string)
    remove_column(:jobs, :output)
    remove_column(:jobs, :successful)
    remove_column(:jobs, :running)
  end

  def self.down
    add_column(:jobs, :running, :boolean)
    add_column(:jobs, :successful, :boolean)
    add_column(:jobs, :output, :text)
    remove_column(:jobs, :output_file_path)
    remove_column(:jobs, :stage)
    remove_column(:jobs, :status)
  end
end
