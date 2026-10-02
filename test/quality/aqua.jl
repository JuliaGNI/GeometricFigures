# Aqua.jl quality-assurance checks. See https://github.com/JuliaTesting/Aqua.jl.

using Aqua
using GeometricFigures
using Test

Aqua.test_all(GeometricFigures)
