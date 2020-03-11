defmodule ImageApi.Graphql.Plug do
  @behaviour Plug
  import Plug.Conn
  require Logger

  def init(_opts) do
    %{}
  end

  @doc """
  Parses, validates, resolves, and executes the given Graphql Document.
  """
  def call(conn, _opts) do
    case Map.get(conn.body_params, "query") do
      nil -> json_response(conn, 400, %{error: "no query supplied"})
      query -> query_request(conn, query)
    end
  end

  defp query_request(conn, query) do
    operation = Map.get(conn.body_params, "operation_name")
    variables = Map.get(conn.body_params, "variables")

    Logger.metadata(variables: variables)

    case ImageApi.Graphql.Query.run(query, op_name: operation, vars: variables) do
      {:ok, %{errors: [%{message: "invalid_token"} | _]} = e} ->
        json_response(conn, 401, %{error: e})

      {:ok, response} ->
        json_response(conn, 200, response)

      {:error, data} ->
        Logger.debug("ImageApi.Graphql.Plug error: #{inspect(data)}")
        Logger.debug("conn.body_params: #{inspect(conn.body_params)}\n#{query}")
        json_response(conn, 400, %{error: data})
    end
  end

  defp json_response(conn, status_code, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Poison.encode!(data, iodata: true, force: %{null: nil}))
  end

  #   def sentry_body_scrubber(%{body_params: body_params} = conn) when is_map(body_params) do
  #     Sentry.Plug.default_body_scrubber(conn)
  #     |> Map.merge(body_params)
  #   end

  #   def sentry_body_scrubber(conn), do: Sentry.Plug.default_body_scrubber(conn)
end
