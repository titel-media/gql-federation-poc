defmodule HTTP do
  use Plug.Router

  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded, :multipart],
    ignored_routes: ["/_ping"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  get "/_ping" do
    send_resp(conn, 200, "ok")
  end

  forward("/", to: ImageApi.Graphql.Plug)

  def child_spec(_opts) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      plug: __MODULE__,
      options: [compress: true, port: Application.get_env(:image_api, :port)]
    )
  end

  def log_if(_), do: true
end
