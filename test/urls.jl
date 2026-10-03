using GeometricFigures
using GeometricFigures: figures
using Test

const SITE = "https://juliagni.github.io/GeometricFigures/figures"

@testset "the URL of the seed figure" begin
    dir = "$SITE/solvers/dogleg-tikz"
    for theme in ("light", "dark")
        @test figure_url("dogleg-tikz"; theme, format = "pdf") ==
              "$dir/dogleg-tikz_$theme.pdf"
        @test figure_url("dogleg-tikz"; theme, format = "svg") ==
              "$dir/dogleg-tikz_$theme.svg"
        for dpi in (150, 300, 600)
            @test figure_url("dogleg-tikz"; theme, format = "png", dpi) ==
                  "$dir/png$dpi/dogleg-tikz_$theme.png"
        end
    end
end

@testset "the URL form of every figure: $(f.name)" for f in figures()
    dir = "$SITE/$(f.topic)/$(f.name)"
    for theme in ("light", "dark")
        for format in ("pdf", "svg")
            @test figure_url(f.name; theme, format) == "$dir/$(f.name)_$theme.$format"
        end
        for dpi in (150, 300, 600)
            @test figure_url(f.name; theme, format = "png", dpi) ==
                  "$dir/png$dpi/$(f.name)_$theme.png"
        end
    end
end

@testset "an unknown name" begin
    @test_throws ArgumentError figure_url("no-such-figure"; theme = "light", format = "svg")
    @test_throws ArgumentError figure_url("dogleg_tikz"; theme = "light", format = "svg")
    @test_throws ArgumentError figure_url(""; theme = "light", format = "svg")
end

@testset "an unknown theme" begin
    for theme in ("sepia", "Light", "", "light ")
        @test_throws ArgumentError figure_url("dogleg-tikz"; theme, format = "svg")
    end
end

@testset "an unknown format" begin
    for format in ("jpg", "PDF", "eps", "")
        @test_throws ArgumentError figure_url("dogleg-tikz"; theme = "light", format)
    end
end

@testset "a PNG without a DPI of 150, 300 or 600" begin
    @test_throws ArgumentError figure_url("dogleg-tikz"; theme = "light", format = "png")
    for dpi in (200, 72, 0, -300, 1200, 300.0, "300", true)
        @test_throws ArgumentError figure_url("dogleg-tikz"; theme = "dark", format = "png", dpi)
    end
end

@testset "a DPI on PDF or SVG" begin
    for format in ("pdf", "svg"), dpi in (150, 300, 600, 200)

        @test_throws ArgumentError figure_url("dogleg-tikz"; theme = "light", format, dpi)
    end
end
