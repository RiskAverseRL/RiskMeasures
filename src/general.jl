using Distributions: DiscreteNonParametric, DiscreteAffineDistribution


_bad_risk(msg::AbstractString) =
    error(msg)
_bad_distribution(msg::AbstractString) =
    error(msg)

# checks a pmf for correctness
function _check_pmf(pmf::AbstractVector{<:Real})
    T = eltype(pmf)
    !isempty(pmf) || _bad_distribution("pmf must be non-empty.")
    mapreduce(isfinite, &, pmf) || _bad_distribution("Probabilities must be finite.")
    mapreduce(x -> x ≥ zero(T), &, pmf) ||
        _bad_distribution("Probabilities must be non-negative.")
    sum(pmf) ≈ one(T) ||
        _bad_distribution("Probabilities must sum to 1 and not $(sum(pmf)).")
end

function _check_pmf(support::AbstractVector{<:Real}, pmf::AbstractVector{<:Real})
    length(support) == length(pmf) ||
        _bad_distribution("Lengths of support and pmf must have the same size.")
    _check_pmf(pmf)
end

function _check_α(α::Real)
    zero(α) ≤ α ≤ one(α) || _bad_risk("Risk level α must be in [0,1].")
end

# converts a random variable to a support and a probability mass function
function rv2pmf(x̃::DiscreteNonParametric)
    sp = support(x̃)
    (sp, pdf.(x̃, sp))
end

function rv2pmf(x̃::DiscreteAffineDistribution)
    # needs to handle location-scale separately because
    # the implementation of the pdf function in Distributions.LocationScale
    # leads to numerrical errors

    sp = support(x̃.ρ)
    pmf = pdf.(x̃.ρ, sp)
    sp = @. sp * x̃.σ + x̃.μ
    (sp, pmf)
end

function swap!(vals::AbstractVector{<:Real}, p::AbstractVector{<:Real}, i::Int, j::Int)
    @inbounds begin
        vals[i], vals[j] = vals[j], vals[i]
        p[i], p[j] = p[j], p[i]
    end
end

function lomuto_partition!(vals::AbstractVector{<:Real}, p::AbstractVector{<:Real}, f::Int, b::Int)
    pivot = f + Int(ceil((b - f) / 2))
    pivot_val = vals[pivot]
    swap!(vals, p, pivot, b)
    store_index = f
    @inbounds for i ∈ range(f, b - 1)
        if vals[i] < pivot_val
            swap!(vals, p, store_index, i)
            store_index += 1
        end
    end
    swap!(vals, p, b, store_index)
    return store_index
end
