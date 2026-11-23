#ifndef LOA_UNALIGNED_H
#define LOA_UNALIGNED_H

#include <cstring>
#include <type_traits>

// Packed disk/database buffers do not promise the alignment of their fields.
template <typename T>
T ReadUnaligned(void const* source)
{
    static_assert(std::is_trivially_copyable_v<T>);
    T value;
    std::memcpy(&value, source, sizeof(value));
    return value;
}

template <typename T>
void WriteUnaligned(void* destination, T const& value)
{
    static_assert(std::is_trivially_copyable_v<T>);
    std::memcpy(destination, &value, sizeof(value));
}

#endif
