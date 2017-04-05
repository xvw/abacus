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

  defp int_to_float(x) do 
    x / 1.0
  end

  @doc false 
  defmacro __before_compile__(_env) do
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

  defmacro base(name) do 
    quote do 
      if @base do
        raise Abacus, message: "Base is already defined"
      end
      @base unquote(name)
      @childs Map.put_new(@childs, unquote(name), unquote(1.0))
      def unquote(name)(value), do: {__MODULE__, unquote(name), value}
    end
  end

  defmacro unit(name, in_expr) do
    expr = int_to_float(in_expr)
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
