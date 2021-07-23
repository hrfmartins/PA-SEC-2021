using Test: length
using Base: Symbol
include("eval.jl")
using Test

initial = vcat(initial_bindings(), primitive_functions())

@testset "Simple operations tests" begin
    @test evaluate(Meta.parse("2 + 3"), initial) == 5
    @test evaluate(Meta.parse("2 - 3"), initial) == -1
    @test evaluate(Meta.parse("3 * 2"), initial) == 6
    @test evaluate(Meta.parse("6 / 2"), initial) == 3
    @test evaluate(Meta.parse("6 // 2"), initial) == 3
    @test evaluate(Meta.parse("6 % 2"), initial) == 0

    @test evaluate(Meta.parse("2 + 3 * 4"), initial) == 14
    @test evaluate(Meta.parse("2 + 3 + 4"), initial) == 9
    @test evaluate(Meta.parse("2 + 3 - 4"), initial) == 1
    @test evaluate(Meta.parse("(2 + 3) / 4"), initial) == 1.25

    @test evaluate(Meta.parse("2 > 3"), initial) == false
    @test evaluate(Meta.parse("6 >= 2"), initial) == true
    @test evaluate(Meta.parse("6 <= 2"), initial) == false
    @test evaluate(Meta.parse("6 == 2"), initial) == false
    @test evaluate(Meta.parse("(1 + 1 + 1) >= (0+1)"), initial) == true # complex conditions

end

@testset "Self-evaluating" begin
    @test evaluate(Meta.parse("\"Hello World\""), initial) == "Hello World" # String
    @test evaluate(Meta.parse("1"), initial) == 1 
    @test evaluate(Meta.parse("true"), initial) == true
    @test evaluate(Meta.parse("-6"), initial) == -6

end

@testset "Constants pi and e" begin
    @test evaluate(Meta.parse("pi"), initial) == 3.14159
    @test evaluate(Meta.parse("e"), initial) == 2.71828
    @test evaluate(Meta.parse("e + 1"), initial) == 3.71828
end

@testset "ternary conditions" begin
    @test evaluate(Meta.parse("3 > 2 ? 2<3 : 0"), initial) == true  # ternary conditions
    @test evaluate(Meta.parse("true ? 1 : 0"), initial) == 1  # ternary conditions
end

@testset "denial operator" begin
    @test evaluate(Meta.parse("!false"), initial) == true # denial of booleans
    @test evaluate(Meta.parse("!(1 > 2)"), initial) == true # denial of conditions
end

@testset "Let form" begin
    @test evaluate(Meta.parse("let x=1; x; end"), initial) == 1
    @test evaluate(Meta.parse("let x=2; x*pi; end"), initial) == 6.28318
    @test evaluate(Meta.parse("let a=1, b=2; b; end"), initial) == 2
    @test evaluate(Meta.parse("let a=1, b=2; b; end == 2"), initial) == true
    @test evaluate(Meta.parse("let e=1; e; end"), initial) == 1 # Redefining "constants"
    @test evaluate(Meta.parse("let a=1, b=2; let a=3; a+b; end; end"), initial) == 5
    @test evaluate(Meta.parse(" let a = 1 
    a + 2 
    end"), initial) == 3
end

@testset "Let form for functions" begin
    @test evaluate(Meta.parse("let x(y)=y; x(1); end"), initial) == 1
    @test evaluate(Meta.parse("let x(y)=y+1; x(1); end"), initial) == 2
    @test evaluate(Meta.parse("let x(y,z)=y+z; x(1,2); end"), initial) == 3
end

@testset "Let form with a mix of variables and functions" begin
    @test evaluate(Meta.parse("let x = 1, y(x) = x+1; y(x+1); end"), initial) == 3
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = x+1; y(1) + z; end"), initial) == 4
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = x+1; y(1) > 3 + z; end"), initial) == false
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = true ? 1 : 0: false; y(1) + z; end"), initial) == 3
    @test evaluate(Meta.parse("let x = 1, z = 2, y(p) = p>2 ? 1 : 0; y(1) + z; end"), initial) == 2
    @test evaluate(Meta.parse("let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(1); end"), initial) == false
    @test evaluate(Meta.parse("let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(2); end"), initial) == true
end

@testset "Overriding primitive functions" begin
    @test evaluate(Meta.parse("let x = 1, +(x,y) = \"hello I am a sum\"; +(x, 1); end"), initial) == "hello I am a sum" # Redefining the + function
    @test evaluate(Meta.parse("let + = 10; *(+,+); end"), initial) == 100 # Redefining + as an integer and using *
    @test evaluate(Meta.parse("let x = 1, +(x,y) = x*y; +(10, 10); end"), initial) == 100
    @test evaluate(Meta.parse("let + = *, * = +; (1 * 2) + 3; end"), initial) == 9
    @test evaluate(Meta.parse("let (+ , *) = (*, +) ; (1 * 2) + 3; end"), initial) == 9

end

@testset "ifs, elseif and else" begin
    @test evaluate(Meta.parse("if 1 > 3 1 elseif 3 > 3 3 else 2 end"), initial) == 2
    @test evaluate(Meta.parse("if 4 > 3 3 end"), initial) == 3
    @test evaluate(Meta.parse("if 3 > 3 3 elseif 4 > 3 4 end"), initial) == 4
    @test evaluate(Meta.parse("if 4 > 3 3 else 2 end"), initial) == 3
    @test evaluate(Meta.parse("if 3 > 3 3 else 2 end"), initial) == 2
    @test evaluate(Meta.parse("if 3 > 2 1 else 0 end"), initial) == 1
    @test evaluate(Meta.parse("if 3 < 2 1 elseif 2 > 3 2 else 0 end"), initial) === 0

    @test evaluate(Meta.parse("let abs(x) = if x > 1 x else -x end; abs(-1); end"), initial) == 1

end

@testset "Blocks with begin and (;;)" begin
    @test evaluate(Meta.parse("begin 1+2; 2*3; 3/4 end"), initial) == 0.75
    @test evaluate(Meta.parse("(1+2;1;2;3;4)"), initial) == 4
    @test evaluate(Meta.parse("(1+2;1;2;3;)"), initial) == 3
    @test evaluate(Meta.parse("(1;;;3;)"), initial) == 3
    @test evaluate(Meta.parse("(1;;;true;)"), initial) == true
    @test evaluate(Meta.parse("(1+2;;let y(x) = x; y(1); end;)"), initial) == 1
    @test evaluate(Meta.parse("begin 1+2; 2*3; 3/4 end == 3/4"), initial) == true
    @test evaluate(Meta.parse("begin 1+2; end"), initial) == 3
end

@testset "example defining variable x, and function triple" begin
    @test evaluate(Meta.parse("x = 1+2"), initial) == 3
    @test evaluate(Meta.parse("x+2"), initial) == 5
    @test evaluate(Meta.parse("triple(a) = a + a + a"), initial) === nothing
    @test evaluate(Meta.parse("triple(x+3)"), initial) == 18
end

@testset "function foo definition" begin
    @test evaluate(Meta.parse("function foo(x); x+1; end"), initial) === nothing
    @test evaluate(Meta.parse("foo(1)"), initial) == 2
end

@testset "function foo definition" begin
    @test evaluate(Meta.parse("baz = 3"), initial) == 3
    @test evaluate(Meta.parse("let x = 0; baz = 5; end + baz"), initial) == 8
    @test evaluate(Meta.parse("let x = 0; baz = 6; end + baz"), initial) == 9
end

@test evaluate(Meta.parse("true"), initial) == true
