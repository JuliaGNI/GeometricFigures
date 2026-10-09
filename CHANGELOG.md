# Release Notes

All notable changes to GeometricFigures.

The TikZ figures of the JuliaGNI packages, compiled in light and dark themes and published on the
package's site.


## [Unreleased] — targeting 0.1.0

### Changed

* **CI uploads coverage from the `Julia 1 - ubuntu-latest` job.** It replaces `Julia min`, and a
  test job saves the Julia cache only when it succeeds.

* **The tests of `source_date_epoch` moved from `test/epoch.jl` to `test/integration/epoch.jl`.**
  The test convention keeps a test file at the top level of `test/` only where it mirrors
  `src/<name>.jl`, and there is no `src/epoch.jl`. The function is in `src/build.jl`, whose mirror
  `test/build.jl` already holds the tests of `build`.

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

* **In the dark theme `bg` is `#1F2424`, the page background of Documenter's `documenter-dark`
  theme, no longer black.** The figures are transparent, so `bg` shows only where a source fills
  with it or mixes a colour with it: a label mask, an open marker, a grey `fg!<p>!bg`, a tint
  `<colour>!<p>!bg`. On a `documenter-dark` page those were pitch-black patches; now a mask is the
  page colour. The value is the `background-color` of `html.theme--documenter-dark` in
  Documenter's `assets/html/themes/documenter-dark.css` (every release from 1.8.1 to 1.19.0).
  `fg` stays white, which is also that theme's text colour. Every light render is byte-identical
  to before. Eight dark renders change: the open markers of the six projection figures of
  `integrators`, the text on the central node of `solver`, and the grey fill of `vp-transformer`,
  which is lighter and no longer pixel-identical to GeometricMachineLearning's dark original
  (`scripts/references.toml` says so). The dark previews of the site are on `#1F2424`.
  `scripts/check-dark.jl` now counts the opaque, unsaturated pixels darker than `bg` (HSL
  lightness below 0.11, where `bg` has 0.13) instead of those darker than 25 % grey: with a grey
  `bg`, a mask, a grey `fg!<p>!bg` and a tint `<colour>!<p>!bg` are as light as the page or lighter,
  and a faint tint mixed with it has too little saturation to pass as a colour fill.

* **14 figures of homogeneous spaces, Lie groups and tangent spaces from the talk *Geometric
  Machine Learning* (LMU, September 2026).** Twelve are in the topic `manifolds`:
  `homogeneous-space`, `homogeneous-space-action`, `lie-group-venn`, `lie-group`, `lie-algebra`,
  `lie-algebra-representation`, `projected-diagram`, `tangent-space`,
  `manifold-with-tangent-space`, `manifold-with-tangent-space-e`, `homogeneous-geodesics` and
  `skew-sym-projection`. Two are in `optimizers`: `general-optimization-notation` and
  `manifold-optimization-motivation`. Names are the talk's file names with `-` for `_`, with four
  exceptions:
  - the talk's `manifold` is `homogeneous-space-action`, because a generic name is permanent once
    deployed;
  - its `skew_sym_visualization`, a different picture from the existing `skew-sym-visualization`
    (a general matrix and the skew-symmetric matrix built from its strictly lower triangle), is `skew-sym-projection`;
  - its `general_optimizer` is `general-optimization-notation`, because it is
    `general-optimization-with-boundary` with mathematical notation in place of code names;
  - its `manifold_with_tangent_spaceE` is `manifold-with-tangent-space-e`, so that every name is
    lower case.

  Each loads `geometricfigures.sty` and takes `fg` for black, `bg` for white, `muted` for gray and
  `<colour>!<p>!bg` for a tint used as a fill. The light theme renders pixel-identical to the
  original compiled with `xelatex` at 150 dpi. The animated variants of four of them are left out:
  they are multi-page PDFs, and each static figure is the last frame of its animation.

* **Six overview diagrams of the talk "Geometric Machine Learning" (LMU, September 2026) are
  figures of the topic `overview`.** `numerics-triangle`, `two-directions`,
  `solution-vs-structure`, `derived-vs-learned`, `mathematical-landscape` and
  `juliagni-ecosystem` each load `geometricfigures.sty` and take `fg` for black, `bg` for white,
  `black!<p>` as `fg!<p>!bg`, a grey `gray!<p>` as `muted!<p>!bg` and a palette tint
  `<colour>!<p>` as `<colour>!<p>!bg`, so that the light theme renders pixel-identical to the
  original at 150 dpi and the dark theme is new. They compile with `xelatex`, as the originals do,
  and load only `amsmath` and `amsfonts` beside TikZ. Two code changes keep the output unchanged:
  `derived-vs-learned` renames its layer `bg` to `background`, because `bg` is now the theme
  colour, and `numerics-triangle` drops the colours `labET`, `labTS` and `labES`, which only its
  animation used. The animated versions the talk plays are not added: each is a multi-page PDF
  whose last frame is the static figure. `juliagni-ecosystem` shows the main registered JuliaGNI
  packages with their latest versions as of 5 October 2026, newer than the talk's, so its version
  labels are the one place where the light theme differs from the original.
  `scripts/references.toml` has no entry for them.

* **Two finite element exterior calculus figures of the talk "Geometric Machine Learning" (LMU,
  September 2026) are figures of the topic `feec`: `de-rham-commuting-diagram` and
  `feec-nn-swap`.** Each loads `geometricfigures.sty` and takes `fg` for black, a palette tint
  `<colour>!<p>` as `<colour>!<p>!bg` and the grey `gray!55` as `muted!55!bg`, so that the light
  theme renders pixel-identical to the original at 150 dpi and the dark theme is new. They compile
  with `xelatex`, as the originals do, and load only TeX Live packages (`amsmath`, `amssymb`,
  `amsfonts`, `pifont`). `scripts/references.toml` has no entry for them.

* **The versions of two symplectic-autoencoder figures in the paper on symplectic autoencoders
  (arXiv:2312.10004) are figures of the topic `reduced-order-modeling`: `sae-paper-autoencoder` and
  `sae-paper-architecture`.** They compile with `pdflatex` and differ in content from
  `symplectic-autoencoder` and `symplectic-autoencoder-architecture`: the paper labels the inputs
  $z_i$ where those have $x_i$, and its decoder ends in `PSDLayer(2n, 2N)` and `GradientQ(2N, 2N,
  tanh)`, with the encoder and the decoder labelled $\mathcal{P}$ and $\mathcal{R}$, where
  `symplectic-autoencoder-architecture` ends in `PSDLayer(2n, 2M)`, two gradient layers on `2M` and
  `PSDLayer(2M, 2N)`, labelled $\Psi^e$ and $\Psi^d$. They take the theme colours as those two do.
  The paper's third figure is `third-degree-spline` except for the `very thick` lines that figure
  took from GeometricMachineLearning, so it is not added again.

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
