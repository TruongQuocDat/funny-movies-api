class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :video, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :comments }

      t.timestamps
    end
  end
end
