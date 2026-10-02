using GeometricFigures: source_date_epoch
using Test

# Each case builds its own repository in a temporary directory, with fixed commit times.
function git(dir, args...; time = nothing)
    env = ["LC_ALL" => "C", "GIT_AUTHOR_NAME" => "t", "GIT_AUTHOR_EMAIL" => "t@t",
        "GIT_COMMITTER_NAME" => "t", "GIT_COMMITTER_EMAIL" => "t@t"]
    time === nothing || push!(env, "GIT_COMMITTER_DATE" => "@$(time) +0000")
    run(addenv(Cmd(`git -c commit.gpgsign=false $(args)`; dir), env...))
end

# A repository with `a/f` committed at 1000000000 and `b` committed later, at 1100000000.
function repository(root)
    repo = joinpath(root, "repo")
    mkpath(joinpath(repo, "a"))
    git(repo, "init", "-q", ".")
    write(joinpath(repo, "a", "f"), "x")
    git(repo, "add", "a")
    git(repo, "commit", "-q", "-m", "a"; time = 1000000000)
    write(joinpath(repo, "b"), "y")
    git(repo, "add", "b")
    git(repo, "commit", "-q", "-m", "b"; time = 1100000000)
    return repo
end

@testset "the epoch is the commit time of the directory's last change" begin
    mktempdir() do root
        repo = repository(root)
        @test source_date_epoch(joinpath(repo, "a")) == 1000000000
        @test source_date_epoch(joinpath(repo, "a") * "/") == 1000000000
        @test source_date_epoch(repo) == 1100000000
    end
end

@testset "the epoch is 0 for a directory in no repository" begin
    mktempdir() do root
        @test source_date_epoch(root) == 0
    end
end

@testset "the epoch is 0 for a source with no commit yet" begin
    mktempdir() do root
        # A repository without any commit.
        empty = joinpath(root, "empty")
        mkpath(empty)
        git(empty, "init", "-q", ".")
        write(joinpath(empty, "f"), "x")
        @test source_date_epoch(empty) == 0
        # An uncommitted directory in a repository with commits.
        repo = repository(root)
        mkpath(joinpath(repo, "new"))
        write(joinpath(repo, "new", "f"), "x")
        @test source_date_epoch(joinpath(repo, "new")) == 0
    end
end

@testset "the epoch throws in a shallow clone" begin
    mktempdir() do root
        repo = repository(root)
        git(root, "clone", "-q", "--depth", "1", "file://" * repo, "shallow")
        @test_throws ErrorException source_date_epoch(joinpath(root, "shallow", "a"))
    end
end

@testset "the epoch throws on any other git failure" begin
    mktempdir() do root
        repo = repository(root)
        # Delete the loose objects: HEAD still names a commit, which git can no longer read.
        objects = joinpath(repo, ".git", "objects")
        for d in readdir(objects)
            occursin(r"^[0-9a-f]{2}$", d) && rm(joinpath(objects, d); recursive = true)
        end
        @test_throws ErrorException source_date_epoch(joinpath(repo, "a"))
    end
end
