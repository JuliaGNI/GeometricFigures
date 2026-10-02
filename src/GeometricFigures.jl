"""
    GeometricFigures

The TikZ figures of the JuliaGNI packages, compiled in a light and a dark theme and published on
the package's site. [`figure_url`](@ref) gives the published address of a figure,
[`GeometricFigures.build`](@ref) compiles the figures, and [`GeometricFigures.figures`](@ref) lists
them.
"""
module GeometricFigures

using TOML: TOML

export figure_url
public build, figures

"The directory that holds the figure sources, the manifest and `geometricfigures.sty`."
const SOURCE_DIR = @__DIR__

"The manifest of the figures."
const MANIFEST = joinpath(SOURCE_DIR, "figures.toml")

"The address of the published figures."
const SITE = "https://juliagni.github.io/GeometricFigures/figures"

const THEMES = ("light", "dark")
const FORMATS = ("pdf", "svg", "png")
const DPIS = (150, 300, 600)
const ENGINES = ("xelatex", "pdflatex")

include("manifest.jl")
include("urls.jl")
include("build.jl")

end
