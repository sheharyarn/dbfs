defmodule DBFS.Repo.Response do
  @moduledoc """
  Generic module to normalize responses in
  different formats
  """


  def normalize(:ok),            do: {:ok, :success}
  def normalize({:ok, resp}),    do: {:ok, resp}

  def normalize(:error),         do: {:error, :unknown}
  def normalize({:error, resp}), do: {:error, resp}
  def normalize(term),           do: {:error, term}
end
