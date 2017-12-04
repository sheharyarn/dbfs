defmodule DBFS.Repo.Response do
  @moduledoc """
  Generic module to normalize responses in
  different formats
  """


  defp normalize(:ok),            do: {:ok, :success}
  defp normalize({:ok, resp}),    do: {:ok, resp}

  defp normalize(:error),         do: {:error, :unknown}
  defp normalize({:error, resp}), do: {:error, resp}
  defp normalize(term),           do: {:error, term}
end
