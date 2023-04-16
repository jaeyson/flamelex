import Config

config :flamelex,
  :key_mapping, Flamelex.KeyMappings.VimClone

memex_env = "Paracelcus"
memex_base_dir = "/Users/luke/memex" # this directory is where we store all Memex related data, for all environments

config :memelex,
  active?: false,
  environment: %{
    name: memex_env,
    memex_directory: "#{memex_base_dir}/#{memex_env}",
    backups_directory: "#{memex_base_dir}/backups/#{memex_env}"
  }

config :event_bus,
  # https://github.com/otobus/event_bus/wiki/Creating-(Registering)-Topics
  topics: [
    :general,         # This topic is used by Fluxus, it's for updating internal Fluxus state by firing actions #TODO rename this to `actions`?
    :user_input,      # This topic is for transmitting user input throughout the application, to the appropriate listeners, which will likely in turn fire off Fluxus actions as a result of that input
    :memelex,         # This topic handles all messages related to Memelex
    :interrupts       # The idea behind this topic is to handle external interrupts, e.g. perhaps we will add email as a feature to Flamelex, well getting an email might go on the interrupts channel
  ]

config :elixir,
  # https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database
  :time_zone_database, Tzdata.TimeZoneDatabase

config :scenic,
  :assets, module: Flamelex.App.Scenic.Assets

config :logger,
  level: :debug,
  truncate: :infinity,
  console:
    [format: "$time $metadata[$level] $levelpad$message\n"] # remove superfluous newline characters from logs, see: https://elixirforum.com/t/why-does-logger-output-in-iex-have-to-have-an-empty-line-after-every-line-logged/21822/4
