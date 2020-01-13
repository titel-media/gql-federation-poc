defmodule UserApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :user_api,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {UserApi, [env: Mix.env()]},
      start_phases: [
        {:load_graphql_schema, []}
      ],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # this is the graphql library providing query parsing and object resolvers
      # {:graphqx, path: "./upstream/graphqx"},
      {:graphqx, git: "git@github.com:titel-media/graphqx.git", branch: "master"},
      # dependency for graphqx that is not being fetched otherwise
      {:graphql, git: "https://github.com/Overbryd/graphql-erlang.git", branch: "develop"},
      {:plug_cowboy, "~> 2.0"},
      # cowboy is our web server layer
      {:cowboy, "~> 2.5"},
    ]
  end
end
