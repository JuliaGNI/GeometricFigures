"""
    Figure

One entry of the manifest `src/figures.toml`: the figure's `name`, its `topic`, its `caption`, and
the TeX `engine` that compiles it. The source is `src/<topic>/<name>/<name>.tex`.
"""
struct Figure
    name::String
    topic::String
    caption::String
    engine::String
end

"""
    read_manifest(path = MANIFEST) -> Vector{Figure}

The entries of the manifest at `path`, in the order of the file. An entry without an `engine`
compiles with `xelatex`.
"""
function read_manifest(path::AbstractString = MANIFEST)
    entries = get(TOML.parsefile(path), "figure", Any[])
    return [Figure(e["name"], e["topic"], e["caption"], get(e, "engine", "xelatex"))
            for e in entries]
end

"""
    GeometricFigures.figures() -> Vector{Figure}

Every figure of the manifest, in the order of the file. Each has the fields `name`, `topic`,
`caption` and `engine`.
"""
figures() = read_manifest()

"""
    figure(name) -> Figure

The manifest entry of the figure `name`. Throws an `ArgumentError` for an unknown name.
"""
function figure(name::AbstractString)
    for f in figures()
        f.name == name && return f
    end
    throw(ArgumentError("unknown figure $(repr(name)); the names are in $(MANIFEST)"))
end

"The directory of the source of `f`, which also holds its raster inputs."
source_dir(f::Figure) = joinpath(SOURCE_DIR, f.topic, f.name)
