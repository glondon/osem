class AddContextToTags < ActiveRecord::Migration
  def change
    add_column :tags, :context, :text
  end
end
