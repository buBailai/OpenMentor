# OpenMentor Windows 免安装包 · 构建工具

> 本工具在 **Windows 电脑** 上运行，把 OpenMentor 源码 + 嵌入式 Python + 全部依赖打包成一个**完全免安装**的文件夹（最终用户双击 `OpenMentor启动器.bat` 即可使用，**电脑无需预先安装 Python**）。

---

## 给 Claude（Windows 端）的指令

如果你正在 Windows 上用 Claude / Trae / Cherry Studio 等 AI Agent 跑这个脚本，**把下面这段直接复制给 AI**：

> 我有一个 OpenMentor 项目源码在 `<填路径，比如 D:\OpenMentor>`，请帮我执行 `tools\windows_bundle\build.ps1` 来构建 Windows 免安装包。
>
> 1. 用 PowerShell 进入项目目录
> 2. 由于 PowerShell 默认禁止运行未签名脚本，先临时放行当前会话：
>    `Set-ExecutionPolicy -Scope Process Bypass -Force`
> 3. 然后执行：`.\tools\windows_bundle\build.ps1`
> 4. 等 5-10 分钟（首次需下载 Python embeddable + pip + 17 个依赖包，共约 200MB）
> 5. 完成后会在 `..\dist\OpenMentor_Vx.y.z_Windows免安装包\` 生成完整的免安装文件夹和同名 zip
>
> 跑完后告诉我两个产物的路径，并双击 `OpenMentor启动器.bat` 实测一下是否能启动。

---

## 一、前置要求（运行此脚本的 Windows 电脑）

- **Windows 10 / 11**（PowerShell 5.1 自带，或装 PowerShell 7+）
- **互联网连接**：要从 python.org 下载 Python embeddable + 从 pypi.org 下载依赖包
- **磁盘 ≥ 1 GB 可用**：构建过程缓存约 100MB，最终成品约 250MB，zip 约 80-120MB
- **不需要预装 Python**——脚本会自己下载嵌入式 Python

---

## 二、运行步骤

### 1. 解锁 PowerShell 脚本执行（仅当前会话生效，安全）
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
```

### 2. 切换到项目目录
```powershell
cd D:\OpenMentor   # ← 改成你解压 OpenMentor 源码的实际路径
```

### 3. 运行构建脚本（默认参数即可）
```powershell
.\tools\windows_bundle\build.ps1
```

或者指定参数：
```powershell
.\tools\windows_bundle\build.ps1 -PythonVersion 3.12.7 -ZipOutput $true -UseTsinghua $true
```

### 4. 等待构建完成

控制台会输出每一步进度：
```
[OK] 源码完整 (app.py, OpenMentor启动器.bat, ...)
[OK] 创建输出目录
[-] 下载 Python 3.12.7 embeddable (amd64)...
[OK] Python embeddable: ...\.cache\python-3.12.7-embed-amd64.zip (10.5 MB)
[OK] env\python.exe 已就位
[OK] 已启用 site-packages: python312._pth
[-] 安装 pip...
[OK] pip 已安装
[-] 安装项目依赖（首次约 3-8 分钟）...
[OK] 项目依赖安装完成
[-] 复制 OpenMentor 源码...
[OK] 源码已复制（已排除 .venv / .git / .env / db / uploads / reports）
[-] 验证嵌入式 Python 能 import flask...
flask 3.0.3
[OK] 验证通过
[OK] 包大小：234.8 MB
[-] 打包成 zip...
[OK] zip 已生成: ..\dist\OpenMentor_V1.1.3_Windows免安装包.zip (98.2 MB)

================================================================
  ✓ 构建完成！
================================================================
```

### 5. 验证

```powershell
cd ..\dist\OpenMentor_V1.1.3_Windows免安装包
.\OpenMentor启动器.bat
```

如果看到 GUI 启动器窗口、能成功启动服务（按 ▶ 按钮）、能打开浏览器访问 `http://localhost:5001`，就**构建成功**。

---

## 三、参数说明

