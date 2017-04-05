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

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Test for unwrap" do 
    input = Length.cm(12)
    assert (Length.unwrap input) == 12
  end

  test "Unwrapping between different modules" do 
    input = Length.cm(12)
    Money.unwrap(input)
    try do 
      Money.unwrap(input)
      assert false
    rescue _ -> assert true
    end
    
  end
  

end
