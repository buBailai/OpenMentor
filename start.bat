@echo off
REM ============================================================
REM OpenMentor 一键启动脚本（Windows）
REM - 自动检查 Python 3.11+
REM - 自动创建虚拟环境并安装依赖（首次约 1-3 分钟）
REM - 自动生成 .env 含随机 SECRET_KEY
REM - 启动服务并打印本机 + 局域网访问地址
REM
REM 用法：双击 start.bat 即可
REM ============================================================
chcp 65001 > nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo ========================================================
echo   OpenMentor 一键启动 . 让每位师生都有自己的开源 AI 导师
echo ========================================================
echo.

REM ---------- 1. 检查 Python ----------
set "PYTHON_CMD="
for %%P in (python3.14 python3.13 python3.12 python3.11 python3 python py) do (
    where %%P >nul 2>&1
    if not errorlevel 1 (
        for /f "tokens=*" %%V in ('%%P -c "import sys; print('%%d.%%d' %% sys.version_info[:2])" 2^>nul') do (
            set "VER=%%V"
            for /f "tokens=1,2 delims=." %%a in ("!VER!") do (
                set "MAJ=%%a"
                set "MIN=%%b"
                if !MAJ! geq 3 if !MIN! geq 11 (
                    set "PYTHON_CMD=%%P"
                    goto :py_found
                )
            )
        )
    )
)

:py_not_found
echo [X] 未检测到 Python 3.11 或以上版本
echo.
echo 请先安装 Python：https://www.python.org/downloads/
echo 安装时务必勾选 "Add Python to PATH"
echo.
pause
exit /b 1

:py_found
for /f "tokens=*" %%V in ('!PYTHON_CMD! --version') do echo [OK] Python 版本: %%V

REM ---------- 2. 创建虚拟环境 ----------
if not exist ".venv" (
    echo [-] 首次启动，创建虚拟环境...
    !PYTHON_CMD! -m venv .venv
    if errorlevel 1 (
        echo [X] 创建虚拟环境失败，请手动检查
        pause
        exit /b 1
    )
)

call .venv\Scripts\activate.bat
echo [OK] 虚拟环境已激活

REM ---------- 3. 安装依赖 ----------
set "DEPS_FLAG=.venv\.om_deps_installed"
set "REQ_HASH_FILE=.venv\.om_requirements_hash"

REM 计算 requirements.txt 的简易"指纹"（文件大小 + 修改时间），用于变更检测
set "CUR_FP="
for %%F in (requirements.txt) do set "CUR_FP=%%~zF_%%~tF"
set "PREV_FP="
if exist "%REQ_HASH_FILE%" set /p PREV_FP=<"%REQ_HASH_FILE%"

REM 已有标记 + 指纹一致 → 跳过重装
if exist "%DEPS_FLAG%" (
    if "!CUR_FP!" == "!PREV_FP!" (
        echo [OK] 依赖已是最新（如需强制重装：删除 .venv 后重新启动）
        goto deps_done
    )
)

REM 没标记 → 先看 flask 能不能直接 import（接管手动装好的环境）
if not exist "%DEPS_FLAG%" (
    python -c "import flask" >nul 2>&1
    if not errorlevel 1 (
        echo [OK] 检测到已安装的依赖（跳过重装）
        type nul > "%DEPS_FLAG%"
        > "%REQ_HASH_FILE%" echo !CUR_FP!
        goto deps_done
    )
)

echo [-] 安装/更新依赖（首次约 1-3 分钟，请耐心等待）...
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --quiet
if errorlevel 1 (
    echo [!] 清华镜像失败，尝试默认源...
    pip install -r requirements.txt --quiet
    if errorlevel 1 (
        echo [X] 依赖安装失败，请检查网络连接或手动执行：pip install -r requirements.txt
        pause
        exit /b 1
    )
)
echo [OK] 依赖安装完成
type nul > "%DEPS_FLAG%"
> "%REQ_HASH_FILE%" echo !CUR_FP!

:deps_done

REM ---------- 4. 生成 .env ----------
if not exist ".env" (
    echo [-] 生成 .env（含随机 SECRET_KEY）...
    for /f "tokens=*" %%S in ('!PYTHON_CMD! -c "import secrets; print(secrets.token_urlsafe(48))"') do set "SECRET=%%S"
    > .env echo SECRET_KEY=!SECRET!
    echo [OK] .env 已生成
)

REM ---------- 5. 找局域网 IP（IPv4 优先）----------
set "LAN_IP="
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /R /C:"IPv4 .*: 192\.168\." /C:"IPv4 .*: 10\." /C:"IPv4 .*: 172\." 2^>nul') do (
    set "IP=%%i"
    set "IP=!IP: =!"
    if not defined LAN_IP set "LAN_IP=!IP!"
)

REM ---------- 6. 启动 ----------
echo.
echo ========================================================
echo   OpenMentor 启动中...
echo ========================================================
echo   本机访问:           http://localhost:5001
if defined LAN_IP echo   局域网（学生扫码用）: http://!LAN_IP!:5001
echo   默认账号:           admin / openmentor
echo   停止服务:           按 Ctrl+C ^| 关闭此窗口
echo ========================================================
echo.

python app.py
echo.
echo OpenMentor 已退出。按任意键关闭窗口...
pause >nul
