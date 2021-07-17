include("eval.jl")
using Test

initial = vcat(initial_bindings(), primitive_functions())

@test evaluate(Meta.parse("true"), initial) == true # Booleans

@test evaluate(Meta.parse("1.33"), initial) == 1.33 # Floats

@test evaluate(Meta.parse("2 + 3"), initial) == 5

@test evaluate(Meta.parse("2 - 3"), initial) == -1

@test evaluate(Meta.parse("3 * 2"), initial) == 6

@test evaluate(Meta.parse("6 / 2"), initial) == 3

@test evaluate(Meta.parse("6 // 2"), initial) == 3

@test evaluate(Meta.parse("6 % 2"), initial) == 0

# ____________ Conditions ____________

@test evaluate(Meta.parse("2 > 3"), initial) == false

@test evaluate(Meta.parse("6 >= 2"), initial) == true

@test evaluate(Meta.parse("6 <= 2"), initial) == false

@test evaluate(Meta.parse("6 == 2"), initial) == false

@test evaluate(Meta.parse("(1+1) >= (0+1)"), initial) == true # complex conditions

@test evaluate(Meta.parse("\"Hello World\""), initial) == "Hello World" # String

@test evaluate(Meta.parse("3 > 2 ? 2<3 : 0"), initial) == true  # ternary conditions

@test evaluate(Meta.parse("true ? 1 : 0"), initial) == 1  # ternary conditions

@test evaluate(Meta.parse("!false"), initial) == true # denial of booleans

@test evaluate(Meta.parse("!(1 > 2)"), initial) == true # denial of conditions

@test evaluate(Meta.parse("pi"), initial) == 3.14159

@test evaluate(Meta.parse("e"), initial) == 2.71828

@test evaluate(Meta.parse("e + 1"), initial) == 3.71828

@test evaluate(Meta.parse("let x=1; x; end"), initial) == 1

@test evaluate(Meta.parse("let x=2; x*pi; end"), initial) == 6.28318

@test evaluate(Meta.parse("let a=1, b=2; b; end"), initial) == 2

@test evaluate(Meta.parse("let a=1, b=2; b; end == 2"), initial) == true

@test evaluate(Meta.parse("let e=1; e; end"), initial) == 1 # Redefining "constants"

@test evaluate(Meta.parse("let a=1, b=2; let a=3; a+b; end; end"), initial) == 5

@test evaluate(Meta.parse(" let a = 1 
a + 2 
end"), initial) == 3

