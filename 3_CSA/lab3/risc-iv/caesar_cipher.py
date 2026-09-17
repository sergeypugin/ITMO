def caesar_cipher(input: str) -> tuple[str | list[int], str]:
    """Apply a Caesar cipher to a line of text.

    Input format:
        <shift>\\n
        <text>\\n

    - Positive shift encrypts the text.
    - Negative shift is also allowed.
    - Only ASCII letters are shifted.
    - Uppercase and lowercase letters preserve their case.
    - Non-letter characters remain unchanged.
    - Shift is taken modulo 26.

    Returns:
        tuple: A tuple containing the transformed string and remaining input.
    """
    lines = input.split("\n")

    if len(lines) < 2:
        return [-1], input

    shift_line = lines[0]
    text = lines[1]

    try:
        if not shift_line:
            return [-1], "\n".join(lines[1:])

        shift = int(shift_line)

        if shift < -2147483648 or shift > 2147483647:
            return [-1], "\n".join(lines[2:])

        shift %= 26

        result = []

        for char in text:
            if "a" <= char <= "z":
                result.append(chr((ord(char) - ord("a") + shift) % 26 + ord("a")))
            elif "A" <= char <= "Z":
                result.append(chr((ord(char) - ord("A") + shift) % 26 + ord("A")))
            else:
                result.append(char)

        remaining = "\n".join(lines[2:])

        return "".join(result), remaining

    except Exception():
        return [-1], input


assert caesar_cipher("3\nHello, World!\n") == ("Khoor, Zruog!", "")
assert caesar_cipher("-3\nKhoor\n") == ("Hello", "")
assert caesar_cipher("0\nHello\n") == ("Hello", "")

if __name__ == "__main__":
    print(caesar_cipher("3\nHello, World!\n"))
