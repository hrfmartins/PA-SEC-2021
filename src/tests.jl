using Test: length
using Base: Symbol
include("eval.jl")
using Test


initial = empty_environment()

@testset "deposit and withdrawl" begin
    @test evaluate(Meta.parse("reflexive_op(exp, x) = exp(x ,x)"), initial) === nothing
    @test evaluate(Meta.parse("reflexive_op(+, 4)"), initial) === 8
end

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
    initial = empty_environment()

    @test evaluate(Meta.parse("3 > 2 ? 2<3 : 0"), initial) == (3 > 2 ? 2<3 : 0)  # ternary conditions
    @test evaluate(Meta.parse("true ? 1 : 0"), initial) == (true ? 1 : 0) # ternary conditions
end

@testset "denial operator" begin
    initial = empty_environment()

    @test evaluate(Meta.parse("!false"), initial) == !false # denial of booleans
    @test evaluate(Meta.parse("!(1 > 2)"), initial) == (!(1 > 2)) # denial of conditions
end

@testset "Let form" begin
    initial = empty_environment()

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
    initial = empty_environment()

    @test evaluate(Meta.parse("let x(y)=y; x(1); end"), initial) == (let x(y)=y; x(1); end)
    @test evaluate(Meta.parse("let x(y)=y+1; x(1); end"), initial) == (let x(y)=y+1; x(1); end)
    @test evaluate(Meta.parse("let x(y,z)=y+z; x(1,2); end"), initial) == (let x(y,z)=y+z; x(1,2); end)
    @test evaluate(Meta.parse("let x = 2; x = 3; x + 2; end"), initial) == 5 # With mixed declarations in the body
end

@testset "Let form with a mix of variables and functions" begin
    initial = empty_environment()

    @test evaluate(Meta.parse("let x = 1, y(x) = x+1; y(x+1); end"), initial) == (let x = 1, y(x) = x+1; y(x+1); end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = x+1; y(1) + z; end"), initial) == (let x = 1, z = 2, y(x) = x+1; y(1) + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = x+1; y(1) > 3 + z; end"), initial) == (let x = 1, z = 2, y(x) = x+1; y(1) > 3 + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(x) = true ? 1 : 0: false; y(1) + z; end"), initial) == (let x = 1, z = 2, y(x) = true ? 1 : 0: false; y(1) + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, y(p) = p>2 ? 1 : 0; y(1) + z; end"), initial) == (let x = 1, z = 2, y(p) = p>2 ? 1 : 0; y(1) + z; end)
    @test evaluate(Meta.parse("let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(1); end"), initial) == (let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(1); end)
    @test evaluate(Meta.parse("let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(2); end"), initial) == (let x = 1, z = 2, pair(p) = p%2 == 0 ? true : false; pair(2); end)
end

@testset "Overriding primitive functions" begin
    initial = empty_environment()

    @test evaluate(Meta.parse("let x = 1, +(x,y) = \"hello I am a sum\"; +(x, 1); end"), initial) == "hello I am a sum" # Redefining the + function
    @test evaluate(Meta.parse("let + = 10; *(+,+); end"), initial) == (let + = 10; *(+,+); end) # Redefining + as an integer and using *
    @test evaluate(Meta.parse("let x = 1, +(x,y) = x*y; +(10, 10); end"), initial) == (let x = 1, +(x,y) = x*y; +(10, 10); end)
    @test evaluate(Meta.parse("let + = *, * = +; (1 * 2) + 3; end"), initial) == (let + = *, * = +; (1 * 2) + 3; end) 
end

@testset "ifs, elseif and else" begin
    initial = empty_environment()
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
    initial = empty_environment()
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
    initial = empty_environment()
    @test evaluate(Meta.parse("x = 1+2"), initial) == (x = 1+2)
    @test evaluate(Meta.parse("x+2"), initial) == (x=1+2; x+2)
    @test evaluate(Meta.parse("triple(a) = a + a + a"), initial) === nothing
    @test evaluate(Meta.parse("triple(x+3)"), initial) == 18
end

@testset "function foo definition" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("function foo(x); x+1; end"), initial) === nothing
    @test evaluate(Meta.parse("foo(1)"), initial) == 2
end

@testset "changin baz inside the frame in the local scope" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("baz = 3"), initial) == 3
    @test evaluate(Meta.parse("let x = 0; baz = 5; end + baz"), initial) == 8
    @test evaluate(Meta.parse("let x = 0; baz = 6; end + baz"), initial) == 9
end

@testset "changing the value of a definition inside a scope (scope of the let form)" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("baz = 3"), initial) == 3
    @test evaluate(Meta.parse("let ; baz = 6; end + baz"), initial) == 9
end

@testset "defining a global inside a let form" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("let x = 1; global inc() = x + 1; end"), initial) === nothing
    @test evaluate(Meta.parse("inc()"), initial) == 2

end

@testset "accessing a global variable without global giving an error, unlike the Python behavior" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("counter = 0"), initial) == 0
    @test evaluate(Meta.parse("incr() = counter = counter + 1"), initial) === nothing
    @test evaluate(Meta.parse("incr()"), initial) == 1
end

@testset "defining global access to a variable and doing attributions" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("counter = 0"), initial) == 0
    @test evaluate(Meta.parse("incr() = global counter = counter + 1"), initial) === nothing
    @test evaluate(Meta.parse("incr()"), initial) == 1
    @test evaluate(Meta.parse("incr()"), initial) == 2
end

