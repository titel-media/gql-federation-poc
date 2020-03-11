use Mix.Config

config :image_api, ImageApi.Schema,
  filename: "schema.gql",
  mapping: %{
    unions: %{ default: ImageApi.Resolver },
    scalars: %{ default: ImageApi.Resolver },
    #objects: %{ default: ImageApi.Resolver },
    interfaces: %{ default: ImageApi.Resolver },
    objects: %{
      default: ImageApi.Resolver,
      "Query": ImageApi.Resolver,
      "Mutation": ImageApi.Resolver,
    }
  }

config :image_api, 
  port: 3030

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
#import_config "#{Mix.env()}.exs"
