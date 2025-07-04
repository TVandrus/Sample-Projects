"""
collatz race to 1 billion

for a large sample space of positive integers `s` 
confirm that all elements terminate their collatz sequence in '1'
and record the path length
"""


####################
# definition section
####################


"""
base case, brute force
"""
function collatz_path_recursive(i::Integer, path::Integer=0)::Integer
    if i == 1
        return path
    elseif iseven(i)
        return collatz_path_recursive(i ÷ 2, path+1)
    else 
        return collatz_path_recursive(3 * i + 1, path+1)
    end
end 


"""
avoid re-computing paths where possible
"""
function collatz_map!(m::Dict{I, I} where I <: Integer, i::Integer)     
    if !haskey(m, i) # if not found in map
        if iseven(i)
            m[i] = 1 + collatz_map!(m, i ÷ 2)[2]
        else 
            m[i] = 1 + collatz_map!(m, 3 * i + 1)[2]
        end
    end
    return m, m[i]
end


function collatz_batch!(m::Dict{I, I} where I <: Integer, batch)
    s = Set(batch)
    setdiff!(s, keys(m)) # find unmapped items from s
    while length(s) > 0
        for i in s 
            if iseven(i)
                m[i] = 1 + collatz_map!(m, i ÷ 2)[2]
            end
        end
        setdiff!(s, keys(m))
        for i in s 
            if !iseven(i)
                m[i] = 1 + collatz_map!(m, 3 * i + 1)[2]
            end
        end
        setdiff!(s, keys(m))
    end
    return m
end


####################
# testing section
####################

space = 1:50_000_000
#space = rand(space, length(space));


result_recursive = Dict(1=>0);
@time for i in space
    result_recursive[i] = collatz_path_recursive(i)
end 
result_recursive;

result_map = Dict(1=>0);
@time for i in space
    collatz_map!(result_map, i)
end
result_map;

result_batch_map = Dict(1=>0);
@time collatz_batch!(result_batch_map, space);
result_batch_map;


result_recursive = nothing
result_map = nothing
result_batch_map = nothing
