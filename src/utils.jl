
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

function self_evaluating(exp, env) 
    return typeof(exp)<:Number || typeof(exp)<:String
end