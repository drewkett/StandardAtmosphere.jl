module StandardAtmosphere

export Atm, Env, kcas, keas, ktas, mach

import Base: show, *

using SIUnits
using SIUnits.ShortUnits

include("atm.jl")
include("env.jl")

end # module
