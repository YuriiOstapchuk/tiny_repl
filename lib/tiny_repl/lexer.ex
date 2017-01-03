defmodule TinyRepl.Lexer do
  alias TinyRepl.Token

  def get_lexemes(input) do
    input
    |> String.trim
    |> String.replace(~r/([\+\-\*\/\=\(\)]+)/, "@\\1@")
    |> String.split([" ", "@"], trim: true)
    |> Enum.map(fn part ->
      case part do
        "=" ->
          Token.assignment
        "(" ->
          Token.opening_parenthesis
        ")" ->
          Token.closing_parenthesis
        "+" ->
          Token.plus
        "-" ->
          Token.minus
        "*" ->
          Token.mul
        "/" ->
          Token.div
        _ ->
          cond do
            String.match?(part, ~r/^[\-\+]?\d+(\.\d+)?$/) ->
              {number, _} = Float.parse(part)
              Token.number(number)

            String.match?(part, ~r/^[A-z_][A-z_0-9]*$/) ->
              Token.variable(part)

            true -> {:unknown, part}
          end
      end
    end)
    |> validate_lexemes
  end

  defp validate_lexemes(lexemes) do
    unknown =
      lexemes
      |> Enum.filter(fn
        {:unknown, _} -> true
        _ -> false
      end)

    if Enum.count(unknown) == 0 do
      {:ok, lexemes}
    else
      {:error, unknown}
    end
  end
end
