defmodule Abacus.Mixfile do
  use Mix.Project

  def project do
    [
      app: :abacus,
      version: "1.0.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      name: "Abacus",
      source_url: "https://github.com/xvw/abacus",
      homepage_url: "https://xvw.github.io/xvw/abacus",
      docs: [
        main: "README",
        extras: ["README.md"]
      ],
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description do 
    """
    Abacus is a module for transforming other modules into metric systems.
    These modules (metric systems) make it possible to use functions to create values enclosed 
    in a metric system and functions to manipulate these values.
    """
  end

  defp package do
    [
     name: :abacus,
     files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Xavier Van de Woestyne"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/xvw/abacus",
              "Docs" => "http://xvw.github.io/abacus/"}]
  end


end
