defmodule TinyRepl do
  use Application
  alias TinyRepl.Parser

  def main(_args) do
    read_line(1)
  end

  def read_line(line_number) do
    line = IO.gets "tiny_repl(#{line_number})> "

    case Parser.evaluate(line) do
      {:ok, result} ->
        IO.puts IO.ANSI.bright <> "#{result}" <> IO.ANSI.reset
      {:error, message} ->
        IO.puts IO.ANSI.red <> message <> IO.ANSI.reset
    end

    read_line(line_number + 1)
  end

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Parser, [])
    ]

    opts = [strategy: :one_for_one, name: TinyRepl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
