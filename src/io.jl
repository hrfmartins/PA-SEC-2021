include("eval.jl")

function repl()
    while (true)
        prompt_for_input()
        value = readline()
        println(evaluate(Meta.parse(value), Nothing))
    end
end

function prompt_for_input()
    print(">> ")
end
