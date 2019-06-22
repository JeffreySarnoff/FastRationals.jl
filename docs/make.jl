using Documenter, DoubleFloats

makedocs(
    modules = [FastRationals],
    sitename = "FastRationals.jl",
    authors = "Jeffrey Sarnoff",
    pages = Any[
        "Overview" => "index.md",
        "Appropriate Uses" => "appropriate.md",
        "References" => "references.md"
    ]
)

deploydocs(
    repo = "github.com/JeffreySarnoff/FastRationals.jl.git",
    target = "build"
)
