class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :author_id
      t.integer :bug_id
      t.text :body

      t.timestamps null: false
    end
  end
end
