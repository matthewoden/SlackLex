defmodule SlackLex.Responders.NaturalLanguage do
  require Logger

  alias Hedwig.{Responder}
  alias SlackLex.Normalize
  alias SlackLex.Responders.NaturalLanguage.Lex
  alias Lex.Runtime.{Response, Request, Conversations}

  use Responder

  @usage "hey slackbot <ask for a joke> - Returns a joke."

  hear ~r/^hey slackbot/i, msg do
    input = 
      msg.text
      |> String.replace("hey slackbot", "")
      |> String.trim()
      |> Normalize.decode_characters()
      
    user = user(msg)
    context = context(msg)

    Lex.converse(input, user, context, respond(), fulfill()) 

    :ok
  end

  @doc """
  Check a message to see if we should reply. 
  """

  def check_conversations(msg) do
    user = user(msg)
    context = context(msg)
    
    if Conversations.in_conversation?(user, context) do
      Logger.debug("IN CONVERSATION > #{user} #{context}")

      input = 
        msg.text
        |> String.trim()
        |> Normalize.decode_characters()

      Lex.converse(input, user, context, respond(msg), fulfill(msg)) 
    end
  end
  
  # Sets the context for the conversation.
  #
  # if we're in a thread, use the current thread timestamp to keep the conversation going.
  # if it's a message, grab the timestamp so we can reply as a thread.
  # otherwise, set a generic context.

  defp context(%{ private: %{ "thread_ts" => context }}), do: context
  defp context(%{ private: %{ "ts" => context }}), do: context
  defp context(_), do: "default"

  # grab the user off the message, without all that extra slack data.
  defp user(msg), do: Normalize.user_id(msg.user)


  # callbacks
  # ######
  # These could be a proper interface, but since we have one implementation, we'll use callbacks.

  # handler for how the bot should respond. We could look at the message and reply 
  # based on context. For now, we'll just thread all replies.
  # 
  # We create a closure over the message, so our Lex methods don't need to care 
  # about the initial message.
  defp respond(msg) do
    fn (response) -> SlackLex.Robot.thread(msg, response) end
  end

  # handler for how the bot should respond when the intention is understood.
  # 
  # Like above, we return anonymous function.
  defp fulfill(msg) do
    fn (intent, slots) ->
      case intent do
        "ExampleIntent" ->
          # with this example, we reply in the thread, but share the information
          # with the whole channel.
          SlackLex.Robot.thread(msg, "Example Reply", [reply_broadcast: true])

        _ ->
          SlackLex.Robot.thread(msg, "I don't know what to do!", [reply_broadcast: false])
      end
    end
  end
 
end       