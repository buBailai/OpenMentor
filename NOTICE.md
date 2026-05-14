# NOTICE · OpenMentor 开源致谢与归属声明

OpenMentor 是基于 [QuickForm 2.0（纯代码版）](https://github.com/wstlab/quickform) 进行二次开发的开源项目。

## 上游项目

| 项目 | QuickForm |
| --- | --- |
| 开发单位 | 温州科技高级中学 AI 科创中心 + 温州大学 |
| GitHub | <https://github.com/wstlab/quickform> |
| Gitee | <https://gitee.com/wstlab/quickform> |
| 在线演示 | <https://quickform.cn> |
| 二次开发起点版本 | QuickForm 教师版 2.0（纯代码版） |
| 协议 | MIT License (Copyright © 2026 xiezuoru) |

## 本项目（OpenMentor）

| 项目 | OpenMentor |
| --- | --- |
| 开发者 | 厦门市演武小学 信息中心 |
| GitHub | <https://github.com/buBailai/OpenMentor> |
| 协议 | MIT License（沿用 QuickForm 上游协议） |

## 二次开发原则

OpenMentor 遵循**「加法不减法」**原则：

1. **路由不冲突**：新增 `/assistant/*` `/chat/*`，不动现有 `/dashboard` `/task/*` `/api/<task_id>`
2. **数据库不破坏**：新增表 + Task 加字段（带默认值），不改现有 Submission/Attachment 结构
3. **模板不覆盖**：新增 `assistant_*.html` `chat_*.html`，不改原 `dashboard.html` `task_detail.html`
4. **导航不替换**：在原导航栏新增「AI 导师」「班级花名册」「学情大屏」与「QuickForm」下拉，原任务功能集中在 QuickForm 子菜单下
5. **AI 调用兼容**：`call_ai_model()` 函数增加可选参数，旧调用方不变

QuickForm 原有所有功能（任务管理、HTML 表单、数据采集、AI 报告、QF 数据互联、用户管理、附件上传等）100% 保留并继续可用。

## 主要新增功能（V1.1.3 / V1.2.0）

> V1.2.0 在 V1.1.3 基础上：
> - **AI 导师广场**（V1.2.0 新）：浏览全国老师分享的 AI 导师卡片，按学科 / 学段 / 关键词筛选，一键克隆到自己的库直接使用；导师详情页可一键分享自己的导师到广场（公开 + 不可撤回）
> - **AI 优化已有提示词**（V1.2.0 新）：编辑导师时新增「AI 优化这段」按钮，老师说明优化方向，AI 在保留原意基础上精准优化
> - **数学 / 化学公式渲染**（V1.2.0 引入）：所有 markdown 渲染面（学生对话 / 老师审计 / AI 学情报告 / 智能分析）支持 LaTeX 数学公式（`$...$` / `$$...$$`）和 mhchem 化学公式（`\ce{H2SO4}`），由 KaTeX 排版，全部资源本地化（`static/vendor/katex/` ≈ 596KB）
> - **首页「📍 打卡与意见」按钮 + 中国地图实时打卡热力图**（V1.2.0 引入）：学生 / 老师可一键打卡、看全国 OpenMentor 用户分布；「💬 提意见」跳飞书反馈表单
> - **更新日志页**（V1.2.0 新）：右上角用户菜单加入口，老师能直观看到每版改了啥
> - 多处 UI 一致性修复（hero 三按钮单行、各功能页标题字体统一）
> - `.gitignore` 把数据库 `openmentor.db` 等运行时文件从 git 摘出

OpenMentor 在 QuickForm 之上新增：

- **AI 导师**：创建 / 编辑 / 克隆 / 模板导入导出，每个导师可独立配置系统提示词、欢迎语、模型、多模态开关、安全策略
- **AI 帮你写提示词**（带素材萃取）：填几个引导问题或上传素材，AI 提炼要点融入 system prompt 草稿
- **提示词草稿历史**（V1.1.3 新）：localStorage 自动保存最近 10 条生成结果，可随时恢复 / 删除 / 清空
- **学生端对话**：扫码 → 身份验证 → SSE 流式回复，支持 Markdown / 图片输入 / 文件上传 / AI 生图
- **班级花名册**：Excel 导入 + 自由填写模式班级选项配置（年级 / 班级两层下拉）
- **设备 × 身份双重隔离**：token = sha256(device_uuid + class + name)，同名不同设备相互不可见
- **对话评分**：学生可对每条 AI 回复点 👍/👎，老师后台看满意度统计
- **AI 学情报告**（V1.1.2 引入；V1.1.3 升级 SSE 流式）：单学生 / 全班级一键生成结构化 Markdown 报告，AI 边写边显示不再等几十秒；自动持久化到「报告历史」可随时回看 / 下载 / 删除
- **学情大屏**：基于 ECharts，含每日趋势 / 班级活跃度 / 学生参与排行 / 满意度 / 24 小时热度等 7 张图
- **审计大屏**：实时查看每位学生的对话、附件、AI 生成图，支持搜索 / 班级筛选 / 状态筛选；多设备会话自动聚合
- **附件按日期分桶存储**（V1.1.2 引入）：所有附件按 `<日期>/<会话>/` 二级目录组织，长期使用不会单层目录爆掉
- **QuickForm 任务支持附件上传**（V1.1.2 引入）：原本仅采集 JSON，现在 multipart 表单可附图片/文档/音视频；老师后台「查看附件」模态框预览
- **附件 docx / xlsx 在线预览**（V1.1.3 新）：浏览器端懒加载渲染（docx-preview + SheetJS），免下载查看 Word 文档和 Excel 工作簿
- **服务器本机打开附件文件夹**（V1.1.2 引入）：审计页一键 reveal in Finder / Explorer，自部署场景免下载
- **API Key 申请直达**（V1.1.3 新）：设置页选模型后下方自动出现"申请 API Key"按钮，链接到对应官网
- **黑名单与越狱检测**：关键词分类管理，命中自动拦截 + 老师审计标红
- **6 大国产 LLM**：DeepSeek / 豆包 / 通义千问 / 智谱 / 硅基流动 / Ollama，全部 BYO API Key
- **PWA 化**：可"添加到主屏幕"，离线可加载界面
- **Anthropic 风格 UI**：奶油 + 粘土橙的 editorial 视觉，支持深色模式

## 协议与法律

- 本项目采用 **MIT License**（与 QuickForm 上游一致）
- 所有原 QuickForm 代码版权归原开发单位（温州科技高级中学 AI 科创中心 + 温州大学 / xiezuoru）所有
- OpenMentor 新增部分代码版权归 厦门市演武小学 信息中心 白鹭辉 所有
- 使用本项目时，请保留 LICENSE 文件中的两份版权声明

## 致谢

特别致敬 QuickForm 项目，它是中国教育界少见的、真正服务一线教师的开源工具，为本项目提供了坚实的基础。
