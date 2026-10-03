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

* **The 14 TikZ figures of GeometricIntegrators, GeometricProblems, SimpleSolvers and GMLDatasets
  are figures of the package.** The topic `integrators` holds the ten projection and variation
  figures of GeometricIntegrators, `problems` holds `pendulum` and `double-pendulum`, `solvers`
  holds `solver`, and `data` holds `mnist-visualization` with its raster inputs, the Julia script
  that writes them and the TeX source of `final_image.pdf`. Each source renders both themes. Each
  light theme, and the dark themes of `pendulum`, `double-pendulum` and `mnist-visualization`, are
  pixel-identical to the old sources at the old resolution. The other 11 dark themes are new.

* **`geometricfigures.sty` defines `axes` and four fill tints.** `axes` is darkgray in the light
  theme and gray in the dark theme. `morangetint`, `mbluetint`, `mpurpletint` and `mredtint` are
  40 % of their palette colour in the light theme and 70 % in the dark theme.

* **`scripts/compare.jl` compares every figure with its original sources, and `scripts/check-dark.jl`
  checks the dark themes.** `compare.jl` reads the originals from `scripts/references.toml`,
  compiles each one with its old engine on its repository's `origin/main`, and prints the number
  of differing pixels at the old resolution. `check-dark.jl` counts the opaque pixels of each dark
  PNG that are darker than 25 % grey and not a colour fill. Each script exits with status 1 on a
  difference or a dark pixel.
