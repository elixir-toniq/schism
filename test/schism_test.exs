defmodule SchismTest do
  use ExUnit.Case
  doctest Schism

  @moduletag :capture_log

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

    for partition <- partitions do
      Schism.heal(partition)
    end

    for node <- nodes do
      for other_node <- nodes, node != other_node do
        assert :pong = :rpc.call(node, Node, :ping, [other_node])
      end
    end
  end
end

