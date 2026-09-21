def rotate_left(val: int, n: int) -> list[int]:
    """Rotate a 32-bit integer to the left by n bits.

    Bits that are shifted out from the left side are wrapped
    around and placed back on the right side. The rotation amount
    is taken modulo 32, so rotating by 32 bits leaves the value unchanged.

    Args:
        val (int): The 32-bit integer to rotate.
        n (int): Number of bits to rotate left.

    Returns:
        list: A one-element list containing the rotated 32-bit value.
    """
    val32 = val & 0xFFFFFFFF
    shift = n & 0x1F
    if shift == 0:
        return [uint32_to_int32(val32)]
    result = ((val32 << shift) | (val32 >> (32 - shift))) & 0xFFFFFFFF
    return [uint32_to_int32(result)]

def uint32_to_int32(val32: int) -> int:
    if val32 >= 0x80000000:
        return val32 - 0x100000000
    return val32

assert rotate_left(1, 1) == [2]
assert rotate_left(305419896, 4) == [591751041]
assert rotate_left(1, 0) == [1]
