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
| 开发者 | 厦门市演武小学 信息中心 白鹭辉 |
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

## 主要新增功能（V1.1.1）

OpenMentor 在 QuickForm 之上新增：

- **AI 导师**：创建 / 编辑 / 克隆 / 模板导入导出，每个导师可独立配置系统提示词、欢迎语、模型、多模态开关、安全策略
- **AI 帮你写提示词**：填几个引导问题或上传素材，自动生成 system prompt 草稿
- **学生端对话**：扫码 → 身份验证 → SSE 流式回复，支持 Markdown / 图片输入 / 文件上传 / AI 生图
- **班级花名册**：Excel 导入 + 自由填写模式班级选项配置（年级 / 班级两层下拉）
- **设备 × 身份双重隔离**：token = sha256(device_uuid + class + name)，同名不同设备相互不可见
- **对话评分**：学生可对每条 AI 回复点 👍/👎，老师后台看满意度统计
- **学情大屏**：基于 ECharts，含每日趋势 / 班级活跃度 / 学生参与排行 / 满意度 / 24 小时热度等 7 张图
- **审计大屏**：实时查看每位学生的对话、附件、AI 生成图，支持搜索 / 班级筛选 / 状态筛选；多设备会话自动聚合
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
