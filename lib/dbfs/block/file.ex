defmodule DBFS.Block.File do
  alias DBFS.Crypto
  alias DBFS.Repo.Response

  @path Path.expand(Application.get_env(:dbfs, :data_path))


  def hash(file), do: Crypto.sha256(file)

  def encode(file), do: Base.encode64(file)
  def decode(file), do: Base.decode64!(file)


  def save(%{hash: hash} = _block, binary) do
    mkdir!

    hash
    |> full_path
    |> File.write(binary)
    |> Response.normalize
  end


  def load!(%{hash: hash}) do
    hash
    |> full_path
    |> read
  end

  def read(path) do
    path |> File.read! |> encode
  end



  def next(hash) do
    block = DBFS.Block.next(hash)
    file  = load!(block)

    # TODO:
    # Make sure that the block type is file_create

    %{block: block, file: file}
  end


  defp mkdir! do
    "test"
    |> full_path
    |> File.mkdir_p!
  end

  defp full_path(suffix) do
    Path.join([
      @path,
      System.get_env("NODE") || "default",
      suffix,
    ])
  end

end

