


# Set up Helpers
# --------------

alias DBFS.Seeds
alias DBFS.Crypto
alias DBFS.Block
alias DBFS.Blockchain

defmodule Seeds do
  @keypvt Application.get_env(:dbfs, :zero_key)
  @keypub Crypto.public_key(@keypvt)

  def upload_file do
    Block.last
    |> Block.new(type: :file_create, creator: @keypub, data: %{})
    |> Ecto.Changeset.apply_changes
    |> Crypto.sign!(@keypvt)
    |> Crypto.hash!
    |> Map.from_struct
    |> Map.delete(:__meta__)
    |> Blockchain.insert
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

