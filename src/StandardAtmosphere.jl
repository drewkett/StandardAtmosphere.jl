module StandardAtmosphere

export Atm

using JSON
using Base.Test
import Base: show

using MySIUnits
import MySIUnits: SILength, SITemperature, SIPressure, SIDensity, SIVelocity, N, LengthUnit, TemperatureUnit

immutable Atm
    altitude::SILength{Float64}
    delta_temperature::SITemperature{Float64}
    temperature::SITemperature{Float64}
    temperature_ratio::Float64
    pressure::SIPressure{Float64}
    pressure_ratio::Float64
    density::SIDensity{Float64}
    density_ratio::Float64
    speed_of_sound::SIVelocity{Float64}
end


SeaLevelTemperature = 288.2K
SeaLevelDensity = 1.225kg/m^3
SeaLevelPressure = 101325N/m^2
SeaLevelSpeedOfSound = 340.294m/s
function Atm(altitude::SILength{Float64},delta_temperature::SITemperature{Float64} = 0.0K)
    if (altitude < 36089.24ft)
        temperature_ratio = (1-altitude/145445.6ft);
        pressure_ratio = temperature_ratio^5.2561;
        density_ratio = temperature_ratio^4.2561;
    else
        temperature_ratio = 0.75187;
        pressure_ratio = 0.22336*exp(-(altitude-36089.24ft)/20806.03ft);
        density_ratio = pressure_ratio/0.75187;
    end
    delta_temperature_ratio = 1+delta_temperature/(temperature_ratio*SeaLevelTemperature);
    temperature_ratio *= delta_temperature_ratio;
    density_ratio /= delta_temperature_ratio;

    temperature = temperature_ratio * SeaLevelTemperature;
    density = density_ratio * SeaLevelDensity;
    pressure = pressure_ratio * SeaLevelPressure;

    speed_of_sound = SeaLevelSpeedOfSound*sqrt(pressure_ratio);
    Atm(altitude,
        delta_temperature,
        temperature,
        temperature_ratio,
        pressure,
        pressure_ratio,
        density,
        density_ratio,
        speed_of_sound)
end

function show(io::IO,atm::Atm)
    print(io,"Atm(")
    print(io,"Altitude=",round(atm.altitude,1),", ")
    print(io,"Temperature=",round(atm.temperature,1),", ")
    print(io,"Pressure=",round(atm.pressure,1),", ")
    print(io,"Density=",round(atm.density,3),")")
end

function Atm{N1<:Real,N2<:Real,U1<:LengthUnit,U2<:TemperatureUnit}(altitude::Quantity{N1,U1},delta_temperature::Quantity{N2,U2} = 0.0K)
    Atm(convert(SIQuantity{Float64},altitude),convert(SIQuantity{Float64},delta_temperature))
end

include("env.jl")

end # module
