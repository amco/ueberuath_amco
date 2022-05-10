defmodule UeberauthAmco.MixProject do
  use Mix.Project

  @source_url "https://github.com/amco/ueberauth_amco"
  @version "0.1.0"

  def project do
    [
      app: :ueberauth_amco,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :oauth2, :ueberauth]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 2.0"},
      {:ueberauth, "~> 0.7.0"},
      {:better_params, "~> 0.5.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "CONTRIBUTING.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "An Uberauth strategy for Amco authentication.",
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE"],
      maintainers: ["Alejandro Gutiérrez"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/ueberauth_amco/changelog.html",
        GitHub: @source_url
      }
    ]
  end
end
