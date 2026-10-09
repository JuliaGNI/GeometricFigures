# Release Notes

All notable changes to GeometricFigures.

The TikZ figures of the JuliaGNI packages, compiled in light and dark themes and published on the
package's site.


## [Unreleased] — targeting 0.1.0

### Changed

* **CI uploads coverage from the `Julia 1 - ubuntu-latest` job.** It replaces `Julia min`, and a
  test job saves the Julia cache only when it succeeds.

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

* **The 13 TikZ figures of GeometricIntegrators, GeometricProblems and SimpleSolvers are figures
  of the package.** The topic `integrators` holds the ten projection and variation figures of
  GeometricIntegrators, `problems` holds `pendulum` and `double-pendulum`, and `solvers` holds
  `solver`. Each source renders both themes. Each light theme, and the dark themes of `pendulum`
  and `double-pendulum`, are pixel-identical to the old sources at the old resolution. The other
  11 dark themes are new.

* **`geometricfigures.sty` defines `onfill`, `axes`, `pointer` and four fill tints.** `onfill`, for
  text and strokes drawn on a colour fill, is black in both themes. `axes` is darkgray in the light
  theme and gray in the dark theme. `pointer`, for an arrow from a label to a point on a colour
  fill, is `blue!40!fg` in the light theme and `blue!60!white` in the dark theme. `morangetint`,
  `mbluetint`, `mpurpletint` and `mredtint` are 40 % of their palette colour in the light theme
  and 70 % in the dark theme.

* **`scripts/compare.jl` compares every figure with its original sources, and
  `scripts/check-dark.jl` checks the dark themes.** `compare.jl` reads the originals from `scripts/references.toml`,
  compiles each one with its old engine, as many times as its old build ran it, on its
  repository's `origin/main`, and prints the number of differing pixels at the old resolution.
  `check-dark.jl` counts the opaque pixels of each dark PNG that are darker than 25 % grey and not
  a colour fill. Each script exits with status 1 on a difference or a dark pixel.

* **The 34 figures of GeometricMachineLearning are figures of GeometricFigures.** They include the
  three that GeometricOptimizers holds and the two that GeometricProblems holds, on the topic pages
  `neural-networks`, `optimizers`, `manifolds`, `reduced-order-modeling`, `data`, `problems` and
  `logos`. Each has one source for both themes, and `scripts/references.toml` lists the old sources
  it replaces. Against them, every figure renders pixel-identical at the old resolution, except
  where a cause is stated: `solution-manifold-2` has black tick labels in the light theme, where
  the original's were white, and a white box in the dark theme, where the original's was black;
  `third-degree-spline` takes GeometricMachineLearning's `very thick` lines, which
  GeometricProblems' version lacks. `general-optimization`, `logo` and
  `logo-with-name-without-jl` had no dark version and gain one. `grassmann-sampling` keeps
  GeometricMachineLearning's `rosenbrock_plot.jl` as `grassmann-sampling.jl`, the script that
  writes its raster input `rosenbrock_naked.png`; the build runs it, no longer TeX through
  `\write18`, and the PNG is not committed.

* **`GeometricFigures.build` runs a figure's Julia script before TeX.** Where a figure's directory
  holds `<name>.jl`, `build` runs it in a new module, in the build copy of that directory, so that
  it writes the figure's raster inputs there. A script that throws makes `build` throw, naming the
  figure. The scripts load their packages from the active environment: `docs/Project.toml` holds
  CairoMakie, and `scripts/compare.jl`, `scripts/check-dark.jl` and `scripts/reproducible.jl` run
  with `--project=docs`.

* **`transformer-upscaling`, `logo`, `logo-with-name` and `logo-with-name-without-jl` load the
  `neuralnetwork` package of the TeX distribution.** No copy of it is in the repository, so the
  build needs the package installed (TeX Live `collection-pictures`). A neuron's text is `onfill`.
  `transformer-upscaling` draws its transformer box itself, as a `fit` node over the neurons it
  encloses, in place of GeometricMachineLearning's `\maketransformerblack` and
  `\maketransformerwhite`.

* **`solver` shows the fields of SimpleSolvers' current `NonlinearSolver`.** They are, in the order
  of the struct's definition, `nonlinearproblem::NonlinearProblem` (with its `F` and its `J`, a
  callable or `missing`), `linearproblem::AbstractLinearProblem`, `jacobian::Jacobian`,
  `linearsolver::AbstractLinearSolver`, `linesearch::Linesearch`, `method::NonlinearSolverMethod`,
  `cache::AbstractNonlinearSolverCache` and `config::Options`, each with the bound of its type
  parameter. The `status` field is gone, the cache is no longer a `NewtonSolverCache`, the line
  search is a `Linesearch` rather than a `LinesearchState`, and the `NonlinearProblem` no longer
  holds a `Jacobian`. SimpleSolvers removed its own `docs/src/tikz/solver.tex`, so the figure has
  no original to compare with any more, and its entry in `scripts/references.toml` is gone.

* **28 TikZ figures of a symplectic autoencoder trained on the pendulum are figures of the topic
  `pendulum-autoencoder`.** They accompany the paper on symplectic autoencoders
  (arXiv:2312.10004). Each loads `geometricfigures.sty` and takes `fg` for black and `bg` for
  white, with `black!<p>` as `fg!<p>!bg` and a palette tint `<colour>!<p>` as `<colour>!<p>!bg`,
  so that the light theme renders pixel-identical to the original at 150 dpi and the dark theme is
  new. They compile with `pdflatex` and need no data file: the coordinates generated from trained
  weights are written into the sources. `scripts/references.toml` has no entry for them.

* **The `pendulum-autoencoder` figures are resynced with the paper as of 2026-10-06, and two are
  new.** `action-angle-chart` draws the action–angle atlas in the layout of `angle-atlas`, and
  `latent-invariant` draws why a symplectic decoder preserves the action of every closed latent
  curve. In 19 existing figures the text is set at least at `\footnotesize` at printed size,
  panel and chart names sit below their panels, overlapping and crowded labels are moved (also
  the top labels of `angle-atlas`), and the separatrix is drawn alike in the four area figures. `rotating-cap` now shades the two families in their
  family colours and hatches the enclosed area as its caption says, `atlas-vs-chart` labels the
  hole areas a₀, and `upper-branch` says from which level the curves self-intersect.
  The chart tints of `angle-atlas` and `rotating-cap`, passed through a macro argument, now mix
  with `bg`, so they are dark in the dark theme. The light themes are pixel-identical to the
  paper's sources at 150 dpi.

* **A topic page can open with a tracked introduction.** `docs/make.jl` writes
  `docs/topic-intros/<topic>.md`, where it exists, between the page's heading and its figures; the
  file is outside `docs/src/`, so Documenter does not publish it as a page of its own. The
  introduction of `pendulum-autoencoder` names the paper (arXiv:2312.10004), and an info box lists
  the figures that draw trained weights or the training set, which must be regenerated from the
  re-trained network and resynced after a re-training.
