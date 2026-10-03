# Release Notes

All notable changes to GeometricFigures.

The TikZ figures of the JuliaGNI packages, compiled in light and dark themes and published on the
package's site.


## [Unreleased] — targeting 0.1.0

### New Features

* **`figure_url(name; theme, format, dpi = nothing)` locates published figures.** Returns the URL
  of a figure in the `"light"` or `"dark"` theme, as `"pdf"`, `"svg"` or `"png"`. A PNG requires a
  `dpi` of 150, 300 or 600. Throws `ArgumentError` for an unknown figure name, theme or format, for
  a PNG without such a `dpi`, and for a `dpi` on PDF or SVG.

* **`GeometricFigures.build(outdir; names)` compiles figures in both themes.** Renders each figure
  to PDF, SVG and transparent PNG at 150, 300 and 600 dpi. Two builds of the same commit on one
  machine give byte-identical files: `SOURCE_DATE_EPOCH` is the commit time of the figure's last
  change, so `build` throws in a shallow clone, and `docs/make.jl` fetches the full history first.
  A source that does not compile throws an error that names the figure and quotes the last 20
  lines of its log. A tool that is not on the `PATH` throws an error that names it.

* **`GeometricFigures.figures()` lists the figure manifest.** Returns every figure of
  `src/figures.toml`, each with its name, topic, caption and TeX engine.

* **`geometricfigures.sty` provides theme colours and a palette.** Defines `fg`, `bg` and `muted`,
  which switch between the light theme (black, white, gray) and the dark theme (white, black,
  white), and the Matplotlib tab10 colours `mblue`, `morange`, `mgreen`, `mred` and `mpurple`.

* **The seed figure `dogleg-tikz` replaces SimpleSolvers' `dogleg_tikz_light` and
  `dogleg_tikz_dark` pair.** One source renders both themes, pixel-identical to the two old sources
  at 300 dpi.

* **The site deploys unversioned to the `gh-pages` root.** The figures are under
  `https://juliagni.github.io/GeometricFigures/figures/`, and `figures.css` beside them is the
  theme switch that a Documenter manual loads as a remote asset.

* **The repository is `JuliaGNI/GeometricFigures.jl`, so the site and every figure URL are under
  `https://juliagni.github.io/GeometricFigures.jl/`.** The earlier address
  `https://juliagni.github.io/GeometricFigures/` served the site only in the minutes between the
  first deployment and the rename, and GitHub Pages does not redirect it.
