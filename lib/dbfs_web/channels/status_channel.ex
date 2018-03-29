defmodule DBFS.Web.Channels.Status do
  use Phoenix.Channel

  def join("status", _payload, socket) do
    {:ok, socket}
  end


  def handle_in("get", _payload, socket) do
    status = %{nodes: DBFS.Consensus.status}
    {:reply, {:ok, status}, socket}
  end

end
