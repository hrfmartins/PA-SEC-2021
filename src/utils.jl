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
    ## (flets, lets) = filter_flets(exp)
    ## 
    ## names = vcat(let_names(lets), flet_func_names(flets))
    ## inits = vcat(eval_expr(let_inits(lets), env), flet_functions(flets))

    ## extended_environment = augment_environment(names, inits, env)
    pushfirst!(env, []) # a new frame for scope of the let form
    expr = make_let_block(exp)
    evaluated = evaluate(expr, env, env)
    deleteat!(env, 1)
    evaluated
end

## function filter_flets(exp)
##     flets = []
##     lets = []
##     if (exp.args[1].args == [])
##     
##     elseif (typeof(exp.args[1].args[1]) == Symbol) # Single let x = 1; x + 1
##         push!(lets, exp.args[1])
## 
##     elseif (exp.args[1].args[1].head == :call)
##         push!(flets, exp.args[1])
##         
##     elseif (isa(exp.args[1].args[1], Expr))
##         for e in exp.args[1].args
##             if (e.head == :call)
##                 continue
##             elseif (typeof(e.args[1]) == Symbol)
##                 push!(lets, e)
##             elseif (isa(e.args[1], Expr))
##                 push!(flets, e)
##             end
##         end
##     end
##     return (flets, lets)
## end

function make_let_block(exp)
    q = string("begin ")

    if (exp.args[1].args == [])
    
    elseif (typeof(exp.args[1].args[1]) == Symbol) # Single let x = 1; x + 1
        q = string(q, " ", exp.args[1],";")

    elseif (exp.args[1].args[1].head == :call)
        q = string(q, " ", exp.args[1],";")
        
    elseif (isa(exp.args[1].args[1], Expr))
        for e in exp.args[1].args
            if (e.head == :call)
                continue
            elseif (typeof(e.args[1]) == Symbol)
                q = string(q, " ", e,";")
            elseif (isa(e.args[1], Expr))
                q = string(q, " ", e,";")

            end
        end
    end

    for e in exp.args[2].args # Iterate over the  body that's not part of the definition.
        q = string(q, e, ";")
    end
    return Meta.parse(string(q, " end"))
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
        return evaluate(exp.args[2].args[1], env)
    elseif length(exp.args) > 2
        eval_elseif(exp.args[3], env)
    end
end

function eval_elseif(exp,env)
    if exp.head == :block
        return evaluate(exp.args[1], env)
    elseif (exp.head == :elseif && evaluate(exp.args[1].args[1], env))
        return evaluate(exp.args[2].args[1], env)
    else
        if (length(exp.args) == 3)
            return eval_elseif(exp.args[3], env)
        else
            return nothing
        end
    end
end


function augment_environment(names, values, env)
    #newEnv = deepcopy(env)
    pushfirst!(env, map((i, j) -> (i,j), names, values))
end

function augment_environment_global(names, values, env)
    #newEnv = deepcopy(env)
    tups = map((i, j) -> (i,j), names, values)
    for e in tups
        pushfirst!(env[length(env)], e)
    end
        vcat(env, [])
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

flet_func_body(expr) = expr.args[2].args[1]

flet_body(expr) = expr.args[2]

flet_params(expr) = expr.args[1].args[2:length(expr.args[1].args)]

function local_or_global(x)
    if x.head == :global
        :global
    else
        :local 
    end
end

function make_function(params, body, env, glob = false)
    return (:function, (params, body, deepcopy(env) , glob ? :global : :local))
end

funct_env(func) = func[2][3]

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
    func = evaluate(call_operator(exp), env)
    args = eval_expr(call_operands(exp), env)

    if (primitive_or_user_def(func, env))
        if (length(args) == 1) 
            apply_primitive_single(func, args)
        else
            apply_primitive(func, args)
        end

    else

        extended_env = augment_environment(function_parameters(func), args,  funct_env(func))
        env = augment_environment(function_parameters(func), args,  env)


        evaluated = evaluate(function_body(func), extended_env, env, func[2][4] == :global)
        deleteat!(extended_env, 1)
        deleteat!(env, 1)
        evaluated

    end
end

is_lambda(exp) = exp.head == :(->)

lambda_parameters(exp) = isa(exp.args[1], Symbol) ? [exp.args[1]] : exp.args[1].args

lambda_body(exp) = exp.args[2]

eval_lambda(exp, env, glob) = return make_function(lambda_parameters(exp), lambda_body(exp), env, glob)


is_block(exp) = exp.head == :block ? true : false 

function eval_block(exp, env, initial_env, glob)
    if isa(exp.args[1], LineNumberNode)
        eval_chain_block(exp.args[2:length(exp.args)], env, initial_env, glob)
    else
        eval_chain_block(exp.args, env, initial_env, glob)
    end
end

