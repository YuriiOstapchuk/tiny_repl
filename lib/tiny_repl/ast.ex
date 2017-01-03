defmodule TinyRepl.Ast do
  alias TinyRepl.Token

  def build(lexemes) do
    lexemes
    |> Enum.reduce(%{expressions: [], operators: []}, &add_lexeme/2)
  end

  defp add_lexeme(lexeme, %{expressions: expressions, operators: operators} = state) do
    cond do
      lexeme == Token.opening_parenthesis ->
        %{state | operators: [lexeme | operators]}

      Enum.member?([Token.plus, Token.minus, Token.mul, Token.div], lexeme) ->
        nil
    end
  end
end
