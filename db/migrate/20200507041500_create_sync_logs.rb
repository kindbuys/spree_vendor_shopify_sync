class CreateSyncLogs < ActiveRecord::Migration
  def change
    create_table :sync_logs do |t|
    	t.references :syncable, polymorphic: true
    	t.hstore :options
    	t.string :action
    	t.string :provider
    	t.timestamps
    end
  end
end
