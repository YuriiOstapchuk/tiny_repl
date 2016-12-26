defmodule TinyReplTest do
  use ExUnit.Case

  alias TinyRepl.{Lexer, Token, Syntaxer}

  test "lexeme parser simple expression" do
    assert Lexer.get_lexemes("1 + 2") == {:ok, [Token.number(1.0),
                                                Token.operator("+"),
                                                Token.number(2.0)]}
  end

  test "lexeme parser complex expression" do
    assert Lexer.get_lexemes("20 * (3 - x)") == {:ok, [Token.number(20.0),
                                                       Token.operator("*"),
                                                       Token.opening_parenthesis,
                                                       Token.number(3.0),
                                                       Token.operator("-"),
                                                       Token.variable("x"),
                                                       Token.closing_parenthesis]}
  end

  test "lexeme parser unknown" do
    assert Lexer.get_lexemes("1 # 4") == {:error, [{:unknown, "#"}]}
  end

  test "syntax checker" do
    lexemes = [Token.number(20.0),
               Token.operator("*"),
               Token.opening_parenthesis,
               Token.number(3.0),
               Token.operator("-"),
               Token.variable("x"),
               Token.closing_parenthesis]
    assert Syntaxer.valid_syntax?(lexemes)
  end

  test "syntax checker error finding" do
    lexemes = [Token.number(20.0),
               Token.operator("*"),
               Token.opening_parenthesis,
               Token.number(3.0),
               Token.operator("-"),
               Token.variable("x")]
    assert Syntaxer.valid_syntax?(lexemes) == {:error, ""}
  end
end
