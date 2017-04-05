defmodule AbacusTest do
  use ExUnit.Case
  use Abacus

  base :cm
  unit :km, 1000

  doctest Abacus

  test "the truth" do
    IO.inspect km(1000)
    assert 1 + 1 == 2
  end
end
