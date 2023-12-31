defmodule GraphqlApiRtr.ErrorUtils do
  @moduledoc """
  Standardizes errors returned from
  the GraphQL API
  """

  def conflict(message, details) do
    %{
      code: :conflict,
      message: message,
      details: details
    }
  end

  def bad_request(message, details) do
    %{
      code: :bad_request,
      message: message,
      details: details
    }
  end

  def internal_server_error(message, details) do
    %{
      code: :internal_server_error,
      message: message,
      details: details
    }
  end
end
