class RemoveOutgoingSmsLanguageFromSettings < ActiveRecord::Migration
  def up
    remove_column :settings, :outgoing_sms_language
  end

  def down
    add_column :settings, :outgoing_sms_language, :string
  end
end
