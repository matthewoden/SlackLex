defmodule SlackerLex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do

    slackerton_config = %{
      aws_access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
      http_adapter: Lex.Http.Hackney,
      json_parser: Lex.Json.Jason,
    }


    children = [
      {Lex, slackerton_config},
      {SlackLex.Robot, []},
    ]

    opts = [strategy: :one_for_one, name: SlackLex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
