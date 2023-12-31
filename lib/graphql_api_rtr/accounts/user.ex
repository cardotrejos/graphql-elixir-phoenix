defmodule GraphqlApiRtr.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias GraphqlApiRtr.Accounts.{Preference, User}

  schema "users" do
    field :email, :string
    field :name, :string

    has_one :preferences, Preference
  end

  @required_params [:name, :email]

  def create_changeset(params) do
    changeset(%User{}, params)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint(:email)
    |> cast_assoc(:preferences, required: true)
  end

  def join_preferences(query \\ User) do
    join(query, :inner, [u], p in assoc(u, :preferences), as: :preferences)
  end

  def by_preferences(query \\ join_preferences(), {filter, boolean}) do
    where(query, [preferences: p], field(p, ^filter) == ^boolean)
  end

  def by_name(query \\ User, name) do
    where(query, [u], u.name == ^name)
  end
end
