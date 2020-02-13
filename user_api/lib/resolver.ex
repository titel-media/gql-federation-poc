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
    4 => %{
      "email" => "donatella@highsnobiety.com",
      "id" => 4,
    },
    5 => %{
      "email" => "sylvia@highsnobiety.com",
      "id" => 5,
    },
    6 => %{
      "email" => "joan@highsnobiety.com",
      "id" => 6,
    },
  }

  @groups %{
    "groupA" => %{
      "name" => "groupA",
      "founder" => 1,
      "admin" => 2,
      "members" => [3,4]
    },
    "groupB" => %{
      "name" => "groupB",
      "founder" => 5,
      "admin" => 6,
      "members" => [1,2]
    },
    "groupC" => %{
      "name" => "groupC",
      "founder" => 3,
      "admin" => 1,
      "members" => [6,2,5,4]
    },
  }


  def execute(%{type: :user}), do: handle_value("User")

  def execute(_ctx, _obj, "fetchUserById", %{"id" => id}) do
    get_user(id)
    |> handle_value
  end

  def execute(_ctx, _obj, "fetchUserGroup", %{"name" => name}) do
    Map.get(@groups, name, :null)
    |> handle_value
  end

  def execute(_ctx, _obj, "fetchUsers", %{"ids" => ids}) do
    ids
    |> Enum.map(&get_user/1)
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

  def execute(%{object_type: "UserGroup"}, obj, field, _args)
  when field in ~w[founder admin] do
    Map.get(obj, field)
    |> get_user()
    |> handle_value
  end

  def execute(%{object_type: "UserGroup"}, obj, "members", _args) do
    Map.get(obj, "members")
    |> Enum.map(&get_user/1)
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

  defp get_user(id) when id <= 6 do
    case Map.get(@users, id) do
      nil -> :null
      p -> %{type: :user, data: p}
    end
  end

  defp get_user(id) do
    seed(id)
    %{
      type: :user,
      data: %{
        "id" => id,
        "email" => Faker.Internet.email(),
        "gallery" => 0..:rand.uniform(3) |> Enum.map(fn _ -> get_image(:rand.uniform(100)) end)
      }
    }
  end

  defp get_image(id) do
    seed(id)
    %{
      type: :image,
      data: %{
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
