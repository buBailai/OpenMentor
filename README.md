# OpenMentor

<p align="center">
  <strong>🤖 让每位师生都有自己的开源 AI 导师</strong><br>
  <em>5 分钟搭出 AI 助教，无需懂 Coze、无需部署 Dify、无需服务器，全部本地化。</em>
</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-brightgreen" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/python-3.11%2B-blue" alt="Python 3.11+">
  <img src="https://img.shields.io/badge/version-V1.1.3-D97757" alt="V1.1.3">
</p>

---

OpenMentor 是基于 [QuickForm 2.0](https://github.com/wstlab/quickform) 二次开发的开源 AI 助学/助教平台。教师在本地启动后填写一段系统提示词，即可拥有一个专属 AI 助教，并通过二维码分享给学生使用。学生扫码 → 填班级姓名 → 直接对话；老师在后台实时看到学生的每一次提问与 AI 的回答，必要时可一键封禁、紧急熔断或导出对话报告。

整个过程**数据不出校园网，老师自带 API Key，无任何 SaaS 服务器**，完美契合中小学/高校真实场景。

## ✨ 核心特色

| 能力 | 说明 |
|------|------|
| 🎯 **AI 导师配置** | 老师写一段系统提示词，立即拥有专属角色（学伴、答疑、写作助手、学科导师等） |
| 🤖 **AI 帮你写提示词** | 不会写 Prompt 工程？填几个问题、上传一份教材，AI 自动生成 800 字专业 system prompt |
| 📱 **学生扫码即用** | 填班级+姓名直接进入对话，无需注册账号、无需安装 App |
| 🖼️ **多模态对话** | 图片识别 / 文件上传（PDF/Word/TXT）/ AI 生成图片 |
| 👁️ **对话审计大屏** | 老师后台实时看每个学生的对话流，每 5-8 秒自动刷新 |
| 🔒 **多重安全防护** | 每日消息上限 / 链接有效期 / 关键词黑名单 / 越狱检测 / 紧急熔断 |
| 📦 **模板分享** | 一键导出 JSON 模板，老师之间互相分享、克隆使用 |
| 🔌 **6 大国产模型** | DeepSeek / 豆包 / 通义 / 智谱 / 硅基流动 / Ollama 本地 |
| ♻️ **不丢 QuickForm** | QuickForm 原有数据采集 + AI 报告等功能完整保留 |

## 🚀 快速开始

### 推荐 ①：Windows 免安装包（最快 · 双击即用）

Windows 用户从 [**📘 OpenMentor 教程文档**](https://scnxnljz0ey0.feishu.cn/docx/I8qxdpNdPo38xJxsaiscMC09n6g)（已上传免安装包和代码包）下载 `OpenMentor_V1.1.3_免安装包.zip`，解压后**直接双击 `OpenMentor启动器.bat`** 即可自动安装依赖并运行项目，无需手动装 Python 或 pip。

启动后会先弹出「OpenMentor 一键部署安装程序」自动补齐依赖，随后自动打开「OpenMentor 启动器」界面，点「启动服务」即可使用。

### 推荐 ②：让 AI Agent 帮你装（适合纯代码版本 / macOS / Linux）

如果你下载的是纯代码版本，又不熟悉 Python / 终端命令，可以让 AI Agent 全程代劳：

1. 从 [**📘 OpenMentor 教程文档**](https://scnxnljz0ey0.feishu.cn/docx/I8qxdpNdPo38xJxsaiscMC09n6g) 下载最新代码包解压到任意目录
2. 打开 **Cherry Studio / Trae / Claude Code / OpenClaw** 等支持终端调用的 AI Agent 客户端
3. 把项目路径告诉 Agent，对它说 **"帮我启动这个项目"**
4. Agent 会自动检查 Python 环境、创建虚拟环境、安装依赖、启动服务、给你访问 URL

### 手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/buBailai/OpenMentor.git
cd OpenMentor

# 2. 创建虚拟环境（推荐）
python3 -m venv .venv
source .venv/bin/activate     # macOS / Linux
# .venv\Scripts\activate      # Windows

# 3. 安装依赖
pip install -r requirements.txt

# 4. 配置环境变量（设置 SECRET_KEY）
cp .env.example .env
# 编辑 .env 把 SECRET_KEY 改成一段长随机字符串

# 5. 启动
python app.py
```

浏览器打开 `http://<本机IP>:5001` —— 默认账号：

- 用户名：`admin`
- 密码：`openmentor`

> 详细安装步骤见 [INSTALL.md](./INSTALL.md)，使用流程见 [USAGE.md](./USAGE.md)。

## 🎬 5 分钟体验流程

1. **配置 AI** — 个人设置 → 选一家国产模型（推荐 DeepSeek）→ 填 API Key 保存
2. **创建 AI 导师** — 导航 AI 导师 → 创建 → 写系统提示词（或点 🤖 让 AI 帮你写）
3. **复制学生链接** — 详情页自动生成二维码
4. **学生扫码使用** — 填班级姓名 → 开始对话
5. **后台审计** — 详情页 → 对话审计，看学生提问与 AI 回答

## 📋 系统要求

| 项目 | 要求 |
|---|---|
| 操作系统 | Windows / macOS / Linux 任选 |
| Python | 3.11+ （推荐 3.12 / 3.14） |
| 内存 | ≥ 2 GB |
| 网络 | 教师机有外网（调用 LLM API）+ 学生与教师机同 LAN/Wi-Fi |
| 磁盘 | ≥ 200 MB（含依赖） |

## 🛡️ 安全设计

OpenMentor 默认面向**未成年学生**使用场景，安全防护贯穿全栈：

- **链接有效期**：默认 48 小时，最长 7 天
- **每日消息上限**：默认 50 条/学生，老师可调
- **关键词黑名单**：4 类默认（暴力 / 色情 / 越狱 / 作弊），老师可编辑
- **紧急熔断**：助学一键禁用，所有学生立即无法访问
- **数据隔离**：每个会话的上传文件存独立目录，跨会话路径访问被拒
- **隐私保护**：数据全部存教师本地 SQLite，不上传第三方（除调用 LLM API 时）

## 🏛️ 与 QuickForm 的关系

OpenMentor 严格遵循"**加法不减法**"原则：

- ✅ QuickForm 全部原有功能 100% 保留并继续可用（任务管理、HTML 表单、数据采集、AI 报告、QF 数据互联）
- ✅ 新增独立的「AI 导师」模块，与「数据任务」菜单并列
- ✅ 数据库以"加字段 + 新增表"方式平滑升级，旧数据不受影响

详见 [NOTICE.md](./NOTICE.md)。

## 📂 项目结构

```
OpenMentor/
├── app.py                  # 主程序（Flask 单文件 monolith）
├── requirements.txt        # Python 依赖
├── README.md               # 本文档
├── INSTALL.md              # 安装手册（面向老师）
├── USAGE.md                # 使用手册（面向老师）
├── NOTICE.md               # 开源归属声明
├── openmentor.db           # SQLite 数据库（首次启动自动生成）
├── static/                 # 静态资源（CSS/JS/上传文件）
│   ├── css/
│   ├── js/
│   ├── vendor/             # Bootstrap, qrcodejs, marked.js, highlight.js
│   └── uploads/            # QuickForm + OpenMentor 上传文件
└── templates/              # Jinja2 模板
    ├── assistant_*.html    # AI 导师管理 / 详情 / 审计
    ├── chat_*.html         # 学生端聊天
    ├── dashboard.html      # QuickForm 数据任务（保留）
    └── ...
```

## 🤝 开源致谢

OpenMentor 站在 QuickForm 的肩膀上。特别致谢：

- **温州科技高级中学 AI 科创中心** 与 **温州大学** —— 提供 QuickForm 开源项目作为基础
- 各国产大模型厂商（DeepSeek / 字节豆包 / 阿里通义 / 智谱 / 硅基流动 / Ollama 社区）

链接：

- QuickForm GitHub：<https://github.com/wstlab/quickform>
- QuickForm Gitee：<https://gitee.com/wstlab/quickform>
- QuickForm 在线版演示：<https://quickform.cn>

## 📜 开源协议

本项目采用 [MIT License](./LICENSE)，沿用 QuickForm 上游协议。

- QuickForm 原版权：Copyright © 2026 xiezuoru / 温州科技高级中学 AI 科创中心 + 温州大学
- OpenMentor 新增部分版权：Copyright © 2026 厦门市演武小学 信息中心

详见 [NOTICE.md](./NOTICE.md)。

## ⭐ Star 趋势

[![Star History Chart](https://api.star-history.com/svg?repos=buBailai/OpenMentor&type=Date)](https://star-history.com/#buBailai/OpenMentor&Date)

> 如果 OpenMentor 帮到了你，欢迎点个 ⭐ Star 让更多老师看到。
