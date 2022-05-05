using Documenter, Metal

const src = "https://github.com/JuliaGPU/Metal.jl"
const dst = "https://metal.juliagpu.org/stable/"

function main()
    makedocs(
        sitename = "Metal.jl",
        authors = "Max Hawkins, Tim Besard, and Filippo Vicentini",
        repo = "$src/{commit}{path}#{line}",
        format = Documenter.HTML(
            # Use clean URLs on CI
            # prettyurls = ci,
            canonical = dst,
            assets = ["assets/favicon.ico"],
            # analytics = "",
        ),
        doctest = true,
        #strict = true,
        modules = [Metal],
        pages = Any[
            "Home" => "index.md",
            "Usage" => "usage/overview.md",
            "Development" => "development.md",
            "API Reference" => Any[
                "api/overview.md",
                "api/compiler.md",
                "api/kernel.md",
            ],
            "Contribute" => "contribute.md",
        ]
    )
end

isinteractive() || main()
