defmodule Abacus do

  @moduledoc """
  Abacus is a tool to simplify the handling of units. 

  For example : 

  ```
  # This module is used during the documentation to 
  # show some examples.

  defmodule AbacusTest.Length do 
    use Abacus.SystemMetric

    # :cm is the unit used as a reference in the metric system 'Length'
    unit :cm 
    unit :mm, (1/10)
    unit :dm, 10
    unit :m,  100
    unit :km, 100000

  end
  ```

  This module provides functions for referencing a metric type:

  -  `Length.cm/0`
  -  `Length.mm/0`
  -  `Length.dm/0`
  -  `Length.m/0`
  -  `Length.km/0`

  and to create a value enclosed in a metric system:

  -  `Length.cm/1`
  -  `Length.mm/1`
  -  `Length.dm/1`
  -  `Length.m/1`
  -  `Length.km/1`

  Here is an example of using Abacus : 

  ```
  a_distance = Length.cm(12)
  a_distance_in_km = Abacus.from(a_distance, to: Length.km)
  ```

  A `metric_type` is defined by a module and a subtype. For example `Length` and `:cm`.

  """

  @typedoc """
  This type represents a unit of measure (defined with using Abacus.SystemMetric)
  """
  @type metric_type :: {
    module, 
    atom, 
    number
  }

  @typedoc """
  This type represents a value wrapped in a metric system
  """
  @type typed_value :: {
    metric_type, 
    number
  }

  @typedoc """
  This type represents a results of a comparison
  """
  @type comparison_result :: :eq | :lt | :gt


  defmodule SystemMetric do 

    @doc false
    defmacro __using__(_opts) do
      quote do
        import Abacus.SystemMetric
        @base nil
      end
    end

    @doc """
    A macro to generate the base of the system.
    This unit is the reference of each other units.
    

    For example : 
    ```
    defmodule Example do 
      use Abacus.SystemMetric

      unit :cm
    end
    ```
    """
    defmacro unit(name) do 
      quote do 
        if @base do
          raise RuntimeError, message: "Base is already defined"
        end
        @base unquote(name)
        def unquote(name)(), do: {__MODULE__, unquote(name), unquote(1.0)}
        def unquote(name)(value) do 
          {
            apply(__MODULE__, unquote(name), []), 
            value * 1.0
          }
        end
      end
    end

    @doc """
    A macro to generate an unit using the `base` as a reference. 
    This is referenced by a name (`:km` for example) and by a 
    reference to the base, in the case of `:km` in a system 
    referenced by `:cm` : 100000.


    For example: 
    ```
    defmodule Example do 
      use Abacus.SystemMetric

      unit :cm
      unit :m, 100 # (100 cm  == 1 m)
      unit :dm, 10 # (10 cm == 1 dm)
    end
    ```
    """
    defmacro unit(name, expr) do
      quote do
        unless @base do 
          raise RuntimeError, message: "Base must be defined"
        end
        unit_name  = unquote(name)
        if @base == unit_name do 
          raise RuntimeError, message: "#{unit_name} is already defined"
        end
        def unquote(name)(), do: {__MODULE__, unquote(name), unquote(expr)}
        def unquote(name)(value) do 
          {
            apply(__MODULE__, unquote(name), []), 
            value * 1.0
          }
        end
      end
    end
  end

  @doc """
  Retrieves the wrapped numeric value in a `typed_value()`.

  For example: 
      iex> x = AbacusTest.Length.cm(12)
      ...> Abacus.unwrap(x)
      12.0

  """
  @spec unwrap(typed_value()) :: number()
  def unwrap({_, elt}), do: elt

  @doc """
 Converts a `typed_value()` to another subtype of its metric system.

  For example: 
      iex> x = AbacusTest.Length.cm(120)
      ...> Abacus.from(x, to: AbacusTest.Length.m)
      {AbacusTest.Length.m, 1.2}
  """
  @spec from(typed_value(), [to: metric_type()]) :: typed_value()
  def from({{module, _, coeff}, elt}, to: {module, _, coeff_basis} = basis) do 
    divider = 1 / coeff_basis
    basis_elt = (elt * coeff) * divider
    {basis, basis_elt}
  end

  def from({{module, _, _}, _}, to: {other_module, _, _}) do 
    raise RuntimeError, message: "[#{module}] is not compatible with [#{other_module}]"
  end

  @doc """
  Applies a function to the numeric value of a typed value and re-packs
  the result of the function in the same subtype.

  For example:
      iex> AbacusTest.Length.km(120)
      ...> |> Abacus.map(fn(x) -> x * 2 end)
      {AbacusTest.Length.km, 240.0}
  """
  @spec map(typed_value(), (number() -> number())) :: typed_value()
  def map({type, elt}, f) do 
    {type, f.(elt)}
  end

  @doc """
  Applies a function to the two numeric values of two `typed_values()` in 
  the same metric system, and re-packages the result 
  of the function in a `typed_value()` of the subtype of the left `typed_values()`.

  For example: 
      iex> a = AbacusTest.Length.dm(100)
      ...> b = AbacusTest.Length.dm(2)
      ...> Abacus.map2(a, b, &(&1 * &2))
      {AbacusTest.Length.dm, 200.0}
  """
  @spec map2(
    typed_value(), 
    typed_value(), 
    (number(), number() -> number())
    ) :: typed_value
  def map2({{module, _, _} = t, elt}, {{module, _, _}, _} = elt2, f) do 
    converted = from(elt2, to: t)
    {t, f.(elt, unwrap(converted))}
  end

  def map2({{module, _, _}, _}, {{other_module, _, _}, _}, _) do 
    raise RuntimeError, message: "[#{module}] is not compatible with [#{other_module}]"
  end

  @doc """
  `List.foldl` for a list of `typed_value()` from the same metric system.

  For example:

      iex> Abacus.fold(
      ...>   [
      ...>       AbacusTest.Length.cm(10), 
      ...>       AbacusTest.Length.dm(1), 
      ...>       AbacusTest.Length.m(12)
      ...>   ],
      ...>   AbacusTest.Length.cm(12),
      ...>   fn(x, acc) -> Abacus.map2(x, acc, &(&1+&2)) end,
      ...>   to: AbacusTest.Length.cm
      ...>)
      {AbacusTest.Length.cm, 1232.0}

  """
  @spec fold(
    [typed_value()], 
    any(), 
    (typed_value(), any() -> any()),
    [to: metric_type()]
    ) :: any()
  def fold(list, default, f, to: basis) do 
    List.foldl(list, default, fn(x, acc) ->
      converted = Abacus.from(x, to: basis)
      f.(converted, acc)
    end)
  end


  @doc """
  Calculates the sum of a list of `typed_value()` of the same 
  metric system, projected into a specific subtype.

  For example: 

      iex> Abacus.sum(
      ...>   [
      ...>       AbacusTest.Length.cm(10), 
      ...>       AbacusTest.Length.dm(1), 
      ...>       AbacusTest.Length.m(12)
      ...>   ], 
      ...>   to: AbacusTest.Length.dm
      ...> )
      {AbacusTest.Length.dm, 122.0}
  """
  @spec sum([typed_value()], [to: metric_type]) :: typed_value()
  def sum(list, to: {module, basis_name, _coeff} = basis) do 
    fold(
      list, apply(module, basis_name, [0]),
      &add/2,
      to: basis
    )
  end

  @doc """
  Comparison between two `typed_value()` of the same metric system.

  The function returns:
  -  `:eq` for `equals` 
  -  `:lt` if the left-values is **lower than** the right-values
  -  `:gt` if the left-values is **greater than** the right-values

  For example:

      iex> x = AbacusTest.Length.m(1)
      ...> y = AbacusTest.Length.cm(100)
      ...> Abacus.compare(x, with: y)
      :eq
  """
  @spec compare(typed_value(), [with: typed_value()]) :: comparison_result
  def compare({t, _} = left, with: right) do 
    a = unwrap(left)
    b = unwrap(from(right, to: t))
    cond do 
      a > b -> :gt 
      b > a -> :lt
      true  -> :eq
    end
  end

  @doc """
  To be done
  """
  @spec add(typed_value(), typed_value()) :: typed_value()
  def add(a, b) do 
    map2(a, b, &(&1 + &2))
  end

  @doc """
  To be done
  """
  @spec sub(typed_value(), typed_value()) :: typed_value()
  def sub(a, b) do 
    map2(a, b, &(&1 - &2))
  end

  @doc """
  To be done
  """
  @spec mult(typed_value(), number) :: typed_value()
  def mult(a, b) do 
    map(a, fn(x) -> x * b end)
  end

  @doc """
  To be done
  """
  @spec div(typed_value(), number) :: typed_value()
  def div(a, b) do 
    mult(a, 1/b)
  end
  

end
