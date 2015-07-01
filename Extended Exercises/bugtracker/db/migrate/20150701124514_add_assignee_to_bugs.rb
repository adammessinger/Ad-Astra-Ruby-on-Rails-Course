class AddAssigneeToBugs < ActiveRecord::Migration
  def change
    add_column :bugs, :assignee_id, :integer, index: true
  end
end
