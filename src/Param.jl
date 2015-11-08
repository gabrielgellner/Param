module Param

export @paramdef, @withparam, walk_expr

macro paramdef(name, fields...)
    if !isa(name, Symbol)
        throw(ArgumentError("invalid name for parameter type (must be a symbol): $name"))
    end

    tname = esc(name) # for anti-macro hygiene ... I think this is needed! Check

    nfields = length(fields)
    varnames = Array{Any}(nfields)
    vars = Array{Any}(nfields)
    for i in 1:nfields
        varnames[i] = fields[i].args[1]
        # create the type named `name` with the fields given by the keywords (add checks to make sure they are kw's!)}
        # we need to eval the args[2] to get the correct types for things like `BigFloat(3.0)` etc
        vars[i] = Expr(:(::), varnames[i], typeof(eval(fields[i].args[2])))
    end
    typedef = Expr(:type, true, tname, Expr(:block, vars...))

    # create a default constructor for the type with the provided defaults
    ##TODO: add better error messages on entering the wrong types
    constructor = :( $tname(; $(fields...)) = $tname($(varnames...)) )
    ##TODO: add a nice printing method

    return Expr(:block, typedef, constructor)
end

"""utitlity function to return all subexpression so that replacement can be used on
variable names. Uses depth first search.

The operations to carry out on each expression (and sub expression) is `f`
"""
function dfs_expr(f, ex::Expr)
    parts = Any[ex.head]
    for arg in ex.args
        if isa(arg, Expr)
            push!(parts, dfs_expr(f, arg))
        else
            push!(parts, f(arg))
        end
    end
    return Expr(parts...)
end

macro withparam(pnames, argname, func)
    ##TODO: how to I get the fieldnames of a type in a macro ... I just found `Parameters.jl`
    ## which looks like a better version of this package. But I do like the idea I have with this macro
    ## making the @withparam change the function itself, instead of unpacking inside
    ## the function.
    ## what `Parameters.jl` does to get the type information is that a macro is made
    ## for each type defined that does the correct thing. I will try this for my withparam,
    ## though it also supports passing in the names of the parameters explicity
    ##
    ## So this works with the call @withparam [:p1, :p2, ..., :3] function <blah>
    lookup = eval(pnames)

    function replace_pars(arg)
        if arg in lookup
            return :($argname.$arg)
        else
            return arg
        end
    end
    code = dfs_expr(replace_pars, func)
    return esc(code)
end

end # module
