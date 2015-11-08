using Param
using Base.Test

@paramdef(LVPar,
    r = 1.5,
    K = 10.0,
    a = 1.8,
    e = 1.0,
    m = 0.3
)

@withparam LVPar function ydot(t, y, par)
    ydot = zeros(2)
    ydot[1] = r*y[1]*(1.0 - y[1]/K) - a*y[1]*y[2]
    ydot[2] = e*a*y[1]*y[2]
    return ydot
end

p1 = LVPar(r = 0.8, a = 1.1)
ydot(0, [0.5, 0.5], p1)
