defmodule AbacusTest do
  use ExUnit.Case
  use Abacus

  base :cm
  unit :km, 1000

  doctest Abacus

  test "the truth" do
    IO.inspect (from (cm 1000), to: :km)
    assert 1 + 1 == 2
  end
end
