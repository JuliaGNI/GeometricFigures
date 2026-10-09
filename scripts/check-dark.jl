# Check that the dark theme of figures draws no dark foreground.
#
#   julia --project=docs scripts/check-dark.jl [<name> ...]
#
# Compiles the figures named, or every figure without a name, with `GeometricFigures.build`, and
# reads the dark PNG at 300 dpi of each. Counts its pixels that are opaque (alpha = 1) and darker
# than the dark background `bg`, #1F2424 of `geometricfigures.sty` (HSL lightness below that of
# `bg`, 0.13, by more than 0.02), except colour fills (HSL saturation >= 0.3). A `bg` mask, a grey
# `fg!<p>!bg` and a tint `<colour>!<p>!bg` are at least as light as the page and do not count; black
# does. Prints the count for each figure, and exits 1 if any count is above 0.
#
# Needs the engines of the figures, `pdftocairo` and `magick`.

using GeometricFigures
using GeometricFigures: figure, figure_path

"The HSL lightness and saturation of the 8-bit colour `r`, `g`, `b`."
function lightness_saturation(r, g, b)
    hi, lo = max(r, g, b) / 255, min(r, g, b) / 255
    l = (hi + lo) / 2
    s = hi == lo ? 0.0 : (hi - lo) / (1 - abs(2l - 1))
    return l, s
end

"The dark theme's `bg` of `geometricfigures.sty`, as 8-bit RGB, and its HSL lightness."
const BG = (0x1f, 0x24, 0x24)
const BG_LIGHTNESS = first(lightness_saturation(BG...))

"""
The number of opaque pixels of the PNG `path` with lightness < `BG_LIGHTNESS` - 0.02 and
saturation < 0.3.
"""
function dark_pixels(path)
    rgba = read(`magick $(path) -depth 8 rgba:-`)
    return count(Iterators.partition(rgba, 4)) do (r, g, b, a)
        l, s = lightness_saturation(r, g, b)
        return a == 0xff && l < BG_LIGHTNESS - 0.02 && s < 0.3
    end
end

const NAMES = isempty(ARGS) ? [f.name for f in GeometricFigures.figures()] : ARGS
foreach(figure, NAMES)

new = GeometricFigures.build(mktempdir(); names = NAMES)
counts = map(NAMES) do name
    n = dark_pixels(joinpath(new,
        figure_path(figure(name); theme = "dark", format = "png", dpi = 300)))
    println("$(name) dark: $(n) opaque pixels darker than the background outside colour fills")
    return n
end
all(iszero, counts) || exit(1)
