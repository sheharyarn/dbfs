defmodule DBFS.Blockchain do
  alias DBFS.Block
  alias DBFS.Blockchain

  @moduledoc """
  A naive Blockchain data structure implemented on top
  of a Linked List
  """

  defstruct [:chain, :count]


  @doc "Create a new blockchain with a zero block"
  def new do
    %Blockchain{chain: [Block.zero()], count: 1}
  end


  @doc "Get the newest block on the chain"
  def head(%Blockchain{chain: [head | _tail]}) do
    head
  end


  @doc "Add a new block to the chain"
  def add(%Blockchain{} = bc, %Block{} = block) do
    %{ bc | chain: [block | bc.chain], count: bc.count + 1 }
  end
end
