module RiskMeasures

# Write your package code here.

include("general.jl")

include("distribution.jl")
export Distribution, uniform, mean

include("var.jl")
export var

include("cvar.jl")
export cvar
    
include("erm.jl")
export erm

include("evar.jl")
export evar

end
