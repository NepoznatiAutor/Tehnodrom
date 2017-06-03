module ConductorMaterials
    
    # personal preference towards using "tau" instead of "2 pi"
    # certain equations become more reasonable when tau is used
    tau     = 2*pi
    
    # speed of light in vacuum
    c0      = 299792458

    # absolute vacuum permeability
    u0      = 2*tau*1e-7    # well known as 4*pi*1e-7

    # absolute vacuum permittivity
    e0      = 1/u0/c0^2     # should yield 8.854187817e-12

    type ConductorMaterial
        name    ::typeof("")
        rho     ::typeof(.0)
        ur      ::typeof(.0)
        alpha   ::typeof(.0)
    end
    
    Tref        = 20 # referent temperature for conductor resistance [degC]
    
    copper      = ConductorMaterial( "copper",    17.2e-9, 1.0, 4.041e-3 )
    aluminum    = ConductorMaterial( "aluminum", 100.0e-9, 1.0, 4.308e-3 )
    

    # copper resistance and conductance at room temperature, 25 degC
    rho_cu      = 17.2e-9       # [Ohms/m]
    sigma_cu    = 1/rho_cu      # [Sm] (or [S/m]? I'll think about it)
    
    # returns skin depth of a given conductor material [m] at a single frequency
    function skin_depth(m::ConductorMaterial, f::typeof(.0), Tc=25.0::typeof(.0))
        rho     = m.rho*( 1 + m.alpha.*(Tc-Tref) )
        ux      = u0 * m.ur
        sd      = sqrt(rho./(ux*pi*f))
        return sd
    end
    
    # same as above, just at an array of frequencies
    function skin_depth(m::ConductorMaterial, f::Array{typeof(.0)}, Tc=25.0::typeof(.0))
        rho     = m.rho*( 1 + m.alpha.*(Tc-Tref) )
        ux      = u0 * m.ur
        sd      = sqrt(rho./(ux*pi*f))
        return sd
    end
    
    # TODO: rename x and y so I know what those the fuck are
    function xi(x::typeof(.0))
        y   = x .* ( sinh(x) - sin(x) ) ./ ( cosh(x) + cos(x) )
        return y
    end
    
    function proximity()
        
    end
    
    # converts AWG to wire surface area [mm2]
    function awg_area(awg)
        area    = 0.012668e-6 * 92.^((36-awg)/19.5)
    end

    # converts AWG to wire radius [mm]
    function awg_radius(awg)
        radius  = sqrt(awg_area(awg)/pi)
    end
    
    # converts AWG to wire 
    function awg_diameter(awg)
        diameter = 2 * awg_radius(awg)
    end

    # variables to be visible outside:
    # tau = 2 * pi  - because it makes sense in many ways
    # c0            - speed of light in vacuum
    # e0            - absolute permittivity in vacuum
    # u0            - absolute permeability in vacuum

    export tau, c0, e0, u0 
end

    

    function winding_resistance(Rdc::typeof(.0))
        
        alpha   = sqrt( 1im.*w.*u0.*N.*a./b )
        M       = alpha.*h .* coth( alpha.*h )
        D       = 2.*alpha.*h .* tanh( alpha.*h./2 )
        Rac     = Rdc .* ( real(M) + (m.^2-1)*real(D)./3 )
        return Rac
    end


################################################################
# this region is unfinished / for testing, needs more work
################################################################

if false
    F       = 1 # skin effect factor

    Rdc     = 1 # wire DC resistance
    Irms    = 1 # wire current 

    Ps      = F.*Rdc.*Irms.^2

    l       = 1 # wire length
    G       = 1
    H       = 1
    Pp      = G.*H.^2*l

    Pp_0    = 1
    Pp_i    = 1

    d_0     = 1e-3 # strand diameter
    d_i     = # diameter of a bundle in the i-th twisting step
    r_0     = d_0 / 2
    r_i     = d_i / 2
    p_i     = 1 # pitch of the i-th twisting operation
end
# strand-level skin effect factor
if false
    plot()
    # I found that Litz wire strands radius is expensive above 25e-6
    r       = [1e-3,  3e-4,   1e-4,   3e-5]
    
    # I guessed fill factor and its decrease with strand radius
    fill    = 0.8.^[0, 1, 2, 3, 4]
    n       = [1,     3e-1,   1e-1,   3e-2].^2
    for i = 1:length(r)
        rho     = 1.72e-8
        f       = 10.^(3:0.1:9)
        sdepth  = skin_depth(f)
        xi      = r[i] .* sqrt(2) ./ sdepth
        xi_mod  = xi * 1im^1.5
        F_0     = real(rho*l./(tau*r[i].^2).*xi_mod.*(besselj0(xi_mod)./besselj1(xi_mod)))
    end
end


