using GeometricFigures
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
