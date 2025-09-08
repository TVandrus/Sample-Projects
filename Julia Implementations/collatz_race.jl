### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ e3473b0e-629f-4d3f-8112-2b1c066a6c7d
using Base.Threads

# ╔═╡ dce2fe8f-6982-4ba7-9288-562c5a209574
md"# collatz_race.jl demo notebook"

# ╔═╡ 6341c3f0-f583-11ef-0ea0-3b774a224d61
md"collatz race to 1 billion

for a large sample space of positive integers `s` 
confirm that all elements terminate their collatz sequence in '1'
and record the path length"

# ╔═╡ 66deeeb2-e0dc-42a3-b9c8-efc457f62084
md"## functions"

# ╔═╡ bac6ce64-eecb-4176-a52c-589cae405072
Base.Threads.nthreads()

# ╔═╡ 16c95105-1184-45ac-8931-fa9c8c57d486
function collatz_path_recursive(i::Integer, path::Integer=0)::Integer
	"""
	base case, brute force
	"""
    if i == 1
        return path
    elseif iseven(i)
        return collatz_path_recursive(i ÷ 2, path+1)
    else 
        return collatz_path_recursive(3 * i + 1, path+1)
    end
end 

# ╔═╡ af1a49c5-2ce3-45c8-a52b-b72c7a81ab0a
function collatz_map!(m::Dict{I, I} where I <: Integer, i::Integer)     
	"""
	avoid re-computing paths where possible
	"""    
	if !haskey(m, i) # if not found in map
        if iseven(i)
            m[i] = 1 + collatz_map!(m, i ÷ 2)[2]
        else 
            m[i] = 1 + collatz_map!(m, 3 * i + 1)[2]
        end
    end
    return m, m[i]
end

# ╔═╡ 580eb5b5-e646-4b58-83eb-358aa12cb781
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

# ╔═╡ 226dbfce-f1aa-470f-94b4-d3987558b806
md"## performance testing"

# ╔═╡ 8a309050-7292-4601-af37-bb8ec8573e0c
space = 1:5_000_000

# ╔═╡ 9c5668cf-f80c-44ba-a9e8-34aa2c7894a8
begin
	result_map = Dict(1=>0);
	@time for i in space
	    collatz_map!(result_map, i)
	end
	result_map;
end

# ╔═╡ 5617b5b3-817e-4345-886f-63d2f40e7d99
begin
	result_batch_map = Dict(1=>0);
	@time collatz_batch!(result_batch_map, space);
	result_batch_map;
end

# ╔═╡ 01ea8a2f-aeb9-47dc-a2e5-7e0d82565ad3
begin
	result_recursive = Dict(1=>0);
	@time for i in space
	    result_recursive[i] = collatz_path_recursive(i)
	end 
	result_recursive;
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╟─dce2fe8f-6982-4ba7-9288-562c5a209574
# ╟─6341c3f0-f583-11ef-0ea0-3b774a224d61
# ╟─66deeeb2-e0dc-42a3-b9c8-efc457f62084
# ╠═e3473b0e-629f-4d3f-8112-2b1c066a6c7d
# ╠═bac6ce64-eecb-4176-a52c-589cae405072
# ╠═16c95105-1184-45ac-8931-fa9c8c57d486
# ╠═af1a49c5-2ce3-45c8-a52b-b72c7a81ab0a
# ╠═580eb5b5-e646-4b58-83eb-358aa12cb781
# ╟─226dbfce-f1aa-470f-94b4-d3987558b806
# ╠═8a309050-7292-4601-af37-bb8ec8573e0c
# ╠═9c5668cf-f80c-44ba-a9e8-34aa2c7894a8
# ╠═5617b5b3-817e-4345-886f-63d2f40e7d99
# ╠═01ea8a2f-aeb9-47dc-a2e5-7e0d82565ad3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
