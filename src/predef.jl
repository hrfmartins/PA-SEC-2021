function make_primitive(exp)
    eval(Meta.parse(string("(x,y) -> ", String(Symbol(exp)), "( x", ", y)")))
end

function make_primitive_single(exp)
    eval(Meta.parse(string("(x) -> ", String(Symbol(exp)), "( x )")))
end

function initial_bindings()
    return const_bindings
end

function primitive_functions()
    return pre_def
end

function is_primitive(exp)
    filter(x -> x[1] == exp.args[1], pre_def) != []
end

function apply_primitive(exp, p, q, env)
    filter(x -> x[1] == exp.args[1], env)[1][2](p, q)
end

function apply_primitive_single(exp, p, env)
    filter(x -> x[1] == exp.args[1], env)[1][2](p)
end

pre_def = [ (:+, make_primitive(+)),
            (:-, make_primitive(-)),
            (:/, make_primitive(/)),
            (:*, make_primitive(*)),
            (:>, make_primitive(>)),
            (:<, make_primitive(<)),
            (:(>=), make_primitive(>=)),
            (:(<=), make_primitive(<=)),
            (:(==), make_primitive(==)),
            (:(!=), make_primitive(!=)),
            (:%, make_primitive(%)),
            (:!, make_primitive_single(!)),
            (:(//), make_primitive(//))
]

const_bindings = [(:pi, 3.14159),  (:e, 2.71828)]
