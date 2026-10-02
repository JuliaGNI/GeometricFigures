"""
    source_date_epoch(dir) -> Int

The commit time of the last change under `dir`, in seconds since the epoch; 0 where `git` is
missing, where `dir` is in no repository, or where nothing under `dir` is committed.
"""
function source_date_epoch(dir::AbstractString)
    git = Sys.which("git")
    git === nothing && return 0
    out = IOBuffer()
    cmd = Cmd(`$(git) log -1 --format=%ct -- .`; dir, ignorestatus = true)
    p = run(pipeline(cmd; stdout = out, stderr = devnull))
    time = strip(String(take!(out)))
    return success(p) && !isempty(time) ? parse(Int, time) : 0
end

"""
    compile(f::Figure, theme, workdir) -> String

Compile the source of `f` in `theme` in `workdir`, an empty directory, and return the path of the
PDF. The engine runs twice, in a copy of the source's own directory, so that `\\includegraphics`
takes a name relative to the source. The copy keeps the absolute path of the work directory out of
the PDF: both engines hash the path of their output into its `/ID`. The dark theme has
`\\def\\darkmode{}` prepended. Throws an error that names the figure and quotes the last 20 lines
of the log when a run fails.
"""
function compile(f::Figure, theme::AbstractString, workdir::AbstractString)
    for file in readdir(source_dir(f))
        cp(joinpath(source_dir(f), file), joinpath(workdir, file))
    end
    job = "$(f.name)_$(theme)"
    prefix = theme == "dark" ? "\\def\\darkmode{}" : ""
    input = prefix * "\\input{$(f.name).tex}"
    cmd = `$(f.engine) -no-shell-escape -interaction=nonstopmode -halt-on-error
           -jobname=$(job) $(input)`
    cmd = addenv(Cmd(cmd; dir = workdir),
        "SOURCE_DATE_EPOCH" => string(source_date_epoch(source_dir(f))),
        "FORCE_SOURCE_DATE" => "1",
        "TEXINPUTS" => SOURCE_DIR * (Sys.iswindows() ? ";" : ":"))
    for _ in 1:2
        success(pipeline(cmd; stdout = devnull, stderr = devnull)) && continue
        log = joinpath(workdir, job * ".log")
        tail = isfile(log) ? join(last(readlines(log), 20), "\n") : "(no log at $(log))"
        error("the figure $(f.name) ($(theme)) does not compile with $(f.engine); " *
              "the last 20 lines of its log:\n$(tail)")
    end
    return joinpath(workdir, job * ".pdf")
end

"The path of one output of `f` under `outdir`, with its directory made."
function output(outdir, f::Figure, theme, format, dpi = nothing)
    path = joinpath(outdir, figure_path(f; theme, format, dpi))
    mkpath(dirname(path))
    return path
end

"""
    GeometricFigures.build(outdir; names = [f.name for f in figures()]) -> outdir

Compile the figures `names` into `outdir`, each in both themes, and convert each PDF into an SVG
and into transparent PNGs at 150, 300 and 600 dpi. The files are

    <outdir>/<topic>/<name>/<name>_<theme>.pdf
    <outdir>/<topic>/<name>/<name>_<theme>.svg
    <outdir>/<topic>/<name>/png<dpi>/<name>_<theme>.png

which is the layout of the published `figures/` directory (see [`figure_url`](@ref)). Two builds
of the same commit give the same bytes: `SOURCE_DATE_EPOCH` is the commit time of the figure's last
change.

Needs the engine of each figure, `xelatex` or `pdflatex`, and `pdftocairo` from Poppler. Throws an
`ArgumentError` for an unknown name, and an error that names the figure and quotes the last 20
lines of its log when a source does not compile.
"""
function build(outdir::AbstractString; names = [f.name for f in figures()])
    selected = [figure(string(name)) for name in names]
    for f in selected, theme in THEMES

        mktempdir() do workdir
            pdf = compile(f, theme, workdir)
            cp(pdf, output(outdir, f, theme, "pdf"); force = true)
            run(`pdftocairo -svg $(pdf) $(output(outdir, f, theme, "svg"))`)
            for dpi in DPIS
                png = output(outdir, f, theme, "png", dpi)
                run(`pdftocairo -png -transp -r $(dpi) -singlefile $(pdf) $(first(splitext(png)))`)
            end
        end
    end
    return outdir
end
