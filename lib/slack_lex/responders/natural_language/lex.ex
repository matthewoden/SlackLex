defmodule SlackLex.Responders.NaturalLanguage.Lex do
  alias Lex.Runtime.Response


  def converse(input, user, context, reply, fullfill) do
    user_input(input, user, context)
    |> aws_response(reply, fullfill)
  end

  defp user_input(input, user, context) do
    Request.new()
    |> Request.set_bot_name("SlackLex")
    |> Request.set_bot_alias("dev")
    |> Request.set_context(context)
    |> Request.set_user_id(user)
    |> Request.set_text_input(input)
    |> Request.send()
  end
  
  defp aws_response(response, reply, fulfill) do
    case response do
      %Response.ElicitIntent{ message: message } -> 
        reply.(message)

      %Response.ConfirmIntent{ message: message } -> 
        reply.(message)

      %Response.ElicitSlot{ message: message } -> 
        reply.(message)

      %Response.ReadyForFulfillment{ intent_name: intent, slots: slots } -> 
        fulfill.(intent, slots)
    end
  end

end