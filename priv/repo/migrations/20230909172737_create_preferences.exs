defmodule GraphqlApiRtr.Repo.Migrations.CreatePreferences do
  use Ecto.Migration

  def change do
    create table(:preferences) do
      add :likes_emails, :boolean, null: false
      add :likes_phone_calls, :boolean, null: false
      add :likes_faxes, :boolean, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:preferences, [:user_id])
  end
end
