defmodule ProductApi.Resolver do
  @products %{
    1 => %{
      "name" => "Red Belt",
      "brand" => "Gucci",
      "priceUSD" => 1000,
    },
    2 => %{
      "name" => "Blue Hat",
      "brand" => "Balenciaga",
      "priceUSD" => 2000,
    },
    3 => %{
      "name" => "Green Scarf",
      "brand" => "Vetements",
      "priceUSD" => 3000,
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

  def execute(_ctx, %{"products" => p}, "products", _args) do
    handle_value(p)
  end


  def execute(_ctx, %{"id" => id}, "products", _args) do
    IO.puts("Fetching products for user: #{id}")
    product_ids_for_user(id)
    |> Enum.map(&get_product/1)
    |> handle_value
  end

  def execute(_ctx, _obj, "_entities", %{"representations" => r}) do
    # Here we would do any lookups of the given entities, based on the
    # defined key fields present in the objects
    # in this case we have the User with an id, and no additonal
    # hydration is required
    IO.inspect r
    # Given we have a list of users here, we can bulk fetch their
    r = add_products_to_users(r)
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

  def execute(%{object_type: "Product"}, %{id: id}, "image", _args) do
    seed(id)
    case :rand.uniform(100) do
      n when n < 10 -> :null
      _ -> get_image(id)
    end
    |> handle_value()
  end

  def execute(%{object_type: "Product"}, %{id: id}, "images", _args) do
    seed(id)
    1..:rand.uniform(10)
    |> Enum.map(fn _ ->
      :rand.uniform(100)
      |> get_image()
    end)
    |> handle_value()
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
      nil -> random_product(id)
      p -> %{id: id, type: :product, data: p}
    end
  end

  defp random_product(id) do
    seed(id)
    %{
      id: id,
      type: :product,
      data: %{
        "name" => Faker.Commerce.product_name(),
        "brand" => Faker.Company.name(),
        "priceUSD" => :rand.uniform(80) * 125,
      }
    }
  end

  defp add_products_to_users(users) do
    ids = Enum.map(users, fn %{"id" => id} -> id end)
    IO.puts("Bulk fetching products for users: #{Enum.join(ids, ",")}")
    users
    |> Enum.map(fn %{"id" => id} = user ->
      products_for_user =
        product_ids_for_user(id)
        |> Enum.map(&get_product/1)
      Map.put(user, "products", products_for_user)
    end)
  end

  defp product_ids_for_user(id) when is_binary(id), do: String.to_integer(id) |> product_ids_for_user()

  defp product_ids_for_user(id) do
    seed(id)
    case Map.get(@user_products, id) do
      nil ->
        n_products = Integer.floor_div(:rand.uniform(99), 25) + 1
        (1..n_products) |> Enum.map(fn _ -> :rand.uniform(20) end)
      p -> p
    end
  end

  defp get_image(id) do
    seed(id)
    %{
      type: :image,
      data: %{
        "id" => id,
        "url" => Faker.Internet.image_url(),
        "altText" => Faker.Lorem.paragraph(1),
      }
    }
  end

  defp seed(seed) do
    :random.seed(seed)
    :rand.seed(:exrop, {seed,1,1})
  end

  defp handle_value(value) when is_list value do
    value = value
            |> Enum.map(fn v -> {:ok, v} end)
    {:ok, value}
  end

  defp handle_value(value), do: {:ok, value}
end
