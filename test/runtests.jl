using SafeTestsets

const GROUPS = isempty(ARGS) ? ["core", "slow"] : ARGS

if "core" in GROUPS
    @safetestset "Aqua" include("quality/aqua.jl")
    @safetestset "Manifest" include("manifest.jl")
    @safetestset "URLs" include("urls.jl")
    @safetestset "Source date epoch" include("integration/epoch.jl")
    @safetestset "Build" include("build.jl")
end
