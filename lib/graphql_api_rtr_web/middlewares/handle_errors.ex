defmodule GraphqlApiRtrWeb.Middlewares.HandleErrors do
  @moduledoc false
  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware

  alias GraphqlApiRtr.ErrorUtils

  def call(resolution, _) do
    %{resolution | errors: Enum.flat_map(resolution.errors, &handle_error/1)}
  end

  defp handle_error(%ErrorMessage{} = error_message) do
    [ErrorMessage.to_jsonable_map(error_message)]
  end

  defp handle_error(%Ecto.Changeset{} = changeset) do
    Map.get(changeset.changes, :email)

    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.flat_map(fn {k, v} -> [k, v] end)
    |> handle_error(changeset.changes)
  end

  defp handle_error(error) do
    [
      ErrorUtils.internal_server_error("Internal server error", %{
        error: inspect(error)
      })
    ]
  end

  defp handle_error([k | [v]], changes) do
    user_input = Map.get(changes, k)

    case List.first(v) do
      "has already been taken" = message ->
        [ErrorUtils.conflict(message, %{argument: k, value: user_input})]

      message ->
        [ErrorUtils.bad_request(message, %{argument: k, value: user_input})]
    end
  end
end
