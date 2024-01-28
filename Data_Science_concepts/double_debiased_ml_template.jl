### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ e08688d0-752f-11ee-150f-51ef33f03b0a
using XGBoost, DuckDB, DataFrames, CategoricalArrays

# ╔═╡ a4fdd2d9-fb27-401c-b99c-018f3df71eba
db_loc = "__local_artifacts__/portable.duckdb";

# ╔═╡ ca89b3a5-529e-4a13-a59c-705aab63519d
begin
	# retrieve data 
	db = DuckDB.open(db_loc)
	con = DuckDB.connect(db)
	results = DuckDB.execute(con, "select * from sim.archery")
	DuckDB.disconnect(con)
	DuckDB.close(db)
end

# ╔═╡ 9c47ef5c-184c-4b9d-bbae-6f6090eff314
feature_df = DuckDB.toDataFrame(results);

# ╔═╡ 53dbaa27-1254-44da-8b16-99bce522cce0
feature_df.skill = categorical(feature_df.skill)

# ╔═╡ 3b8a1037-ae56-4697-b559-d14b34cf337c
Y = feature_df.:score;

# ╔═╡ ffe4249d-dcf3-4260-a3f8-7710279ad3c6
T = feature_df.:bow;

# ╔═╡ 9df19072-bf82-4009-ab20-7c4a7f200d7d
x_cols = [
	:skill,
	:strength, 
	:range,
	:arrow,
	:wind, 
]

# ╔═╡ 9ad92de3-bc79-4565-984f-4371cfa0ba9f
X = feature_df[!, x_cols]

# ╔═╡ d8704407-b4f5-4851-b9bf-353d28a8f165
begin
	n = nrow(X)
	aux_1 = n / 2
end

# ╔═╡ 538bd9eb-4bf1-4353-8954-ac06767a802e
# specify models
# Y ~ X
Y_model_params = (
	booster="gbtree", 
	objective="binary:logistic",
	tree_method="hist", 
	num_round=1, 
	eta=1, 
	num_parallel_tree=200, 
	subsample=0.66, 
	sampling_method="uniform", 
	max_depth=10, 
	colsample_bynode=0.6, 
	min_split_loss=0, 
	min_child_weight=0, 
	max_leaves=100, 
	max_delta_step=Inf, 
	reg_alpha=0, 
	reg_lambda=0, 
	max_bin=256, 
	grow_policy="lossguide", 
	#max_cat_to_onehot=0, 
	nthread=2, 
	verbosity=1,
)

# ╔═╡ 260cd818-e3c9-4383-bef8-cb5bce16ecbd
# T ~ X 
T_model_params = (
	booster="gbtree", 
	num_rounds=1, 
	eta=1, 
	num_parallel_tree=200, 
	subsample=0.66, 
	sampling_method="uniform", 
	max_depth=10, 
	colsample_bynode="0.6", 
	min_split_loss=0, 
	min_child_weight=0, 
	max_leaves=100, 
	max_delta_step=Inf, 
	reg_alpha=0, 
	reg_lambda=0, 
	tree_method="hist", 
	max_bin=256, 
	grow_policy="lossguide", 
	max_cat_to_onehot=0, 
	max_cat_threshold=10, 
	nthread=2, 
	verbosity=2,
)

# ╔═╡ 8b3f44d1-2252-4d82-aa72-ed6f89fad1dd
# ϵY ~ ϵT
resid_model_params = (
	booster="gblinear", 
	num_round=1, 
	eta=1, 
	reg_alpha=0, 
	reg_lambda=0, 
	nthread=2, 
	verbosity=2,
)

# ╔═╡ 55e74549-9894-4857-a28c-631d38968e6e
df = DataFrame(randn(100,3), [:a, :b, :y])

# ╔═╡ 819e795e-f0cc-481f-8555-0fc921968552
# can accept tabular data, will keep feature names
bst = xgboost((df[!, [:a, :b]], df.y))

# ╔═╡ 8450409d-d0ac-4219-a38e-3c0e24873656
# display importance statistics retaining feature names
importancereport(bst)

# ╔═╡ f9a3cbca-203b-4404-aa4d-2d2340f96366
# return AbstractTrees.jl compatible tree objects describing the model
trees(bst)

# ╔═╡ 14e8b0b2-9544-487f-8ba3-c34ba4322ec4
xgmodel = XGBoost.xgboost(DMatrix((feature_df[!, x_cols]), feature_df[!, :score]); Y_model_params...)

# ╔═╡ 3007a68d-e3b7-404c-b492-6e0887ab8a7a
trees(xgmodel)

# ╔═╡ edde6e62-337a-4874-9979-fb7cabc46374
function cross_train(
	X_train, T_train, Y_train, 
	X_pred, T_pred, Y_pred, 
	Y_model, T_model, resid_model) 
	# train Y_train ~ X_train 
	
	# train T_train ~ X_train 
	# pred Y_pred ~ X_pred 
	# pred T_pred ~ X_pred 
	# ϵY_pred ~ ϵT_pred
	# return ΔϵY_pred / ΔϵT_pred
