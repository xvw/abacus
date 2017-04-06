defmodule Abacus do

  @moduledoc """
  Abacus is a tool to Abacus is a tool to simplify 
  the handling of units.
  """

  defexception message: "default message"

  defmodule SystemMetric do 

    @doc false
    defmacro __using__(_opts) do
      quote do
        import Abacus.SystemMetric
        @base nil
        @before_compile Abacus.SystemMetric
      end
    end

    @doc false
    defmacro create_map_function() do 
      quote do 
        def map({mod, t, _} = data, f) do 
          elt = Abacus.unwrap(data)
          {mod, t, f.(elt)}
        end
      end
    end

    @doc false 
    defmacro create_map2_function() do 
      quote do 
        def map2({mod, t, _} = data, {mod, t, _} = data2, f) do 
          value_a = Abacus.unwrap(data)
          value_b = Abacus.unwrap(data2)
          {mod, t, f.(value_a, value_b)}
        end
      end
    end

    @doc false 
    defmacro create_sum_function() do 
      quote do 
        def sum(list, to: {_, basis_name, coeff} = basis) do 
          fold(
            list, apply(__MODULE__, basis_name, [0]),
            fn(x, acc) ->
              map2(x, acc, fn(a, b) -> a + b end)
            end, 
            to: basis
          )
        end
      end
    end

    @doc false 
    defmacro create_fold_function() do 
      quote do 
        def fold(list, acc, f, to: basis) do 
          List.foldl(list, acc, fn(x, acc) ->
            converted = Abacus.from(x, to: basis)
            f.(converted, acc)
          end)
        end
      end
    end

     @doc false 
    defmacro __before_compile__(_env) do
      quote do
        create_map_function()
        create_map2_function()
        create_fold_function()
        create_sum_function()
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

  def unwrap({_, _, elt}), do: elt

  def from({module, {_, _, coeff,}, elt}, to: {module, _, coeff_basis} = basis) do 
    divider = 1 / coeff_basis
    basis_elt = (elt * coeff) * divider
    {module, basis, basis_elt}
  end

  def from({module, _, _}, to: {other_module, _, _}) do 
    raise Abacus, message: "[#{module}] is not compatible with [#{other_module}]"
  end

end
