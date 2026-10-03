# Check that two consecutive builds give the same bytes.
#
#   julia --project=docs scripts/reproducible.jl [<name> ...]
#
# Runs `GeometricFigures.build` twice, into two directories, for the figures named, or for every
# figure without a name. Runs `cmp` on each of the 10 files of each figure: the PDF, the SVG and
# the PNGs at 150, 300 and 600 dpi, in both themes. Prints one line per file that differs, and
# exits 1 if one differs or is missing.

using GeometricFigures
using GeometricFigures: DPIS, THEMES, figure, figure_path

const NAMES = isempty(ARGS) ? [f.name for f in GeometricFigures.figures()] : ARGS

first_build = GeometricFigures.build(mktempdir(); names = NAMES)
second_build = GeometricFigures.build(mktempdir(); names = NAMES)

files = [figure_path(figure(name); theme, format, dpi)
         for name in NAMES, theme in THEMES
         for (format, dpi) in [("pdf", nothing); ("svg", nothing);
                               [("png", d) for d in DPIS]]]

differ = filter(files) do file
    a, b = joinpath(first_build, file), joinpath(second_build, file)
    same = isfile(a) && isfile(b) &&
           success(pipeline(`cmp -s $(a) $(b)`; stdout = devnull, stderr = devnull))
    same || println("differs: $(file)")
    return !same
end
println("$(length(files) - length(differ)) of $(length(files)) files identical in two builds")
isempty(differ) || exit(1)
