defmodule DBFS.Crypto do
  alias DBFS.Block

  @sign_fields [:data, :type, :prev, :creator, :timestamp]
  @hash_fields [:signature | @sign_fields]


  @doc "Calculate a block's hash"
  def hash(%Block{} = block) do
    block
    |> payload(@hash_fields)
    |> sha256
  end

  def hash!(%Block{} = block) do
    %{ block | hash: hash(block) }
  end



  @doc "Sign block data using a private key"
  def sign(%Block{} = block, private_key) do
    block
    |> payload(@sign_fields)
    |> RsaEx.sign(private_key)
  end

  def sign!(%Block{} = block, private_key) do
    %{ block | signature: sign(block, private_key) }
  end



  @doc "Verify a block using the public key present in it"
  def verify(%Block{} = block) do
  end



  # Private Helpers

  defp payload(block, fields) do
    block
    |> Map.take(fields)
    |> Poison.encode!
  end

  defp sha256(payload) do
    :crypto.hash(:sha256, payload) |> Base.encode16
  end
end
