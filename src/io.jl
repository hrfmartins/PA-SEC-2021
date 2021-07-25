include("eval.jl")

function repl()
    env = empty_environment()
    while(true)
        prompt_for_input()
        value = readline()
        val = Meta.parse(value, raise = false)
        if (isa(val, Expr))
            while ( Meta.parse(value, raise = false).head == :incomplete )
                value = string(value, "\n", readline())
            end
        end
        println(evaluate(Meta.parse(value), env))
    end

end

function prompt_for_input()
    print(">> ")
end

repl()