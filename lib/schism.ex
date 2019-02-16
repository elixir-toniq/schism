defmodule Schism do
  @moduledoc """
  Schism allows you to create network partitions in erlang nodes.
  """

  @doc """
  Creates a partition amongst a set of nodes. Any nodes in the partition
  will be able to see each other but no other nodes in the network.
  """
  def partition(nodes, id \\ random_string()) when is_binary(id) do
    manager = Node.self()

    for node <- nodes do
      # Set the remote nodes cookie to a different value
      true = :rpc.call(node, :erlang, :set_cookie, [node, String.to_atom(id)])

      # Force the node to disconnect from all other nodes that aren't us or in
      # the partition
      node
      |> :rpc.call(Node, :list, [])
      |> Enum.reject(fn n -> n == manager || n in nodes end)
      |> Enum.each(fn n -> :rpc.call(node, Node, :disconnect, [n]) end)

      # Ensure we can still talk to the node
      :pong = Node.ping(node)
    end
  end

  @doc """
  """
  def heal(nodes) do
    for n <- nodes do
      # Reset the node and ensure we can still talk with it
      true = :rpc.call(n, :erlang, :set_cookie, [n, :erlang.get_cookie()])
      :pong = Node.ping(n)
    end
  end

  defp random_string do
    :crypto.strong_rand_bytes(10)
    |> Base.url_encode64
    |> binary_part(0, 10)
  end
end

