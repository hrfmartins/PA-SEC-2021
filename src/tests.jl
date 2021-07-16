using Test: Meta
include("eval.jl")
using Test

@test evaluate(Meta.parse("true"), Nothing) == true # Booleans

@test evaluate(Meta.parse("1.33"), Nothing) == 1.33 # Floats

@test evaluate(Meta.parse("2 + 3"), Nothing) == 5

@test evaluate(Meta.parse("2 - 3"), Nothing) == -1

@test evaluate(Meta.parse("3 * 2"), Nothing) == 6

@test evaluate(Meta.parse("6 / 2"), Nothing) == 3

@test evaluate(Meta.parse("6 // 2"), Nothing) == 3

@test evaluate(Meta.parse("6 % 2"), Nothing) == 0

# ____________ Conditions ____________

@test evaluate(Meta.parse("2 > 3"), Nothing) == false

@test evaluate(Meta.parse("6 >= 2"), Nothing) == true

@test evaluate(Meta.parse("6 <= 2"), Nothing) == false

@test evaluate(Meta.parse("6 == 2"), Nothing) == false

@test evaluate(Meta.parse("(1+1) >= (0+1)"), Nothing) == true # complex conditions

@test evaluate(Meta.parse("\"Hello World\""), Nothing) == "Hello World" # String

@test evaluate(Meta.parse("3 > 2 ? 2<3 : 0"), Nothing) == true  # ternary conditions

@test evaluate(Meta.parse("true ? 1 : 0"), Nothing) == 1  # ternary conditions

@test evaluate(Meta.parse("!false"), Nothing) == true # denial of booleans

@test evaluate(Meta.parse("!(1 > 2)"), Nothing) == true # denial of conditions