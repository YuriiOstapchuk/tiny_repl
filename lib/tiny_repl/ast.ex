defmodule TinyRepl.Ast do
  alias TinyRepl.Token

  @precedences %{
    opening_parenthesis: 0,
    closing_parenthesis: 1,
    assignment: 2,
    plus: 3,
    minus: 3,
    mul: 4,
    div: 4
  }

  def build(lexemes) do
    lexemes
    |> Enum.reduce(%{expressions: [], operators: []}, &add_lexeme/2)
    |> complete_building
    |> format_variables
  end

  defp add_lexeme(lexeme, %{expressions: expressions, operators: operators} = state) do
    case lexeme do
      %Token{type: :number, value: number} ->
        %{state | expressions: [number | expressions]}

      %Token{type: :variable, value: _} = lexeme ->
        %{state | expressions: [lexeme | expressions]}

      %Token{type: _} ->
        case operators do
          [] ->
            %{state | operators: [lexeme | operators]}

          [op | _] ->
            if @precedences[lexeme.type] == 0 || @precedences[lexeme.type] > @precedences[op.type] do
              %{state | operators: [lexeme | operators]}
            else
              case {lexeme, parse_operator(lexeme, state)} do
                {%Token{type: :closing_parenthesis}, %{operators: [%Token{type: :opening_parenthesis} | ops]} = new_state} ->
                  %{new_state | operators: ops}
                {_, new_state} ->
                  %{new_state | operators: [lexeme | new_state.operators]}
              end
            end
        end
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

  defp format_variables({%Token{type: :assignment}, variable, value}) do
    {%Token{type: :assignment}, variable, unref_variables(value)}
  end
  defp format_variables(state), do: state

  defp unref_variables(item) when is_tuple(item) do
    case item do
      {op, %Token{type: :variable, value: var}, val} ->
        {op, {:unref, var}, unref_variables(val)}

      {op, val, %Token{type: :variable, value: var}} ->
        {op, unref_variables(val), {:unref, var}}

      {op, %Token{type: :variable, value: var1}, %Token{type: :variable, value: var2}} ->
        {op, {:unref, var1}, {:unref, var2}}

      {op, val1, val2} ->
        {op, unref_variables(val1), unref_variables(val2)}
    end
  end
  defp unref_variables(item), do: item
end
