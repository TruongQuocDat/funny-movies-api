# frozen_string_literal: true

class CreateEmotions < ActiveRecord::Migration[7.0]
  def change
    create_table :emotions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :emotionable_type, null: false
      t.bigint :emotionable_id, null: false
      t.string :kind, null: false

      t.timestamps
    end

    add_index :emotions, [:emotionable_type, :emotionable_id]
    add_index :emotions, [:user_id, :emotionable_type, :emotionable_id], unique: true, name: 'index_emotions_on_user_and_emotionable'
  end
end