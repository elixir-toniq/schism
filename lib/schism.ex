defmodule Schism do
  @moduledoc """
  Schism allows you to create network partitions in erlang nodes without
  needing to leave elixir.

  Let's say that we have 5 nodes and we want to test what happens when they
  disconnect from each other. We can use Schism like so:

  ```elixir
  test "netsplits" do
    [n1, n2, n3, n4, n5] = nodes

    # Partition our nodes
    Schism.partition([n1, n3])
    Schism.partition([n4])
    Schism.partition([n2, n5])

    # Test some stuff...

    # Heal our partitions
    Schism.heal([n1, n3])
    Schism.heal([n2, n4, n5])
  end
  ```

  This api is useful for testing and development in conjunction with tools like
  [local cluster](https://github.com/whitfin/local-cluster) and
  [propcheck](https://github.com/alfert/propcheck).
  """

  @doc """
  Creates a partition amongst a set of nodes. Any nodes in the partition
  will be able to see each other but no other nodes in the network. The
  partitioned nodes will still be able to see the node that induced the
  partition. Otherwise we would not be able to heal the partition.
  """
  @spec partition([Node.t], String.t) :: [Node.t] | none()
  def partition(nodes, id \\ random_string()) when is_binary(id) do
    manager = Node.self()

    for node <- nodes do
      # Force the node to disconnect from all nodes that aren't us
      all_except_us = :rpc.call(node, Node, :list, []) -- [manager]
      Enum.each(all_except_us, fn n -> :rpc.call(node, Node, :disconnect, [n]) end)

      # Set the remote nodes cookie to a different value
      true = :rpc.call(node, :erlang, :set_cookie, [node, String.to_atom(id)])

      # Ensure we can still talk to the node
      :pong = Node.ping(node)
    end

    # Reconnect the nodes in partition now that the cookie is the same
    connect_nodes(nodes)

    nodes
  end

  @doc """
  Re-connects the nodes to the cluster.
  """
  @spec heal([Node.t]) :: [Node.t] | none()
  def heal(nodes) do
    # Restore the cookie
    partition(nodes, Atom.to_string(:erlang.get_cookie()))
  end

  defp connect_nodes([node | other_nodes]) do
    Enum.each(other_nodes, fn n -> :rpc.call(node, Node, :connect, [n]) end)
    connect_nodes(other_nodes)
  end

  defp connect_nodes([]), do: :ok

  defp random_string do
    :crypto.strong_rand_bytes(10)
    |> Base.url_encode64
    |> binary_part(0, 10)
  end
end
