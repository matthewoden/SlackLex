defmodule SlackLexTest do
  use ExUnit.Case
  doctest SlackLex

  test "greets the world" do
    assert SlackLex.hello() == :world
  end
end
