# Build the site: compile every figure into docs/src/figures/, write one page per topic into
# docs/src/topics/, each opened by docs/topic-intros/<topic>.md where that file exists, and run
# Documenter. docs/src/figures/ and docs/src/topics/ are build products and are gitignored.
#
#   julia --project=docs docs/make.jl
#
# Needs the TeX engines and `pdftocairo` that `GeometricFigures.build` calls.

using Documenter
using GeometricFigures
using GeometricFigures: DPIS, THEMES, figure_path

const SRC = joinpath(@__DIR__, "src")
const FIGURES = joinpath(SRC, "figures")
const TOPICS = joinpath(SRC, "topics")
# An optional tracked introduction of a topic page, written below its heading. It is outside src/,
# so that Documenter does not also publish it as a page of its own.
const INTROS = joinpath(@__DIR__, "topic-intros")

# With pretty URLs a topic page is topics/<topic>/index.html, else topics/<topic>.html.
const PRETTY = get(ENV, "CI", nothing) == "true"
const UP = PRETTY ? "../../" : "../"

# actions/checkout makes a depth-1 clone, in which `build` throws: the commit time of a figure's
# last change, its SOURCE_DATE_EPOCH, needs the full history. A failed query, as where `git` is
# missing or the tree is in no repository, reads as not shallow: `build` then decides.
const ROOT = dirname(@__DIR__)
const SHALLOW = Cmd(`git rev-parse --is-shallow-repository`; dir = ROOT, ignorestatus = true)
if Sys.which("git") !== nothing && readchomp(pipeline(SHALLOW; stderr = devnull)) == "true"
    run(Cmd(`git fetch --unshallow`; dir = ROOT))
end

rm(FIGURES; force = true, recursive = true)
rm(TOPICS; force = true, recursive = true)
GeometricFigures.build(FIGURES)
mkpath(TOPICS)

html(text) = replace(text, "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", "\"" => "&quot;")
href(f, theme, format, dpi = nothing) = UP * "figures/" * figure_path(f; theme, format, dpi)

"The card of the figure `f`: the two previews, its name and caption, and the links to its files."
function card(f)
    links = map(THEMES) do theme
        pngs = join(
            ["""<a href="$(href(f, theme, "png", dpi))">$(dpi)</a>""" for dpi in DPIS],
            " · ")
        """<p>$(theme): <a href="$(href(f, theme, "pdf"))">PDF</a> · """ *
        """<a href="$(href(f, theme, "svg"))">SVG</a> · PNG $(pngs)</p>"""
    end
    return """
           ```@raw html
           <div style="display: flex; gap: 1em;">
           <div style="flex: 1; background: white; padding: 1em;"><img src="$(href(f, "light", "svg"))" alt="$(html(f.caption)) (light)"></div>
           <div style="flex: 1; background: black; padding: 1em;"><img src="$(href(f, "dark", "svg"))" alt="$(html(f.caption)) (dark)"></div>
           </div>
           <p><code>$(f.name)</code>: $(html(f.caption))</p>
           $(join(links, "\n"))
           ```
           """
end

topics = sort!(unique(f.topic for f in GeometricFigures.figures()))
for topic in topics
    open(joinpath(TOPICS, "$(topic).md"), "w") do io
        println(io, "# $(topic)\n")
        intro = joinpath(INTROS, "$(topic).md")
        isfile(intro) && println(io, read(intro, String))
        for f in GeometricFigures.figures()
            f.topic == topic || continue
            println(io, "## `$(f.name)`\n")
            println(io, card(f))
        end
    end
end

makedocs(;
    sitename = "GeometricFigures",
    modules = [GeometricFigures],
    checkdocs = :public,
    format = Documenter.HTML(; prettyurls = PRETTY),
    pages = ["Home" => "index.md", "Figures" => ["topics/$(topic).md" for topic in topics]]
)

deploydocs(;
    repo = "github.com/JuliaGNI/GeometricFigures.jl.git",
    devbranch = "main",
    versions = nothing
)