| 参数 | 默认值 | 说明 |
|---|---|---|
| `-PythonVersion` | `3.12.7` | Python 版本。注意必须是 python.org 提供 embeddable zip 的版本，且要兼容 requirements.txt（pandas 2.0.3 wheel 仅到 3.12）|
| `-Arch` | `amd64` | 架构。`amd64` = 64 位（推荐），`win32` = 32 位 |
| `-SourceDir` | （脚本上两级目录）| OpenMentor 源码目录 |
| `-OutputDir` | 源码父目录下 `dist\` | 输出目录 |
| `-ZipOutput` | `$true` | 是否打包成 zip |
| `-UseTsinghua` | `$true` | pip 是否用清华镜像（国内推荐 true）|

---

## 四、产物说明

### 文件夹（用户解压后的样子）
```
OpenMentor_V1.1.3_Windows免安装包\
├── OpenMentor启动器.bat       ← 用户双击这个
├── env\                        嵌入式 Python（含全部依赖）~ 200 MB
│   ├── python.exe
│   ├── python312.dll
│   ├── Lib\site-packages\     已装好 flask / sqlalchemy / pandas / pillow / pypdf / ...
│   └── ...
├── app.py                      主程序
├── templates\                  Jinja2 模板
├── static\                     前端静态资源（CSS / JS / vendor / icons）
├── openmentor_installer.py    GUI 安装器（启动器调用）
├── gui_launcher.py            GUI 控制面板（▶启动 / ■停止 / 🌐打开 / 🔑重置）
├── start.bat / start.sh       命令行启动（备用）
├── README.md / INSTALL.md / USAGE.md / NOTICE.md / LICENSE
└── 免安装包说明.txt
```

### 用户体验
1. 解压 zip
2. 双击 `OpenMentor启动器.bat`
3. 弹出"OpenMentor 一键部署"窗口（检查依赖，应该 0 缺失因为已预装）
4. 自动启动"OpenMentor 启动器" GUI 控制面板
5. 点 ▶ **启动服务** → 等几秒 → 点 🌐 **打开浏览器** → 浏览器自动打开 `http://localhost:5001`
6. 用 `admin / openmentor` 登录

**全程不需要装任何东西**。

---

## 五、常见问题

### Q1: 报错 "无法加载文件 build.ps1，因为在此系统上禁止运行脚本"
解：先执行 `Set-ExecutionPolicy -Scope Process Bypass -Force`（仅当前会话生效，关掉窗口就还原）。

### Q2: 下载 Python embeddable 失败
- 可能国内网络被墙。手动下载到 `tools\windows_bundle\.cache\python-3.12.7-embed-amd64.zip` 后重跑脚本（会复用缓存）。
- 下载链接：<https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip>

### Q3: pip 安装依赖时某个包卡住或失败
- 默认用清华镜像。如果还失败，用 `-UseTsinghua $false` 切回 PyPI。
- 个别 wheel 缺失可能是 Python 版本不匹配，把 `-PythonVersion` 换 `3.11.9` 试试。

### Q4: 包很大（200+MB），能压一压吗
- 默认 zip 是最优压缩，已经压到 ~80-120MB。
- 想再瘦身可以删 `env\Lib\site-packages\matplotlib`（如果不用 QuickForm 的 AI 报告 PDF 渲染）：约能省 30MB。

### Q5: 在国外 / VPN 网络环境下跑
- 加 `-UseTsinghua $false` 走默认 PyPI，国外可能更稳。

### Q6: 想升级 Python 版本
- 脚本参数 `-PythonVersion`。注意 pandas 2.0.3 的 wheel 只到 Python 3.12；如果升到 3.13/3.14，需要先升级 `requirements.txt` 里 pandas 版本（如 `pandas>=2.2`）。

---

## 六、技术细节

### 嵌入式 Python（Python embeddable distribution）特点
- 是 Python.org 提供的"瘦身版"Python：只有解释器 + 标准库，**没有 IDLE / pip / venv 工具**
- 默认禁用了 site-packages（通过 `python312._pth` 里的 `#import site`）
- 本脚本通过修改 `._pth` 文件启用 `import site`，然后用 `get-pip.py` 安装 pip，再用 pip 安装所有依赖
- 装好后 `env\python.exe` 是一个完整可用的 Python，能 `import flask` 等

### 启动器适配
`OpenMentor启动器.bat` 已经写成自动适配三种 Python 来源：
1. **嵌入式**（`env\python.exe` 存在）→ 用本地 python.exe，**这是免安装包的情况**
2. **标准 venv**（`env\Scripts\activate.bat` 存在）→ 激活 venv
3. **系统 Python** → fall back 到 PATH 上的 python

所以同一份 `OpenMentor启动器.bat` 既适用于免安装包，也适用于源码版本。

### 排除的文件（不打包）
- `.git\` `.venv\` `__pycache__\` `.DS_Store`
- `.env`（每个用户应该自己生成，含 SECRET_KEY）
- `openmentor.db`（含 admin 用户但也含构建机的测试数据；用户首次启动会自动生成新的）
- `static\uploads\` 和 `static\reports\` 下的实际文件（保留 `.gitkeep` 占位）
- `tools\windows_bundle\` 自身（不需要打包给用户）

---

## 七、跨版本迁移

V1.1.3 之后构建新版本：
1. 在 Mac 上把 dev 改动同步到 OpenMentor_V1.1.x（按 release flow 文档）
2. 把 V1.1.x 整个文件夹拷贝到 Windows 电脑
3. 在 Windows 上跑 `tools\windows_bundle\build.ps1`
4. 拿到新的免安装包

未来如果想全自动化，可以让 GitHub Actions 在 windows-latest runner 上跑这个脚本，自动生成 release artifact。
