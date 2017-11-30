defmodule DBFS.Crypto do
  alias DBFS.Block
  alias DBFS.JSON

  @sign_fields [:data, :type, :prev, :timestamp]
  @hash_fields [:creator, :signature | @sign_fields]



  @doc "Calculate a block's hash"
  def hash(block) do
    block
    |> JSON.encode(@hash_fields)
    |> sha256
  end

  def hash!(block) do
    %{ block | hash: hash(block) }
  end



  @doc "Sign block data using a private key"
  def sign(block, private_key) do
    block
    |> JSON.encode(@sign_fields)
    |> RsaEx.sign(private_key)
    |> elem(1)
    |> encode
  end

  def sign!(block, private_key) do
    block
    |> Map.put(:creator,   public_key(private_key))
    |> Map.put(:signature, sign(block, private_key))
  end



  @doc "Verify a block using the public key present in it"
  def verify(block) do
    sign = decode(block.signature)
    key  = decode(block.creator)

    {:ok, valid} =
      block
      |> JSON.encode(@sign_fields)
      |> RsaEx.verify(sign, key)

    if valid,
      do:   :ok,
      else: :invalid
  end



  # Helpers

  def sha256(binary) do
    :crypto.hash(:sha256, binary) |> encode
  end

  def public_key(private_key) do
    private_key
    |> RsaEx.generate_public_key
    |> elem(1)
    |> encode
  end

  def encode(binary), do: Base.encode16(binary)
  def decode(binary), do: Base.decode16!(binary)

end
