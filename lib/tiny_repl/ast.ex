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

  @number_operations %{
    plus:  & &1 + &2,
    minus: & &1 - &2,
    mul:   & &1 * &2,
    div:   & &1 / &2
  }

  def evaluate(item, variables) when is_tuple(item) do
    case item do
      {%Token{type: :assignment}, variable, value} ->
        case evaluate(value, variables) do
          {:ok, result} ->
            {:ok, {result, Map.put(variables, variable.value, result)}}

          {:error, msg} ->
            {:error, msg}
        end

      {%Token{type: type}, val1, val2} when type in ~w[plus minus mul div]a ->
        case {evaluate(val1, variables), evaluate(val2, variables)} do
          {{:error, msg}, _} ->
            {:error, msg}

          {_, {:error, msg}} ->
            {:error, msg}

          {{:ok, res1}, {:ok, res2}} ->
            {:ok, @number_operations[type].(res1, res2)}
        end
    end
  end

  def evaluate(%Token{type: :variable, value: var}, variables) do
    if Map.has_key?(variables, var) do
      {:ok, variables[var]}
    else
      {:error, "variable #{var} is not defined"}
    end
  end

  def evaluate(item, _) do
    {:ok, item}
  end
end
