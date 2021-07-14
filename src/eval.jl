include("utils.jl")

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
            
        else # In case its a simple expression like an addition
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
            end
        end
    
    else
        error("Unknown ", exp, " Type")
    end
end