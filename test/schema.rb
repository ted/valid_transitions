require 'active_record'
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :cars, :force => true do |t|
    t.string :state
    t.string :doors
    t.string :brand
    t.string :condition, default: 'working'
    t.timestamps
  end

end
