immutable Atm
    altitude::@quantity(Float64,Meter)
    delta_temperature::@quantity(Float64,Kelvin)
    temperature::@quantity(Float64,Kelvin)
    temperature_ratio::Float64
    pressure::@quantity(Float64,N/m^2)
    pressure_ratio::Float64
    density::@quantity(Float64,kg/m^3)
    density_ratio::Float64
    speed_of_sound::@quantity(Float64,m/s)
end


SeaLevelTemperature = 288.15K
SeaLevelDensity = 1.225kg/m^3
SeaLevelPressure = 101327.0N/m^2
SeaLevelSpeedOfSound = 340.2979m/s
LowerStratosphereTemperature = 216.649K
LowerStratosphereTemperatureRatio = LowerStratosphereTemperature/SeaLevelTemperature
LowerStratospherePressure = 22633.0N/m^2
LowerStratospherePressureRatio = LowerStratospherePressure/SeaLevelPressure
HydrostaticConstant = 34.163195K/m

function Atm(altitude::@quantity(Float64,Meter),delta_temperature::@quantity(Float64,Kelvin) = 0.0K)
    # http://www.pdas.com/programs/atmos.f90
    if (altitude < 11000m)
        temperature_ratio = 1 - altitude/11000m*(1-LowerStratosphereTemperatureRatio);
        pressure_ratio = temperature_ratio^(HydroStaticConstant/(6.5K/m));
    elseif altitude < 25000m
        temperature_ratio = LowerStratosphereTemperatureRatio;
        pressure_ratio = LowerStratospherePressureRatio*exp(-HydrostaticConstant*(altitude-11000m)/LowerStratosphereTemperature);
    else
        throw(ErrorException("Atmosphere above 25000m not supported"))
    end
    density_ratio = pressure_ratio/temperature_ratio;
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

# function Atm{N1<:Real,N2<:Real,U1<:LengthUnit,U2<:TemperatureUnit}(altitude::Quantity{N1,U1},delta_temperature::Quantity{N2,U2} = 0.0K)
#     Atm(convert(SIQuantity{Float64},altitude),convert(SIQuantity{Float64},delta_temperature))
# end
