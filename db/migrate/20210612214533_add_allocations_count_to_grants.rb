class AddAllocationsCountToGrants < ActiveRecord::Migration[6.1]
  def change
    add_column :grants, :allocations_count, :integer
  end
end
