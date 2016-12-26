defmodule TinyRepl.Parser do
  use GenServer
  alias TinyRepl.{Token, Lexer, Syntaxer}

  @name :parser

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    {:ok, %{variables: []}}
  end

  def evaluate(input) do
    GenServer.call(@name, {:evaluate, input})
  end

  def handle_call({:evaluate, input}, _from, state) do
    with {:ok, lexemes} <- Lexer.get_lexemes(input),
         true <- Syntaxer.valid_syntax?(lexemes) do
      result = 0
      {:reply, {:ok, lexemes}, state}
    else
      error ->
        {:reply, error, state}
    end
  end
end
