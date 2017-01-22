defmodule TinyReplTest do
  use ExUnit.Case

  alias TinyRepl.{Lexer, Token, Syntaxer, Ast, Parser}

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
    assert Lexer.get_lexemes("1 # 4 $ 5") == {:error, "Unknown tokens: #, $"}
  end

  test "syntax checker" do
    {:ok, lexemes} = Lexer.get_lexemes "20 * (3 - x)"
    assert Syntaxer.valid_syntax?(lexemes) == true
  end

  test "syntax checker big expression with assignment" do
    {:ok, lexemes} = Lexer.get_lexemes "a = 20 + 1 * 4 * (20 / (10 + 2) * 6 - 5)"
    assert Syntaxer.valid_syntax?(lexemes) == true
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

  test "ast assignment" do
    {:ok, lexemes} = Lexer.get_lexemes "a = (1 + x)"
    assert Ast.build(lexemes) == {Token.assignment, Token.variable("a"), {Token.plus, 1.0, Token.variable("x")}}
  end

  test "ast parenthesis" do
    {:ok, lexemes} = Lexer.get_lexemes "(1 + 2)"
    assert Ast.build(lexemes) == {Token.plus, 1.0, 2.0}
  end

  test "ast complex" do
    {:ok, lexemes} = Lexer.get_lexemes "a = 20 + 1 * 4 * (b / (10 + 2) * 6 - c)"
    assert Ast.build(lexemes) ==
      {Token.assignment, Token.variable("a"),
        {Token.plus, 20.0,
          {Token.mul, {Token.mul, 1.0, 4.0},
            {Token.minus,
              {Token.mul, {Token.div, Token.variable("b"), {Token.plus, 10.0, 2.0}}, 6.0}, Token.variable("c")}}}}
  end

  test "ast evaluation" do
    input = "20 + 1 * 4 * (b / (10 + 2) * 6 - c)"

    {:reply, {:ok, value}, _} =
      Parser.handle_call({:evaluate, input}, {}, %{variables: %{"b" => 5, "c" => 10}})
    assert value == -10
  end

  test "assignment evaluation" do
    input = "a = 10"

    {:reply, {:ok, value}, %{variables: variables}} =
      Parser.handle_call({:evaluate, input}, {}, %{variables: %{}})

    assert value == 10
    assert Map.has_key?(variables, "a")
    assert variables["a"] == 10
  end

  test "evaluation error" do
    input = "5 + a"

    {:reply, {:error, message}, _} =
      Parser.handle_call({:evaluate, input}, {}, %{variables: %{}})

    assert message == "a is undefined"
  end
end
