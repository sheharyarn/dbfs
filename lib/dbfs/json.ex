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




# Poison.Encoder Implementations
# ------------------------------

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


defimpl Poison.Encoder, for: NaiveDateTime do
  def encode(dt, opts) do
    {ms, _c} = dt.microsecond

    %{ dt | microsecond: {ms, 3} }
    |> NaiveDateTime.to_iso8601()
    |> Kernel.<>("Z")
    |> Poison.Encoder.BitString.encode(opts)
  end
end

