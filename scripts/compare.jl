# Compare the seed figure `dogleg-tikz` with the two sources it replaces, pixel by pixel.
#
#   julia --project=. scripts/compare.jl <SimpleSolvers checkout>
#
# Renders `dogleg-tikz` with `GeometricFigures.build` at 300 dpi in both themes. Compiles
# SimpleSolvers' `docs/src/trust_region/dogleg_tikz_{light,dark}.tex`, as committed on its
# `origin/main`, the way its Makefile does: `pdflatex`, then `pdftocairo -png -r 300 -transp
# -singlefile`. Prints `magick compare -metric AE` for each theme, the number of pixels that
# differ, and exits 1 unless both are 0.
#
# Needs `pdflatex`, `pdftocairo`, `magick` and `git`. Compile both on one machine: TeX Live of
# another version renders other pixels.

using GeometricFigures

length(ARGS) == 1 ||
    error("usage: julia --project=. scripts/compare.jl <SimpleSolvers checkout>")
const SIMPLESOLVERS = abspath(ARGS[1])
const OLD = "docs/src/trust_region"

"The PNG of the old source of `theme`, compiled in `dir` the way SimpleSolvers' Makefile does."
function old_png(theme, dir)
    name = "dogleg_tikz_$(theme)"
    source = read(`git -C $(SIMPLESOLVERS) show origin/main:$(OLD)/$(name).tex`, String)
    write(joinpath(dir, name * ".tex"), source)
    run(pipeline(Cmd(`pdflatex -interaction=nonstopmode -halt-on-error $(name).tex`; dir);
        stdout = devnull))
    run(Cmd(`pdftocairo -png -r 300 -transp -singlefile $(name).pdf $(name)`; dir))
    return joinpath(dir, name * ".png")
end

"The number of pixels that differ between the PNGs `a` and `b`, as `magick compare` prints it."
function differing_pixels(a, b)
    err = IOBuffer()
    run(pipeline(ignorestatus(`magick compare -metric AE $(a) $(b) null:`); stderr = err))
    return strip(String(take!(err)))
end

new = GeometricFigures.build(mktempdir(); names = ["dogleg-tikz"])
old = mktempdir()
equal = map(("light", "dark")) do theme
    a = joinpath(new, "solvers", "dogleg-tikz", "png300", "dogleg-tikz_$(theme).png")
    b = old_png(theme, old)
    ae = differing_pixels(a, b)
    println("$(theme): magick compare -metric AE = $(ae)")
    return startswith(ae, "0") && (length(ae) == 1 || ae[2] == ' ')
end
all(equal) || exit(1)
