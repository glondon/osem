class RolifyCreateTags < ActiveRecord::Migration
  def change
    create_table(:tags) do |t|
      t.string :name
      t.string :description
      t.references :resource, polymorphic: true

      t.timestamps
    end

    create_table(:users_tags, id: false) do |t|
      t.references :tag
      t.references :user
    end

    add_index(:tags, :name)
    add_index(:tags, [ :name, :resource_type, :resource_id ])
    add_index(:users_tags, [ :user_id, :tag_id ])
  end
end
