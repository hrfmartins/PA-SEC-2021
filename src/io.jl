include("eval.jl")

function repl()
    while(true)
        prompt_for_input()
        value = readline()
        while ( Meta.parse(value, raise = false).head == :incomplete )
            value = string(value, "\n", readline())
        end
        println(evaluate(Meta.parse(value), empty_environment()))
    end

end

function prompt_for_input()
    print(">> ")
end
