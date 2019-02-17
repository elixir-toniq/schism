defmodule Schism.MixProject do
  use Mix.Project

  def project do
    [
      app: :schism,
      version: "1.0.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      description: description(),
      package: package(),
      name: "Schism",
      source_url: "https://github.com/keathley/schism",
      docs: docs(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:local_cluster, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: [:dev, :test]},
    ]
  end

  def aliases do
    [
      test: "test --no-start",
    ]
  end

  def description do
    """
    Schism provides a simple api for partitioning networked BEAM instances
    without having to leave elixir code.
    """
  end

  def package do
    [
      name: "schism",
      license: ["MIT"],
      links: %{"GitHub" => "https://github.com/keathley/schism"},
    ]
  end

  def docs do
    [
      main: "Schism",
    ]
  end
end
