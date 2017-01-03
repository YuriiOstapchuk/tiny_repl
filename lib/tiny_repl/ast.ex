defmodule TinyRepl.Ast do
  alias TinyRepl.Token

  @precedences %{plus: 0,
                 minus: 0,
                 mul: 1,
                 div: 1}

  def build(lexemes) do
    lexemes
    |> Enum.reduce(%{expressions: [], operators: []}, &add_lexeme/2)
  end

  defp add_lexeme(lexeme, %{expressions: expressions, operators: operators} = state) do
    IO.inspect lexeme.type
    cond do
      # lexeme.type == :opening_parenthesis ->
      #   %{state | operators: [lexeme | operators]}

      lexeme.type == :number ->
        %Token{type: :number, value: number} = lexeme
        %{state | expressions: [number | expressions]}

      Enum.member?(~w[plus minus mul div]a, lexeme.type) ->
        new_state =
          operators
          |> Enum.reduce_while(state, fn _, %{expressions: expressions, operators: [op | ops]} = acc ->
            IO.inspect acc
            if @precedences[op.type] >= @precedences[lexeme.type] do
              [e2, e1 | exps] = expressions
              {:cont, %{expressions: [{op, e1, e2} | exps], operators: ops}}
            else
              {:halt, acc}
            end
          end)

        %{new_state | operators: [lexeme | new_state.operators]}

      true ->
        raise "Cannot build AST"
    end
  end
end
