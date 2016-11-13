# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mud_server,
  ecto_repos: [MudServer.Repo]

# Configures the endpoint
config :mud_server, MudServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NQPXeQHU8S0/iuyecxhWiY0YY7jxv94GymmpYSdEn9OEfqM0TnRzyDSwmNZK5WZc",
  render_errors: [view: MudServer.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MudServer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
