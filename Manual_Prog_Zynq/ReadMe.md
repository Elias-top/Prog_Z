# 🔧 Прошивка флеш-памяти Zynq через `prog_flash.cmd`

## 📁 Структура проекта

📅 Убедитесь, что в корне проекта находятся следующие файлы и папки:

```
/Manual_Prog_Zynq
├── BOOT.mcs           # Образ загрузки, созданный через bootgen
├── fsbl.elf           # First Stage Boot Loader (FSBL)
├── prog_flash.cmd          # Скрипт запуска прошивки

```

## 💠 Содержимое `prog_flash.cmd`

```cmd
echo Запуск hw_server...

echo Прошивка флеш-памяти Zynq...
cmd /C bin\program_flash.bat -f BOOT.mcs -offset 0 -flash_type qspi-x4-single -fsbl fsbl.elf -verify -url tcp:localhost:3121

pause
```

## 📌 Описание параметров

| Параметр                     | Описание                                                              |
| ---------------------------- | --------------------------------------------------------------------- |
| `-f BOOT.mcs`                | Путь к `.mcs` файлу — образу для прошивки                             |
| `-offset 0`                  | Смещение записи в памяти (обычно `0` для начала памяти)               |
| `-flash_type qspi-x4-single` | Тип флеш-памяти (QSPI в режиме x4)                                    |
| `-fsbl fsbl.elf`             | ELF-файл загрузчика первого уровня (FSBL)                             |
| `-verify`                    | Включает верификацию прошивки после записи                            |
| `-url tcp:localhost:3121`    | Адрес JTAG-сервера hw\_server, к которому подключается program\_flash |

## ▶️ Инструкция по запуску

1. Подключите Zynq-плату через JTAG.
2. Убедитесь, что `program_flash.bat` имеет доступ в папку ../bin.
3. Откройте CMD **от имени администратора**.
4. Перейдите в корень папки:
   ```cmd
   cd путь\к\Manual_Prog_Zynq
   ```
5. Запустите:
   ```cmd
   prog_flash.cmd
   ```

```cmd
Либо двойным нажатием на prog_flash.cmd
```
---

> 💡 **Совет:** Если увидите следующие сообщение проверьте подключение программатора к ПК
>```cmd
> WARNING: Failed to connect to hw_server at tcp:localhost:3121
> ```


