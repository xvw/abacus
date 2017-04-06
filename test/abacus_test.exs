defmodule AbacusTest do
  use ExUnit.Case

  doctest Abacus

  defmodule Length do 
    use Abacus.SystemMetric
    unit :cm 
    unit :mm, (1/10)
    unit :dm, 10
    unit :m,  100
    unit :km, 100000
  end

  defmodule Money do 
    use Abacus.SystemMetric
    unit :euro
    unit :dollar, 1.06665
  end

  test "Test for unwraping" do 
    input = Length.cm(12)
    assert (Abacus.unwrap input) == 12
  end

  test "Test for difftyped data" do 
    k = Money.euro(12)
    module = Money
    other_module = Length
    assert_raise Abacus, "[#{module}] is not compatible with [#{other_module}]", fn -> 
      _ = Abacus.from(k, to: Length.cm)
    end
  end

  test "Test conversion" do 
    input = Length.cm(350)
    to_m  = Abacus.from input, to: Length.m
    assert Abacus.unwrap(to_m) == 3.5
  end

  test "Test for Mapping" do 
    input = Length.cm(12)
    |> Length.map(fn(x) -> x + 10 end)
    |> Abacus.unwrap
    assert input == 22
  end

  test "Test for map2" do 
    a = Length.dm(12)
    b = Length.dm(34)
    c = Length.map2(a, b, fn(x, y) -> x + y end)
    assert Abacus.unwrap(c) == 46
  end 

  test "failure for map2" do 
    a = Length.dm(12)
    b = Length.cm(34)
    Length.map2(a, b, fn(x, y) -> x + y end)
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
        to: Length.m
        )
      |> Abacus.unwrap
      assert result == 1014

  end

  test "for Sum" do 
    result = 
      [Length.m(12), Length.km(1), Length.cm(14)]
      |> Length.sum(to: Length.cm)
      |> Abacus.unwrap()

    assert result == (100000 + 1200 + 14)
    
  end
  

end
