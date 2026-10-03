using GeometricFigures
using GeometricFigures: ENGINES, SOURCE_DIR, figures, read_manifest
using Test

const ENTRIES = figures()
const NAMES = [f.name for f in ENTRIES]

# A source is `src/<topic>/<name>/<name>.tex`; any other file of that directory is an input, or
# the script `<name>.jl` that writes one.
const SOURCES = [(topic, name)
                 for topic in readdir(SOURCE_DIR)
                 if isdir(joinpath(SOURCE_DIR, topic))
                 for name in readdir(joinpath(SOURCE_DIR, topic))
                 if isfile(joinpath(SOURCE_DIR, topic, name, name * ".tex"))]

@testset "the manifest is not empty" begin
    @test !isempty(ENTRIES)
    @test !isempty(SOURCES)
end

@testset "every entry has its source: $(f.name)" for f in ENTRIES
    @test isfile(joinpath(SOURCE_DIR, f.topic, f.name, f.name * ".tex"))
end

@testset "every source has one entry: $topic/$name" for (topic, name) in SOURCES
    @test count(f -> f.topic == topic && f.name == name, ENTRIES) == 1
end

@testset "names are unique" begin
    @test allunique(NAMES)
end

@testset "a name contains no underscore: $name" for name in NAMES
    @test !isempty(name)
    @test !occursin('_', name)
end

@testset "the engine is xelatex or pdflatex: $(f.name)" for f in ENTRIES
    @test f.engine in ENGINES
end

@testset "a caption is given: $(f.name)" for f in ENTRIES
    @test !isempty(strip(f.caption))
end

@testset "an entry without an engine compiles with xelatex" begin
    path = tempname() * ".toml"
    write(path,
        """
        [[figure]]
        name = "a-figure"
        topic = "a-topic"
        caption = "A figure."

        [[figure]]
        name = "b-figure"
        topic = "a-topic"
        caption = "B figure."
        engine = "pdflatex"
        """)
    entries = read_manifest(path)
    rm(path)
    @test [f.engine for f in entries] == ["xelatex", "pdflatex"]
    @test [f.name for f in entries] == ["a-figure", "b-figure"]
    @test [f.topic for f in entries] == ["a-topic", "a-topic"]
    @test [f.caption for f in entries] == ["A figure.", "B figure."]
end
