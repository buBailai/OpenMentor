#!/usr/bin/env bash
# ============================================================
# OpenMentor 一键启动脚本（macOS / Linux）
# - 自动检查 Python 3.11+
# - 自动创建虚拟环境并安装依赖（首次约 1-3 分钟）
# - 自动生成 .env 含随机 SECRET_KEY
# - 启动服务并打印本机 + 局域网访问地址
#
# 用法：终端执行  ./start.sh   或  bash start.sh
# 如果首次执行提示 "Permission denied"，先运行：chmod +x start.sh
# ============================================================
set -e
cd "$(dirname "$0")"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
DIM='\033[2m'
NC='\033[0m'   # reset

echo ""
echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE}  OpenMentor 一键启动 · 让每位师生都有自己的开源 AI 导师${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""

# ---------- 1. 检查 Python ----------
PYTHON_CMD=""
for cmd in python3.14 python3.13 python3.12 python3.11 python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        # 验证版本 ≥ 3.11
        VER=$("$cmd" -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>/dev/null || echo "")
        if [ -n "$VER" ]; then
            MAJOR=${VER%.*}
            MINOR=${VER#*.}
            if [ "$MAJOR" -ge 3 ] && [ "$MINOR" -ge 11 ]; then
                PYTHON_CMD="$cmd"
                break
            fi
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo -e "${RED}❌ 未检测到 Python 3.11 或以上版本${NC}"
    echo ""
    echo "请先安装 Python：https://www.python.org/downloads/"
    echo "macOS 推荐用 Homebrew：  brew install python@3.12"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓${NC} Python 版本：$($PYTHON_CMD --version)"

# ---------- 2. 创建虚拟环境 ----------
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}→${NC} 首次启动，创建虚拟环境..."
    "$PYTHON_CMD" -m venv .venv
    NEW_VENV=1
else
    NEW_VENV=0
fi

# 激活
# shellcheck disable=SC1091
source .venv/bin/activate
echo -e "${GREEN}✓${NC} 虚拟环境已激活：$(which python)"

# ---------- 3. 安装依赖 ----------
DEPS_FLAG=".venv/.om_deps_installed"
REQ_HASH_FILE=".venv/.om_requirements_hash"
CUR_HASH=$(shasum requirements.txt 2>/dev/null | cut -d' ' -f1 || echo "")
PREV_HASH=$(cat "$REQ_HASH_FILE" 2>/dev/null || echo "")

NEED_INSTALL=false
ALREADY_OK=false
if [ ! -f "$DEPS_FLAG" ]; then
    # 没标记 → 看现有 venv 是否已经能 import flask（接管手动装好的环境）
    if python -c "import flask" >/dev/null 2>&1; then
        ALREADY_OK=true
        touch "$DEPS_FLAG"
        echo "$CUR_HASH" > "$REQ_HASH_FILE"
    else
        NEED_INSTALL=true
    fi
elif [ "$CUR_HASH" != "$PREV_HASH" ]; then
    NEED_INSTALL=true
fi

if $NEED_INSTALL; then
    echo -e "${YELLOW}→${NC} 安装/更新依赖（首次约 1-3 分钟，请耐心等待）..."
    # 优先用清华镜像加速；失败则回退到默认源
    if pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --quiet; then
        echo -e "${GREEN}✓${NC} 依赖安装完成（清华镜像）"
    else
        echo -e "${YELLOW}⚠${NC} 清华镜像失败，尝试默认源..."
        if pip install -r requirements.txt --quiet; then
            echo -e "${GREEN}✓${NC} 依赖安装完成（默认源）"
        else
            echo -e "${RED}❌${NC} 依赖安装失败，请检查网络或手动执行：pip install -r requirements.txt"
            exit 1
        fi
    fi
    touch "$DEPS_FLAG"
    echo "$CUR_HASH" > "$REQ_HASH_FILE"
elif $ALREADY_OK; then
    echo -e "${GREEN}✓${NC} 检测到已安装的依赖（跳过重装）"
else
    echo -e "${GREEN}✓${NC} 依赖已是最新（如需强制重装：删除 .venv 后重新启动）"
fi

# ---------- 4. 生成 .env ----------
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}→${NC} 生成 .env（含随机 SECRET_KEY）..."
    SECRET=$("$PYTHON_CMD" -c "import secrets; print(secrets.token_urlsafe(48))")
    echo "SECRET_KEY=$SECRET" > .env
    echo -e "${GREEN}✓${NC} .env 已生成"
fi

# ---------- 5. 找局域网 IP ----------
LAN_IP=""
if command -v ipconfig >/dev/null 2>&1; then
    # macOS: 优先 en0 (Wi-Fi/有线)，其次 en1
    for iface in en0 en1 en2; do
        IP=$(ipconfig getifaddr "$iface" 2>/dev/null || true)
        if [ -n "$IP" ]; then LAN_IP="$IP"; break; fi
    done
fi
if [ -z "$LAN_IP" ] && command -v hostname >/dev/null 2>&1; then
    # Linux fallback
    LAN_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi

# ---------- 6. 启动 ----------
echo ""
echo -e "${BLUE}========================================================${NC}"
echo -e "${GREEN}  OpenMentor 启动中...${NC}"
echo -e "${BLUE}========================================================${NC}"
echo -e "${DIM}  本机访问：${NC}  http://localhost:5001"
[ -n "$LAN_IP" ] && echo -e "${DIM}  局域网（学生扫码用）：${NC}  http://$LAN_IP:5001"
echo -e "${DIM}  默认账号：${NC}    admin / openmentor"
echo -e "${DIM}  停止服务：${NC}    按 Ctrl+C"
echo -e "${BLUE}========================================================${NC}"
echo ""

exec python app.py
