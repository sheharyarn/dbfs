defmodule DBFS.JSON do
  @moduledoc """
  Custom implementation of JSON encoding because
  it needs to be in a very specific way
  """


  def encode(%{} = map, fields) do
    map
    |> Map.take(fields)
    |> encode
  end

  def encode(term) do
    Poison.encode!(term)
  end

end



# Custom Implementation of Poison.Encoder for Maps

defimpl Poison.Encoder, for: Map do
  def encode(map, opts) do
    encoded =
      map
      |> Map.keys
      |> Enum.sort
      |> Enum.map(&encode_by_key(map, &1, opts))
      |> Enum.join(",")

    "{" <> encoded <> "}"
  end


  defp encode_by_key(%{} = map, key, opts) do
    "#{Poison.Encoder.encode(key, opts)}:#{Poison.Encoder.encode(map[key], opts)}"
  end
end
