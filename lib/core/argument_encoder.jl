export MtlArgumentEncoder

const MTLArgumentEncoder = Ptr{MtArgumentEncoder}

mutable struct MtlArgumentEncoder
    handle::MTLArgumentEncoder
end

function MtlArgumentEncoder(fun::MtlFunction, entry::Integer)
    handle = mtNewArgumentEncoderWithBufferIndexFromFunction(fun, entry-1)
    obj = MtlArgumentEncoder(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(enc::MtlArgumentEncoder)
    mtRelease(enc.handle)
end

Base.unsafe_convert(::Type{MTLArgumentEncoder}, enc::MtlArgumentEncoder) = enc.handle

Base.:(==)(a::MtlArgumentEncoder, b::MtlArgumentEncoder) = a.handle == b.handle
Base.hash(fun::MtlArgumentEncoder, h::UInt) = hash(mod.handle, h)


## properties

Base.propertynames(o::MtlArgumentEncoder) = (
    # identification
    #=:device, :label,=#
    # creation
    :encodedLength,
    # alignment
    :alignment,
)

function Base.getproperty(o::MtlArgumentEncoder, f::Symbol)
    if f === :encodedLength
        mtArgumentEncoderLength(o)
    elseif f === :alignment
        mtArgumentEncoderAlignment(o)
    else
        getfield(o, f)
    end
end

Base.sizeof(a::MtlArgumentEncoder) = Int(mtArgumentEncoderLength(a))


## operations

function assign_argument_buffer!(enc::MtlArgumentEncoder, buf::MtlBuffer, offset::Integer=1)
    mtArgumentEncoderSetArgumentBufferWithOffset(enc, buf, offset-1)
end

function assign_argument_buffer!(enc::MtlArgumentEncoder, buf::MtlBuffer, offset::Integer, element::Integer)
    mtArgumentEncoderSetArgumentBufferWithOffsetForElement(enc, buf, offset-1, element)
end

set_buffer!(enc::MtlArgumentEncoder, buf::MtlBuffer, offset::Integer, index::Integer) =
    mtArgumentEncoderSetBufferOffsetAtIndex(enc, buf, offset, index-1)
set_buffers!(enc::MtlArgumentEncoder, bufs::Vector{<:MtlBuffer},
             offsets::Vector{Int}, indices::UnitRange{Int}) =
    mtArgumentSetBuffersOffsetsWithRange(enc, handle_array(bufs), offsets, indices .- 1)

function set_bytes!(enc::MtlArgumentEncoder, src, length::Integer, index::Integer)
    dst = Base.bitcast(typeof(ptr), mtArgumentEncoderConstantDataAtIndex(enc, index-1))
    Base.unsafe_copyto!(dst, src, length)
    return
end

function set_field!(enc::MtlArgumentEncoder, val::Number, index::Integer)
    dst = Base.bitcast(Ptr{typeof(val)}, mtArgumentEncoderConstantDataAtIndex(enc, index-1))
    Base.unsafe_store!(dst, val, 1)
    return
end

function set_field!(enc::MtlArgumentEncoder, val::NTuple{N,T}, index::Integer) where {N,T}
    dst = Base.bitcast(Ptr{typeof(val)}, mtArgumentEncoderConstantDataAtIndex(enc, index-1))
    Base.unsafe_store!(dst, val, 1)
    return
end
