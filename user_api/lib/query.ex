defmodule UserApi.Graphql.Query do
  require Logger

  def run!(statement, options \\ []) do
    operation_name = Keyword.get(options, :op_name) || :undefined
    vars = Keyword.get(options, :vars) || %{}

    {:ok, fun_env, ast} = prepare_statement(statement)
    params = :graphql.type_check_params(fun_env, operation_name, vars)
    context = %{params: params, operation_name: operation_name}

    :graphql.execute(context, ast)
  end

  def run(statement, options \\ []) do
    IO.puts "Received query: \n#{statement}"
    operation_name = Keyword.get(options, :op_name) || :undefined
    vars = Keyword.get(options, :vars) || %{}

    try do
      case prepare_statement(statement) do
        {:ok, fun_env, ast} ->
          params = :graphql.type_check_params(fun_env, operation_name, vars)
          context = %{params: params, operation_name: operation_name}

          response = :graphql.execute(context, ast)

          {:ok, response}

        error ->
          error
      end
    catch
      {:error, error_object} = error_tuple when is_map(error_object) ->
        error_tuple

      unhandled ->
        Logger.error("UserApi.Graphql.Query#run unhandled error: #{inspect(unhandled)}")
        throw(unhandled)
    end
  end

  def introspect!(schema_query) do
    %{data: %{"__schema" => data}} = run!("{ __schema { #{schema_query} } }")
    data
  end

  defp prepare_statement(statement) do
    res =
      with {:ok, ast} <- :graphql.parse(statement),
           {:ok, %{fun_env: fun_env, ast: ast}} <- :graphql.type_check(ast),
           :ok <- :graphql.validate(ast),
           :ok <- validate(ast) do
        {:ok, fun_env, ast}
      else
        {:error, {:parser_error, {_, :graphql_parser, messages}}} ->
          message = Enum.map(messages, &to_string/1) |> Enum.join("")
          {:error, %{key: "parser_error", message: message}}

        {:error, _error} = error_tuple ->
          error_tuple

        unhandled ->
          Logger.error(
            "UserApi.Graphql.Query#prepare_statement unhandled error: #{inspect(unhandled)}"
          )

          unhandled
      end
    res
  end

  defp validate(_), do: :ok
end
