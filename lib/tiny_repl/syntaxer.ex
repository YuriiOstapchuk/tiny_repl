defmodule TinyRepl.Syntaxer do
  alias TinyRepl.Token

  def valid_syntax?(lexemes) do
    lexemes
    |> check_grammar
    |> validate
  end

  defp check_grammar(lexemes) do
    case lexemes do
      [%Token{type: :variable, value: _}, %Token{type: :assignment} | rest] ->
        check_expression(rest)
      _ ->
        check_expression(lexemes)
    end
  end

  defp validate(lexemes) do
    case lexemes do
      [] ->
        true
      [unexpected | _] ->
        {:error, "Unexpected token #{unexpected.type}"}
      error ->
        error
    end
  end

  defp repeat([first | rest] = lexemes, repeated, next) do
    if first in repeated do
      rest
      |> next.()
      |> repeat(repeated, next)
    else
      lexemes
    end
  end
  defp repeat(lexemes, _, _), do: lexemes

  defp check_expression(lexemes) do
    lexemes
    |> check_term
    |> repeat([%Token{type: :plus}, %Token{type: :minus}], &check_term/1)
  end

  defp check_term(lexemes) do
    lexemes
    |> check_multiplier
    |> repeat([%Token{type: :mul}, %Token{type: :div}], &check_multiplier/1)
  end

  defp check_multiplier([]), do: {:error, "Unexpected token operator"}
  defp check_multiplier([first | rest] = lexemes) do
    case first do
      %Token{type: type, value: _} when type in ~w[variable number]a ->
        rest

      %Token{type: :opening_parenthesis} ->
        rest
        |> check_expression
        |> validate_closing_parenthesis

      _ ->
        lexemes
    end
  end

  defp validate_closing_parenthesis([%Token{type: :closing_parenthesis} | rest]) do
    rest
  end

  defp validate_closing_parenthesis(_lexemes) do
    {:error, "Unexpected end of input"}
  end
end
