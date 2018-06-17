defmodule SlackLex.Robot do
  use Hedwig.Robot, otp_app: :slack_lex
  
  require Logger

  alias SlackLex.Responders.NaturalLanguage
  alias SlackLex.Normalize
  alias Lex.Runtime.Conversations

  @moduledoc """
  Hedwig Robot instance.
  """
  def handle_connect(%{name: name} = state) do
    if :undefined == :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    {:reconnect, 5000, state}
  end

  @doc """
  Listens to incoming messages, and checks to see if the message is
  part of an active conversation.
  """
  def handle_in(%Hedwig.Message{} = msg, state) do
    NaturalLanguage.check_conversations(msg)
    {:dispatch, msg, state}
  end

  def handle_in(_, state) do
    {:noreply, state}
  end

  def broadcast(msg) do
    pid = :global.whereis_name("slackerton")
    Hedwig.Robot.send(pid, msg)
  end

  def thread(msg, response, options \\ []) 

  def thread(%{private:  %{"ts" => thread_ts }} = msg, response, options) do
    broadcast(Map.merge(msg, %{ 
      text: response,
      thread_ts: thread_ts,
      reply_broadcast: Keyword.get(options, :reply_broadcast, false)
    }))
  end

  def thread(msg, response, _options) do   
    broadcast(%{msg | text: response })
  end

end
