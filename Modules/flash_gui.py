import tkinter as tk
from tkinter import filedialog, messagebox
import subprocess
import os
import threading
import time

def browse_boot():
    path = filedialog.askopenfilename(filetypes=[("BOOT or MCS Files", "*.bin *.mcs")])
    if path:
        boot_entry.delete(0, tk.END)
        boot_entry.insert(0, path)

def browse_fsbl():
    path = filedialog.askopenfilename(filetypes=[("FSBL ELF", "*.elf")])
    if path:
        fsbl_entry.delete(0, tk.END)
        fsbl_entry.insert(0, path)

def flash():
    def run_flash():
        boot = boot_entry.get()
        fsbl = fsbl_entry.get()

        if not os.path.isfile(boot) or not os.path.isfile(fsbl):
            messagebox.showerror("Ошибка", "Неверный путь к файлам")
            return

        flash_type = "qspi-x4-single"
        url = "tcp:127.0.0.1:3121"
        offset = "0"

        # Формируем команду для запуска через cmd /U /c
        program_flash_cmd = [
            "cmd", "/c", "start", "cmd", "/k",  # Открываем новое окно консоли
            "bin\\program_flash.bat",
            "-f", f"\"{boot}\"",
            "-fsbl", f"\"{fsbl}\"",
            "-flash_type", flash_type,
            "-verify",
            "-offset", offset,
            "-url", url
        ]

        # Очистка текстового поля перед прошивкой
        output_text.delete(1.0, tk.END)

        try:
            # Запускаем команду с захватом вывода
            subprocess.run(" ".join(program_flash_cmd), shell=True)
            # messagebox.showinfo("Информация", "Команда прошивки запущена в отдельном окне.")
            output_text.insert(tk.END, "Команда прошивки запущена в отдельном окне.")

        except Exception as e:
            messagebox.showerror("Ошибка", f"Ошибка при прошивке: {str(e)}")

    # Запуск в отдельном потоке, чтобы не блокировать GUI
    threading.Thread(target=run_flash, daemon=True).start()
        
root = tk.Tk()
root.title("Zynq Program Flash")

# Виджеты для загрузки файлов
tk.Label(root, text="BOOT.bin / .mcs").grid(row=0, column=0, sticky="e")
boot_entry = tk.Entry(root, width=50)
boot_entry.grid(row=0, column=1)
tk.Button(root, text="Обзор...", command=browse_boot).grid(row=0, column=2)

tk.Label(root, text="FSBL .elf").grid(row=1, column=0, sticky="e")
fsbl_entry = tk.Entry(root, width=50)
fsbl_entry.grid(row=1, column=1)
tk.Button(root, text="Обзор...", command=browse_fsbl).grid(row=1, column=2)

# Кнопка для прошивки
tk.Button(root, text="Прошить Zynq", command=flash, bg="green", fg="white").grid(row=2, column=1, pady=10)

# Текстовое поле для вывода консольных сообщений
output_text = tk.Text(root, height=15, width=80)
output_text.grid(row=3, column=0, columnspan=3)

root.mainloop()
