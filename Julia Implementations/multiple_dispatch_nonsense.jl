# multiple_dispatch_nonsense.jl
"""
    JuliaCon 2019 | The Unreasonable Effectiveness of Multiple Dispatch | Stefan Karpinski
        https://www.youtube.com/watch?v=kc9HwsxE1OY

    Problem:
        To what degree does your design allow you to:
            + extend the data model
            + extend the set of possible operations
        While minimizing any instances of:
            - modifying existing code
            - code repetition
            - unhandled runtime error types

        --Mads Torgersen, "The Expression Problem Revisited"
"""

##################################################
# original Point

    """
        abstract type does not have structure
        does not have concrete data type representation
        does not have any behaviours in the definition
    """
    abstract type AbstractPoint <: Any end 

    """
        Point is a subset/instance of AbstractPoint, and can be materialized  
        Valid instances are only restricted by abstract Number type, concrete structure still ambiguous  
        No behaviours baked in at the time of definition, beyond implicit constructor  
    """
    struct Point <: AbstractPoint
        x::Number
        y::Number
    end

    """
        Generic function to return an immutable struct 
        as the same type as given
        with one specified field modified, if present
    """
    function transform(x::T, field::Symbol, op::Function) where T <: AbstractPoint
        fns = fieldnames(T)
        if field in fns
            args = []
            for f in fns
                if f === field
                    push!(args, op(getfield(x, f)))
                else
                    push!(args, getfield(x, f))
                end
            end
            return T(args...)
        else
            return x::T
        end
    end

    """
    Basic re-use of a function to reduce code repetition
    and provide a nicer interface for desired use cases
    """
    function move_up(p::AbstractPoint)
        return transform(p, :y, y->(y+1))
    end

    function move_left(p::AbstractPoint)
        return transform(p, :x, x->(x-1))
    end

    # concise interface to abstract some predicted use cases
    P1 = Point(5, 3.0)
    move_up(P1)

##################################################
# explicitly depends on above resources, and adds new extensions

    struct iPoint <: AbstractPoint
        x::Integer
        y::Integer
    end

    P2 = iPoint(7, 4)

    struct Point3D <: AbstractPoint
        x::Number
        y::Number
        z::Number
    end 

    P3 = Point3D(3.0, 5, 8)

    function move_away(p::AbstractPoint)
        return transform(p, :z, z->(z-1))
    end

    function move_diagonal(p::AbstractPoint, dim1::Symbol, dim2::Symbol, dist::Number)
        return transform(p, dim1, d->(d + dist)) |>
            px->(transform(px, dim2, d->(d + dist))) 
    end

    move_diagonal(P2, :x, :y, -2)
    move_away(P3)

    # simple "inheritance", further code re-use
    # apply original functionality to structures that were unknown
    move_up(P2)
    move_up(P3)


    # well-behaved/'reasonable' result when applying new functionality to upstream data structures?
    # reverse-inheritance? (smart dispatch of appropriate generic)
    # if it makes logical sense, often it "just works" as expected
    move_away(P1)
    move_diagonal(P1, :x, :y, 1)

##################################################
# more complex/convoluted extension

    struct iPoint3D <: AbstractPoint
        x::Integer
        y::Integer
        z::Integer
    end

    P4 = iPoint3D(7, 1, 4)

    struct TimePoint <: AbstractPoint
        x::Number
        y::Number
        t::Number
    end

    P5 = TimePoint(-3, 2, 0)

    function Base.:+(a::P, b::P) where P <: AbstractPoint
        args = []
        for field in fieldnames(P)
            push!(args, +(getfield(a, field), getfield(b, field)))
        end
        return P(args...)
    end

    function Base.:*(a::P, b::P) where P <: AbstractPoint
        args = []
        for field in fieldnames(P)
            push!(args, *(getfield(a, field), getfield(b, field)))
        end
        return P(args...)
    end

    function Base.:+(a::P, n::Number) where P <: AbstractPoint
        args = []
        for field in fieldnames(P)
            push!(args, +(getfield(a, field), n))
        end
        return P(args...)
    end

    function Base.:*(a::P, n::Number) where P <: AbstractPoint
        args = []
        for field in fieldnames(P)
            push!(args, *(getfield(a, field), n))
        end
        return P(args...)
    end

    function zero(x::P) where P <: AbstractPoint
        return P(zeros(Number, fieldcount(P))...)
    end

    """
    Would/should iPoint3D traditionally 'inherit' from Point? iPoint? Point3D?
    Answer for multiple-dispatch: it doesn't matter during development, re-use what's available and just implement more specialized behaviour when desired
        best to default to the abstract type and let the compiler decide when the function is called
    """

##################################################
# feasible extension-space expands exponentially

    abstract type AbstractRegion <: Any end
    abstract type AbstractShape <: Any end 

    struct Line <: AbstractRegion 
        p1::AbstractPoint 
        p2::AbstractPoint 
    end

    struct Triangle <: AbstractShape
        p1::AbstractPoint 
        p2::AbstractPoint 
        p3::AbstractPoint 
    end

    T1 = Triangle(Point(0, 0), Point(4, 0), Point(0, 3))

    function transform_shape(x::T, op::Function) where T <: AbstractShape
        vertices = fieldnames(T) 
        args = [] 
        for p in vertices 
            push!(args, op(getfield(x, p))) 
        end
        return T(args...) 
    end
    
    transform_shape(T1, move_up) 

    """
        Triangle can 'inherit' functionality defined for AbstractShape
        Instead, if Triangle is 'composed' of AbstractPoints, then any existing AbstractPoint functionality can be applied to the components
        Without constraint on the functionality of AbstractPoints/Points, AbstractShapes/Triangle at the time of definition
        And if the 
    """

    T2 = Triangle(Point(0, 0), Point3D(4, 0, 0), TimePoint(0, 3, 0))

    function advance_time(p::AbstractPoint)
        return transform(p, :t, t->(t+1))
    end

    """
        It doesn't really matter if a Triangle is made that conforms to the original intention
        (it was not formalized that a Triangle must be three AbstractPoints of the same concrete Type)
        If the composition of Triangle is clear, and the behaviour/function is defined in terms of the composition
        Then multiple dispatch 'just works' to apply a relevant method wherever needed, and the result 'makes sense'

    """

    transform_shape(T1, advance_time)
    transform_shape(T2, advance_time)

    function advance_time(s::T) where T <: AbstractShape
        transform_shape(s, advance_time)
    end

    advance_time(T1)
    advance_time(T2)



