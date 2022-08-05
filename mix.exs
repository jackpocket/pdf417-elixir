defmodule PDF417.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/jackpocket/pdf417-elixir"

  def project do
    [
      app: :pdf417,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :png]
    ]
  end

  defp package do
    [
      name: "pdf417",
      descrption: "PDF417 Barcode generation library",
      organization: "jackpocket",
      links: %{"GitHub" => @source_url},
      licenses: ["MIT"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false},
      {:png, "~> 0.2.1"}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.txt": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      assets: "assets",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
