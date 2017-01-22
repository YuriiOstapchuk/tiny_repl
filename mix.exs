defmodule TinyRepl.Mixfile do
  use Mix.Project

  def project do
    [app: :tiny_repl,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript(),
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [mod: {TinyRepl, []},
     applications: [:logger]]
  end

  def escript do
    [main_module: TinyRepl,
     path: "./bin/tiny_repl"]
  end

  defp deps do
    []
  end

  defp aliases do
    ["build": ["escript.build"]]
  end
end
