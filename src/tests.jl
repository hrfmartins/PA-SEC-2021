using Test: length
using Base: Symbol
include("eval.jl")
using Test

initial = empty_environment()

initial

evaluate(Meta.parse("f(x,y) = (println(x); println(y);)"), initial)

evaluate(Meta.parse("f(1,2)"), initial)

@test evaluate(Meta.parse("(x=1;;;3;)"), initial) == 3
initial
@test evaluate(Meta.parse("x"), initial) == 1

@testset "Simple operations tests" begin
    @test evaluate(Meta.parse("2 + 3"), initial) == 2 + 3
    @test evaluate(Meta.parse("2 - 3"), initial) == 2 - 3
    @test evaluate(Meta.parse("3 * 2"), initial) == 3 * 2
    @test evaluate(Meta.parse("6 / 2"), initial) == 6 / 2
    @test evaluate(Meta.parse("6 // 2"), initial) == 6 // 2
    @test evaluate(Meta.parse("6 % 2"), initial) == 6 % 2

    @test evaluate(Meta.parse("2 + 3 * 4"), initial) == 2 + 3 * 4
    @test evaluate(Meta.parse("2 + 3 + 4"), initial) == 2 + 3 + 4
    @test evaluate(Meta.parse("2 + 3 - 4"), initial) == 2 + 3 - 4
    @test evaluate(Meta.parse("(2 + 3) / 4"), initial) == (2 + 3) / 4

    @test evaluate(Meta.parse("2 > 3"), initial) == (2 > 3)
    @test evaluate(Meta.parse("6 >= 2"), initial) == (6 >= 2)
    @test evaluate(Meta.parse("6 <= 2"), initial) == (6 <= 2)
    @test evaluate(Meta.parse("6 == 2"), initial) == (6 == 2)
    @test evaluate(Meta.parse("(1 + 1 + 1) >= (0+1)"), initial) == ((1 + 1 + 1) >= (0+1)) # complex conditions

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
    @test evaluate(Meta.parse("3 > 2 ? 2<3 : 0"), initial) == (3 > 2 ? 2<3 : 0)  # ternary conditions
    @test evaluate(Meta.parse("true ? 1 : 0"), initial) == (true ? 1 : 0) # ternary conditions
end

@testset "denial operator" begin
    @test evaluate(Meta.parse("!false"), initial) == !false # denial of booleans
    @test evaluate(Meta.parse("!(1 > 2)"), initial) == (!(1 > 2)) # denial of conditions
end

