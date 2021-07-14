include("utils.jl")

function evaluate(exp, env)
    if (self_evaluating(exp, env))
        return exp
    end
    if (typeof(exp) == Expr)
        if isAddition(exp)
            evaluate(first_operand(exp), env) + evaluate(second_operand(exp), env)

        elseif isSubtraction(exp)
            evaluate(first_operand(exp), env) - evaluate(second_operand(exp), env)

        elseif isMultiplication(exp)
            evaluate(first_operand(exp), env) * evaluate(second_operand(exp), env)

        elseif isRemainder(exp)
            evaluate(first_operand(exp), env) % evaluate(second_operand(exp), env)

        elseif isDivision(exp)
            evaluate(first_operand(exp), env) / evaluate(second_operand(exp), env)

        elseif isRationalDivision(exp)
            evaluate(first_operand(exp), env) // evaluate(second_operand(exp), env)

        elseif isEqual(exp)
            evaluate(first_operand(exp), env) == evaluate(second_operand(exp), env)

        elseif isSmallerOp(exp)
            evaluate(first_operand(exp), env) < evaluate(second_operand(exp), env)

        elseif isBiggerOp(exp)
            evaluate(first_operand(exp), env) > evaluate(second_operand(exp), env)
        
        elseif isSmallerOrEqualOp(exp)
            evaluate(first_operand(exp), env) <= evaluate(second_operand(exp), env)

        elseif isBiggerOrEqualOp(exp)
            evaluate(first_operand(exp), env) >= evaluate(second_operand(exp), env)

        else
            error("Unknown Expression ",exp," Type")
        end
    
    else
        error("Unknown ", exp, " Type")
    end
end
