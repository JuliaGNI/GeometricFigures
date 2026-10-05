# Check that the dark theme of figures draws no dark foreground.
#
#   julia --project=docs scripts/check-dark.jl [<name> ...]
#
# Compiles the figures named, or every figure without a name, with `GeometricFigures.build`, and
# reads the dark PNG at 300 dpi of each. Counts its pixels that are opaque (alpha = 1) and darker
# than 25 % grey (HSL lightness < 0.25), except colour fills (HSL saturation >= 0.3) and the dark
# background `bg` itself, #1F2424 of `geometricfigures.sty`, within 2 per 8-bit channel: a `bg` mask
# is the page colour, not a foreground. Prints the count for each figure, and exits 1 if any count
# is above 0.
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

"The dark theme's `bg` of `geometricfigures.sty`, as 8-bit RGB."
const BG = (0x1f, 0x24, 0x24)

"Whether the 8-bit colour `r`, `g`, `b` is `BG` within 2 per channel."
is_bg(r, g, b) = all(abs(Int(c) - Int(c0)) <= 2 for (c, c0) in zip((r, g, b), BG))

"""
The number of opaque pixels of the PNG `path` with lightness < 0.25 and saturation < 0.3 that
are not `BG`.
"""
function dark_pixels(path)
    rgba = read(`magick $(path) -depth 8 rgba:-`)
    return count(Iterators.partition(rgba, 4)) do (r, g, b, a)
        l, s = lightness_saturation(r, g, b)
        return a == 0xff && l < 0.25 && s < 0.3 && !is_bg(r, g, b)
    end
end

const NAMES = isempty(ARGS) ? [f.name for f in GeometricFigures.figures()] : ARGS
foreach(figure, NAMES)

new = GeometricFigures.build(mktempdir(); names = NAMES)
counts = map(NAMES) do name
    n = dark_pixels(joinpath(new,
        figure_path(figure(name); theme = "dark", format = "png", dpi = 300)))
    println("$(name) dark: $(n) opaque pixels darker than 25 % grey outside colour fills")
    return n
end
all(iszero, counts) || exit(1)
