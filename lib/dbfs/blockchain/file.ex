defmodule DBFS.Blockchain.File do
  import DBFS.Repo.Multi

  alias DBFS.Block
  alias DBFS.Blockchain


  @moduledoc """
  Interface for inserting/deleting file-based blocks
  """

  def insert(block, encoded_file) do
    Ecto.Multi.new
    |> run_operation(:block, block)
    |> run_operation(:file, encoded_file)
    |> run_operation(:match_hash, nil)
    |> run_operation(:file_save, nil)
    |> Repo.transaction
  end


  # Insert Block in the chain
  defp block(_changes, block) do
    block
    |> Blockchain.Schema.insert
    |> Repo.Multi.normalize
  end

  # Decode Encoded File
  defp file(_changes, encoded_file) do
    case Base.decode64(encoded_file) do
      {:ok, file} -> {:ok, file}
      :error      -> {:error, :invalid_encoding}
    end
  end

  # Compare Block / File hashes
  defp match_hash(%{file: file, block: block}, nil) do
    file_hash  = Block.File.hash(file)
    block_hash = block.data.file_hash

    case file_hash == block_hash do
      true  -> {:ok, :valid_hash}
      false -> {:error, :hashes_do_not_match}
    end
  end

  # Write file to disk
  defp file_save(%{file: file, block: block}, nil) do
    Block.File.save(block, file)
  end

end
