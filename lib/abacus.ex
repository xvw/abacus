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

  @doc false 
  defmacro __before_compile__(_env) do
  end

  defexception message: "default message"

  defmacro base(name) do 
    quote do 
      if @base do
        raise Abacus, message: "Base is already defined"
      end
      @base unquote(name)
      def unquote(name)(value), do: {unquote(name), value}
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
      def unquote(name)(value), do: {unquote(name), value}
    end
  end

end
