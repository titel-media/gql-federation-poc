defmodule UserApi.Resolver do
  @users %{
    1 => %{
      "email" => "virgil@highsnobiety.com",
    },
    2 => %{
      "email" => "kanye@highsnobiety.com",
    },
    3 => %{
      "email" => "karl@highsnobiety.com",
    },
  }

  def execute(%{type: :user}), do: handle_value("User")

  def execute(_ctx, _obj, "fetchUserById", %{"id" => id}) do
    get_user(id)
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
