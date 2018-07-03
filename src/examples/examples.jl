module Examples

include("pitchfork.jl")
include("transcritical.jl")
include("calcium.jl")
include("predator_prey.jl")
include("bazykin_85.jl")

using Compat

example_modules() = [
    Pitchfork,
    Transcritical,
    Calcium,
    PredatorPrey,
    Bazykin85,
]

examples() = [nameof(ex) => ex for ex in example_modules()]

end  # module

using .Examples: examples