# GeometricFigures

The TikZ figures of the JuliaGNI packages, compiled in a light and a dark theme. Each figure is
published as PDF, as SVG, and as a transparent PNG at 150, 300 and 600 dpi. The pages under
*Figures* show every figure in both themes, with the links to its files.

## Using a figure in a manual

Link the two SVGs of a figure on two lines, and load the theme switch `figures.css` as a remote
asset, so that the reader sees the one that matches the Documenter theme:

```julia
makedocs(;
    format = Documenter.HTML(;
        assets = [asset("https://juliagni.github.io/GeometricFigures.jl/figures.css"; islocal = false)]),
    ...)
```

```markdown
![The dogleg path.](https://juliagni.github.io/GeometricFigures.jl/figures/solvers/dogleg-tikz/dogleg-tikz_light.svg)
![The dogleg path.](https://juliagni.github.io/GeometricFigures.jl/figures/solvers/dogleg-tikz/dogleg-tikz_dark.svg)
```

[`figure_url`](@ref) returns each address. The addresses are not versioned, and the name of a
figure does not change once it is published.

## Adding a figure

A figure is one source, `src/<topic>/<name>/<name>.tex`, with its raster inputs beside it, and one
entry in `src/figures.toml`. The source loads `geometricfigures.sty`, which defines the theme
colours `fg`, `bg` and `muted` and the shared palette. The build compiles each source twice, the
second time with `\def\darkmode{}` prepended, so a source takes every colour that depends on the
theme from the package and never writes `white` or `black`.

## Reference

```@docs
GeometricFigures
figure_url
GeometricFigures.build
GeometricFigures.figures
```
