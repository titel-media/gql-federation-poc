use Mix.Config

config :product_api, ProductApi.Schema,
  filename: "schema.gql",
  mapping: %{
    unions: %{ default: ProductApi.Resolver },
    scalars: %{ default: ProductApi.Resolver },
    #objects: %{ default: ProductApi.Resolver },
    interfaces: %{ default: ProductApi.Resolver },
    objects: %{
      default: ProductApi.Resolver,
      "Query": ProductApi.Resolver,
      "Mutation": ProductApi.Resolver,
    }
  }

config :product_api, 
  port: 3010

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
#import_config "#{Mix.env()}.exs"
