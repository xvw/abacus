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

  test "Test for map2" do 
    a = Length.dm(12)
    b = Length.dm(34)
    c = Length.map2(a, b, fn(x, y) -> x + y end)
    assert Length.unwrap(c) == 46
  end 

  test "failure for map2" do 
    a = Length.dm(12)
    b = Length.cm(34)
    try do 
      _ = Length.map2(a, b, fn(x, y) -> x + y end)
      assert false 
    rescue _ -> assert true 
    end
  end

  test "for fold" do 
    result = 
      [Length.cm(100), Length.km(1), Length.m(13)]
      |> Length.fold(
        Length.m(0), 
        fn(x, acc) -> 
          Length.map2(x, acc, fn(a, b) -> a+b end) 
        end,
        to: :m
        )
      |> Length.unwrap
      assert result == 1014

  end

  test "for Sum" do 
    result = 
      [Length.m(12), Length.km(1), Length.cm(14)]
      |> Length.sum(to: :cm)
      |> Length.unwrap()

    assert result == (100000 + 1200 + 14)
    
  end
  

end
