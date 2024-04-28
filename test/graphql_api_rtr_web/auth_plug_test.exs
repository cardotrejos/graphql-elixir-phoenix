defmodule GraphqlApiRtrWeb.AuthPlugTest do
  use GraphqlApiRtrWeb.ConnCase
  alias GraphqlApiRtrWeb.AuthPlug

  test "puts secret key provided through the HTTP authorization header as context in the Absinthe.Plug under the :absinthe key", %{conn: conn} do
    conn = Plug.Conn.put_req_header(conn, "authorization", "Bearer Secret")
    assert %Plug.Conn{private: %{absinthe: %{context: %{secret_key: "Secret"}}}} = AuthPlug.call(conn, %{})
  end

  test "returns unchanged conn when no authorization header is provided", %{conn: conn} do
    assert conn === AuthPlug.call(conn, %{})
  end
end
