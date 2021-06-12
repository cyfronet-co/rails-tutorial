class CreateAllocations < ActiveRecord::Migration[6.1]
  def change
    create_table :allocations do |t|
      t.string :host
      t.integer :vcpu
      t.references :grant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
