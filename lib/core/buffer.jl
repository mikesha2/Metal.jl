export MtlBuffer, device, content, alloc, free, handle

const MTLBuffer = Ptr{MtBuffer}

# From docs: "MSL implements a buffer as a pointer to a built-in or user defined data type described in the
# device, constant, or threadgroup address space.
struct MtlBuffer{T} <: MtlResource
    handle::MTLBuffer
end

Base.unsafe_convert(::Type{MTLBuffer}, buf::MtlBuffer) = buf.handle

Base.:(==)(a::MtlBuffer, b::MtlBuffer) = a.handle == b.handle
Base.hash(buf::MtlBuffer, h::UInt) = hash(buf.handle, h)


## properties

Base.propertynames(o::MtlBuffer) = (
    :length,
    invoke(propertynames, Tuple{MtlResource}, o)...
)

function Base.getproperty(o::MtlBuffer, f::Symbol)
    if f === :length
        mtBufferLength(o)
    else
        invoke(getproperty, Tuple{MtlResource, Symbol}, o, f)
    end
end

Base.sizeof(buf::MtlBuffer)          = Int(buf.length)
Base.length(d::MtlBuffer{T}) where T = sizeof(d) ÷ sizeof(T)

content(buf::MtlBuffer{T}) where T   = Base.bitcast(Ptr{T}, mtBufferContents(buf))


## allocation

alloc_buffer(dev::MtlDevice, bytesize, opts::MtlResourceOptions) =
    mtDeviceNewBufferWithLength(dev, bytesize, opts)
alloc_buffer(dev::MtlHeap, bytesize, opts::MtlResourceOptions) =
    mtHeapNewBufferWithLength(heap, bytesize, opts)
alloc_buffer(dev::MtlDevice, bytesize, opts::MtlResourceOptions, ptr::Ptr) =
    mtDeviceNewBufferWithBytes(dev, ptr, bytesize, opts)
alloc_buffer(dev::MtlHeap, bytesize, opts::MtlResourceOptions, ptr::Ptr) =
    mtHeapNewBufferWithBytes(heap, ptr, bytesize, opts)

alloc_buffer(dev, bytesize, opts::Integer) =
    alloc_buffer(dev, bytesize, Base.bitcast(MtlResourceOptions, UInt32(opts)))
alloc_buffer(dev, bytesize, opts::Integer, ptr) =
    alloc_buffer(dev, bytesize, Base.bitcast(MtlResourceOptions, UInt32(opts)), ptr)

# TODO: buffer should be untyped
function MtlBuffer{T}(dev::Union{MtlDevice,MtlHeap},
                      length::Integer;
                      storage = Private,
                      hazard_tracking = DefaultTracking,
                      cache_mode = DefaultCPUCache) where {T}
    opts = storage | hazard_tracking | cache_mode

    bytesize = length * sizeof(T)
    ptr = alloc_buffer(dev, bytesize, opts)

    return MtlBuffer{T}(ptr)
end

function MtlBuffer{T}(dev::Union{MtlDevice,MtlHeap},
                      length::Integer,
                      ptr::Ptr;
                      storage = Managed,
                      hazard_tracking = DefaultTracking,
                      cache_mode = DefaultCPUCache) where {T}
    storage == Private && error("Can't create a Private copy-allocated buffer.")
    opts =  storage | hazard_tracking | cache_mode

    bytesize = length * sizeof(T)
    ptr = alloc_buffer(dev, bytesize, opts, ptr)

    dev = dev isa MtlDevice ? dev : dev.device
    return MtlBuffer{T}(ptr)
end

MtlBuffer(T::Type, dev::Union{MtlDevice,MtlHeap}, args...; kwargs...) =
    MtlBuffer{T}(dev, args...;kwargs...)
MtlBuffer(dev::Union{MtlDevice,MtlHeap}, args...; kwargs...) =
    MtlBuffer(Cvoid, dev, args...;kwargs...)

"""
    alloc(T, device, length, [ptr=nothing]; storage=Default, hazard_tracking=Default, chache_mode=Default)
    MtlBuffer{T}(device, length...)

Allocates a Metal Buffer on `device` of bytes equal to `length * sizeof(T)`. If
a CPU-pointer is passed as last argument, then the Metal Buffer is initialized
with the content of the memory starting at `ptr`, otherwise it's
zero-initialized.

! Note: You are responsible for freeing the returned buffer

The storage kwarg controls where the buffer is stored. Possible values are:
 - Private : Residing on the device
 - Shared  : Residing on the host
 - Managed : Keeps two copies of the buffer, on device and on host. Explicit
   calls must be given to syncronize the two
 - Memoryless : an iOs specific thing that won't work on Mac.

Note that `Private` buffers can't be directly accessed from the CPU, therefore
you cannot use this option if you pass a ptr to initialize the memory.
"""
alloc(args...; kwargs...) = MtlBuffer(args...; kwargs...)

"""
    free(buffer::MtlBuffer)

Frees the buffer if the handle is valid.
This does not protect against double-freeing of the same buffer!
"""
free(buf::MtlBuffer) = mtRelease(buf.handle)

"""
    DidModifyRange!(buf::MtlBuffer{T}, range::UnitRange)

Notifies the GPU that the range of elements `range`, corresponding to the bytes
`sizeof(T)*first(range):sizeof(T)*last(range)` have been modified on the CPU,
and that they should be transferred to the device before executing any following
command.

Only valid for `Managed` buffers.
"""
function DidModifyRange!(buf::MtlBuffer{T}, range::UnitRange) where {T}
    mtBufferDidModifyRange(buf, range*sizeof(T))
end

# Views on different device
NewBuffer(buf::MtlBuffer, d::MtlDevice) =
    mtBufferNewRemoteBufferViewForDevice(buf, d);

function ParentBuffer(buf::MtlBuffer)
    orig = mtBufferRemoteStorageBuffer(buf);
    if orig == C_NULL
        return nothing
    else
        return MtlBuffer(orig)
    end
end


## interop with CPU array

function Base.unsafe_wrap(t::Type{<:Array}, buf::MtlBuffer{T}, dims; own=false) where {T}
    ptr = content(buf)
    ptr == C_NULL && error("Can't unsafe_wrap a GPU Private array.")
    return unsafe_wrap(t, ptr, dims; own=own)
end

handle_array(vec::Vector{<:MtlBuffer}) = [buf.handle for buf in vec]
