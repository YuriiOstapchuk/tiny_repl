defmodule TinyReplTest do
  use ExUnit.Case

  alias TinyRepl.{Lexer, Token, Syntaxer}

  test "lexeme parser simple expression" do
    assert Lexer.get_lexemes("1 + 2") == {:ok, [Token.number(1.0),
                                                Token.plus,
                                                Token.number(2.0)]}
  end

  test "lexeme parser complex expression" do
    assert Lexer.get_lexemes("20 * (3 - x)") == {:ok, [Token.number(20.0),
                                                       Token.mul,
                                                       Token.opening_parenthesis,
                                                       Token.number(3.0),
                                                       Token.minus,
                                                       Token.variable("x"),
                                                       Token.closing_parenthesis]}
  end

  test "lexeme parser unknown" do
    assert Lexer.get_lexemes("1 # 4") == {:error, [{:unknown, "#"}]}
  end

  test "syntax checker" do
    {:ok, lexemes} = Lexer.get_lexemes "20 * (3 - x)"
    assert Syntaxer.valid_syntax?(lexemes)
  end

  test "syntax checker error finding" do
    {:ok, lexemes} = Lexer.get_lexemes "20 (3 - x"
    assert Syntaxer.valid_syntax?(lexemes) == {:error, "Unexpected token opening_parenthesis"}
  end

  test "syntax checker error eof" do
    {:ok, lexemes} = Lexer.get_lexemes "20 * (3 - x"
    assert Syntaxer.valid_syntax?(lexemes) == {:error, "Unexpected end of input"}
  end

  test "syntax checker error multiple operators" do
    {:ok, lexemes} = Lexer.get_lexemes "20 + *"
    assert Syntaxer.valid_syntax?(lexemes) == {:error, "Unexpected token operator"}
  end
end
