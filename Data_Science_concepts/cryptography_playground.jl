# cryptography.jl

# naive prime-checker
function prime_checker_naive(x::Integer)::Bool
    """
    checks for even divisibility by all factors between 2 and sqrt(x), inclusive
    """
    if x < 2
        return false
    end
    for i in 2:(ceil(sqrt(x)))
        if x % i == 0
            return false
        end
    end
    return true
end

# naive prime generator
function prime_generator_naive(n::Integer)::Set{Integer} 
    primes = Set(2:n) 
    for i in 2:n 
        if ! prime_checker_naive(i)
            delete!(primes, i)
        end
    end 
    return primes 
end 


# simple sieve prime generator 
function prime_generator_simple_sieve(n::Integer)#::Set{Integer} 
    primes = Set(2:n) 
    ticks = 0
    for i in 2:n 
        ticks += 1
        if i in primes 
            for j in 2:ceil(n/i) 
                delete!(primes, i*j)
                ticks += 1 
            end 
        end 
    end 
    return (n=n, ticks=ticks), primes
end 


# segmented abritrary-sieve prime generator 
function prime_generator_abritrary_sieve(lower::Integer=1_000, upper::Integer=10_000)
    check_n = ceil(sqrt(upper))
    check_primes = Set(2:check_n) 
    ticks = 0 
    for i in 2:check_n
        ticks += 1
        if i in check_primes 
            for j in 2:ceil(check_n / i) 
                ticks += 1 
                delete!(check_primes, i*j)
            end 
        end 
    end 
    primes = Set(max(2, lower) : upper)
    for p in check_primes
        for q in max(2, ceil(lower / p)) : max(2, floor(upper / p))
            ticks += 1
            delete!(primes, p*q)
        end
    end
    return (n=upper-lower, ticks=ticks), primes
end


