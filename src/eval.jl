include("utils.jl")
include("predef.jl")

function evaluate(exp, env)
    if (self_evaluating(exp))
        return exp

    elseif (is_name(exp))
        eval_name(exp, env)

    elseif (typeof(exp) == Expr)
        if (if_expr(exp))
            if (is_ternary(exp))
                eval_ternary(exp, env)
            else # if its a regular if
                eval_if(exp, env)
            end

        elseif (let_expr(exp))
            eval_let(exp, env)
            
        elseif is_primitive(exp) # In case its a simple expression like an addition
            if (length(exp.args) == 3)
                apply_primitive(exp, evaluate(exp.args[2], env), evaluate(exp.args[3], env), env)
            elseif (length(exp.args) == 2)
                apply_primitive_single(exp, evaluate(exp.args[2], env), env)
            end
        end
    
    else
        error("Unknown ", exp, " Type")
    end
end