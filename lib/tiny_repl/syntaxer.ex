defmodule TinyRepl.Syntaxer do
  alias TinyRepl.Token

  def valid_syntax?(lexemes) do
    case lexemes do
      [%Token{type: :variable, value: _}, %Token{type: :assignment} | rest] ->
        check_expression(rest)
      _ ->
        check_expression(lexemes)
    end
    |> case do
      [] -> true
      kek -> kek
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

  defp check_multiplier([first | rest]) do
    case first do
      %Token{type: :variable, value: _} ->
        rest

      %Token{type: :number, value: _} ->
        rest

      %Token{type: :opening_parenthesis} ->
        rest
        |> check_expression
        |> validate_closing_parenthesis
    end
  end

  defp validate_closing_parenthesis([%Token{type: :closing_parenthesis} | rest]) do
    rest
  end

  defp validate_closing_parenthesis(lexemes) do
    {:error, ""}
  end
end
