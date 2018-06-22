using StaticArrays: SMatrix

using ..Continuations: AbstractContinuationProblem, AbstractContinuationSolver,
    AbstractContinuationCache,
    as, SweepSetup, ContinuationSweep, ContinuationSolution,
    ContinuationCache, ContinuationOptions, ContinuationSolver,
    residual_jacobian!

using ..BifurcationsBase: timekind, Continuous, Discrete
import ..BifurcationsBase: TimeKind

using ..BifurcationsBase
using ..BifurcationsBase: SpecialPoint, SpecialPointInterval,
    BifurcationSweep, BifurcationSolution, BifurcationSolver,
    BifurcationProblem, BifurcationCache,
    eigvals_prototpye, allocate_sweep!, check_sweep_length, record!
import ..BifurcationsBase: analyze!, re_analyze!

abstract type Codim1Problem{skind, tkind} <: BifurcationProblem{skind, tkind} end

# Once (a reference to) bifurcation problem is stored in points,
# sweeps, and solutions, set proper type aliases.
const Codim1Sweep = BifurcationSweep
const Codim1Solution = BifurcationSolution

module PointTypes
@enum(
    PointType,
    none,
    # initial,
    # simple_bifurcation,
    saddle_node,
    hopf,
    period_doubling,
)
end  # module
using .PointTypes: PointType

BifurcationsBase.regular_point(::Type{PointType}) = PointTypes.none

BifurcationsBase.eigvals_prototpye(prob::Codim1Problem,
                                   cache::ContinuationCache) =
    cache.u[1:end - 1]
# TODO: improve it for SVector


mutable struct Codim1Cache{P, C <: ContinuationCache{P},
                           JType, eType,
                           } <: BifurcationCache{P}
    # TODO: declare types
    super::C
    J::JType
    eigvals::eType
    point_type::PointType
end

function Codim1Cache(super::C,
                     J::JType,
                     eigvals::eType,
                     point_type = PointTypes.none,
                     ) where {P, C <: ContinuationCache{P},
                              JType, eType}
    return Codim1Cache{P, C, JType, eType}(super, J, eigvals, point_type)
end
# TODO: Remove this constructor after removing the type parameter `P`.

Codim1Cache(prob::Codim1Problem, super::ContinuationCache) =
    Codim1Cache(
        super,
        ds_jacobian(super),
        copy(eigvals_prototpye(prob, super)),
    )

BifurcationsBase.BifurcationCache(prob::Codim1Problem,
                                  super::ContinuationCache) =
    Codim1Cache(prob, super)

const Codim1Solver{
        R <: ContinuationSolver,
        P <: Codim1Problem,
        C <: Codim1Cache,
        S <: Codim1Solution,
        } =
    BifurcationSolver{R, P, C, S}

function re_analyze!(solver::Codim1Solver, u::AbstractVector)
    residual_jacobian!(as(solver.cache, ContinuationCache), u)
    analyze!(solver.cache, solver.opts)

    # Suppress special point recording:
    # It's a bit ugly hack... (communicate by sharing!)
    solver.cache.point_type = PointTypes.none  # TODO: FIX!

    record!(solver.sol, solver.cache)
end

function analyze!(cache::Codim1Cache, opts)
    cache.J = J = ds_jacobian(cache)
    eigvals = ds_eigvals(timekind(cache), J)
    cache.point_type = guess_point_type(timekind(cache), cache, eigvals, opts)
    cache.eigvals = eigvals
end

ds_jacobian(solver) = ds_jacobian(as(solver, ContinuationSolver).cache)
ds_jacobian(cache::Codim1Cache) = ds_jacobian(as(cache, ContinuationCache))
ds_jacobian(cache::ContinuationCache) = ds_jacobian(cache.J)
ds_jacobian(HJ::AbstractArray) = @view HJ[:, 1:end-1]
ds_jacobian(HJ::SMatrix) = HJ[:, 1:end-1]
# TOOD: optimize it for StaticArrays using generated functions
