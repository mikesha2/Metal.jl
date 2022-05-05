# Kernel programming

This section lists the package's public functionality that corresponds to special Metal
functions for use in device code. For more information about certain intrinsics,
refer to the
[Apple offical docs](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf).


## Indexing
```@docs
thread_index_in_quadgroup
thread_index_in_simdgroup
thread_index_in_threadgroup
quadgroup_index_in_threadgroup
simdgroup_index_in_threadgroup
thread_position_in_threadgroup_1d
thread_position_in_grid_1d
threadgroup_position_in_grid_1d
```

## Dimensions

```@docs
thread_execution_width
threads_per_simdgroup
threads_per_threadgroup_1d
quadgroups_per_threadgroup
simdgroups_per_threadgroup
threads_per_grid_1d
threadgroups_per_grid_1d
grid_origin_1d
grid_size_1d
```


## Device arrays

Metal.jl provides a primitive, lightweight array type to manage GPU data organized in a
plain, dense fashion. This is the device-counterpart to the `MtlArray`, and implements (part
of) the array interface as well as other functionality for use _on_ the GPU:

```@docs
MtlDeviceArray
Metal.Const
```


## Synchronization

```@docs
threadgroup_barrier
simdgroup_barrier
MemoryFlags
```


## Math

Many mathematical functions are implemented via intrinsics in Metal, and are wrapped by Metal.jl. These functions are used to implement well-known functions from the Julia standard
library and packages like SpecialFunctions.jl, e.g., calling the `cos` function will
automatically use `air.cos`.

Some functions do not have a counterpart in the Julia ecosystem, those have to be called directly. For example, to call `air.clz`, use `Metal.clz` in a kernel.

For a list of available functions, look at `src/device/metal/math.jl`.

## Dispatching

```@docs
dispatch_threads_per_threadgroup_1d
dispatch_quadgroups_per_threadgroup
dispatch_simdgroups_per_threadgroup
```