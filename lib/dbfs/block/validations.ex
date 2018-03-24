defmodule DBFS.Block.Validations do
  import Ecto.Changeset
  require Logger

  alias DBFS.Block
  alias DBFS.Crypto


  @doc "Validate a block using previous block's hash"
  def validate(%{prev: prev} = block) do
    validate(block, prev)
  end

  def validate(%{} = block, %{hash: prev_hash}) do
    validate(block, prev_hash)
  end

  def validate(%{hash: hash, prev: reference} = block, prev_hash) do
    cond do
      (reference != prev_hash) ->
        {:error, :invalid_reference}

      ((calculated = Crypto.hash(block)) != hash) ->
        Logger.error("Hashes don't match")
        Logger.error("Passed:     "  <> inspect(hash))
        Logger.error("Calculated: "  <> inspect(calculated))
        Logger.error("Full Block:\n" <> inspect(block))

        {:error, :invalid_hash}

      (Crypto.verify(block) != :ok) ->
        {:error, :invalid_signature}

      true ->
        :ok
    end
  end





  def validate_crypto(%Ecto.Changeset{} = changeset) do
    prev  = Block.last()
    block = apply_changes(changeset)

    case validate(block, prev) do
      :ok ->
        changeset

      {:error, error} ->
        add_error(changeset, :crypto, to_string(error))
    end
  end






  def validate_data(changeset) do
    case get_field(changeset, :type) do
      :zero        -> validate_data_contents(:zero, changeset)
      :file_create -> validate_data_contents(:file_create, changeset)
      _            -> data_error(changeset, "Invalid Type")
    end
  end

  defp validate_data_contents(:zero, changeset) do
    case Enum.count(get_data(changeset)) do
      0 -> changeset
      _ -> data_error(changeset, "Zero Block's data should be empty")
    end
  end


  @required [:file_hash, :file_name]
  @optional [:file_type, :file_size, :file_key]
  defp validate_data_contents(:file_create, changeset) do
    data = get_data(changeset)
    _zzz = Map.take(data, @optional)

    if Enum.all?(@required, &!is_nil(data[&1])) do
      changeset
    else
      data_error(changeset, "Missing required fields: #{inspect(@required)}")
    end
  end

  defp get_data(changeset) do
    get_field(changeset, :data)
  end

  defp data_error(changeset, error) do
    add_error(changeset, :data, error)
  end

end
