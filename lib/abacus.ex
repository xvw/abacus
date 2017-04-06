defmodule Abacus do

  @moduledoc """
  Abacus is a tool to simplify the handling of units.
  """

  @typedoc """
  This type represents a type (defined with using SystemMetric)
  """
  @type metric_type :: {
    module, 
    atom, 
    number
  }

  @typedoc """
  This type represents a value wrapped in a metric_type
  """
  @type typed_value :: {
    metric_type, 
    number
  }

  @typedoc """
  This type represents the option 'to:'
  """
  @type to_option :: {
    {:to, metric_type}
  }


  defexception message: "default message"

  defmodule SystemMetric do 

    @doc false
    defmacro __using__(_opts) do
      quote do
        import Abacus.SystemMetric
        @base nil
      end
    end

    defmacro unit(name) do 
      quote do 
        if @base do
          raise Abacus, message: "Base is already defined"
        end
        @base unquote(name)
        def unquote(name)(), do: {__MODULE__, unquote(name), unquote(1.0)}
        def unquote(name)(value) do 
          {
            __MODULE__, 
            apply(__MODULE__, unquote(name), []), 
            value
          }
        end
      end
    end

    defmacro unit(name, expr) do
      quote do
        unless @base do 
          raise Abacus, message: "Base must be defined"
        end
        unit_name  = unquote(name)
        if @base == unit_name do 
          raise Abacus, message: "#{unit_name} is already defined"
        end
        def unquote(name)(), do: {__MODULE__, unquote(name), unquote(expr)}
        def unquote(name)(value) do 
          {
            __MODULE__, 
            apply(__MODULE__, unquote(name), []), 
            value
          }
        end
      end
    end
  end

  @spec unwrap(typed_value) :: number
  def unwrap({_, _, elt}), do: elt

  @spec from(typed_value, [to_option]) :: typed_value
  def from({module, {_, _, coeff,}, elt}, to: {module, _, coeff_basis} = basis) do 
    divider = 1 / coeff_basis
    basis_elt = (elt * coeff) * divider
    {module, basis, basis_elt}
  end

  @spec from(typed_value, [to_option]) :: typed_value
  def from({module, _, _}, to: {other_module, _, _}) do 
    raise Abacus, message: "[#{module}] is not compatible with [#{other_module}]"
  end

  @spec map(typed_value, (number -> number)) :: typed_value
  def map({mod, type, elt}, f) do 
    {mod, type, f.(elt)}
  end

  @spec map2(
    typed_value, 
    typed_value, 
    (number, number -> number)
    ) :: typed_value
  def map2({mod, t, elt}, {mod, t, elt2}, f) do 
    {mod, t, f.(elt, elt2)}
  end

  @spec map2(
    typed_value, 
    typed_value, 
    (number, number -> number)
    ) :: typed_value
  def map2({module, {_, t, _}, _}, {other_module, {_, nt, _}, _}, _) do 
    cond do 
      module != module ->
        raise Abacus, message: "[#{module}] is not compatible with [#{other_module}]"
      t != nt -> 
        raise Abacus, message: "[#{t}] is not compatible with [#{nt}]"
      true -> 
        raise Abacus, message: "Invalid Input"
      end
  end

  @spec fold(
    [typed_value], 
    any, 
    (typed_value, any -> typed_value),
    [to_option]
    ) :: any
  def fold(list, default, f, to: basis) do 
    List.foldl(list, default, fn(x, acc) ->
      converted = Abacus.from(x, to: basis)
      f.(converted, acc)
    end)
  end

  @spec sum(
    [typed_value],
    [to_option]
  ) :: typed_value
  def sum(list, to: {module, basis_name, _coeff} = basis) do 
    fold(
      list, apply(module, basis_name, [0]),
      fn(x, acc) -> map2(x, acc, fn(a, b) -> a + b end) end,
      to: basis
    )
  end

end
