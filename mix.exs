defmodule TinyRepl.Mixfile do
  use Mix.Project

  def project do
    [app: :tiny_repl,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: TinyRepl],
     aliases: aliases,
     deps: deps]
  end

  def application do
    [mod: {TinyRepl, []},
     applications: [:logger]]
  end

  defp deps do
    [{:credo, "~> 0.5", only: [:dev, :test]}]
  end

  defp aliases do
    ["build": ["escript.build"]]
  end
end
