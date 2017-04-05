defmodule Abacus do

  @moduledoc """
  Abacus is a tool to Abacus is a tool to simplify 
  the handling of units.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Abacus
      @childs %{}
      @base nil
      @before_compile Abacus
    end
  end


  defexception message: "default message"

  @doc false
  defmacro create_map_function() do 
    quote do 
      def map({mod, t, _} = data, f) do 
        elt = unwrap(data)
        {mod, t, f.(elt)}
      end
    end
  end

  @doc false 
  defmacro create_map2_function() do 
    quote do 
      def map2({mod, t, _} = data, {mod, t, _} = data2, f) do 
        value_a = unwrap(data)
        value_b = unwrap(data2)
        {mod, t, f.(value_a, value_b)}
      end
    end
  end

  @doc false 
  defmacro create_sum_function() do 
    quote do 
      def sum(list, to: basis) do 
        fold(
          list, apply(__MODULE__, basis, [0]),
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
          converted = from(x, to: basis)
          f.(converted, acc)
        end)
      end
    end
  end

  @doc false 
  defmacro create_unwrap_function() do 
    quote do 
      def unwrap({mod, _, value}) do 
        case mod do 
          __MODULE__ -> value 
          _ ->
          raise Abacus, message: "[#{__MODULE__} is not compatible with #{mod}]"
        end
      end
    end
  end

  @doc false 
  defmacro create_from_function() do 
    quote do 
      def from(value, to: basis) do 
        case value do 
          {__MODULE__, type, elt} ->
            case {Map.get(@childs, type), Map.get(@childs, basis)} do 
              {nil, _} -> raise Abacus, message: "Unknown type : [#{type}]"
              {_, nil} -> raise Abacus, message: "Unknown type : [#{basis}]"
              {coeff, coeff_basis} ->
                divider = 1 / coeff_basis
                basis_elt = (elt * coeff) * divider
                {__MODULE__, basis, basis_elt}
            end
          _ -> raise Abacus, message: "Invalid input"
        end
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
      create_unwrap_function()
      create_from_function()
    end
  end

  defmacro unit(name) do 
    quote do 
      if @base do
        raise Abacus, message: "Base is already defined"
      end
      @base unquote(name)
      @childs Map.put_new(@childs, unquote(name), unquote(1.0))
      def unquote(name)(value), do: {__MODULE__, unquote(name), value}
    end
  end

  defmacro unit(name, expr) do
    quote do
      unless @base do 
        raise Abacus, message: "Base must be defined"
      end
      unit_name  = unquote(name)
      if @base == unit_name || Map.has_key?(@childs, unit_name) do 
        raise Abacus, message: "#{unit_name} is already defined"
      end
      @childs Map.put_new(@childs, unit_name, unquote(expr))
      def unquote(name)(value), do: {__MODULE__, unquote(name), value}
    end
  end

end
