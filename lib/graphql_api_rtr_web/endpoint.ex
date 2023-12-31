defmodule GraphqlApiRtrWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :graphql_api_rtr
  use Absinthe.Phoenix.Endpoint

  socket "/socket", GraphqlApiRtrWeb.UserSocket,
    websocket: true,
    longpoll: false

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug GraphqlApiRtrWeb.Router
end
