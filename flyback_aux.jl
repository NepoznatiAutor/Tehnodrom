#!/usr/bin/env julia
# 
# in julia, type:
# include("/work/git/aux supply/Tempest.v1/2. calculation/flyback_aux.jl")
#
# in terminal, type:
# julia flyback2.jl

############################################################
path        = "/tardis/sync/git/aux supply/Tempest.v1/2. calculation"
libs        = "/tardis/sync/git/libs julia"
cores       = "CoreMaterials.jl"
conductors  = "ConductorMaterials.jl"
include("$libs/$cores")
include("$libs/$conductors")
cd(path)

using CoreMaterials
m3F36       = CoreMaterials.m3F36
pv          = CoreMaterials.pv

using CoreShapes
#sE1         = CoreShapes.sE53_27_20
#sE1         = CoreShapes.sE130_60_60
#sE1         = CoreShapes.sE160_120_50
#sE1         = CoreShapes.sE130_70_40
#sE1         = CoreShapes.sE190_80_90
#sRM1        = CoreShapes.sRM7ILP
#sRM1        = CoreShapes.sRM5ILP
#sRM1        = CoreShapes.sRM4I
sRM1        = CoreShapes.sRM5I
# !!!
# here I choose if I am going to use E core or RM core or else
if      1 == 0
    s = sE1
elseif  1 == 1
    s = sRM1
end

# !!!

#Pout        = 6 #[W]
#eff         = 0.7
#Pin         = Pout./eff
#Pinmax      = Pin * 1.1
# here I set AL value of the core set
Al          = 50e-9
Al          = 100e-9
Al          = 160e-9
# definitions from CoreMaterials.jl and ConductorMaterials.jl
Ve          = CoreShapes.Ve
Ae          = CoreShapes.Ae
Aw          = CoreShapes.Aw
lavg        = CoreShapes.lavg

using ConductorMaterials
tau             = ConductorMaterials.tau
skin_depth      = ConductorMaterials.skin_depth
awg_area        = ConductorMaterials.awg_area
awg_radius      = ConductorMaterials.awg_radius
awg_diameter    = ConductorMaterials.awg_diameter
rho             = ConductorMaterials.copper.rho

############################################################
Vin     = 100.0
Pout    = 2.0
Vout    = 10.0
Iout    = Pout/Vout
eff     = 0.75          # total converter efficiency
xeff    = 0.85          # total xformer efficiency
Pin     = Pout / eff

Pinmax  = Pin


Iin     = Pin/Vin


Vdrv1   = 10.0
Vdrv2   = 10.0
Vdrv3   = 5.0

Idrv1   = 1e-3 * (3 + 3*1.5)
Idrv2   = 1e-3 * (0 + 2*1.5)
Idrv3   = 1e-3 * (5 + 0)

Pdrv1   = Vdrv1*Idrv1
Pdrv2   = Vdrv2*Idrv2
Pdrv3   = Vdrv3*Idrv3

Vuc     = 5.0                   # should be 3.3V but LDO is expected off of 5V
Iuc     = 8e-3 * 0.2
Puc     = Vuc*Iuc               # 3V3 rail consumption (including LDO), low power mode

############################################################
# optimization goal: smallest core volume
# to play with Ts, Lp, Ls
#Lp      = 900e-6
Nps     = 100.0/10.0
Lp      = collect(100:1:2000)*1e-6
Ls      = Lp./Nps.^2 #10e-6
#Ton     = 650e-9
fs      = 132e3 * 1
Nfs     = Pinmax ./ Pin
Ts      = 1./fs .* Nfs
fs      = 1./Ts


# NOTE: primary side switch conduction time Ton CAN go well below 1us 
Ip_avg  = Iin
Ton     = sqrt(2 * Iin .* Ts .* Lp ./ Vin)
Ip_pk   = Iin ./ (Ton./Ts) .* 2

Ip_pk   = Vin./Lp.*Ton
Ip_rms  = Ip_pk.*sqrt(Ton./Ts/3)
Ip_avg  = Ip_pk ./ 2 .* Ton./Ts

