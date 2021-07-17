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

function flet_expr(exp)
    if (isa(exp, Expr) && exp.head == :let)
        if (isa(exp.args[1].args[1],Expr))
            if (exp.args[1].args[1].head == :call)
                return true
            end
        end
    end
    return false
end

function let_names(exp)
    l = []

    for p in exp
        if isa(p.args[1], Symbol)
            push!(l, Symbol(p.args[1]))
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
    for p in exp
        if isa(p.args[2], Number)
            push!(l, p.args[2])
        elseif isa(p, Symbol)
            continue
        else
            push!(l, p.args[2])
        end
    end
    return l
end

let_body(exp) = exp.args[2].args[2]

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
    #TODO evaluate normal if conditions
end

function eval_let(exp, env)
    (flets, lets) = filter_flets(exp)
    extended_environment = augment_environment(let_names(lets), eval_expr(let_inits(lets), env), env)
    extended_environment = augment_environment(flet_func_names(flets), flet_functions(flets), extended_environment)
    evaluate(flet_func_body(exp), extended_environment)
end

function filter_flets(exp)
    flets = []
    lets = []

    if (typeof(exp.args[1].args[1]) == Symbol) # Single let x = 1; x + 1
        push!(lets, exp.args[1])

    elseif (exp.args[1].args[1].head == :call)
        push!(flets, exp.args[1])
        
    elseif (isa(exp.args[1].args[1], Expr))
        for e in exp.args[1].args
            if (e.head == :call)
                continue
            elseif (typeof(e.args[1]) == Symbol)
                push!(lets, e)
            elseif (isa(e.args[1], Expr))
                push!(flets, e)
            end
        end
    end
    return (flets, lets)
end

function eval_flet(exp, env)
    extended_env = augment_environment(flet_func_names(exp), flet_functions(exp), env)
    evaluate(flet_func_body(exp), extended_env)

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
        newEnv = deepcopy(env)
        pushfirst!(augment_environment(names[2:length(names)], values[2:length(values)], newEnv), (names[1], values[1]))
    end
end

function empty_environment()
    vcat(initial_bindings(), primitive_functions())
end

function is_call(expr)
    if (expr.head == :call)
        return true
    end
    return false
end

call_operator(expr) = expr.args[1]

call_operands(expr) = expr.args[2:length(expr.args)]

flet_func_names(expr) = [x.args[1].args[1] for x in expr]

flet_func_body(expr) = expr.args[2].args[2]

flet_body(expr) = expr.args[2]

flet_params(expr) = expr.args[1].args[2:length(expr.args[1].args)]

function flet_functions(expr)
    [make_function(flet_params(x), flet_func_body(x)) for x in expr]
end

function make_function(params, body)
    return (:function, (params, body))
end
