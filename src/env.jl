immutable AirspeedType{str} end
kcas = AirspeedType{:kcas}()
keas = AirspeedType{:keas}()
ktas = AirspeedType{:ktas}()
mach = AirspeedType{:mach}()

type Airspeed{T}
    val::Float64
    Airspeed(v) = typeof(T)<:AirspeedType ? new{T}(v) : error("Invalid Airspeed Type")
end

show{T}(io::IO,::AirspeedType{T}) = print(io,T)
show{T}(io::IO,a::Airspeed{T}) = print(io,a.val,T)
*{T}(x::Real,t::AirspeedType{T}) = Airspeed{t}(x)

immutable Env
    atm::Atm
    calibrated_airspeed::@quantity(Float64,m/s)
    equivalent_airspeed::@quantity(Float64,m/s)
    true_airspeed::@quantity(Float64,m/s)
    mach_number::Float64
    q::@quantity(Float64,N/m^2)
end

function calc_calibrated(mach_number::Float64,pressure_ratio::Float64)
     sqrt(5*((((0.2*mach_number^2+1)^3.5 - 1)*pressure_ratio+1)^(1/3.5) - 1))*SeaLevelSpeedOfSound
end

function calc_mach(calibrated_airspeed::@quantity(Float64,m/s),pressure_ratio::Float64)
    sqrt(5*((((0.2*(calibrated_airspeed/SeaLevelSpeedOfSound)^2+1)^3.5 - 1)/pressure_ratio+1)^(1/3.5) - 1))
end

function Env(airspeed::Airspeed{kcas},altitude::@quantity(Float64,m),delta_temperature::@quantity(Float64,K) = 0.0K)
    atm = Atm(altitude,delta_temperature)
    calibrated_airspeed = convert(SIQuantity,airspeed.val*knots)
    mach_number = calc_mach(calibrated_airspeed,atm.pressure_ratio)
    equivalent_airspeed = atm.speed_of_sound*mach_number
    true_airspeed = equivalent_airspeed/sqrt(atm.density_ratio)
    q = 0.5*atm.density*true_airspeed^2
    Env(atm,calibrated_airspeed,equivalent_airspeed,true_airspeed,mach_number,q)
end

function Env(airspeed::Airspeed{mach},altitude::@quantity(Float64,m),delta_temperature::@quantity(Float64,K) = 0.0K)
    atm = Atm(altitude,delta_temperature)
    mach_number = airspeed.val
    calibrated_airspeed = calc_calibrated(mach_number,atm.pressure_ratio)
    equivalent_airspeed = atm.speed_of_sound*mach_number
    true_airspeed = equivalent_airspeed/sqrt(atm.density_ratio)
    q = 0.5*atm.density*true_airspeed^2
    Env(atm,calibrated_airspeed,equivalent_airspeed,true_airspeed,mach_number,q)
end

function Env(airspeed::Airspeed{keas},altitude::@quantity(Float64,m),delta_temperature::@quantity(Float64,K) = 0.0K)
    atm = Atm(altitude,delta_temperature)
    equivalent_Airspeed = convert(SIQuantity,airspeed.val*knots)
    mach_number = equivalent_airspeed/atm.speed_of_sound
    calibrated_airspeed = calc_calibrated(mach_number,atm.pressure_ratio)
    true_airspeed = equivalent_airspeed/sqrt(atm.density_ratio)
    q = 0.5*atm.density*true_airspeed^2
    Env(atm,calibrated_airspeed,equivalent_airspeed,true_airspeed,mach_number,q)
end

# function Env{N1<:Real,N2<:Real,U1<:LengthUnit,U2<:TemperatureUnit}(airspeed::Airspeed,altitude::Quantity{N1,U1},delta_temperature::Quantity{N2,U2} = 0.0K)
#     Env(airspeed,convert(SIQuantity{Float64},altitude),convert(SIQuantity{Float64},delta_temperature))
# end
