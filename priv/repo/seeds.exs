


# Set up Helpers
# --------------

alias DBFS.Seeds
alias DBFS.Crypto
alias DBFS.Block
alias DBFS.Blockchain


defmodule Seeds do
  @keypvt Application.get_env(:dbfs, :zero_key)
  @keypub Crypto.public_key(@keypvt)

  @fixture_path  Path.expand("../fixtures/", __DIR__)
  @fixture_files ["archive.zip", "document.pdf", "image.jpg", "text.txt"]


  def upload_file do
    file = random_file()
    file_encrypted = File.read!(file)
    file_encoded = Block.File.encode(file_encrypted)
    file_data = %{
      file_name: Path.basename(file),
      file_hash: Crypto.sha256(file_encoded)
    }

    block =
      Block.last
      |> Block.new(type: :file_create, creator: @keypub, data: file_data)
      |> Ecto.Changeset.apply_changes
      |> Crypto.sign!(@keypvt)
      |> Crypto.hash!
      |> Poison.encode!
      |> Poison.decode!
      |> ExUtils.Map.symbolize_keys(deep: true)

    {:ok, transaction} = Blockchain.insert_with_file(block, file_encoded)
  end


  defp random_file do
    Path.join(@fixture_path, Enum.random(@fixture_files))
  end
end




# Actual Seeds
# ------------

# Initialize Blockchain
{:ok, _} = Blockchain.initialize


# Create 50 File Uploads
Enum.each(1..50, fn _ ->
  {:ok, _} = Seeds.upload_file
end)

