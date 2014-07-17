class DeleteEventsWithoutUser < ActiveRecord::Migration
  class TempEvent < ActiveRecord::Base
    self.table_name = 'events'
  end

  def change
    # User deletion without all the proper dependent: :destroy options might have left
    # Events without a submitter (event_user association is deleted, but Event itslef is not)
    TempEvent.all.each do |event|
      unless event.submitter
        event.destroy
      end
    end
  end
end
