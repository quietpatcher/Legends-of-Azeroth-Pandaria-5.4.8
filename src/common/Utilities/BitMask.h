#ifndef LOA_BIT_MASK_H
#define LOA_BIT_MASK_H

#include <cstdint>

// Mechanics, aura states and SmartAI phases use 1-based IDs; zero means none.
inline std::uint32_t MakeOneBasedMask32(std::uint32_t position)
{
    return position > 0 && position <= 32 ? (std::uint32_t(1) << (position - 1)) : 0;
}

#endif
