defmodule TinyRepl.Ast do
  alias TinyRepl.Token

  @precedences %{plus: 0,
                 minus: 0,
                 mul: 1,
                 div: 1}

  def build(lexemes) do
    lexemes
    |> Enum.reduce(%{expressions: [], operators: []}, &add_lexeme/2)
    |> complete_building
  end

  defp add_lexeme(lexeme, %{expressions: expressions, operators: operators} = state) do
    case lexeme do
      %Token{type: :opening_parenthesis} ->
        %{state | operators: [lexeme | operators]}

      %Token{type: :number, value: number} ->
        %{state | expressions: [number | expressions]}

      %Token{type: :variable, value: variable} ->
        %{state | expressions: [{:unref, variable} | expressions]}

      %Token{type: operator} when operator in ~w[plus minus mul div]a ->
        new_state = parse_operator(lexeme, state)
        %{new_state | operators: [lexeme | new_state.operators]}

      _ ->
        raise "Cannot build AST"
    end
  end

  defp parse_operator(_, %{operators: []} = acc), do: acc
  defp parse_operator(lexeme, %{expressions: expressions, operators: [op | ops]} = acc) do
    if @precedences[op.type] >= @precedences[lexeme.type] do
      [e2, e1 | exps] = expressions
      parse_operator(lexeme, %{expressions: [{op, e1, e2} | exps], operators: ops})
    else
      acc
    end
  end

  defp complete_building(state) do
    case state do
      %{expressions: [e], operators: []} ->
        e
      %{expressions: [e2, e1 | exps], operators: [op | ops]} ->
        complete_building(%{expressions: [{op, e1, e2} | exps], operators: ops})
      _ ->
        raise "Cannot build AST"
    end
  end
end
