defmodule DBFS.Crypto do
  alias DBFS.Block


  @doc "Calculate a block's hash"
  def hash(%Block{} = block) do
    # TODO: Implement
  end

  def hash!(%Block{} = block) do
    %{ block | hash: hash(block) }
  end



  @doc "Sign block data using a private key"
  def sign(%Block{} = block, private_key) do
  end

  def sign!(%Block{} = block, private_key) do
    %{ block | signature: sign(block, private_key) }
  end



  @doc "Verify a block using the public key present in it"
  def verify(%Block{} = block) do
  end

end
