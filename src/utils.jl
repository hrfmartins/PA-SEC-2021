function second_operand(exp)
    return exp.args[3]
end

function first_operand(exp)
    return exp.args[2]
end

function self_evaluating(exp) 
    return isa(exp, Number) || isa(exp,String) || isa(exp, Bool)
end

function is_name(exp)
    return isa(exp, Symbol)
end

function eval_name(name, env)
    if (env == []) # Reached the end and it wasnt there, it's unbound!
        error(string("Unbound name", env, "EVAL-NAME"))
    elseif (name == env[1][1])
        return env[1][2]
    else
        eval_name(name, env[2:length(env)]) #recursively call with the rest of the list

    end
end

function let_expr(exp)
    if (isa(exp, Expr) && exp.head == :let)
        return true
    end
    return false
end

function let_names(exp)
    l = []
    for p in exp.args[1].args
        if isa(p, Symbol)
            push!(l, Symbol(p))
        elseif isa(p, Number)
            continue
        else
            push!(l, Symbol(p.args[1]))
        end
    end
    return l
end

function let_inits(exp)
    l = []
    for p in exp.args[1].args
        if isa(p, Number)
            push!(l, p)
        elseif isa(p, Symbol)
            continue
        else
            push!(l, p.args[2])
        end
    end
    return l
end

let_body(exp) = exp.args[2].args[2]

function eval_expr(expr, env)
    #TODO 19:41 Teo 2020-04-29 15.20
end

function eval_ternary(exp, env)
    if (is_true(exp.args[1], env))
        evaluate(exp.args[2], env)
    else
        evaluate(exp.args[3], env)
    end
end

function is_true(exp, env)
    if (evaluate(exp, env))
        return true
    else
        return false
    end
end

function is_ternary(exp)
    if (exp.args[1] == Expr || self_evaluating(exp.args[2])|| self_evaluating(exp.args[3]))
        return true
    else
        return false
    end
end

function if_expr(exp)
    if exp.head == :if 
        return true
    else
        return false
    end
end

function eval_if(exp, env)
    if (evaluate(exp.args[1], env))
        return exp.args[2]
    end
    #TODO
end

function eval_let(exp, env)
    values = eval_expr(let_inits(exp), env)
    extended_environment = augment_environment(let_names(exp), values, env)
    evaluate(let_body(exp), extended_environment)
end

function eval_expr(expr, env)
    l = []
    if (expr == [])
        return []
    else
        push!(l, evaluate(expr[1], env))
        x = eval_expr(expr[2:length(expr)], env)

        if (x != [])
            append!(l, x)
        end
    end
    l
end


function augment_environment(names, values, env)
    if names == [] || values == []
        env
    else
        pushfirst!(augment_environment(names[2:length(names)], values[2:length(values)], env), (names[1], values[1]))
    end
end

function empty_environment()
    vcat(initial_bindings(), primitive_functions())
end