# Writes rosenbrock_naked.png, an input of grassmann-sampling.tex, into the working directory.
# `GeometricFigures.build` runs it before TeX, in the build copy of this directory, with CairoMakie
# from docs/Project.toml.
using CairoMakie
CairoMakie.activate!()

rosenbrock(x::Vector) = ((1.0 - x[1]) ^ 2 + 100.0 * (x[2] - x[1] ^ 2) ^ 2) / 1000
x, y = -1.5:0.1:1.5, -1.5:0.1:1.5
z = [rosenbrock([x, y]) for x in x, y in y]
function make_rosenbrock(; alpha = 0.7)
    textcolor = :black
    fig = Figure(; backgroundcolor = :transparent, size = (900, 675))
    ax = Axis3(fig[1, 1];
        limits = ((-1.5, 1.5), (-1.5, 1.5), (0.0, rosenbrock([-1.5, -1.5]))),
        azimuth = π / 6,
        elevation = π / 8,
        backgroundcolor = (:tomato, 0.5),
        xgridcolor = textcolor,
        ygridcolor = textcolor,
        zgridcolor = textcolor,
        xtickcolor = textcolor,
        ytickcolor = textcolor,
        ztickcolor = textcolor,
        xticklabelcolor = textcolor,
        yticklabelcolor = textcolor,
        zticklabelcolor = textcolor,
        xypanelcolor = :transparent,
        xzpanelcolor = :transparent,
        yzpanelcolor = :transparent,
        xlabel = L"x",
        ylabel = L"y",
        zlabel = L"z",
        xlabelcolor = textcolor,
        ylabelcolor = textcolor,
        zlabelcolor = textcolor)
    surface!(ax, x, y, z; alpha = alpha, transparency = true)

    fig, ax
end

fig_light, ax_light = make_rosenbrock()
hidedecorations!(ax_light)
hidespines!(ax_light)
save("rosenbrock_naked.png", fig_light)