Is_pk   = sqrt(Lp./Ls) .* Ip_pk .* xeff
Toff    = Is_pk ./ Vout .* Ls
Is_rms  = Is_pk.*sqrt(Toff./Ts/3)
Is_avg  = Is_pk ./ 2 .* Toff./Ts
Rsw     = 6     ./1
Csw     = 6e-12 .*1
Lp_lk   = Lp .* 0.05
Vfwd    = 0.6
Rfwd    = 0.1

Np      = round( sqrt(Lp./Al) )
Ns      = round( sqrt(Ls./Al) )

# # # # # # # # # # # # # # # # # # # # # # # # # #
# effective volume:     Ve      given in [mm3]
# effective area:       Ae      given in [mm2]
# window area:          Aw      given in [mm2]
# mean wire length:     rw      given in [mm]

#Ve      = Ve(s)
#Ae      = Ae(s)
#Aw      = Aw(s)
#rw      = meanlw(s)

# # # # # # # # # # # # # # # # # # # # # # # # # #
# HERE BE DRAGONS!!!

#Apcu    = (0.2*Aw) * 0.3       # effective copper area of the primary winding
Apcu_1 = awg_area(40)
#Ascu_1 = awg_area(33)

Apcu    = Apcu_1    .* Np
#Ascu    = Ascu_1    .* Ns

Awp     = Apcu .* 8
Aws     = Aw(s) - Awp
if Aws != abs(Aws)
    println("********************************************")
    println("********************************************")
    println("Too much area for primary side winding!")
    println("********************************************")
    println("********************************************")
end

Ascu    = Aws ./ 8
Ascu_1  = Ascu ./ Ns

# TODO: check if the used area is filled, underfilled, overfilled

#Ascu_1  = Ascu ./ Ns
#Ascu_2  = Ascu_1
#Ascu_3  = Ascu_1

# # # # # # # # # # # # # # # # # # # # # # # # # #
# I.    resistance is calculated as:
#       resistivity / copper area x turn mean length x number of turns 
# II.   resistance is augmented by proximity effect factor Fac
#
# TODO: determine analytically proximity effect factor Fac

Fpac    = 2
Fsac    = 2
Rpcu    = Np.*rho.*lavg(s) ./ Apcu_1 * Fpac
Rscu    = Ns.*rho.*lavg(s) ./ Ascu_1 * Fsac

# # # # # # # # # # # # # # # # # # # # # # # # # #

Bmax    = (Vin./Np) .* Ton ./ Ae(s) ./ 1
fs1     = 1./(4.*Ton)
fs2     = 1./(4.*Toff)
Tamb    = 75.0
Pv1     = pv(m3F36, fs1, Bmax, Tamb) .* (Ton./Ts)
Pv2     = pv(m3F36, fs2, Bmax, Tamb) .* (Toff./Ts)

Pv      = Pv1 + Pv2
Pcore   = Ve(s).*Pv
#Pcore   = V*diag(Pv)
# # # # # # # # # # # # # # # # # # # # # # # # # #

Ppcu    = Rpcu.*Ip_rms.^2 .* (Ton/Ts)
Pscu    = Rscu.*Is_rms.^2 .* (Toff/Ts)
Pcopper = Ppcu + Pscu

Pswcon  = Rsw .* Ip_rms.^2 .* (Ton./Ts)
Pdcon   = Vfwd .* Is_avg + Rfwd .* Is_rms.^2 .* (Toff/Ts)

Pswsw   = 0.5 .* Csw.*fs.*Vin.^2

Plk     = 0.5 .* Lp_lk.*fs.*Ip_pk.^2 * 2        # assumed same power loss in both 

Ploss   = Pswsw + Pswcon + Pdcon + Plk + Pcore + Pcopper

Ptotal  = Pdrv1 + Pdrv2 + Pdrv3 + Puc


