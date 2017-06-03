#module CoreShapes
#
#    type CoreShape
#        name    ::typeof("")
#        Ve      ::typeof(.0)
#        Ae      ::typeof(.0)
#    end    
#
#end

module CoreShapes

    abstract CoreShape
    
    type CoreShapeE     <: CoreShape
        name    ::typeof("")
        CF      ::typeof(.0)            # core factor, Sum(I/A), C1                 [mm^-1]
        Ve      ::typeof(.0)            # effective volume                          [mm^3]
        le      ::typeof(.0)            # effective length                          [mm]
        Ae      ::typeof(.0)            # effective cross-sectional area            [mm^2]
        Amin    ::typeof(.0)            # minimum effective cross-sectional area    [mm^2]
                
        mass    ::typeof(.0)            # half mass of the core                     [g]
           
        Aw      ::typeof(.0)
        lavg    ::typeof(.0)
    end
    
    type CoreShapeRM    <: CoreShape
        name    ::typeof("")
        CF      ::typeof(.0)            # core factor, Sum(I/A), C1                 [mm^-1]
        Ve      ::typeof(.0)            # effective volume                          [mm^3]
        le      ::typeof(.0)            # effective length                          [mm]
        Ae      ::typeof(.0)            # effective cross-sectional area            [mm^2]
        Amin    ::typeof(.0)            # minimum effective cross-sectional area    [mm^2]
                
        mass    ::typeof(.0)            # half mass of the core                     [g]
           
        Aw      ::typeof(.0)
        lavg    ::typeof(.0)
    end
    
    sE53_27_20  = CoreShapeE(   "E5.3/2.7/2",
    
                                4.70,
                                33.3,
                                12.5,
                                2.66,
                                2.63,
       
                                0.08,
                                
                                1.5,
                                12.6
                           )

#    sE130_60_30 = CoreShapeE(   "E13/6/3",
#    
#                                2.74,
#                                281.,
#                                27.8,
#                                10.1,
#                                10.1,
#                                
#                                0.70,
#                                
#
#                           )
    sE130_60_60 = CoreShapeE(   "E13/6/6",
    
                                1.37,
                                559.,
                                27.7,
                                20.2,
                                20.2,
                                
                                1.40,
                                
                                15.4,
                                32.0
                           )
    
    sE130_70_40 = CoreShapeE(   "E13/7/4",
    
                                2.39,
                                369.,
                                29.7,
                                12.4,
                                12.2,
                                
                                0.90,
                                
                                11.6,
                                24.0
                           )

    sE160_80_50 = CoreShapeE(  "E16/8/5",

                                1.87,
                                750.,
                                37.6,
                                20.1,
                                19.3,
                                
                                2.00,
                                
                                21.6,
                                33.0
                           )

    sE160_120_50 = CoreShapeE(  "E16/12/5",

                                2.85,
                                1070.,
                                55.3,
                                19.4,
                                19.4,
                                
                                2.60,
                                
                                33.0,
                                37.9
                           )

    sRM4ILP     = CoreShapeRM(  "RM4/ILP",
                                
                                1.190,
                                251.,
                                17.3,
                                14.5,
                                11.3,
                                
                                1.30,
                                
                                3.75,
                                20.7                                
                             )

    sRM5I       = CoreShapeRM(  "RM5/I",
                                
                                0.935,
                                574.,
                                23.2,
                                24.8,
                                18.1,
                                
                                3.20,
                                
                                9.5,
                                24.9                                
                             )

    sRM6SILP    = CoreShapeRM(  "RM6S/ILP",
                                
                                0.58,
                                820.,
                                21.8,
                                37.5,
                                31.2,

                                4.40,
                                
                                6.3,
                                31.0
                             )
    
    sRM7ILP		= CoreShapeRM(	"RM6/ILP",
    
    							0.52,
    							1060.,
    							23.5,
    							45.3,
    							39.6,
    							
    							6.00,
    							
    							(4.7-1.0)*(15.4-7.25-1.0)/2,
    							(15.4+7.25)*pi
    						)
    
    sRM8ILP     = CoreShapeRM(  "RM8/ILP",
                                
                                0.44,
                                1860.,
                                28.7,
                                64.9,
                                55.4,

                                10.0,

                                13.3,
                                41.8
                             )


    function CF(shape::CoreShape)
        return shape.CF     * 1e3
    end
    
    function Ve(shape::CoreShape)
        return shape.Ve     * 1e-9
    end
    
    function le(shape::CoreShape)
        return shape.le     * 1e-3
    end
    
    function Ae(shape::CoreShape)
        return shape.Ae     * 1e-6
    end
    
    function Amin(shape::CoreShape)
        return shape.Amin   * 1e-6
    end
    
    function Aw(shape::CoreShape)
        return shape.Aw     * 1e-6
    end

    function lavg(shape::CoreShape)
        return shape.lavg   * 1e-3
    end

