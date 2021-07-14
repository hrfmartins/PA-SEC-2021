
function second_operand(exp)
    return exp.args[3]
end

function first_operand(exp)
    return exp.args[2]
end

function isAddition(exp)
    return exp.args[1] == :+
end

function isSubtraction(exp)
    return exp.args[1] == :-
end

function isMultiplication(exp)
    return exp.args[1] == :*
end

function isDivision(exp)
    return exp.args[1] == :/
end

function isRationalDivision(exp)
    return exp.args[1] == ://
end


function isRemainder(exp)
    return exp.args[1] == :%
end

function isBiggerOp(exp)
    return exp.args[1] == :>
end

function isSmallerOp(exp)
    return exp.args[1] == :<
end

function isSmallerOrEqualOp(exp)
    return exp.args[1] == :<=
end

function isBiggerOrEqualOp(exp)
    return exp.args[1] == :>=
end

function isEqual(exp)
    return exp.args[1] == :(==)
end

function self_evaluating(exp) 
    return typeof(exp)<:Number || typeof(exp)<:String
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
    if (evaluate(exp.args[1], env))
        exp.args[2]
    else
        exp.args[3]
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