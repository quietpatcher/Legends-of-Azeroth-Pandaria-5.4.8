#ifndef LOA_FLAGGED_VALUES_H
#define LOA_FLAGGED_VALUES_H

#include <cstddef>
#include <limits>
#include <type_traits>

template <class T_VALUES, class T_FLAGS, class FLAG_TYPE, size_t ARRAY_SIZE>
class FlaggedValuesArray32
{
    static_assert(std::is_unsigned_v<T_FLAGS>);
    static_assert(std::numeric_limits<T_FLAGS>::digits >= ARRAY_SIZE);

public:
    FlaggedValuesArray32() : m_values{}, m_flags(0) { }
    T_FLAGS GetFlags() const { return m_flags; }
    bool HasFlag(FLAG_TYPE flag) const { return (m_flags & Mask(flag)) != 0; }
    void AddFlag(FLAG_TYPE flag) { m_flags |= Mask(flag); }
    void DelFlag(FLAG_TYPE flag) { m_flags &= ~Mask(flag); }
    T_VALUES GetValue(FLAG_TYPE flag) const { return m_values[flag]; }
    void SetValue(FLAG_TYPE flag, T_VALUES value) { m_values[flag] = value; }
    void AddValue(FLAG_TYPE flag, T_VALUES value) { m_values[flag] += value; }

private:
    static T_FLAGS Mask(FLAG_TYPE flag)
    {
        return static_cast<size_t>(flag) < ARRAY_SIZE ? (T_FLAGS(1) << flag) : T_FLAGS(0);
    }
    T_VALUES m_values[ARRAY_SIZE];
    T_FLAGS m_flags;
};

#endif
