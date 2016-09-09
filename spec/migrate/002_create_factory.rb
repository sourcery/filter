Sequel.migration do
  up do
    create_table(:factories) do
      primary_key :id
      Time :created_at
      Time :updated_at
      String :name
    end
  end

  down do
    drop_table(:factories)
  end
end
