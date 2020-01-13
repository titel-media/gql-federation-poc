use Mix.Config

config :user_api, UserApi.Schema,
  filename: "schema.gql",
  mapping: %{
    unions: %{ default: UserApi.Resolver },
    scalars: %{ default: UserApi.Resolver },
    #objects: %{ default: UserApi.Resolver },
    interfaces: %{ default: UserApi.Resolver },
    objects: %{
      default: UserApi.Resolver,
      "Query": UserApi.Resolver,
      "Mutation": UserApi.Resolver,
    }
  }

config :user_api, 
  port: 3020

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
#import_config "#{Mix.env()}.exs"
