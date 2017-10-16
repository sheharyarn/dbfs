# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

zero_key = File.read!("priv/keys/zero.pvt")


# General application configuration
config :dbfs,
  namespace: DBFS,
  ecto_repos: [DBFS.Repo]


# Crypto Configs
config :dbfs,
  zero_cookie: "DBFS",
  zero_key: File.read!("priv/keys/zero.pvt")


# Configures the endpoint
config :dbfs, DBFS.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CAursn/+KNVbfFeXMCT1hJrsmB0WS9jmPgKn63yMRYaEHq6ljwS2Jc3oaqsDZdrg",
  render_errors: [view: DBFS.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DBFS.PubSub,
           adapter: Phoenix.PubSub.PG2]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
