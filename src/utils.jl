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
    function lookup_in_frame(frame)
        if frame == []
            eval_name(name, env[2:length(env)])
        elseif (name == frame[1][1])
            return frame[1][2]
        else
            lookup_in_frame(frame[2:length(frame)])
        end
    end
    if (env == []) # Reached the end and it wasnt there, it's unbound!
        error(string("Unbound name - ", name, " - EVAL-NAME"))

    else
        lookup_in_frame(env[1]) #recursively call with the rest of the list
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
    if (length(exp.args) == 3)
        if (exp.args[1] == Expr || self_evaluating(exp.args[2])|| self_evaluating(exp.args[3]))
            return true
        else
            return false
        end
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


function eval_let(exp, env)
    (flets, lets) = filter_flets(exp)
    extended_environment = augment_environment(let_names(lets), eval_expr(let_inits(lets), env), env)
    extended_environment = augment_environment(flet_func_names(flets), flet_functions(flets), extended_environment)
    evaluate(flet_func_body(exp), extended_environment)
end

function filter_flets(exp)
    flets = []
    lets = []
    if (exp.args[1].args == [])
    
    elseif (typeof(exp.args[1].args[1]) == Symbol) # Single let x = 1; x + 1
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

function eval_if(exp, env)
    if (evaluate(exp.args[1], env))
        return evaluate(exp.args[2].args[2], env)
    elseif length(exp.args) > 2
        eval_elseif(exp.args[3], env)
    end
end

function eval_elseif(exp,env)
    if exp.head == :block
        return evaluate(exp.args[2], env)
    elseif (exp.head == :elseif && evaluate(exp.args[1].args[2], env))
        return evaluate(exp.args[2].args[2], env)
    else
        return eval_elseif(exp.args[3], env)
    end
end


function augment_environment(names, values, env)
    newEnv = deepcopy(env)
    pushfirst!(newEnv, map((i, j) -> (i,j), names, values))
        #pushfirst!(augment_environment(names[2:length(names)], values[2:length(values)], newEnv), (names[1], values[1]))
end

function empty_environment()
    [vcat(initial_bindings(), primitive_functions())]
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

function is_function(obj)
    if (isa(obj, Pair)) 
        if (obj[1] == :Function)
            return true
        end
    return false
    end
end

function_parameters(func) = func[2][1]

function_body(func) = func[2][2]

function eval_call(exp, env)
    func = eval_name(call_operator(exp), env)
    args = eval_expr(call_operands(exp), env)

    if (primitive_or_user_def(func, env))
        if (length(args) == 1) 
            apply_primitive_single(func, args)
        else
            apply_primitive(func, args)
        end

    else
        extended_env = augment_environment(function_parameters(func), args, env)
        evaluate(function_body(func), extended_env)
    end
end

is_block(exp) = exp.head == :block ? true : false 

function eval_block(exp, env)
    if isa(exp.args[1], LineNumberNode)
        eval_chain_block(removeLNN(exp.args[2:length(exp.args)]), env)
    else
        eval_chain_block(removeLNN(exp.args), env)
    end
end

function eval_chain_block(blocks, env)
    if (length(blocks) == 1)
        return evaluate(blocks[1], env)
    else
        evaluate(blocks[1], env)
        eval_chain_block(blocks[2:length(blocks)], env)
    end
end

function removeLNN(blocks)
    filter(x-> !isa(x, LineNumberNode),  blocks)
end

is_define(exp) = exp.head == :(=) && length(exp.args) == 2

function def_name(exp)
    if isa(exp.args[1], Symbol)
        exp.args[1]
    elseif isa(exp.args[1], Expr) && exp.args[1].head == :call # function definition
        exp.args[1].args[1]
    end
end

function def_init(exp) 
    if isa(exp.args[2], Expr)
        if (isa(exp.args[1], Symbol))
            return (exp.args[2], false)
        elseif (exp.args[1].head == :call) # function definition
            return (exp.args[2].args[2], true)
        end
    else
        return (exp.args[2], false)
    end
end

function eval_def(exp, env, define_name)
    value, f_or_v = def_init(exp) # function or value

    if (define_name)
        if (f_or_v) # if its a function
            augment_destructively(def_name(exp), make_function(def_params(exp), def_body(exp)), env)
            nothing
        else
            evaluated = evaluate(value, env)
            augment_destructively(def_name(exp), evaluated, env)
            evaluated
        end
    else        # will be useful in the evaluation of let forms
        if (f_or_v)
            augment_environment(def_name(exp), make_function(def_params(exp), def_body(exp)), env)
            nothing
        else
            evaluated = evaluate(value, env)
            augment_environment(def_name(exp), evaluated, env)
            evaluated
        end

    end
end

function augment_destructively(name, value, env)
    binding = (name, value)
    env[1] = vcat(binding, env[1])
end

def_params(exp) = exp.args[1].args[2:length(exp.args[1].args)]

def_body(exp) = exp.args[2].args[2]

is_function_def(exp) = exp.head == :function ? true : false 

eval_func_def(exp, env) = (augment_destructively(def_name(exp), make_function(def_params(exp), funct_body(exp)), env); return nothing)

funct_body(exp) = exp.args[2].args[3]