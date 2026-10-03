using GeometricFigures
using GeometricFigures: Figure, SOURCE_DIR, compile
using Test

@testset "build names a tool that is not on the PATH" begin
    f = first(GeometricFigures.figures())
    mktempdir() do dir
        withenv("PATH" => dir) do
            @test_throws "`$(f.engine)` is not on the PATH" GeometricFigures.build(
                dir; names = [f.name])
        end
    end
end

# A figure `name` in a temporary directory, with the source `script` as its `<name>.jl` (none
# where `script` is `nothing`), and an engine in place of TeX: a shell script (a batch file on
# Windows) that succeeds only where the file `marker` is in its working directory. Calls
# `test(f, workdir)`.
function with_fixture(test, name, script)
    mktempdir() do root
        dir = joinpath(root, "topic", name)
        mkpath(dir)
        write(joinpath(dir, name * ".tex"), "")
        script === nothing || write(joinpath(dir, name * ".jl"), script)
        if Sys.iswindows()
            engine = joinpath(root, "engine.bat")
            write(engine, "@if exist marker (exit /b 0) else (exit /b 1)\r\n")
        else
            engine = joinpath(root, "engine")
            write(engine, "#!/bin/sh\ntest -f marker\n")
        end
        chmod(engine, 0o755)
        f = Figure(name, relpath(joinpath(root, "topic"), SOURCE_DIR), "", engine)
        mktempdir(workdir -> test(f, workdir))
    end
end

@testset "build runs a figure's script in the build copy before TeX" begin
    with_fixture("marker-figure", "write(\"marker\", \"\")\n") do f, workdir
        @test compile(f, "light", workdir) == joinpath(workdir, "marker-figure_light.pdf")
        @test isfile(joinpath(workdir, "marker"))
        @test !isfile(joinpath(GeometricFigures.source_dir(f), "marker"))
    end
end

@testset "build runs a figure's script in a new module" begin
    # The script writes the marker only where it sees neither the package's `SOURCE_DIR` nor
    # this file's `with_fixture`.
    script = "isdefined(@__MODULE__, :SOURCE_DIR) || isdefined(@__MODULE__, :with_fixture) ||\n" *
             "    write(\"marker\", \"\")\n"
    with_fixture("module-figure", script) do f, workdir
        compile(f, "dark", workdir)
        @test isfile(joinpath(workdir, "marker"))
    end
end

@testset "build runs no Julia for a figure without a script" begin
    with_fixture("plain-figure", nothing) do f, workdir
        @test_throws "the figure plain-figure (light) does not compile" compile(
            f, "light", workdir)
    end
end

@testset "a script that throws makes build throw, naming the figure" begin
    with_fixture("throwing-figure", "error(\"no raster\")\n") do f, workdir
        @test_throws r"throwing-figure.*no raster"s compile(f, "light", workdir)
    end
    with_fixture("loading-figure", "using NoSuchPackageForGeometricFigures\n") do f, workdir
        @test_throws r"loading-figure.*NoSuchPackageForGeometricFigures"s compile(
            f, "light", workdir)
    end
end
