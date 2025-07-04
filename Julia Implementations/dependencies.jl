# dependencies.jl
# updated v1.10.4 - 2024-08

#using Core
#using Base
#using Pkg # access from REPL via ']' 
#Pkg.add('package_name')
#Pkg.update('package_name')
#Pkg.rm('package_name')
# help via '?'


# essentials
using Base.Threads, Profile, BenchmarkTools, ProgressMeter
using DataFrames, CategoricalArrays, Dates

# mathematics/statistics/science
using StatsBase, Statistics 
using LinearAlgebra 
using Unitful 

# input/output
using DelimitedFiles, CSV, Arrow, TOML 
using DuckDB, LibPQ, SQLite

# graphics
using Pluto, PlutoUI, Markdown, InteractiveUtils 
using Plots, Plotly

# system 
using PackageCompiler 
using PyCall 
