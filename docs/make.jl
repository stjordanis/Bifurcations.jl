using Documenter, Bifurcations
using DiffEqBase: AbstractODEProblem
using Setfield: Lens
import Plots

Plots.default(dpi=15)

makedocs()

# https://docs.travis-ci.com/user/environment-variables/#Default-Environment-Variables
if get(ENV, "TRAVIS", "") != "true"
    # Don't do anything outside Travis CI
elseif startswith(get(ENV, "TRAVIS_BRANCH", ""), "pre/")
    # For branches pre/*, deploy them into gh-pages.pre.
    branch = ENV["TRAVIS_BRANCH"]
    deploydocs(
        deps   = Deps.pip("mkdocs", "python-markdown-math"),
        repo   = "github.com/tkf/Bifurcations.jl.git",
        julia  = "0.6",
        branch = "gh-pages.pre",
        latest = branch,
    )
else
    deploydocs(
        deps   = Deps.pip("mkdocs", "python-markdown-math"),
        repo   = "github.com/tkf/Bifurcations.jl.git",
        julia  = "0.6",
    )
end
