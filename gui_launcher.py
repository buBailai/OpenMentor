# -*- coding: utf-8 -*-
"""
OpenMentor 启动器（Tkinter GUI）
- 一键启动 / 停止 Flask 服务
- 一键打开浏览器（本地 / 局域网）
- 一键重置管理员密码（admin → openmentor，并清空 API Key）
- 实时显示服务输出
"""
import os
import sys
import socket
import sqlite3
import threading
import subprocess
import webbrowser
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
try:
    from werkzeug.security import generate_password_hash
    HAS_WERKZEUG = True
except ImportError:
    HAS_WERKZEUG = False


PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(PROJECT_DIR, 'openmentor.db')
APP_PORT = 5001


def get_local_ip():
    """获取本机局域网 IP 地址"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return '127.0.0.1'


class OpenMentorLauncher:
    def __init__(self, root):
        self.root = root
        self.root.title('OpenMentor 启动器')
        self.root.geometry('760x560')
        self.root.minsize(640, 480)
        self.root.configure(bg='#F0EEE6')

        self.process = None
        self.is_running = False
        self.read_thread = None

        self._build_ui()
        self.root.protocol('WM_DELETE_WINDOW', self.on_closing)

    # ---------- UI ----------
    def _build_ui(self):
        BG = '#F0EEE6'
        INK = '#141413'
        MUTED = '#6B6760'
        CLAY = '#D97757'

        # 标题
        title_frame = tk.Frame(self.root, bg=BG)
        title_frame.pack(pady=(16, 4))
        tk.Label(title_frame, text='🤖 OpenMentor 启动器',
                 font=('Microsoft YaHei', 17, 'bold'), bg=BG, fg=INK).pack()
        tk.Label(title_frame, text='让每位师生都有自己的开源 AI 导师',
                 font=('Microsoft YaHei', 9), bg=BG, fg=MUTED).pack(pady=(2, 0))

        # 版权信息
        info_frame = tk.Frame(self.root, bg=BG)
        info_frame.pack(pady=4)
        tk.Label(info_frame, text='本项目由 厦门市演武小学 信息中心 基于 QuickForm 二次开发',
                 font=('Microsoft YaHei', 8), bg=BG, fg=MUTED).pack()
        link = tk.Label(info_frame, text='https://github.com/buBailai/OpenMentor',
                        font=('Microsoft YaHei', 8), bg=BG, fg='#3A6FB7', cursor='hand2')
        link.pack(pady=(2, 0))
        link.bind('<Button-1>', lambda e: webbrowser.open('https://github.com/buBailai/OpenMentor'))

        # 控制按钮
        btn_frame = tk.Frame(self.root, bg=BG)
        btn_frame.pack(pady=12)
        self.start_btn = tk.Button(btn_frame, text='▶ 启动服务',
                                    command=self.start_service,
                                    font=('Microsoft YaHei', 10, 'bold'),
                                    bg=CLAY, fg='white', activebackground='#C26A4D',
                                    relief='flat', padx=18, pady=6, cursor='hand2')
        self.start_btn.pack(side=tk.LEFT, padx=4)

        self.stop_btn = tk.Button(btn_frame, text='■ 停止服务',
                                   command=self.stop_service,
                                   font=('Microsoft YaHei', 10, 'bold'),
                                   bg='#B8463E', fg='white', activebackground='#933830',
                                   relief='flat', padx=18, pady=6, cursor='hand2',
                                   state='disabled')
        self.stop_btn.pack(side=tk.LEFT, padx=4)

        self.open_btn = tk.Button(btn_frame, text='🌐 打开浏览器',
                                   command=self.open_app,
                                   font=('Microsoft YaHei', 10, 'bold'),
                                   bg='#141413', fg='#F7F4EC', activebackground='#2D2A24',
                                   relief='flat', padx=18, pady=6, cursor='hand2',
                                   state='disabled')
        self.open_btn.pack(side=tk.LEFT, padx=4)

        self.reset_btn = tk.Button(btn_frame, text='🔑 重置管理员密码',
                                    command=self.reset_password,
                                    font=('Microsoft YaHei', 10, 'bold'),
                                    bg='#5B7553', fg='white', activebackground='#475D43',
                                    relief='flat', padx=18, pady=6, cursor='hand2')
        self.reset_btn.pack(side=tk.LEFT, padx=4)

        # 状态行
        self.status_label = tk.Label(self.root, text='⚪ 服务未运行',
                                      font=('Microsoft YaHei', 10), bg=BG, fg=MUTED)
        self.status_label.pack(pady=(2, 4))

        # 服务器信息
        info_box = tk.LabelFrame(self.root, text=' 访问地址 ',
                                  font=('Microsoft YaHei', 9, 'bold'),
                                  bg=BG, fg=INK, bd=1, relief='solid', padx=10, pady=8)
        info_box.pack(fill=tk.X, padx=24, pady=4)
        local_ip = get_local_ip()
        for label_text, url, color in [
            ('本机访问', f'http://localhost:{APP_PORT}', '#3A6FB7'),
            ('局域网（学生扫码用）', f'http://{local_ip}:{APP_PORT}', '#3A6FB7'),
        ]:
            row = tk.Frame(info_box, bg=BG)
            row.pack(fill=tk.X, pady=1)
            tk.Label(row, text=f'{label_text}：', font=('Microsoft YaHei', 9),
                     bg=BG, fg=MUTED, width=18, anchor='w').pack(side=tk.LEFT)
            link_label = tk.Label(row, text=url, font=('Consolas', 10, 'underline'),
                                   bg=BG, fg=color, cursor='hand2')
            link_label.pack(side=tk.LEFT)
            link_label.bind('<Button-1>', lambda e, u=url: webbrowser.open(u))
        # 默认账号
        row_acc = tk.Frame(info_box, bg=BG)
        row_acc.pack(fill=tk.X, pady=(4, 0))
        tk.Label(row_acc, text='默认账号：', font=('Microsoft YaHei', 9),
                 bg=BG, fg=MUTED, width=18, anchor='w').pack(side=tk.LEFT)
        tk.Label(row_acc, text='admin / openmentor（首次登录请改密码）',
                 font=('Consolas', 10), bg=BG, fg=INK).pack(side=tk.LEFT)

        # 服务输出
        out_box = tk.LabelFrame(self.root, text=' 服务输出 ',
                                 font=('Microsoft YaHei', 9, 'bold'),
                                 bg=BG, fg=INK, bd=1, relief='solid', padx=4, pady=4)
        out_box.pack(fill=tk.BOTH, expand=True, padx=24, pady=(4, 16))
        self.output = scrolledtext.ScrolledText(out_box, wrap=tk.WORD,
                                                 font=('Consolas', 9),
                                                 bg='#FFFFFF', fg=INK, bd=0,
                                                 state='disabled')
        self.output.pack(fill=tk.BOTH, expand=True)

    # ---------- 日志 ----------
    def log(self, msg):
        try:
            self.output.config(state='normal')
            self.output.insert(tk.END, msg + '\n')
            self.output.see(tk.END)
            self.output.config(state='disabled')
            self.root.update_idletasks()
        except tk.TclError:
            pass

    # ---------- 启动 ----------
    def start_service(self):
        if self.is_running:
            return
        if not os.path.exists(os.path.join(PROJECT_DIR, 'app.py')):
            messagebox.showerror('错误', f'找不到 app.py，请确认本启动器位于 OpenMentor 项目目录下。\n当前目录：{PROJECT_DIR}')
            return
        try:
            self.is_running = True
            self.start_btn.config(state='disabled')
            self.stop_btn.config(state='normal')
            self.status_label.config(text='🟡 服务启动中...', fg='#B8860B')
            self.log('正在启动 OpenMentor 服务...')
            self.log(f'工作目录：{PROJECT_DIR}')

            env = os.environ.copy()
            env['PYTHONIOENCODING'] = 'utf-8'
            env['PYTHONUNBUFFERED'] = '1'

            self.process = subprocess.Popen(
                [sys.executable, '-u', 'app.py'],
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                cwd=PROJECT_DIR, env=env,
                bufsize=1, text=True, encoding='utf-8', errors='replace',
            )
            self.read_thread = threading.Thread(target=self._read_output, daemon=True)
            self.read_thread.start()
            self.root.after(2000, self._confirm_running)
        except Exception as e:
            self.log(f'启动失败：{e}')
            self.is_running = False
            self.start_btn.config(state='normal')
            self.stop_btn.config(state='disabled')
            self.status_label.config(text='🔴 启动失败', fg='#B8463E')

    def _read_output(self):
        try:
            for line in iter(self.process.stdout.readline, ''):
                if not line:
                    break
                self.log(line.rstrip())
        except Exception as e:
            self.log(f'读取服务输出异常：{e}')
        # 进程结束
        if self.is_running and self.process:
            ret = self.process.poll()
            if ret is not None and self.is_running:
                self.is_running = False
                try:
                    self.start_btn.config(state='normal')
                    self.stop_btn.config(state='disabled')
                    self.open_btn.config(state='disabled')
                    self.status_label.config(text=f'⚪ 服务已退出（exit code {ret}）', fg='#6B6760')
                except tk.TclError:
                    pass

    def _confirm_running(self):
        if self.is_running and self.process and self.process.poll() is None:
            self.status_label.config(text=f'🟢 服务运行中 · 端口 {APP_PORT}', fg='#5B7553')
            self.open_btn.config(state='normal')
            self.log(f'✓ 服务已启动，访问 http://localhost:{APP_PORT}')

    # ---------- 停止 ----------
    def stop_service(self):
        if not self.is_running or not self.process:
            return
        try:
            self.log('正在停止 OpenMentor 服务...')
            self.process.terminate()
            try:
                self.process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.log('强制结束服务进程')
            self.is_running = False
            self.start_btn.config(state='normal')
            self.stop_btn.config(state='disabled')
            self.open_btn.config(state='disabled')
            self.status_label.config(text='⚪ 服务已停止', fg='#6B6760')
            self.log('✓ 服务已停止')
        except Exception as e:
            self.log(f'停止失败：{e}')

    # ---------- 浏览器 ----------
    def open_app(self):
        local_ip = get_local_ip()
        choice = messagebox.askquestion(
            '选择访问地址',
            f'选择要打开的地址：\n\n'
            f'1. 本机访问：http://localhost:{APP_PORT}\n'
            f'2. 局域网访问：http://{local_ip}:{APP_PORT}（学生扫码）\n\n'
            f'点【是】打开本机地址，点【否】打开局域网地址'
        )
        if choice == 'yes':
            webbrowser.open(f'http://localhost:{APP_PORT}')
        else:
            webbrowser.open(f'http://{local_ip}:{APP_PORT}')

    # ---------- 重置密码 ----------
    def reset_password(self):
        if not HAS_WERKZEUG:
            messagebox.showerror('错误', '缺少 werkzeug 包。请先启动一次服务（会自动安装依赖），再试一次。')
            return
        if not os.path.exists(DB_PATH):
            messagebox.showinfo('提示', '数据库尚未生成，请先启动一次服务。')
            return
        if not messagebox.askyesno(
            '确认重置',
            '将执行以下操作：\n\n'
            '• 把 admin 用户的密码重置为 openmentor\n'
            '• 清空所有 AI 模型的 API Key\n\n'
            '原有的 AI 导师、对话记录、花名册数据**不会**被删除。\n\n'
            '是否继续？'
        ):
            return
        try:
            conn = sqlite3.connect(DB_PATH)
            cur = conn.cursor()
            self.log('正在清空 AI 模型 API Key...')
            try:
                cur.execute("UPDATE ai_model_config SET api_key = NULL")
                self.log(f'  ✓ 已清空 {cur.rowcount} 条 API Key 配置')
            except sqlite3.Error as e:
                self.log(f'  ⚠ 清空 API Key 时跳过：{e}')

            self.log('正在重置 admin 用户密码...')
            new_hash = generate_password_hash('openmentor')
            cur.execute("UPDATE user SET password = ? WHERE username = ?",
                        (new_hash, 'admin'))
            if cur.rowcount > 0:
                self.log('  ✓ admin 密码已重置为 openmentor')
            else:
                self.log('  ⚠ 未找到 admin 用户（数据库可能尚未初始化，请先启动一次服务）')

            conn.commit()
            conn.close()
            messagebox.showinfo(
                '完成',
                '管理员密码已重置：\n\n账号：admin\n密码：openmentor\n\nAI 模型 API Key 已清空，请在「个人设置 → AI 配置」中重新填写。'
            )
        except Exception as e:
            self.log(f'❌ 重置失败：{e}')
            messagebox.showerror('错误', f'重置失败：{e}')

    # ---------- 关闭窗口 ----------
    def on_closing(self):
        if self.is_running:
            if messagebox.askokcancel('退出', '服务正在运行，关闭窗口将停止服务，是否继续？'):
                self.stop_service()
                self.root.destroy()
        else:
            self.root.destroy()


def main():
    root = tk.Tk()
    OpenMentorLauncher(root)
    root.mainloop()


if __name__ == '__main__':
    main()
