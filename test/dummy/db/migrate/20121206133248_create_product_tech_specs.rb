class CreateProductTechSpecs < ActiveRecord::Migration
  def change
    create_table :product_tech_specs do |t|
      t.references :product, :null => false
      t.string :entry_key, :null => false
      t.text :value, :null => false
      t.integer :value_type, :null => false
      t.boolean :symbol_key, :null => false, :default => true

      t.timestamps
    end

    add_index :product_tech_specs, [:product_id, :entry_key]
  end
end
