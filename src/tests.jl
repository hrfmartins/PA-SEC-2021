include("eval.jl")
using Test

@test evaluate(Meta.parse("2 > 3"), Nothing) == false

@test evaluate(Meta.parse("2 + 3"), Nothing) == 5

@test evaluate(Meta.parse("2 - 3"), Nothing) == -1

@test evaluate(Meta.parse("3 * 2"), Nothing) == 6

@test evaluate(Meta.parse("6 / 2"), Nothing) == 3

@test evaluate(Meta.parse("6 // 2"), Nothing) == 3

@test evaluate(Meta.parse("6 % 2"), Nothing) == 0

@test evaluate(Meta.parse("6 >= 2"), Nothing) == true

@test evaluate(Meta.parse("6 <= 2"), Nothing) == false

@test evaluate(Meta.parse("6 == 2"), Nothing) == false

@test evaluate(Meta.parse("(1+1) >= (0+1)"), Nothing) == true

