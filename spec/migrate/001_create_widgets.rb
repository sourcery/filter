Sequel.migration do
  up do
    create_table(:widgets) do
      primary_key :id
      Time :created_at
      Time :updated_at
      Date :produced_on
      Date :delivered_on
      String :sku
      Boolean :has_defect
      String :produced_by
      Integer :factory_id
    end
  end

  down do
    drop_table(:widgets)
  end
end
