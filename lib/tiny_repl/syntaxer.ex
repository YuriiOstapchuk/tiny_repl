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

  def check_expression(lexemes) do
    lexemes
    |> check_term
    |> case do
      [first | rest] when first in [%Token{type: :operator, value: "+"},
                                    %Token{type: :operator, value: "-"}] ->
        check_term(rest)

      lexemes ->
        lexemes
    end
  end

  defp check_term(lexemes) do
    lexemes
    |> check_multiplier
    |> case do
      [first | rest] when first in [%Token{type: :operator, value: "*"},
                                    %Token{type: :operator, value: "/"}] ->
        check_multiplier(rest)

      lexemes ->
        lexemes
    end
  end

  defp check_multiplier([]), do: {:error, "Unexpected token operator"}
  defp check_multiplier([first | rest] = lexemes) do
    case first do
      %Token{type: :variable, value: _} ->
        rest

      %Token{type: :number, value: _} ->
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
