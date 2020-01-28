defmodule ProductApi.Resolver do
  @products %{
    1 => %{
      "name" => "Red Belt",
      "brand" => "Gucci",
      "priceUSD" => 1000
    },
    2 => %{
      "name" => "Blue Hat",
      "brand" => "Balenciaga",
      "priceUSD" => 2000
    },
    3 => %{
      "name" => "Green Scarf",
      "brand" => "Vetements",
      "priceUSD" => 3000
    },
  }

  @user_products %{
    1 => [1,2,3],
    2 => [1],
    3 => [],
    4 => [2,3],
    5 => [2],
    6 => [1,3],
  }

  def execute(%{"__typename" => type}), do: handle_value(type)
  def execute(%{type: :product}), do: handle_value("Product")

  def execute(_ctx, _obj, "product", %{"id" => id}) do
    get_product(id)
    |> handle_value
  end

  def execute(_ctx, %{"id" => id}, "products", args) do
    IO.puts("Fetching products for user: #{id}")
    Map.get(@user_products, String.to_integer(id), [])
    |> Enum.map(&get_product/1)
    |> handle_value
  end

  def execute(_ctx, _obj, "_entities", %{"representations" => r}) do
    #    IO.inspect r
    handle_value(r)
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

  defp get_product(id) when is_binary id do
    id
    |> String.to_integer
    |> get_product
  end

  defp get_product(id) do
    case Map.get(@products, id) do
      nil -> :null
      p -> %{type: :product, data: p}
    end
  end

  defp handle_value(value) when is_list value do
    value = value
            |> Enum.map(fn v -> {:ok, v} end)
    {:ok, value}
  end

  defp handle_value(value), do: {:ok, value}
end
