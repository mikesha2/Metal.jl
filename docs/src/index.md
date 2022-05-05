# Metal programming in Julia

The Metal.jl package is intended to be the main entrypoint for programming Apple M-series
GPUs in Julia. This package
makes it possible to do so at various abstraction levels, from easy-to-use arrays down to
hand-written kernels using low-level Metal APIs.

**NOTE: This package is still under significant development. Bugs, errors, and missing
features are all regularly expected at the moment.**

If you have any questions or want to contribute to this package,
please feel free to use the `#gpu` channel on the [Julia
slack](https://julialang.slack.com/), or the [GPU domain of the Julia
Discourse](https://discourse.julialang.org/c/domain/gpu).

## Requirements

- Mac device with M-series hardware
- macOS Catalina 10.15 or newer
- Julia 1.8 (currently in beta)
- [This GPUCompiler fork](https://github.com/maleadt/GPUCompiler.jl)

## Quick Start

As long as the requirements above are met, installation is easy:

```julia
# install the package
using Pkg
Pkg.add(url="https://github.com/JuliaGPU/Metal.jl")
```

If you want to ensure everything works as expected, you can execute the test suite (it only
takes a minute or two):

```julia
using Pkg
Pkg.test("Metal")
```

To understand the toolchain in more detail, have a look at
the example directory in this package. For an overview of the available functionality, read the
[Usage](@ref UsageOverview) section. The following resources may also be of interest
(primarily CUDA.jl focused but still good material for reference):

- Effectively using GPUs with Julia: [video](https://www.youtube.com/watch?v=7Yq1UyncDNc),
  [slides](https://docs.google.com/presentation/d/1l-BuAtyKgoVYakJSijaSqaTL3friESDyTOnU2OLqGoA/)
- How Julia is compiled to GPUs: [video](https://www.youtube.com/watch?v=Fz-ogmASMAE)

## Distinctions from Other GPU-backends

Metal.jl mandates the use of an Apple, M-series chip, so many assumptions can be made from
that - some of which include:

- Unified Memory: M-series chips all feature unified memory, meaning that the CPU, GPU, and
other co-processors all share the same memory pool. This is in contrast to discrete GPUs
where the GPU and CPU each have their own memory pool (usually separated by a PCI-e
conncetion), and data must be explicitly managed by the user.

- Other Hardware Accelerators: M-series chips contain more processors than just the CPU and
GPU. They also contain a neural engine, a matrix co-processor, video encoders/decoders, and
more. The degree to which Julia can target these processors remains to be seen, but their
existence could broaden the utility and performance of Metal.jl in the future.

## Acknowledgements

The Julia Metal stack is brought to you by:

- Max Hawkins (@max-Hawkins)
- Tim Besard (@maleadt)
- Filippo Vicentini (@PhilipVinc)

## Contributing

This package is still under development. If you notice missing functionality you want,
don't hesitate to reach out and ask for it, submit a GitHub issue, or add the functionality
yourself (see [Contributing to Metal.jl](@ref)).