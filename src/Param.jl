module Param
import Parameters: @with_kw

export @with_kw, @withparam

"""
    dfs_expr(f, ex::Expr)

Utitlity function that returns all subexpression so that replacement can be used on
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

"""
    @withparam type arg func

Rewrite a function definition were the fieldnames of `type` are replaced by `arg.(name)`.
"""
macro withparam(typename, argname, func)
    # use Core.eval so the typename will be defined from the calling program and not this
    # modules scope.
    lookup = Core.eval(:(fieldnames($typename)))

    function replace_pars(arg)
        #TODO: this code doesn't differentiate a symbol on its own and a symbol that
        # is a type lookup
        # that is if the code has something like a*t.a
        # both symbols :a willl be replaced, even though we likely only want to replace
        # the first one. Should also check how having the symbols inside function calls
        # could work like sin(a) vs sin(t.a) to make sure I do the correct replacement
        if arg in lookup
            return :($argname.$arg)
        else
            return arg
        end
    end
    code = dfs_expr(replace_pars, func)
    return esc(code)
end

#=
# Some nice utitlities for working with these kind of Parameter types
=#

#TODO: see if I can get this to work
# function like{T}(par::T; kwargs...)
#     flds = fieldnames(par)
#     newpar = T()
#     for (name, val) in kwargs
#         if name in flds
#             newpar.(name) = val
#         else
#             throw(ArgumentError("$name is not a field of $T"))
#         end
#     end
#     return newpar
# end

end # module
