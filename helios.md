# SSH на Helios без пароля

Пароль запрашивается при каждом `ssh` и `scp`, пока на Helios не настроен ключ. Достаточно один раз создать ключ и скопировать его публичную часть на сервер.

> [!note]
> Все команды ниже -- обычный bash, никакого PowerShell. На Linux и macOS они выполняются как есть, на Windows -- в Git Bash или WSL
>
> Git Bash и WSL -- разные среды со своими домашними каталогами: ключ, созданный в одной, другая не видит. Выберите одну и работайте в ней. Сам файл `~/.ssh` на Windows лежит в `C:\Users\serge\.ssh`

## Как выполнять команды в Git Bash и WSL

### Git Bash

Открыть можно:
- в проводнике -- правый клик по папке -> `Open Git Bash here`
- из PowerShell -- `& "C:\Program Files\Git\bin\bash.exe" -l`

Дальше команды пишутся как в любом линуксе:

```bash
ls -la ~/.ssh
```

Здесь `~` -- это `C:\Users\serge`, то есть `/c/Users/serge` внутри bash. Команда покажет ровно тот каталог, который использует `ssh` на Windows:

```text
-rw-r--r-- 1 serge 197609 411 Oct 19 16:59 id_ed25519
-rw-r--r-- 1 serge 197609  96 Oct 19 16:59 id_ed25519.pub
-rw-r--r-- 1 serge 197609 159 Oct 19 16:59 config
```

### WSL

Запуск -- `wsl` из PowerShell или `Ubuntu` из меню «Пуск». Это полноценный Linux со своим `~`, и там он другой:

```bash
ls -la ~/.ssh
```

```text
ls: cannot access '/home/serge/.ssh': No such file or directory
```

Это нормально: ключа в WSL может просто не быть, потому что он мог создаться в Git Bash.

Если работаете в WSL, все шаги ниже выполняйте в WSL, а не в Git Bash: иначе ключ окажется в другом домашнем каталоге

## Шаг 1. Создайте ключ

```bash
ssh-keygen -t ed25519 -C "s365809@helios"
```

На вопрос о пути нажмите Enter, на вопрос о парольной фразе -- тоже Enter (дважды). Фраза не нужна: с ней `ssh` спрашивал бы её при каждом подключении, а смысл задачи -- ходить на Helios без ввода пароля. Отдельно фразу можно добавить позже через `ssh-keygen -p -f ~/.ssh/id_ed25519`

Проверка:

```bash
ls -la ~/.ssh
```

Должны появиться `id_ed25519` и `id_ed25519.pub`

> [!warning]
> На Windows `chmod` ничего не меняет: NTFS не хранит POSIX-права, и вывод `ls -la` покажет `-rw-r--r--` при любом `chmod`. Правами там управляет ACL, а `ssh` для Windows проверяет именно его. Если в ACL есть посторонние пользователи, `ssh` откажется читать файл с ошибкой `Bad owner or permissions`
>
> Правильный способ -- `icacls` в PowerShell или Git Bash (подставьте своё имя учётной записи вместо `BOOK3OFPUGIN\serge`):
>
> ```powershell
> icacls "$env:USERPROFILE\.ssh" /inheritance:r /grant:r "$env:USERNAME:(OI)(CI)F" "NT AUTHORITY\SYSTEM:(OI)(CI)F" "BUILTIN\Administrators:(OI)(CI)F"
> ```
>
> `/inheritance:r` убирает унаследованные записи (в том числе «Гость» и группы доступа), а `/grant:r` оставляет только вас, SYSTEM и администраторов. Права на файлы внутри каталога подтянутся сами

## Шаг 2. Скопируйте ключ на Helios

```bash
ssh-copy-id -p 2222 s365809@helios.cs.ifmo.ru
```

Пароль спросят в последний раз. Если `ssh-copy-id` не нашёлся:

```bash
cat ~/.ssh/id_ed25519.pub | ssh -p 2222 s365809@helios.cs.ifmo.ru "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

## Шаг 3. Добавьте алиас в `~/.ssh/config`

```bash
touch ~/.ssh/config
```

На Linux и в WSL права выставляются как обычно:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
```

На Windows вместо этого один раз выполните `icacls` из блока про права в шаге 1 -- он накрывает весь каталог `.ssh` вместе с `config`

Внутрь:

```sshconfig
Host helios
    HostName helios.cs.ifmo.ru
    Port 2222
    User s365809
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    ServerAliveInterval 60
```

Теперь вместо `ssh -p 2222 s365809@helios.cs.ifmo.ru` достаточно `ssh helios`, а туннель поднимается через `ssh -L 10714:localhost:10714 helios`

## Если пароль всё равно спрашивают

Смотрите `ssh -v helios`: клиент пишет, какие ключи он предложил и какой способ выбрал сервер.

1. ключ лежит там, где его ищет клиент: `ls -la ~/.ssh`
2. права на сервере верные:

   ```bash
   ssh -p 2222 s365809@helios.cs.ifmo.ru "ls -ld ~ ~/.ssh ~/.ssh/authorized_keys"
   ```

   Ожидается `drwx------` у `~/.ssh` и `-rw-------` у `authorized_keys`
3. права локально на Windows: `icacls "$env:USERPROFILE\.ssh"`. В списке должны быть только вы, `SYSTEM` и `Administrators`. Если есть `Гость` или другие группы, выполните `icacls` из шага 1
4. ключ создан в той же среде, где выполняется `ssh`: Git Bash и WSL -- разные домашние каталоги

## Проверка без пароля

```bash
ssh -o BatchMode=yes helios true; echo $?
```

`0` -- вход по ключу работает, `255` -- нет. `BatchMode` запрещает интерактивные запросы, поэтому если ключ не принят, команда упадёт сразу, а не будет ждать пароль

## Забыли фразу

Восстановить нельзя, но доступ не теряется, пока на Helios работает вход по паролю: зайти по паролю, удалить старую строку из `~/.ssh/authorized_keys`, создать новый ключ и повторить шаги 1--2
