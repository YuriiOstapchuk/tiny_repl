defmodule TinyRepl.Parser do
  use GenServer
  alias TinyRepl.{Lexer, Syntaxer, Ast}

  @name :parser

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    {:ok, %{variables: %{}}}
  end

  def evaluate(input) do
    GenServer.call(@name, {:evaluate, input})
  end

  def handle_call({:evaluate, input}, _from, state) do
    with {:ok, lexemes} <- Lexer.get_lexemes(input),
         true <- Syntaxer.valid_syntax?(lexemes),
         ast <- Ast.build(lexemes),
         {:ok, result} <- Ast.evaluate(ast, state.variables) do

      case result do
        {value, variables} ->
          {:reply, {:ok, value}, %{state | variables: variables}}

        value ->
          {:reply, {:ok, value}, state}
      end
    else
      error ->
        {:reply, error, state}
    end
  end
end
