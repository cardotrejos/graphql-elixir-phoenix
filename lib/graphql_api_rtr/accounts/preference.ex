defmodule GraphqlApiRtr.Accounts.Preference do
  use Ecto.Schema
  import Ecto.Changeset
  alias GraphqlApiRtr.Accounts.User

  schema "preferences" do
    field :likes_emails, :boolean, default: false
    field :likes_faxes, :boolean, default: false
    field :likes_phone_calls, :boolean, default: false

    belongs_to :user, User
  end

  @required_params [:likes_emails, :likes_faxes, :likes_phone_calls]

  def required_params, do: @required_params

  def changeset(preference, attrs) do
    preference
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(:user_id)
  end
end
