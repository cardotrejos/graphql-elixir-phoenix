defmodule GraphqlApiRtr.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :text
      add :email, :text
    end

    create unique_index(:users, [:email])
  end
end
