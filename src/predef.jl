function make_primitive(exp)
    expr = Expr(:call, exp, :x, :y)
    return (Symbol(exp), (:function, ([:x, :y], expr)))
end

function make_prim(exp)
    expr = Expr(:call, exp, :x, :y)
    return (:function, ([:x, :y], expr))
end

function make_prim_no_args(exp)
    expr = Expr(:call, exp)
    return (:function, ([], expr))
end

function make_prim_single(exp)
    expr = Expr(:call, exp, :x)
    return (:function, ([:x], expr))
end

function make_primitive_single(exp)
    expr = Expr(:call, exp, :x)
    return (Symbol(exp), (:function, ([:x], expr)))

end

function make_primitive_indiv(exp)
    expr = Expr(:call, exp)
    return (Symbol(exp), (:function, ([], expr)))

end

function initial_bindings()
    return const_bindings
end

function primitive_or_user_def(func, env)
    if (func in pre_def_set)
        if (func in pre_def && func in env[length(env)][1:len(env)-len(pre_def)]) # the expression on the right gives us the new defenitions (and redefenitions of primary)
         # its user defined and it was a primary function, its in the set and it was initially
            return false
        else
            return true
        end
    else
        return false
    end
end

function primitive_functions()
    return pre_def
end

function is_primitive(exp)
    filter(x -> x[1] == exp[2][2], pre_def) != []
end

function apply_primitive(func, args)
    x = Meta.parse(string(Symbol(func[2][2].args[1]), Tuple(args)))
    eval(x)
end

function apply_primitive_single(func, args)
    x = Meta.parse(string(Symbol(func[2][2].args[1]), "(", args[1], ")"))
    eval(x) 
end

pre_def = [ make_primitive(+),
            make_primitive(-),
            make_primitive(/),
            make_primitive(*),
            make_primitive(>),
            make_primitive(<),
            make_primitive(>=),
            make_primitive(<=),
            make_primitive(==),
            make_primitive(!=),
            make_primitive(:%),
            make_primitive_single(!),
            make_primitive_single(-),
            make_primitive(//),
            make_primitive_single(println),
            make_primitive_single(readline),
            make_primitive_indiv(exit)

]

pre_def_set = [ make_prim(+),
            make_prim(-),
            make_prim(/),
            make_prim(*),
            make_prim(>),
            make_prim(<),
            make_prim(>=),
            make_prim(<=),
            make_prim(==),
            make_prim(!=),
            make_prim(:%),
            make_prim_single(!),
            make_prim_single(-),
            make_prim(//),
            make_prim_single(println),
            make_prim_single(readline),
            make_prim_no_args(exit)

            
]

const_bindings = [(:pi, 3.14159),  (:e, 2.71828)]
