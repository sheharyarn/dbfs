


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
    Block.last
    |> Block.new(type: :file_create, creator: @keypub, data: random_file())
    |> Ecto.Changeset.apply_changes
    |> Crypto.sign!(@keypvt)
    |> Crypto.hash!
    |> Map.from_struct
    |> Map.delete(:__meta__)
    |> Blockchain.insert
  end


  defp random_file do
    file = Path.join(@fixture_path, Enum.random(@fixture_files))

    %{
      file_name: Path.basename(file),
      file_hash: Crypto.sha256(File.read!(file))
    }
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