@testset "Let form" begin
    @test evaluate(Meta.parse("let x=1; x; end"), initial) == (let x=1; x; end)
    @test evaluate(Meta.parse("let x=2; x*pi; end"), initial) == 6.28318
    @test evaluate(Meta.parse("let a=1, b=2; b; end"), initial) == (let a=1, b=2; b; end)
    @test evaluate(Meta.parse("let a=1, b=2; b; end == 2"), initial) == (let a=1, b=2; b; end == 2)
    @test evaluate(Meta.parse("let e=1; e; end"), initial) == (let e=1; e; end) # Redefining "constants"
    @test evaluate(Meta.parse("let a=1, b=2; let a=3; a+b; end; end"), initial) == (let a=1, b=2; let a=3; a+b; end; end)
    @test evaluate(Meta.parse(" let a = 1 
    a + 2 
    end"), initial) == 3
end

@testset "Let form for functions" begin
    @test evaluate(Meta.parse("let x(y)=y; x(1); end"), initial) == (let x(y)=y; x(1); end)
    @test evaluate(Meta.parse("let x(y)=y+1; x(1); end"), initial) == (let x(y)=y+1; x(1); end)
    @test evaluate(Meta.parse("let x(y,z)=y+z; x(1,2); end"), initial) == (let x(y,z)=y+z; x(1,2); end)
end

@testset "Let form with a mix of variables and functions" begin
    @test evaluate(Meta.parse("let x = 1, y(x) = x+1; y(x+1); end"), initial) == (let x = 1, y(x) = x+1; y(x+1); end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = x+1; y(1) + z; end"), initial) == (let x = 1, z = 2, y(x) = x+1; y(1) + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = x+1; y(1) > 3 + z; end"), initial) == (let x = 1, z = 2, y(x) = x+1; y(1) > 3 + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = true ? 1 : 0: false; y(1) + z; end"), initial) == (let x = 1, z = 2, y(x) = true ? 1 : 0: false; y(1) + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(p) = p>2 ? 1 : 0; y(1) + z; end"), initial) == (let x = 1, z = 2, y(p) = p>2 ? 1 : 0; y(1) + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(1); end"), initial) == (let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(1); end)
    @test evaluate(Meta.parse("let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(2); end"), initial) == (let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(2); end)
end

@testset "Overriding primitive functions" begin
    @test evaluate(Meta.parse("let x = 1, +(x,y) = \"hello I am a sum\"; +(x, 1); end"), initial) == "hello I am a sum" # Redefining the + function
    @test evaluate(Meta.parse("let + = 10; *(+,+); end"), initial) == (let + = 10; *(+,+); end) # Redefining + as an integer and using *
    @test evaluate(Meta.parse("let x = 1, +(x,y) = x*y; +(10, 10); end"), initial) == (let x = 1, +(x,y) = x*y; +(10, 10); end)
    @test evaluate(Meta.parse("let + = *, * = +; (1 * 2) + 3; end"), initial) == (let + = *, * = +; (1 * 2) + 3; end)  #FIXME implementar sequential reading
end

@testset "ifs, elseif and else" begin
    @test evaluate(Meta.parse("if 1 > 3 1 elseif 3 > 3 3 else 2 end"), initial) == (if 1 > 3 1 elseif 3 > 3 3 else 2 end)
    @test evaluate(Meta.parse("if 4 > 3 3 end"), initial) == (if 4 > 3 3 end)
    @test evaluate(Meta.parse("if 3 > 3 3 elseif 4 > 3 4 end"), initial) == (if 3 > 3 3 elseif 4 > 3 4 end)
    @test evaluate(Meta.parse("if 4 > 3 3 else 2 end"), initial) == (if 4 > 3 3 else 2 end)
    @test evaluate(Meta.parse("if 3 > 3 3 else 2 end"), initial) == (if 3 > 3 3 else 2 end)
    @test evaluate(Meta.parse("if 3 > 2 1 else 0 end"), initial) == (if 3 > 2 1 else 0 end)
    @test evaluate(Meta.parse("if 3 < 2 1 elseif 2 > 3 2 else 0 end"), initial) === (if 3 < 2 1 elseif 2 > 3 2 else 0 end)

    @test evaluate(Meta.parse("let abs(x) = if x > 1 x else -x end; abs(-1); end"), initial) == (let abs(x) = if x > 1 x else -x end; abs(-1); end)

end

@testset "Blocks with begin and (;;)" begin
    @test evaluate(Meta.parse("begin 1+2; 2*3; 3/4 end"), initial) == (begin 1+2; 2*3; 3/4 end)
    @test evaluate(Meta.parse("(1+2;1;2;3;4)"), initial) == ((1+2;1;2;3;4))
    @test evaluate(Meta.parse("(1+2;1;2;3;)"), initial) == (1+2;1;2;3;)
    @test evaluate(Meta.parse("(1;;;3;)"), initial) == (1;;;3;)
    @test evaluate(Meta.parse("(1;;;true;)"), initial) == (1;;;true;)
    @test evaluate(Meta.parse("(1+2;;let y(x) = x; y(1); end;)"), initial) == (1+2;;let y(x) = x; y(1); end;)
    @test evaluate(Meta.parse("begin 1+2; 2*3; 3/4 end == 3/4"), initial) == (begin 1+2; 2*3; 3/4 end == 3/4)
    @test evaluate(Meta.parse("begin 1+2; end"), initial) == (begin 1+2; end)
end

@testset "example defining variable x, and function triple" begin
    @test evaluate(Meta.parse("x = 1+2"), initial) == (x = 1+2)
    @test evaluate(Meta.parse("x+2"), initial) == (x=1+2; x+2)
    @test evaluate(Meta.parse("triple(a) = a + a + a"), initial) === nothing
    @test evaluate(Meta.parse("triple(x+3)"), initial) == 18
end

@testset "function foo definition" begin
    @test evaluate(Meta.parse("function foo(x); x+1; end"), initial) === nothing
    @test evaluate(Meta.parse("foo(1)"), initial) == 2
end

@testset "changin baz inside the frame in the local scope" begin
    @test evaluate(Meta.parse("baz = 3"), initial) == 3
    @test evaluate(Meta.parse("let x = 0; baz = 5; end + baz"), initial) == 8
    @test evaluate(Meta.parse("let x = 0; baz = 6; end + baz"), initial) == 9
end

@testset "changing the value of a definition inside a scope (scope of the let form)" begin
    @test evaluate(Meta.parse("baz = 3"), initial) == 3
    @test evaluate(Meta.parse("let ; baz = 6; end + baz"), initial) == 9
end

@testset "defining a global inside a let form" begin # FIXME fix global forms
    initial = empty_environment()
    @test evaluate(Meta.parse("let x = 1; global inc() = x; end"), initial) === nothing
    @test evaluate(Meta.parse("inc()"), initial) == 1

end

@testset "accessing a global variable without global giving an error, unlike the Python behavior" begin
    @test evaluate(Meta.parse("counter = 0"), initial) == 0
    @test evaluate(Meta.parse("incr() = counter = counter + 1"), initial) === nothing
    @test evaluate(Meta.parse("incr()"), initial) == 1
end

@testset "accessing a global variable without global giving an error, like the Python inherited behavior" begin
    @test evaluate(Meta.parse("counter = 0"), initial) == 0
    @test evaluate(Meta.parse("global incr() = counter = counter + 1"), initial) === nothing
    @test evaluate(Meta.parse("incr()"), initial) == 1
    @test evaluate(Meta.parse("incr()"), initial) == 2 # FIXME global form
end

@testset "defining vars inside the blocks" begin
    @test evaluate(Meta.parse("(x=1;y=2;;3;)"), initial) == (x=1;y=2;;3;)
    @test evaluate(Meta.parse("x"), initial) == (x=1;y=2;;3;x)
    @test evaluate(Meta.parse("y"), initial) == (x=1;y=2;;3;y)
    @test evaluate(Meta.parse("(x=1;y=2;;3;) == x + y"), initial) == ((x=1;y=2;;3;) == x + y)
end



@test evaluate(Meta.parse("true"), initial) == true