# [Overview](@id UsageOverview)

The Metal.jl package provides three distinct, but related, interfaces for Metal programming:

- the `MtlArray` type: for programming with arrays;
- native kernel programming capabilities: for writing Metal kernels in Julia;
- Metal API wrappers: for low-level interactions with the Metal Shading Language.

Much of the Julia CUDA programming stack is intended to be used by just relying on the
`MtlArray` type (although currently, this is lacking),
and using platform-agnostic programming patterns like `broadcast` and other array
abstractions. Only once you hit a performance bottleneck, or some missing functionality, you
might need to write a custom kernel or use the underlying Metal APIs.


## The `MtlArray` type

The `MtlArray` type is an essential part of the toolchain. Primarily, it is used to manage
memory accessible to the GPU.

This is the area most needing further development in the package. Many high-level array
operations will not work on `MtlArrays`.

## Kernel programming with `@metal`

If an operation cannot be expressed with existing functionality for `MtlArray`, or you need
to squeeze every last drop of performance out of your GPU, you can always write a custom
kernel. Kernels are functions that are executed in a massively parallel fashion, and are
launched by using the `@metal` macro:

```julia
a = Metal.zeros(Int8, 1024)

function kernel(a)
    i = thread_position_in_threadgroup_1d()
    a[i] += Int8(1)
    return
end

@metal threads=length(a) kernel(a)
```

These kernels give you all the flexibility and performance a GPU has to offer, within a
familiar language. However, not all of Julia is supported, and the Metal Shading Language
further restricts what can happen within these kernels. Start simple and add complexity
only after ensuring the current kernel compiles and runs as expected.

## Metal Shading Language API

If there is some functionality you need that the high-level APIs don't allow for, then you
can rely on the Metal Shading Language API. Low-level Objective-C calls are wrapped into the
Metal.MTL module and prefixed with 'mt' to indicate their low-level nature.
