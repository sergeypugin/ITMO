def main() -> None:

    while True:
        try:
            text = input("Введите строку: ") + "\n"
            codes = list(text.encode("ascii"))
            print(codes)
        except UnicodeEncodeError:
            print("Ошибка: строка содержит символы вне ASCII")
        print()

if __name__ == "__main__":
    main()
