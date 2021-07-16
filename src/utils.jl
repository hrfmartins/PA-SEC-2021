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
    return typeof(exp) == Symbol
end

function eval_name(exp, env)
    #TODO
end

function let_expr(expr)
    if (typeof(expr) == Vector)
        return expr.head == Vector
    end
    return false
end

function eval_expr()
    #TODO
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