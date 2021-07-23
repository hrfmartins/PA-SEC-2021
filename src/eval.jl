include("utils.jl")
include("predef.jl")

function evaluate(exp, env, define_name=true)
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

        elseif (is_call(exp))
            eval_call(exp, env)

        elseif (is_define(exp))
            eval_def(exp, env, define_name)
    
        elseif is_block(exp)
            eval_block(exp, env)
            
        elseif is_function_def(exp)
            eval_func_def(exp, env)
        end


    else
        error("Unknown ", exp, " Type")
    end
end