# if you want to print calculation results
empty       = ""
separator   = "----------------------------------------"
if 1 == 0
    println(empty)
    println(separator)
    println("maximum no-load power      = ", round(Pout     *1e3,2),    " mW")
    println("9V power consumption       = ", round(Pdrv1    *1e3,2),    " mW")
    println("5V power consumption       = ", round(Pdrv2    *1e3,2),    " mW")
    println("3.3V power consumption     = ", round(Puc      *1e3,2),    " mW")
    println("24V power consumption      = ", round(Pdrv3    *1e3,2),    " mW")
    println(separator)
    println("total power required       = ", round(Ptotal   *1e3,2),    " mW")
    println(separator)
    println(separator)
    println("switch: conduction loss    = ", round(Pswcon   *1e3,2),    " mW")
    println("switch: switching loss     = ", round(Pswsw    *1e3,2),    " mW")
    println("diode: conduction loss     = ", round(Pdcon    *1e3,2),    " mW")
    println("primary: leakage loss      = ", round(Plk      *1e3,2),    " mW")
    println("copper loss                = ", round(Pcopper  *1e3,2),    " mW")
    println("core loss                  = ", round(Pcore    *1e3,2),    " mW")
    println(separator)
    println("total loss                 = ", round(Ploss    *1e3,2),    " mW")
    println(separator)
    println(separator)
    println("average input current      = ", round(Iin      *1e6,2),    " uA")
    println("average input current      = ", round(Ip_avg   *1e6,2),    " uA")
    println(separator)
end

if 1 == 1
    println("maximum power = ", round(Pout.*Nfs, 2), "W")
    println(separator)
end

if 1 == 1
    using Plots
    pyplot()
    
    x       = Lp * 1e6                      # express primary inductance Lp in [uH] in plots
    xticks  = minimum(x):200:maximum(x)     # set x-axis (prim. inductance Lp) ticks
    xaxis   = [minimum(x), maximum(x)]
    Nx      = length(x)
    xlabel  = ("inductance Lprim, [uH]")
    y       = hcat(Pswcon, Pswsw.*ones(length(Pswcon)), Pdcon, Plk, Pcopper, Pcore, Ploss)
    y       = y*1e3
    label   = ["Pswcon" "Pswsw" "Pdcon" "Pleak" "Pcopper" "Pcore" "Ploss"]
    
    plot(
        plot( #loss plot vs Lprim
            x, y,   layout=1, label=label, line=(2),
            xaxis   = (xaxis, font(8)),
            xticks  = (xticks),
            yaxis   = ([0.0, Pin*0.3*1e3], font(8)),
            yticks  = (0:250:1e3),
            #yticks  = (0:100:500),
            xlabel  = xlabel,
            ylabel  = ("power loss Ploss, [mW]"),
            ),
        plot( #conduction time vs Lprim
            x, hcat(Ton*1e6, Toff*1e6, (Ton+Toff)*1e6, Ts/Nfs*1e6*ones(Nx), 0.5*ones(Nx)),    line = (2),
            xaxis   = (xaxis, font(8)),
            xticks  = (xticks),
            yaxis   = ([0, 10], font(8)),
            xlabel  = xlabel,
            ylabel  = ("prim dev on-time [us]"),
            ),
        plot( # number of turns in the primary vs Lprim
            x, Np,  line = (2),
            xaxis   = (xaxis, font(8)),
            xticks  = (xticks),
            yaxis   = ([0, 160], font(8)),
            yticks  = (0:40:160),
            xlabel  = xlabel,
            ylabel  = ("prim. # turns"),
            ),
        plot( # number of turns in the secondary vs Lprim
            x, Ns,  line = (2),
            xaxis   = (xaxis, font(8)),
            xticks  = (xticks),
            yaxis   = ([0, 20], font(8)),
            yticks  = (0:4:20),
            xlabel  = xlabel,
            ylabel  = ("sec. # turns"),
            ),
        plot( # peak primary current vs Lprim
            x, Ip_pk, line = (2),
            xaxis   = (xaxis, font(8)),
            xticks  = (xticks),
            yaxis   = ([0, 1.5], font(8)),
            xlabel  = xlabel,
            ylabel  = ("prim peak current [A]"),
            
            ),
        plot( # peak secondary current vs Lprim
            x, Is_pk, line = (2),
            xaxis   = (xaxis, font(8)),
            xticks  = (xticks),
            yaxis   = ([0, 10.0], font(8)),
            xlabel  = xlabel,
            ylabel  = ("sec peak current [A]"),
            ),
        layout=(3,2)
    )

    gui()
end
