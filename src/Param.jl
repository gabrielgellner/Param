module Param

export @paramdef

macro paramdef(name, fields...)
    if !isa(name, Symbol)
        throw(ArgumentError("invalid name for parameter type (must be a symbol): $name"))
    end

    tname = esc(name) # for macro hygiene ... I think! Check

    nfields = length(fields)
    varnames = Array{Any}(nfields)
    vars = Array{Any}(nfields)
    for i in 1:nfields
        varnames[i] = fields[i].args[1]
        # create the type named `name` with the fields given by the keywords (add checks to make sure they are kw's!)}
        vars[i] = Expr(:(::), varnames[i], typeof(eval(fields[i].args[2])))
    end
    typedef = Expr(:type, true, tname, Expr(:block, vars...))

    # create a default constructor for the type with the provided defaults
    ##TODO: add better error messages on entering the wrong types
    constructor = :( $tname(; $(fields...)) = $tname($(varnames...)) )
    ##TODO: add a nice printing method

    return Expr(:block, typedef, constructor)
end

end # module
