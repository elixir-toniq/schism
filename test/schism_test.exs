defmodule SchismTest do
  use ExUnit.Case
  doctest Schism

  test "paritions nodes" do
    nodes = LocalCluster.start_nodes("partition-nodes", 5)
    [n1, n2, n3, n4, n5] = nodes

    partitions = [[n1, n2], [n3], [n4, n5]]

    for partition <- partitions do
      Schism.partition(partition)
    end

    for partition <- partitions, node <- partition do
      for n <- partition do
        assert :pong = :rpc.call(node, Node, :ping, [n])
      end

      for unreachable <- (nodes -- partition) do
        assert :pang == :rpc.call(node, Node, :ping, [unreachable])
      end
    end
    # Schism.partition([n1, n2])
    # Schism.partition([n3])
    # Schism.partition([n4, n5])

    # for n <- :rpc.call(n1, Node, :list, []), n != manager, do: assert n in [n1, n2]
    # for n <- :rpc.call(n2, Node, :list, []), n != manager, do: assert n in [n1, n2]

    # assert [manager] == :rpc.call(n3, Node, :list, [])

    # for n <- :rpc.call(n4, Node, :list, []), n != manager, do: assert n in [n4, n5]
    # for n <- :rpc.call(n5, Node, :list, []), n != manager, do: assert n in [n4, n5]

    
  end
end

