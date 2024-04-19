defmodule GraphqlApiRtrWeb.AuthPlug do
  @moduledoc """
  Implements authentication for mutations via the Authorization header.
  """
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> secret_key] ->
        Absinthe.Plug.put_options(conn, context: %{secret_key: secret_key})
      _ ->
        conn
    end
  end
end