function eval_chain_block(blocks, env, initial_env, glob)
    if (length(blocks) == 1)
        return evaluate(blocks[1], env, initial_env, glob)
    else
        evaluate(blocks[1], env, initial_env, glob)
        eval_chain_block(blocks[2:length(blocks)], env, initial_env, glob)
    end
end

is_define(exp) = (exp.head == :(=) && length(exp.args)) == 2 || ((exp.head == :global && exp.args[1].head == :(=) && length(exp.args[1].args) == 2))

function def_name(exp)
    if isa(exp.args[1], Symbol)
        exp.args[1]
    elseif isa(exp.args[1], Expr) && exp.args[1].head == :call # function definition
        exp.args[1].args[1]
    elseif isa(exp.args[1], Expr) && exp.args[1].head == :(=) # global variables
        exp.args[1].args[1]
    end
end

function def_init(exp) 
    if isa(exp.args[2], Expr)
        if (isa(exp.args[1], Symbol))
            return (exp.args[2], false)
        elseif (exp.args[1].head == :call) # function definition
            return (exp.args[2], true)
        end
    else
        return (exp.args[2], false)
    end
end

function eval_def(exp, env, intitial_env, glob)
    if (exp.head == :global)
        value, f_or_v = def_init(exp.args[1]) # function or value
    else
        value, f_or_v = def_init(exp)
    end


    if (f_or_v) # if its a function
        name = :placeholder
        body = :placeholder
        if (exp.head == :global)
            name = def_name(exp.args[1])
            body = def_body(exp.args[1])
            params = def_params(exp.args[1])
            augment_destructively(name, make_function(params, body, env, true), exp, env)
        else
            name = def_name(exp)
            body = def_body(exp)
            params = def_params(exp)
            augment_destructively(name, make_function(params, body, env), exp, env)
            pushfirst!(env[1][1][2][2][3], env[length(env)]) # Make the function aware of itself
        end

        nothing
    else
        if (glob)
            evaluated = evaluate(value, env)
            name = def_name(exp)
            update(find_bind(def_name(exp), evaluated, env), env, name, evaluated)
            evaluate(name, env)
        elseif (exp.head == :global ) # its an attribution or a global variable definition!
            evaluated = evaluate(value, intitial_env, env, true)
            name = def_name(exp)
            found_bound = find_bind(def_name(exp), evaluated, intitial_env)
            if (found_bound == (0,0))
                augment_destructively(name, evaluated, exp, env)
                return evaluated
            else
                update(found_bound, intitial_env, name, evaluated)
            end
            evaluate(name, intitial_env)
            
        else
            evaluated = evaluate(value, env)
            augment_destructively(def_name(exp), evaluated, exp, env)
            evaluated
        end
    end

end

update(tuplo, env, name, value) = env[tuplo[1]][tuplo[2]] = (Symbol(name), value)

update_initial(tuplo, env, name, value) = env[tuplo[1]][tuplo[2]] = (Symbol(name), value)




function find_bind(name, value, env, frame_no = 1)
    function look_up_and_update(frame)
        if frame == [] 
            frame_no = frame_no + 1                               # everytime we go deeper within frames
            find_bind(name, value, env[2:length(env)], frame_no)
        elseif (name == frame[1][1])
            return (frame_no, index)                    # Returns the tuple to be updated
        else
            index = index + 1
            look_up_and_update(frame[2:length(frame)])
        end
    end
    if (env == []) # Reached the end and it wasnt there, it's unbound!
        (0, 0) 
    else
        index = 1
        look_up_and_update(env[1]) #recursively call with the rest of the list
    end

end

function augment_destructively(name, value, exp, env)
    if exp.head == :global # global binding
        binding = (name, value)
        env[length(env)] = vcat(binding, env[length(env)])
    else   # local binding
        binding = (name, value)
        env[1] = vcat(binding, env[1])
    end
end

def_params(exp) = exp.args[1].args[2:length(exp.args[1].args)]

def_body(exp) = exp.args[2]

is_function_def(exp) = exp.head == :function ? true : false 

eval_func_def(exp, env) = (augment_destructively(def_name(exp), make_function(def_params(exp), make_block(funct_body(exp)), env), exp, env); return nothing)

funct_body(exp) = exp.args[2].args

function make_block(args)
    q = string("begin")
    for exp in args
        q = string(q, " ", exp,";")
    end
    Base.remove_linenums!(Meta.parse(string(q, " end")))

end

function is_global(exp)
    if (isa(exp, Symbol))
        return false
    end
    exp.head == :global ? true : false
end

is_and(exp) = exp.head == :&& ? true : false

is_or(exp) = exp.head == :|| ? true : false

function eval_and(exp, env) 
    evaluate(exp.args[1], env) && evaluate(exp.args[2], env)
end

function eval_or(exp, env) 
    evaluate(exp.args[1], env) || evaluate(exp.args[2], env)
end

