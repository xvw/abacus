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

  test "for unwraping" do 
    input = Length.cm(12)
    assert (Abacus.unwrap input) == 12
  end

  test "for difftyped data" do 
    k = Money.euro(12)
    module = Money
    other_module = Length
    assert_raise RuntimeError, "[#{module}] is not compatible with [#{other_module}]", fn -> 
      _ = Abacus.from(k, to: Length.cm)
    end
  end

  test "for conversion" do 
    input = Length.cm(350)
    to_m  = Abacus.from input, to: Length.m
    assert Abacus.unwrap(to_m) == 3.5
  end

  test "for Mapping" do 
    input = Length.cm(12)
    |> Abacus.map(fn(x) -> x + 10 end)
    |> Abacus.unwrap
    assert input == 22
  end

  test "for map2" do 
    a = Length.dm(12)
    b = Length.dm(34)
    c = Abacus.map2(a, b, fn(x, y) -> x + y end)
    assert Abacus.unwrap(c) == 46
  end 

  test "failure for map2" do 
    a = Money.euro(12)
    b = Length.dm(34)
    assert_raise RuntimeError, "[#{Money}] is not compatible with [#{Length}]", fn -> 
      _ = Abacus.map2(a, b, fn(x, y) -> x + y end)
    end
  end

  test "for fold" do 
    result = 
      [Length.cm(100), Length.km(1), Length.m(13)]
      |> Abacus.fold(
        Length.m(0), 
        fn(x, acc) -> 
          Abacus.map2(x, acc, fn(a, b) -> a+b end) 
        end,
        to: Length.m
        )
      |> Abacus.unwrap
      assert result == 1014

  end

  test "for Sum" do 
    result = 
      [Length.m(12), Length.km(1), Length.cm(14)]
      |> Abacus.sum(to: Length.cm)
      |> Abacus.unwrap()

    assert result == (100000 + 1200 + 14)
    
  end

  test "for comparison :eq 1" do 
    x = Length.m(1)
    y = Length.cm(100)
    assert (Abacus.compare(x, with: y)) == :eq
    assert (Abacus.compare(x, with: x)) == :eq
    assert (Abacus.compare(y, with: y)) == :eq
    assert (Abacus.compare(y, with: x)) == :eq
  end

  test "for comparison :lt/gt 1" do 
    x = Length.m(23)
    y = Length.cm(100)
    assert (Abacus.compare(x, with: y)) == :gt
    assert (Abacus.compare(y, with: x)) == :lt
  end

  test "failure of comparison" do 
    x = Length.m(23)
    y = Money.euro(100)
    assert_raise RuntimeError, "[#{Length}] is not compatible with [#{Money}]", fn -> 
      _ = Abacus.compare(y, with: x)
    end
  end


end
