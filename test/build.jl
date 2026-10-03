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
# where `script` is `nothing`), the `file => text` pairs of `files` beside it, and an engine in
# place of TeX: a shell script (a batch file on Windows) that succeeds only where the file `marker`
# is in its working directory. Calls `test(f, workdir)`.
function with_fixture(test, name, script, files = ())
    mktempdir() do root
        dir = joinpath(root, "topic", name)
        mkpath(dir)
        write(joinpath(dir, name * ".tex"), "")
        script === nothing || write(joinpath(dir, name * ".jl"), script)
        for (file, text) in files
            write(joinpath(dir, file), text)
        end
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
    # The first script defines a global. Neither `Main` nor the package holds it after the
    # build, and the second script writes the marker only where it does not see it.
    defines = "leaked_by_a_script = 1\nwrite(\"marker\", \"\")\n"
    checks = "isdefined(@__MODULE__, :leaked_by_a_script) || write(\"marker\", \"\")\n"
    with_fixture("module-figure", defines) do f, workdir
        compile(f, "dark", workdir)
        @test isfile(joinpath(workdir, "marker"))
    end
    @test !isdefined(Main, :leaked_by_a_script)
    @test !isdefined(GeometricFigures, :leaked_by_a_script)
    with_fixture("second-figure", checks) do f, workdir
        @test compile(f, "dark", workdir) == joinpath(workdir, "second-figure_dark.pdf")
    end
end

@testset "a figure's script can include a file beside it" begin
    # The helper includes a second helper, which defines a global in the script's module.
    with_fixture("helped-figure",
        "include(\"helper.jl\")\nisdefined(@__MODULE__, :defined_by_a_helper) && " *
        "write(\"marker\", \"\")\n",
        ["helper.jl" => "include(\"inner.jl\")\n",
            "inner.jl" => "defined_by_a_helper = 1\n"]) do f, workdir
        @test compile(f, "light", workdir) == joinpath(workdir, "helped-figure_light.pdf")
    end
    @test !isdefined(Main, :defined_by_a_helper)
    @test !isdefined(GeometricFigures, :defined_by_a_helper)
    # The two-argument form applies its function to each expression of the helper.
    with_fixture(
        "mapped-figure", "include(_ -> :(write(\"marker\", \"\")), \"helper.jl\")\n",
        ["helper.jl" => "nothing\n"]) do f, workdir
        @test compile(f, "light", workdir) == joinpath(workdir, "mapped-figure_light.pdf")
    end
end

@testset "a figure's script can eval in its own module" begin
    with_fixture("eval-figure",
        "eval(:(defined_by_eval = 1))\n@eval write(\"marker\", \"\")\n") do f, workdir
        @test compile(f, "light", workdir) == joinpath(workdir, "eval-figure_light.pdf")
    end
    @test !isdefined(Main, :defined_by_eval)
    @test !isdefined(GeometricFigures, :defined_by_eval)
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

@testset "an interrupt in a script stays an interrupt" begin
    with_fixture("interrupted-figure", "throw(InterruptException())\n") do f, workdir
        @test_throws InterruptException compile(f, "light", workdir)
    end
    # Each `include` adds a `LoadError` around it.
    with_fixture("nested-interrupt", "include(\"helper.jl\")\n",
        ["helper.jl" => "include(\"inner.jl\")\n",
            "inner.jl" => "throw(InterruptException())\n"]) do f, workdir
        @test_throws InterruptException compile(f, "light", workdir)
    end
end
