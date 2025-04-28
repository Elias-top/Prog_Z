import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
import subprocess
import os

import datetime

def update_output_extension():
    current = out_entry.get()
    new_ext = ".bin" if output_format.get() == "bin" else ".mcs"

    if not current:
        # Если поле пустое — вставим дефолт
        out_entry.insert(0, os.path.join(os.getcwd(), f"BOOT{new_ext}"))
    else:
        root, ext = os.path.splitext(current)
        if ext.lower() in [".bin", ".mcs"]:
            out_entry.delete(0, tk.END)
            out_entry.insert(0, root + new_ext)

def browse_fsbl():
    path = filedialog.askopenfilename(filetypes=[("FSBL ELF", "*.elf")])
    if path:
        fsbl_entry.delete(0, tk.END)
        fsbl_entry.insert(0, path)

def browse_bit():
    path = filedialog.askopenfilename(filetypes=[("Bitstream", "*.bit")])
    if path:
        bit_entry.delete(0, tk.END)
        bit_entry.insert(0, path)

def browse_app():
    path = filedialog.askopenfilename(filetypes=[("Application ELF", "*.elf")])
    if path:
        app_entry.delete(0, tk.END)
        app_entry.insert(0, path)

def browse_output():
    ext = ".bin" if output_format.get() == "bin" else ".mcs"
    default_name = "BOOT" + ext
    path = filedialog.asksaveasfilename(
        defaultextension=ext,
        filetypes=[("BIN or MCS", "*.bin *.mcs")],
        initialfile=default_name
    )
    if path:
        out_entry.delete(0, tk.END)
        out_entry.insert(0, path)

def generate_bif(fsbl, bit, app, out_file):
    bif_path = os.path.splitext(out_file)[0] + ".bif"
    lines = [f"[bootloader] {fsbl}"]
    if bit:
        lines.append(bit)
    if app:
        lines.append(app)
    bif_content = "the_ROM_image:\n{\n    " + "\n    ".join(lines) + "\n}"
    with open(bif_path, "w", encoding="utf-8") as f:
        f.write(bif_content)
    return bif_path

def run_bootgen():
    fsbl = fsbl_entry.get().strip()
    bit = bit_entry.get().strip()
    app = app_entry.get().strip()
    out_file = out_entry.get().strip()
    output_text.delete("1.0", tk.END)

    if not fsbl or not os.path.isfile(fsbl):
        messagebox.showerror("Ошибка", "FSBL .elf обязателен.")
        return
    if bit and not os.path.isfile(bit):
        messagebox.showerror("Ошибка", "Указанный .bit файл не найден.")
        return
    if app and not os.path.isfile(app):
        messagebox.showerror("Ошибка", "Указанный app.elf файл не найден.")
        return
    if not out_file:
        messagebox.showerror("Ошибка", "Не указан выходной файл.")
        return

    fmt = output_format.get()
    bif_path = generate_bif(fsbl, bit if bit else None, app if app else None, out_file)

    cmd = [
        "bin\\bootgen.bat",
        "-image", bif_path,
        "-w",
        "-o", out_file,
        "-arch", "zynq"
    ]
    # if fmt == "mcs":
    #     cmd.extend(["-format", "mcs"])

    try:
        process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        output = process.stdout
        output_text.insert(tk.END, output)

        if "ERROR:" in output:
            messagebox.showerror("Ошибка при генерации", "Обнаружена ошибка:\n" + output.split("ERROR:")[1].strip())
        else:
            # messagebox.showinfo("Готово", f"Файл прошивки ({fmt.upper()}) успешно создан!")
            creation_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            output_text.insert(tk.END, f"[{creation_time}] вызов сборки [{out_file}] image.")

    except FileNotFoundError:
        messagebox.showerror("Ошибка", "Команда bootgen не найдена.\nУбедитесь, что Xilinx среда доступна в PATH.")

# GUI
root = tk.Tk()
root.title("Bootgen GUI (с автогенерацией .bif)")

tk.Label(root, text="FSBL .elf (обязателен):").grid(row=0, column=0, sticky="e")
fsbl_entry = tk.Entry(root, width=50)
fsbl_entry.grid(row=0, column=1)
tk.Button(root, text="Обзор...", command=browse_fsbl).grid(row=0, column=2)

tk.Label(root, text=".bit файл (опц.):").grid(row=1, column=0, sticky="e")
bit_entry = tk.Entry(root, width=50)
bit_entry.grid(row=1, column=1)
tk.Button(root, text="Обзор...", command=browse_bit).grid(row=1, column=2)

tk.Label(root, text="App .elf (опц.):").grid(row=2, column=0, sticky="e")
app_entry = tk.Entry(root, width=50)
app_entry.grid(row=2, column=1)
tk.Button(root, text="Обзор...", command=browse_app).grid(row=2, column=2)

tk.Label(root, text="Выходной файл:").grid(row=3, column=0, sticky="e")
out_entry = tk.Entry(root, width=50)
out_entry.grid(row=3, column=1)
tk.Button(root, text="Обзор...", command=browse_output).grid(row=3, column=2)

output_format = tk.StringVar(value="bin")
tk.Label(root, text="Формат выхода:").grid(row=4, column=0, sticky="e")
tk.Radiobutton(root, text="BIN", variable=output_format, value="bin",
               command=update_output_extension).grid(row=4, column=1, sticky="w")
tk.Radiobutton(root, text="MCS", variable=output_format, value="mcs",
               command=update_output_extension).grid(row=4, column=2, sticky="w")

tk.Button(root, text="Сгенерировать BOOT", command=run_bootgen, bg="blue", fg="white").grid(row=5, column=1, pady=10)

output_text = scrolledtext.ScrolledText(root, width=80, height=20)
output_text.grid(row=6, column=0, columnspan=3, padx=10, pady=10)

default_ext = ".bin" if output_format.get() == "bin" else ".mcs"
out_entry.insert(0, os.path.join(os.getcwd(), f"BOOT{default_ext}"))

root.mainloop()
