# GeometricFigures

TikZ figures of the JuliaGNI packages, compiled in light and dark themes.

Each figure is one source, `src/<topic>/<name>/<name>.tex`, listed in `src/figures.toml`. The
build compiles it twice, once per theme, into PDF, SVG and transparent PNG at 150, 300 and 600
dpi, and the [site](https://juliagni.github.io/GeometricFigures.jl/) publishes the files:

```julia
using GeometricFigures
figure_url("dogleg-tikz"; theme = "dark", format = "svg")
# "https://juliagni.github.io/GeometricFigures.jl/figures/solvers/dogleg-tikz/dogleg-tikz_dark.svg"
```

A manual links both themes of a figure and loads
`https://juliagni.github.io/GeometricFigures.jl/figures.css`, which shows the one that matches the
Documenter theme.

Building the figures needs `xelatex`, `pdflatex` and `pdftocairo`:

```sh
julia --project=docs docs/make.jl
```
