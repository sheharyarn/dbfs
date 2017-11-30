defmodule DBFS.JSON do
  @moduledoc """
  Custom implementation of JSON encoding because
  it needs to be in a very specific way
  """

  @safe_structs [NaiveDateTime]
  @blocked_keys [:__struct__, :__meta__]


  def encode(%{} = map, fields) do
    map
    |> Map.take(fields)
    |> encode
  end

  def encode(%{} = map) do
    map
    |> to_keyword
    |> encode
  end

  def encode(term) do
    JSON.encode!(term)
  end



  # Helpers

  def to_keyword(%{__struct__: struct} = map) when struct in @safe_structs do
    to_string(map)
  end

  def to_keyword(%{} = map) do
    map
    |> Map.delete(@blocked_keys)
    |> Map.keys
    |> Enum.sort
    |> Enum.reduce([], &Keyword.put( &2, &1, to_keyword(map[&1]) ))
    |> Enum.reverse
  end

  def to_keyword(term), do: term
end
