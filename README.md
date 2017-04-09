# Abacus

Abacus is a module for transforming other modules into metric systems.

For example :

```elixir
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
```

These modules make it possible to use functions to create values enclosed 
in a metric system and functions to manipulate these values.

For example : 

- [test/abacus_test.exs](https://github.com/xvw/abacus/blob/master/test/abacus_test.exs)
- [lib/abacus.ex](https://github.com/xvw/abacus/blob/master/lib/abacus.ex) (doctest comments)

You can see the documentation here : 

[xvw.github.io/abacus/index.html](https://xvw.github.io/abacus/index.html)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `abacus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:abacus_sm, "~> 1.0.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/abacus_sm](https://hexdocs.pm/abacus).

