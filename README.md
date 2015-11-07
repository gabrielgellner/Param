# Param.jl

This package is motivated by the common need to pass a collection of parameters to functions
such as for ODE's or optimization routines. There are two obvious ways of doing this: 1)
defining a special type

```jl
type ODEParam
    a::Float64
    b::Float64
end

ODEParam(1.0, 2.0)
```

or as a `Dict`

```jl
Dict(a => 1.0, b => 2.0)
```

From these examples we see clearly that the `Dict` option is easier to read what the
values of a and b are. The downside is that we likely do not need the flexibility of
a `Dict` for this issue, and potentially pay a performance penalty for this unwanted
flexibility. For the custom type we have the issue that the default constructor is
opaque, requiring the user to remember the order of the fields in the defined type. This
can be fixed with making a constructor like:

```jl
ODEParam(;a = 0.0, b = 0.0) = Param(a, b)
# with usage
ODEParam(b = 2.0, a = 3)
# etc
```

This is not bad, but we have a lot of boilerplate to generate this every time this is
wanted. So in this package we make some simple macros that do this boilerplate
automatically. So instead you can do:

```jl
@paramdef(ODEParam, a = 1.0, b = 2.0)
par = ODEParam() # a -> 1.0, b -> 2.0
# or
par = ODEParam(b = 3.0) # a -> 1.0, b -> 3.0
```

The second convenience feature is for using the generated type in functions. Normally
we need to do something like:

```jl
function ydot(t, y, par)
    dydt = zeros(2)
    dydt[1] = par.a*y[1] + par.b
    dydt[2] = par.b*y[1] - par.b*y[1]*y[2]
    return dydt
end

# or using Dict
function ydot(t, y, par)
    dydt = zeros(2)
    dydt[1] = par[:a]*y[1] + par[:b]
    dydt[2] = par[:b]*y[1] - par[:b]*y[1]*y[2]
    return dydt
end

```  

(TODO: the only issue with this potentially is that I will be making a bunch of copies
instead of just reading the fields. Can I make references to the fields? as they are
likely just value types/immutable, another idea is to do something like 
`@withparam(par)(ydot)` where it just does a rebind/pattern replacement on the names.)

This package includes the macro `@withparam` that can be used as follows:

```jl
function ydot(t, y, par)
    @withparam(par)
    dydt = zeros(2)
    dydt[1] = a*y[1] + b
    dydt[2] = b*y[1] - b*y[1]*y[2]
    return dydt
end
```
