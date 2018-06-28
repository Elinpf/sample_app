class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
		add_index :relationships, :follower_id
		add_index :relationships, :followed_id
		# unique: 不允许出现自己关注自己
		# :follower_id 和 :followed_id 是一对pair
		add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
