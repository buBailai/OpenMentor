# -*- coding: utf-8 -*-
"""
OpenMentor 一键部署安装程序（Tkinter GUI）
- 自动检查并安装所需 Python 依赖
- 完成后自动启动 gui_launcher.py
"""
import os
import sys
import time
import subprocess
import importlib.util
import threading
import tkinter as tk
from tkinter import ttk, messagebox

PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))

# 包名映射：左边是 pip 包名，右边是 import 名
REQUIRED = [
    ('Flask', 'flask'),
    ('Flask-Login', 'flask_login'),
    ('Flask-SQLAlchemy', 'flask_sqlalchemy'),
    ('Flask-Bcrypt', 'flask_bcrypt'),
    ('SQLAlchemy', 'sqlalchemy'),
    ('bcrypt', 'bcrypt'),
    ('python-dotenv', 'dotenv'),
    ('requests', 'requests'),
    ('pypdf', 'pypdf'),
    ('python-docx', 'docx'),
    ('python-pptx', 'pptx'),
    ('Pillow', 'PIL'),
    ('pillow-heif', 'pillow_heif'),
    ('openpyxl', 'openpyxl'),
    ('xlrd', 'xlrd'),
    ('pandas', 'pandas'),
    ('matplotlib', 'matplotlib'),
]


def detect_missing():
    missing = []
    for pip_name, import_name in REQUIRED:
        try:
            spec = importlib.util.find_spec(import_name)
            if spec is None:
                missing.append(pip_name)
        except (ImportError, ValueError):
            missing.append(pip_name)
    return missing


def pip_install(package, mirror='https://pypi.tuna.tsinghua.edu.cn/simple'):
    """先用清华镜像，失败再用默认源"""
    cmd_mirror = [sys.executable, '-m', 'pip', 'install', '-i', mirror, '--quiet', package]
    cmd_default = [sys.executable, '-m', 'pip', 'install', '--quiet', package]
    try:
        subprocess.check_call(cmd_mirror)
        return True, None
    except subprocess.CalledProcessError:
        try:
            subprocess.check_call(cmd_default)
            return True, None
        except subprocess.CalledProcessError as e:
            return False, str(e)


class InstallerGUI:
    def __init__(self, root):
        self.root = root
        self.root.title('OpenMentor 一键部署')
        self.root.geometry('540x340')
        self.root.resizable(False, False)
        self.root.configure(bg='#F0EEE6')

        BG, INK, MUTED, CLAY = '#F0EEE6', '#141413', '#6B6760', '#D97757'

        # 标题
        tk.Label(root, text='🤖 OpenMentor 一键部署',
                 font=('Microsoft YaHei', 16, 'bold'), bg=BG, fg=INK).pack(pady=(20, 4))
        tk.Label(root, text='让每位师生都有自己的开源 AI 导师',
                 font=('Microsoft YaHei', 9), bg=BG, fg=MUTED).pack()

        # 描述
        tk.Label(root, text='本工具将自动检查并安装运行所需的依赖，然后启动 OpenMentor 启动器。',
                 font=('Microsoft YaHei', 9), bg=BG, fg=INK,
                 wraplength=480, justify=tk.CENTER).pack(pady=(20, 16))

        # 进度条
        style = ttk.Style()
        try:
            style.theme_use('clam')
        except tk.TclError:
            pass
        style.configure('Horizontal.TProgressbar', troughcolor='#E5E0D8',
                        background=CLAY, borderwidth=0, thickness=14)
        self.progress = ttk.Progressbar(root, mode='determinate', length=440)
        self.progress.pack(pady=(0, 12))

        # 状态
        self.status = tk.Label(root, text='准备开始...',
                                font=('Microsoft YaHei', 10), bg=BG, fg=INK)
        self.status.pack()
        self.detail = tk.Label(root, text='',
                                font=('Microsoft YaHei', 8), bg=BG, fg=MUTED)
        self.detail.pack(pady=(2, 0))

        # 启动安装线程
        threading.Thread(target=self.run, daemon=True).start()

    def run(self):
        try:
            self.status.config(text='正在检查 Python 依赖...')
            self.root.update()
            missing = detect_missing()

            if missing:
                total = len(missing)
                self.status.config(text=f'发现 {total} 个缺失的依赖，开始安装...')
                self.detail.config(text='首次安装约 1-3 分钟，请耐心等待')
                self.progress['maximum'] = total
                for i, pkg in enumerate(missing, 1):
                    self.status.config(text=f'正在安装 {pkg}（{i}/{total}）')
                    self.progress['value'] = i
                    self.root.update()
                    ok, err = pip_install(pkg)
                    if not ok:
                        messagebox.showerror(
                            '安装失败',
                            f'无法安装 {pkg}：\n{err}\n\n请检查网络后重试，或手动执行：\n  pip install -r requirements.txt'
                        )
                        self.root.destroy()
                        return
                self.status.config(text='✓ 全部依赖安装完成')
                self.detail.config(text='正在启动 OpenMentor 启动器...')
            else:
                self.status.config(text='✓ 所有依赖已就绪')
                self.detail.config(text='正在启动 OpenMentor 启动器...')
                self.progress['value'] = self.progress['maximum'] = 1

            self.root.update()
            time.sleep(0.6)

            # 启动 GUI launcher
            launcher = os.path.join(PROJECT_DIR, 'gui_launcher.py')
            if not os.path.exists(launcher):
                messagebox.showerror('错误', f'找不到 gui_launcher.py，请确认本程序位于 OpenMentor 项目目录下。\n当前目录：{PROJECT_DIR}')
                self.root.destroy()
                return
            try:
                subprocess.Popen([sys.executable, launcher], cwd=PROJECT_DIR)
            except Exception as e:
                messagebox.showerror('错误', f'启动 GUI 失败：{e}')
                self.root.destroy()
                return

            self.status.config(text='✓ 启动器已启动，本窗口将自动关闭')
            self.root.update()
            self.root.after(2000, self.root.destroy)
        except Exception as e:
            messagebox.showerror('错误', f'部署过程中出错：{e}')
            self.root.destroy()


def main():
    if sys.version_info < (3, 8):
        try:
            root = tk.Tk(); root.withdraw()
            messagebox.showerror('错误', '需要 Python 3.8 或更高版本（推荐 3.11+）')
        except Exception:
            print('需要 Python 3.8+')
        return
    root = tk.Tk()
    InstallerGUI(root)
    root.mainloop()


if __name__ == '__main__':
    main()