@testset "defining global access to a variable and doing attributions" begin
    initial = empty_environment()
    evaluate(Meta.parse("incr =
        let priv_counter = 0
        () -> priv_counter = priv_counter + 1
        end"), initial)
    initial
    @test evaluate(Meta.parse("incr()"), initial) == 1
end

@testset "defining vars inside the blocks" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("(x=1;y=2;;3;)"), initial) == (x=1;y=2;;3;)
    @test evaluate(Meta.parse("x"), initial) == (x=1;y=2;;3;x)
    @test evaluate(Meta.parse("y"), initial) == (x=1;y=2;;3;y)
    @test evaluate(Meta.parse("(x=1;y=2;;3;) == x + y"), initial) == ((x=1;y=2;;3;) == x + y)
end

@testset "short cirtuit evaluators OR" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("true || true"), initial) == true
    @test evaluate(Meta.parse("false || true"), initial) == true
    @test evaluate(Meta.parse("true || false"), initial) == true
    @test evaluate(Meta.parse("false || false"), initial) == false
    @test evaluate(Meta.parse("(true || false) && false"), initial) == false
    @test evaluate(Meta.parse("let x = 3; if x % 2 == 0 || x % 3 == 0 \"divisible by 3 or 2\" else \"not\" end ; end"), initial) == "divisible by 3 or 2"
    @test evaluate(Meta.parse("let x = 7; if x % 2 == 0 || x % 3 == 0 \"divisible by 3 or 2\" else \"not\" end ; end"), initial) == "not"
end

@testset "global variables used inside functions" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("balance = 0"), initial) === 0
    @test evaluate(Meta.parse("deposit(x) = global balance = balance + x"), initial) === nothing
    @test evaluate(Meta.parse("deposit(2)"), initial) === 2
    @test evaluate(Meta.parse("deposit(2)"), initial) === 4
end

@testset "global show_secret" begin
    @test evaluate(Meta.parse("let secret = 1234; global show_secret() = secret; end"), initial) === nothing
    @test evaluate(Meta.parse("show_secret()"), initial) === 1234
end

@testset "defining next without anonym functions" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("soma(x, y) = x + y"), initial) === nothing
    @test evaluate(Meta.parse("menos(x, y) = x - y"), initial) === nothing
    @test evaluate(Meta.parse("next(i) = (if i < 0 menos else soma end)( i, 1)"), initial) === nothing
    @test evaluate(Meta.parse("next(1)"), initial) === 2
end

@testset "lambda functions - anonym" begin
    @test evaluate(Meta.parse("(x -> x + 1)(2)"), initial) === 3
    @test evaluate(Meta.parse("((x, y, z) -> x + y + z)(2, 2, 4)"), initial) === 8
    @test evaluate(Meta.parse("(() -> 5)()"), initial) === 5
    @test evaluate(Meta.parse("((x, y) -> x + y)(1, 2)"), initial) === 3
end

@testset "lambda functions - anonym" begin
    intial = empty_environment()
    @test evaluate(Meta.parse("balance = 0"), initial) === 0
    @test evaluate(Meta.parse("deposit(q) = global balance = balance + q"), initial) === nothing
    @test evaluate(Meta.parse("withdraw(q) = global balance = balance - q"), initial) === nothing
    @test evaluate(Meta.parse("deposit(200)"), initial) === 200
    @test evaluate(Meta.parse("withdraw(50)"), initial) === 150
    @test evaluate(Meta.parse("deposit_and_withdraw(deposited, withdrawed) = (deposit(deposited); withdraw(withdrawed))"), initial) === nothing
    @test evaluate(Meta.parse("deposit_and_withdraw(100, 20)"), initial) === 230
    @test evaluate(Meta.parse("deposit_and_apply_taxes(deposit, tax) = deposit_and_withdraw(deposit, tax*deposit)"), initial) === nothing
    @test evaluate(Meta.parse("deposit_and_apply_taxes(100, 0.4)"), initial) === 290.0
    
end

@testset "updating balance with withdraw and deposit functions" begin
    @test evaluate(Meta.parse("balance = 0"), initial) === 0
    @test evaluate(Meta.parse("deposit(q) = global balance = balance + q"), initial) === nothing
    @test evaluate(Meta.parse("withdraw(q) = global balance = balance - q"), initial) === nothing
    @test evaluate(Meta.parse("deposit(200)"), initial) === 200 
    @test evaluate(Meta.parse("withdraw(50)"), initial) === 150 
    @test evaluate(Meta.parse("balance"), initial) === 150
end

@testset "Higher Order functions with anonym functions" begin
    initial = empty_environment()
    @test evaluate(Meta.parse("sum(f, a, b) =
    a > b ?
    0 :
    f(a) + sum(f, a + 1, b)"), initial) === nothing
    
    @test evaluate(Meta.parse("sum(x -> x*x, 1, 10)"), initial) === 385

    @test evaluate(Meta.parse("next(i) = (if i < 0 (x->x-x) else (x->x+x) end)( i, 1)"), initial) === nothing
    @test evaluate(Meta.parse("next(1)"), initial) === 2
end

@testset "updating balance with withdraw and deposit functions with let form from project statement" begin
    evaluate(Meta.parse("let priv_balance = 0
    global deposit = (quantity -> priv_balance = priv_balance + quantity)
    global withdraw = (quantity -> priv_balance = priv_balance - quantity)
    end"), initial)
    @test evaluate(Meta.parse("deposit(200)"), initial) === 200
    @test evaluate(Meta.parse("withdraw(50)"), initial) === 150 # FAIL
end

@test evaluate(Meta.parse("true"), initial) == true