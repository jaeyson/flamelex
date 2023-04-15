use Mix.Config

memex_env = "Paracelcus"

config :memelex,
  active?: false,
  environment: %{
    name: memex_env,
    memex_directory: "/Users/luke/memex/#{memex_env}",
    backups_directory: "/Users/luke/memex/backups/#{memex_env}"
  }

config :logger, level: :debug

config :logger, truncate: :infinity

config :logger,
       :console,
       format: "[$level] $message $metadata\n",
       metadata: []