end 

# ╔═╡ 4e3bb76d-943a-4089-8f39-3e1a264a2ab0
# permutations 
# for i in 1:50
# split aux 1/2
# cross_train_1 
# cross_train_2 
# return estimate

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DuckDB = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
XGBoost = "009559a3-9522-5dbb-924b-0b6ed2b22bb9"

[compat]
CategoricalArrays = "~0.10.8"
DataFrames = "~1.6.1"
DuckDB = "~0.8.1"
XGBoost = "~2.3.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "6fc20c2ba11f90999f5a2f3f659fef758258bee5"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CUDA_Driver_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "35a37bb72b35964f2895c12c687ae263b4ac170c"
uuid = "4ee394cb-3365-5eb0-8335-949819d2adfc"
version = "0.6.0+3"

[[deps.CUDA_Runtime_jll]]
deps = ["Artifacts", "CUDA_Driver_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "b2574783166b4cfa384810b1e07ecd9e779bb637"
uuid = "76a88914-d11a-5bdc-97e0-2f5a05c973a2"
version = "0.9.1+0"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "e460f044ca8b99be31d35fe54fc33a5c33dd8ed7"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.9.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "9b0dc525a052b9269ccc5f7f04d5b3639c65bca5"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.5.0"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DuckDB]]
deps = ["DBInterface", "DataFrames", "Dates", "DuckDB_jll", "FixedPointDecimals", "Tables", "UUIDs", "WeakRefStrings"]
git-tree-sha1 = "88cd745f64a570e7f865c49c17f59822f7f7e47b"
uuid = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
version = "0.8.1"

[[deps.DuckDB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f23f3781c620a97a9d0f7e4e057e94f9c9ef70e1"
uuid = "2cbbab25-fc8b-58cf-88d4-687a02676033"
version = "0.8.1+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointDecimals]]
deps = ["Parsers"]
git-tree-sha1 = "d58aa8e85901dee0915262c1c2697c4037281982"
uuid = "fb4d412d-6eee-574d-9565-ede6634db7b0"
version = "0.4.3"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "95220473901735a0f4df9d1ca5b171b568b2daa3"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.13.2"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "ee094908d720185ddbdc58dbe0c1cbe35453ec7a"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SparseMatricesCSR]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "38677ca58e80b5cad2382e5a1848f93b054ad28d"
uuid = "a0a7dd2c-ebf4-11e9-1f05-cf50bc540ca1"
version = "0.6.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.XGBoost]]
deps = ["AbstractTrees", "CEnum", "JSON3", "LinearAlgebra", "OrderedCollections", "SparseArrays", "SparseMatricesCSR", "Statistics", "Tables", "XGBoost_jll"]
git-tree-sha1 = "d0e3e51c506ac9879049366a48c335595244cf5d"
uuid = "009559a3-9522-5dbb-924b-0b6ed2b22bb9"
version = "2.3.2"

    [deps.XGBoost.extensions]
    XGBoostCUDAExt = "CUDA"
    XGBoostTermExt = "Term"

    [deps.XGBoost.weakdeps]
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    Term = "22787eb5-b846-44ae-b979-8e399b8463ab"

[[deps.XGBoost_jll]]
deps = ["Artifacts", "CUDA_Runtime_jll", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "8198db558039240c933507eb5ebfa3fd20e2da99"
uuid = "a5c6f535-4255-5ca2-a466-0e519f119c46"
version = "1.7.6+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═e08688d0-752f-11ee-150f-51ef33f03b0a
# ╠═a4fdd2d9-fb27-401c-b99c-018f3df71eba
# ╠═ca89b3a5-529e-4a13-a59c-705aab63519d
# ╠═9c47ef5c-184c-4b9d-bbae-6f6090eff314
# ╠═53dbaa27-1254-44da-8b16-99bce522cce0
# ╠═3b8a1037-ae56-4697-b559-d14b34cf337c
# ╠═ffe4249d-dcf3-4260-a3f8-7710279ad3c6
# ╠═9df19072-bf82-4009-ab20-7c4a7f200d7d
# ╠═9ad92de3-bc79-4565-984f-4371cfa0ba9f
# ╠═d8704407-b4f5-4851-b9bf-353d28a8f165
# ╠═538bd9eb-4bf1-4353-8954-ac06767a802e
# ╠═260cd818-e3c9-4383-bef8-cb5bce16ecbd
# ╠═8b3f44d1-2252-4d82-aa72-ed6f89fad1dd
# ╠═55e74549-9894-4857-a28c-631d38968e6e
# ╠═819e795e-f0cc-481f-8555-0fc921968552
# ╠═8450409d-d0ac-4219-a38e-3c0e24873656
# ╠═f9a3cbca-203b-4404-aa4d-2d2340f96366
# ╠═14e8b0b2-9544-487f-8ba3-c34ba4322ec4
# ╠═3007a68d-e3b7-404c-b492-6e0887ab8a7a
# ╠═edde6e62-337a-4874-9979-fb7cabc46374
# ╠═4e3bb76d-943a-4089-8f39-3e1a264a2ab0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002