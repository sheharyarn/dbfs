defmodule DBFS.Block.File do
  alias DBFS.Repo.Response

  @path Path.expand(Application.get_env(:dbfs, :data_path))


  def hash(file), do: Crypto.sha256(file)


  def encode(file), do: Base.encode64(file)
  def decode(file), do: Base.decode64!(file)


  def save(%{hash: hash} = _block, encoded) do
    File.mkdir_p!(@path)
    binary = decode(encoded)

    @path
    |> Path.join(hash)
    |> File.write(binary)
    |> Response.normalize
  end


  def load!(%{hash: hash}) do
    @path
    |> Path.join(hash)
    |> read
  end

  def read(path) do
    path |> File.read! |> encode
  end

end

