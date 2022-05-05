# Overview

The Metal.jl API closely mimics the Apple Metal Shading Language. For further documentation
beyond these webpages, look to the official Apple documentation:

[Metal API Documentation](https://developer.apple.com/documentation/metal?language=objc)

[Metal Shading Language Specification
](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)


## Naming Conventions

For the most part, low-level Objective-C Metal calls are wrapped and exposed via the
Metal.MTL module. Some of the functions start with the 'mt' prefix indicating lower-level
calls, while others have no prefix and use snake case. These latter functions are generally
higher-level and more Julian.


## Array programming

The Metal array type, `MtlArray`, is intended to implement the Base array interface and all
of its expected methods although currently, it does not.


## Global state

```@docs
device
global_queue
synchronize
```