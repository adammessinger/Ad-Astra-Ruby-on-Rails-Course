class CreateBugs < ActiveRecord::Migration
  def change
    create_table :bugs do |t|
      t.string :title
      t.text :description
      t.string :tags
      t.boolean :closed, default: false

      t.timestamps null: false
    end
  end
end
