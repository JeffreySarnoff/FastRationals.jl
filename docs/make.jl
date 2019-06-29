using Documenter

makedocs(
    sitename = "FastRationals.jl",
    authors = "Jeffrey Sarnoff",
    modules = [FastRationals],
    pages = Any[
        "The BPP formula for PI" => "bpp.md",
        "Finding the Range" => "findingtherange.md",        
        "The Stateless Way" => "thestatelessway.md",
        "What cannot overflow?" => "mayoverflow.md",
        "Rational Magnitude In Action" => "rationalmagnitude.md",
        "A metaphor that illuminates" => "metaphoricalflashlight.md",
    ]
)

deploydocs(
    repo = "github.com/JeffreySarnoff/FastRationals.jl.git",
    target = "build"
)
