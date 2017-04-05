defmodule AbacusTest do
  use ExUnit.Case

  doctest Abacus

  defmodule Length do 
    use Abacus
    unit :cm 
    unit :mm, (1/10)
    unit :dm, 10
    unit :m,  100
    unit :km, 100000
  end

  defmodule Money do 
    use Abacus
    unit :euro
    unit :dollar, 1.06665
  end

  test "Test for unwraping" do 
    input = Length.cm(12)
    assert (Length.unwrap input) == 12
  end

  test "Test conversion" do 
    input = Length.cm(350)
    to_m  = Length.from input, to: :m
    assert Length.unwrap(to_m) == 3.5
  end

  test "Unwrapping between different modules" do 
    input = Length.cm(12)
    try do 
      Money.unwrap(input)
      assert false
    rescue _ -> assert true
    end
  end

  test "Test for Mapping" do 
    input = Length.cm(12)
    |> Length.map(fn(x) -> x + 10 end)
    |> Length.unwrap
    assert input == 22
  end

end
