# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :slackerlex, SlackLex.Robot,
  name: "slacklex",
  aka: "/",
  token: System.get_env("YOUR_SLACK_TOKEN"),
  rooms: [],
  log_level: :debug,
  responders: [
    {SlackLex.Responders.NaturalLanguage, [] }
  ]

config :logger,
  backends: [:console],
  level: :debug,
  compile_time_purge_level: :debug

config :slackerton, Slackerton.Robot,
  adapter: Hedwig.Adapters.Slack