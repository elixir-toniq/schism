defmodule Schism.MixProject do
  use Mix.Project

  def project do
    [
      app: :schism,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def aliases do
    [
      test: "test --no-start",
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:local_cluster, "~> 1.0"},
    ]
  end
end
