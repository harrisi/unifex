defmodule Unifex.MixProject do
  use Mix.Project

  @version "0.2.6"
  @github_link "https://github.com/membraneframework/unifex"

  def project do
    [
      app: :unifex,
      compilers: [:bundlex] ++ Mix.compilers(),
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      name: "Unifex",
      description: "Tool for generating interfaces between native C code and Elixir",
      source_url: @github_link,
      package: package(),
      docs: docs(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      files: ["lib", "c_src", "mix.exs", "README*", "LICENSE*", ".formatter.exs", "bundlex.exs"],
      links: %{
        "GitHub" => @github_link,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "pages/creating_unifex_nif.md"],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [
        Unifex.CodeGenerators,
        Unifex.CodeGenerator.BaseTypes
      ],
      groups_for_modules: [
        CodeGenerators: [~r/Unifex\.CodeGenerators\.*/],
        BaseTypes: [~r/Unifex\.CodeGenerator.BaseTypes\.*/]
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:bunch, "~> 1.0"},
      {:shmex, "~> 0.2.0"},
      {:bundlex,
       git: "https://github.com/membraneframework/bundlex.git",
       branch: "natives-spec",
       override: true},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
    ]
  end
end