end

module CoreMaterials
    
    type RawCoreMaterialData
        name    ::typeof("")
        frange  ::Array{Array{typeof(.0),1}}
        Bmax    ::Array{Array{typeof(.0),1}}
    end
    
    #m3F3    = RawCoreMaterialData(  "3F3",
    #            Array[[]]
    
    type CoreMaterial
        name    ::typeof("")
        frange  ::Array{Array{typeof(.0),1}}
        Cm      ::Array{typeof(.0)}
        x       ::Array{typeof(.0)}
        y       ::Array{typeof(.0)}
        Ct2     ::Array{typeof(.0)}
        Ct1     ::Array{typeof(.0)}
        Ct      ::Array{typeof(.0)}
    end

    #type CoreMaterial
    #    name    ::typeof("")   
    #end

    m3F36   = CoreMaterial( "3F36",                                             # material name
                            Array[[100e3;500e3],[500e3,800e3],[800e3;1200e3]],  # frequency range
                            [6.83E-3,   1.12E-07,   2.24E-10],                  # Cm
                            [1.4390,    2.1952,     2.6105],                    # x
                            [3.2672,    2.7199,     2.4977],                    # y
                            [8.395E-05, 8.926E-05,  6.119E-05],                 # Ct2             
                            [1.078E-02, 1.172E-02,  6.142E-03],                 # Ct1
                            [1.233E+00, 1.282E+00,  1.011E+00]                  # Ct
                          )
    m3F3    = CoreMaterial( "3F3",                                              # material name
                            Array[[100e3;500e3],[500e3,800e3],[800e3;1200e3]],  # frequency range
                            [6.83E-3,   1.12E-07,   2.24E-10],                  # Cm
                            [1.4390,    2.1952,     2.6105],                    # x
                            [3.2672,    2.7199,     2.4977],                    # y
                            [8.395E-05, 8.926E-05,  6.119E-05],                 # Ct2             
                            [1.078E-02, 1.172E-02,  6.142E-03],                 # Ct1
                            [1.233E+00, 1.282E+00,  1.011E+00]                  # Ct
                          )
                          
    
    
    ########################################################
    # single frequency point, single flux density point
    function pv(m::CoreMaterial, f::typeof(.0), Bmax::typeof(.0), Tc::typeof(.0))
        n = 1
        for i = 1:length(m.Cm)
            if      f >= m.frange[i][1] && f < m.frange[i][2]
                n = i
            end
        end
        pv = 2 * m.Cm[n] * f^m.x[n] * Bmax^m.y[n] * (m.Ct2[n]*Tc^2 - m.Ct1[n]*Tc + m.Ct[n]) * 1e3
    end     
    ########################################################
    # array of frequency points, single flux density point
    function pv(m::CoreMaterial, f::Array{typeof(.0)}, Bmax::typeof(.0), Tc::typeof(.0))
        Pv = zeros(length(f))
        for i = 1:length(f)
            Pv[i] = pv(m, f[i], Bmax, Tc)
        end
        return Pv
    end
    ########################################################
    # single frequency point, array of flux density points
    function pv(m::CoreMaterial, f::typeof(.0), Bmax::Array{typeof(.0)}, Tc::typeof(.0))
        Pv = zeros(length(Bmax))
        for i = 1:length(Bmax)
            Pv[i] = pv(m, f, Bmax[i], Tc)
        end
        return Pv
    end
    ########################################################
    # array of frequency points, array of flux density points
    # single frequency point corresponds to single flux density point 
    function pv(m::CoreMaterial, f::Array{typeof(.0)}, Bmax::Array{typeof(.0)}, Tc::typeof(.0))
        if length(f) != length(Bmax)
            return NaN
        end
        Pv = zeros(length(f))
        for i = 1:length(f)
            Pv[i] = pv(m, f[i], Bmax[i], Tc)
        end
        return Pv
    end
    ########################################################
    function pv(m::CoreMaterial, f::Array{typeof(.0)}, Bmax::Array{typeof(.0)}, Tc::typeof(.0), matrix::Bool)
        Pv = zeros(length(f), length(Bmax))
        for i = 1:length(f)
            Pv[i,:] = pv(m, f[i], Bmax, Tc)
        end
        return Pv
    end

    ########################################################
end

if false

    #using Plots
    #pyplot()

    
    m3F36   = CoreMaterials.m3F36                 
    pv      = CoreMaterials.pv

    B = Array(collect(40:10:100))*1e-3
    f = Array(collect(100:1:1200))*1e3
    Pv = pv(m3F36, f, B, 100.0)
    println(Pv[400,2])
    println(Pv[401,2])
    plot(0)
    #plot!(B, collect(Pv[1,:]))
    #for i = 1:length(B)
    #    plot!(f, collect(Pv[:,i]))
    #end
    #gui()
end
