# Compare figures with the original sources they replace, pixel by pixel.
#
#   julia --project=docs scripts/compare.jl [<name> ...]
#
# Takes the figures named, or without a name every figure that has an entry in
# `scripts/references.toml`. Compiles each figure with `GeometricFigures.build` in both themes.
# Compiles each original of `references.toml` the old way: in a copy of its source's directory on
# its repository's `origin/main`, so that `\input`, a `.sty` and raster inputs resolve, with the
# entry's `untracked` files copied in from the local working tree, by the entry's engine, `runs`
# times in that directory (1 where the entry gives no `runs`). Renders the new and the old PDF
# alike, `pdftocairo -png -transp -r <dpi> -singlefile`, at the entry's DPI, which can be outside
# the 150, 300 and 600 of `build`. Prints `magick compare -metric AE`, the number of pixels that
# differ, for each entry, and "no original" for a theme that has no entry. Exits 1 unless every AE
# is 0.
#
# The checkout of an entry's `repository` is the directory of that name in `~/Research/Packages`
# or `~/Research/Experiments`. The script reads `origin/main` as the checkout last fetched it.
#
# Needs `xelatex`, `pdflatex`, `pdftocairo`, `magick`, `git` and `tar`. Compile both on one
# machine: TeX Live of another version renders other pixels.

using GeometricFigures
using GeometricFigures: THEMES, figure, figure_path
using TOML

const REFERENCES = TOML.parsefile(joinpath(@__DIR__, "references.toml"))["reference"]
const CHECKOUTS = [joinpath(homedir(), "Research", d) for d in ("Packages", "Experiments")]

"The local checkout of the repository `name`, in one of the directories of `CHECKOUTS`."
function checkout(name)
    found = filter(isdir, [joinpath(dir, name) for dir in CHECKOUTS])
    length(found) == 1 ||
        error("the checkout $(name) is in $(length(found)) of the directories " *
              "$(join(CHECKOUTS, ", "))")
    return only(found)
end

"""
The PDF of the original source of `ref`, compiled the old way in `dir`: a copy of the source's
directory on `origin/main`, with the `untracked` files of the local working tree.
"""
function old_pdf(ref, dir)
    repo = checkout(ref["repository"])
    sourcedir, file = dirname(ref["path"]), basename(ref["path"])
    run(pipeline(`git -C $(repo) archive --format=tar origin/main:$(sourcedir)`,
        `tar -x -C $(dir)`))
    for path in get(ref, "untracked", String[])
        cp(joinpath(repo, sourcedir, path), joinpath(dir, path); force = true)
    end
    cmd = `$(ref["engine"]) -no-shell-escape -interaction=nonstopmode -halt-on-error $(file)`
    for _ in 1:get(ref, "runs", 1)
        run(pipeline(Cmd(cmd; dir); stdout = devnull))
    end
    return joinpath(dir, first(splitext(file)) * ".pdf")
end

"The PNG of `pdf` at `dpi`, rendered with the flags of `build`, in `dir`."
function png(pdf, dpi, dir)
    stem = joinpath(dir, first(splitext(basename(pdf))))
    run(`pdftocairo -png -transp -r $(dpi) -singlefile $(pdf) $(stem)`)
    return stem * ".png"
end

"The number of pixels that differ between the PNGs `a` and `b`, as `magick compare` prints it."
function differing_pixels(a, b)
    err = IOBuffer()
    run(pipeline(ignorestatus(`magick compare -metric AE $(a) $(b) null:`); stderr = err))
    return strip(String(take!(err)))
end

const NAMES = isempty(ARGS) ? unique(ref["name"] for ref in REFERENCES) : ARGS
foreach(figure, NAMES)

new = GeometricFigures.build(mktempdir(); names = NAMES)
equal = Bool[]
for name in NAMES, theme in THEMES

    refs = filter(ref -> ref["name"] == name && ref["theme"] == theme, REFERENCES)
    isempty(refs) && println("$(name) $(theme): no original")
    for ref in refs
        newpdf = joinpath(new, figure_path(figure(name); theme, format = "pdf"))
        a = png(newpdf, ref["dpi"], mktempdir())
        b = png(old_pdf(ref, mktempdir()), ref["dpi"], mktempdir())
        ae = differing_pixels(a, b)
        println("$(name) $(theme) against $(ref["repository"]):$(ref["path"]) at " *
                "$(ref["dpi"]) dpi: magick compare -metric AE = $(ae)")
        push!(equal, startswith(ae, "0") && (length(ae) == 1 || ae[2] == ' '))
    end
end
all(equal) || exit(1)
