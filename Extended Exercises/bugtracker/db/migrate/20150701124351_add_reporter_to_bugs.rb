class AddReporterToBugs < ActiveRecord::Migration
  def change
    add_column :bugs, :reporter_id, :integer, index: true
  end
end
