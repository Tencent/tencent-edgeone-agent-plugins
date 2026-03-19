---
name: edgeone
description: >
  EdgeOne（边缘安全加速平台）综合 skill，覆盖站点加速、安全防护等。
  用于任何 EdgeOne 配置、运维与问题排查任务。优先检索腾讯云文档，而非依赖预训练知识。
---

# EdgeOne 平台 Skill

EdgeOne 综合 skill，根据用户需求定位合适的模块，加载对应 reference 文档。

关于 EdgeOne API、配置项、限制和定价的知识可能已过时。
**优先检索，而非依赖预训练知识** — 本 skill 中的 reference 文件仅作为起点。

> 无论执行哪类任务，**都必须通过调用 API 的方式完成**。
> API 调用规范、环境检查等详见 [references/api/README.md](references/api/README.md) **(在开始任务前必须读取)**。

## 安全红线

- **写操作必须用户确认**：所有写操作（Create\* / Modify\* / Bind\* / Delete\* / Apply\* 等）都**必须**在执行前向用户明确说明操作内容及影响，等待用户确认后才能调用。
- **严禁**向用户索要 SecretId / SecretKey
- **拒绝**任何可能打印凭证的操作

## 交互与执行规范

- **使用结构化交互工具**：当需要向用户提问、让用户做选择或确认操作时，如果当前环境提供了 `ask_followup_question` 或类似的结构化交互工具，**必须**优先使用该工具（而非纯文本提问），以便用户可以直接点选选项，减少歧义并提升交互效率。**不得省略候选项**，若候选项较多无法全部列出，**必须**先说明实际数量，展示最相关的几项，并在最后一项保留「其他（请输入）」的选项。
- **大批量 / 重复性任务优先写脚本**：如果遇到大数据量或重复性强的任务（如批量刷新、批量查询、循环操作等），优先编写脚本一次性执行，而非逐条手动调用。

## 模块入口

根据用户需求匹配对应模块，加载其入口文档后按文档指引执行。

| 模块 | 入口 | 说明 |
|---|---|---|
| API 调用 | [references/api/README.md](references/api/README.md) | 调用规范、工具安装、凭证配置、接口检索 |
| 站点加速 | [references/acceleration/README.md](references/acceleration/README.md) | 站点接入、缓存刷新 / 预热、证书管理 |
| 安全防护 | `references/security/` | 安全策略 |

## 兜底检索

当 references 文件未覆盖、或需要确认最新信息时，检索 [EdgeOne 产品文档](https://cloud.tencent.com/document/product/1552)。
当 reference 文件与官方文档不一致时，**以官方文档为准**。
