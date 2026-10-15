def power_many(*input_words: int) -> list[int]:
    """Compute powers for multiple (base, exponent) pairs.

    Input format:
        [count, base0, exp0, base1, exp1, ...]

    Each exponent must be non-negative. Results must fit in int32.

    Args:
        *input_words (int): Number of pairs followed by base/exponent pairs.

    Returns:
        list: One result for each pair.
    """
    if not input_words:
        return [-1]

    count = input_words[0]

    if count <= 0 or len(input_words) != 1 + 2 * count:
        return [-1]

    results = []

    for i in range(count):
        base = input_words[1 + 2 * i]
        exp = input_words[2 + 2 * i]

        if exp < 0:
            return [-1]

        result = 1

        for _ in range(exp):
            result *= base

            # if result < min_int32 or result > max_int32:
            #     return [overflow_error_value]

        results.append(result)

    return results


assert power_many(2, 2, 10, 3, 5) == [1024, 243]
assert power_many(3, 5, 0, 0, 5, 10, 2) == [1, 0, 100]
assert power_many(1, 7, 1) == [7]
assert power_many(3, 1, 0, 2, 3) == [-1]
