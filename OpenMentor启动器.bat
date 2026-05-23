@echo off
REM ============================================================
REM OpenMentor 启动器（Windows 双击运行）
REM 自动适配三种 Python 来源（按优先级）：
REM   1. 嵌入式 Python（env\python.exe）—— 完全免安装包
REM   2. 标准虚拟环境（env\Scripts\activate.bat）
REM   3. 系统 PATH 上的 Python
REM ============================================================
chcp 65001 > nul
title OpenMentor 启动器
cd /d "%~dp0"

set "PYTHON_CMD="

REM 1. 嵌入式 Python（Python embeddable，免安装包专用）
if exist "env\python.exe" (
    set "PYTHONHOME=%~dp0env"
    set "PATH=%~dp0env;%~dp0env\Scripts;%PATH%"
    set "PYTHON_CMD=%~dp0env\python.exe"
    goto :check_python
)

REM 2. 标准虚拟环境
if exist "env\Scripts\activate.bat" (
    call env\Scripts\activate.bat
    set "PYTHON_CMD=python"
    goto :check_python
)

REM 3. 系统 Python
set "PYTHON_CMD=python"

:check_python
echo ============================================================
echo   OpenMentor 启动器
echo   让每位师生都有自己的开源 AI 导师
echo ============================================================
echo.

"%PYTHON_CMD%" --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Python，请先安装 Python 3.11 或以上版本
    echo.
    echo 下载地址：https://www.python.org/downloads/
    echo 安装时务必勾选 "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%V in ('"%PYTHON_CMD%" --version') do echo Python: %%V
echo.

REM 启动 GUI 安装器（自动检查依赖 + 启动 GUI 控制面板）
echo 正在启动 OpenMentor 部署工具...
echo.
"%PYTHON_CMD%" openmentor_installer.py
if errorlevel 1 (
    echo.
    echo [警告] 部署过程中出错，可手动运行：
    echo     "%PYTHON_CMD%" gui_launcher.py
)

echo.
echo 按任意键关闭此窗口...
pause >nul
