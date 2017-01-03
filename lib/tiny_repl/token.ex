defmodule TinyRepl.Token do
  @enforce_keys [:type]
  defstruct [:type, :value]

  @token_types [:number,
                :assignment,
                :plus,
                :minus,
                :mul,
                :div,
                :variable,
                :opening_parenthesis,
                :closing_parenthesis]

  @token_types
  |> Enum.each(fn name ->
    def unquote(name)(value \\ nil) do
      %__MODULE__{type: unquote(name), value: value}
    end
  end)

  def lexemes do
    @token_types
  end
end

defimpl Inspect, for: TinyRepl.Token do
  import Inspect.Algebra

  def inspect(dict, opts) do
    doc = & to_doc(&1, opts)
    value = if dict.value != nil, do: [", ", doc.(dict.value)], else: []

    concat ["#Token<", doc.(dict.type)] ++ value ++ [">"]
  end
end
