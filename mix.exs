defmodule Shortler.MixProject do
  use Mix.Project

  def project do
    [
      app: :shortler,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :plug
      ],
      mod: {Shortler, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:cowboy, "~> 2.5"},
      # {:plug, "~> 1.6"},
      # Using this particular version of plug in order to get rid of the
      # following Ranch warning:
      # ```
      # [warn] Setting Ranch options together with socket options is deprecated.
      # Please use the new map syntax that allows specifying socket options
      # separately from other options.
      # ```
      # The format of the options was changed within Ranch version 1.6.
      {:plug, git: "https://github.com/elixir-plug/plug.git", ref: "342a2d1"},
      {:ecto, "~> 2.2"},
      {:postgrex, ">= 0.0.0"},
      {:instream, "~> 0.18"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
