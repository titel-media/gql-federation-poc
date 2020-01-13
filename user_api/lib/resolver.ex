defmodule UserApi.Resolver do
  @users %{
    1 => %{
      "email" => "virgil@highsnobiety.com",
      "id" => 1,
    },
    2 => %{
      "email" => "kanye@highsnobiety.com",
      "id" => 2,
    },
    3 => %{
      "email" => "karl@highsnobiety.com",
      "id" => 3,
    },
  }

  def execute(%{type: :user}), do: handle_value("User")

  def execute(_ctx, _obj, "fetchUserById", %{"id" => id}) do
    get_user(id)
    |> handle_value
  end

  def execute(_ctx, _obj, "_service", _args) do
    schema = File.open!("priv/schema.gql", [:read, :utf8], &IO.read(&1, :all))
             |> String.split("\n")
             |> Enum.reject(fn line -> String.match?(line, ~r/#federation/) end)
             |> Enum.join("\n")
    %{data: %{"sdl" => schema}}
    |> handle_value
  end

  def execute(_ctx, %{data: data}, field, _args) do
    Map.get(data, field, :null)
    |> handle_value
  end

  def execute(_ctx, _obj, _field, _args) do
    handle_value(:null)
  end

  def input(_, value), do: handle_value(value)
  def output(_, value), do: handle_value(value)

  defp get_user(id) do
    case Map.get(@users, id) do
      nil -> :null
      p -> %{type: :user, data: p}
    end
  end

  defp handle_value(value) when is_list value do
    value = value
            |> Enum.map(fn v -> {:ok, v} end)
    {:ok, value}
  end

  defp handle_value(value), do: {:ok, value}
end
