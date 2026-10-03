"""
    figure_path(f::Figure; theme, format, dpi = nothing) -> String

The path of one output of `f`, relative to the directory that [`GeometricFigures.build`](@ref)
writes into and to the published `figures/` directory: `<topic>/<name>/<name>_<theme>.<format>`
for PDF and SVG, and `<topic>/<name>/png<dpi>/<name>_<theme>.png` for PNG. Throws an
`ArgumentError` for an unknown theme or format, for a PNG without a `dpi` of 150, 300 or 600, and
for a `dpi` on PDF or SVG.
"""
function figure_path(f::Figure; theme, format, dpi = nothing)
    theme = string(theme)
    format = string(format)
    theme in THEMES ||
        throw(ArgumentError("unknown theme $(repr(theme)); the themes are $(join(THEMES, ", "))"))
    format in FORMATS ||
        throw(ArgumentError("unknown format $(repr(format)); the formats are $(join(FORMATS, ", "))"))
    file = "$(f.name)_$(theme)"
    if format == "png"
        dpi isa Integer && dpi in DPIS ||
            throw(ArgumentError("a PNG needs `dpi` of $(join(DPIS, ", ", " or ")); got $(repr(dpi))"))
        return "$(f.topic)/$(f.name)/png$(dpi)/$(file).png"
    end
    dpi === nothing ||
        throw(ArgumentError("`dpi` applies to a PNG only; got dpi = $(repr(dpi)) for $(format)"))
    return "$(f.topic)/$(f.name)/$(file).$(format)"
end

"""
    figure_url(name; theme, format, dpi = nothing) -> String

The published address of the figure `name` in the `theme` `"light"` or `"dark"`, as `"pdf"`,
`"svg"` or `"png"`; a PNG takes a `dpi` of 150, 300 or 600:

```julia
figure_url("dogleg-tikz"; theme = "dark", format = "svg")
# "https://juliagni.github.io/GeometricFigures.jl/figures/solvers/dogleg-tikz/dogleg-tikz_dark.svg"

figure_url("dogleg-tikz"; theme = "light", format = "png", dpi = 300)
# "https://juliagni.github.io/GeometricFigures.jl/figures/solvers/dogleg-tikz/png300/dogleg-tikz_light.png"
```

Throws an `ArgumentError` for an unknown name, theme or format, for a PNG without a `dpi` of 150,
300 or 600, and for a `dpi` on PDF or SVG.
"""
function figure_url(name; theme, format, dpi = nothing)
    return "$(SITE)/" * figure_path(figure(string(name)); theme, format, dpi)
end
