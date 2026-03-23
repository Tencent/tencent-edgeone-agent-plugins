# EdgeOne Agent Plugins

帮助 AI Agent 在 [腾讯云 EdgeOne](https://edgeone.ai) 平台上进行配置、运维与问题排查的工具集合。

## 安装

### Claude Code / Codebuddy

通过插件市场安装：

```bash
# 1. 注册市场
/plugin marketplace add TencentEdgeOne/edgeone-agent-plugins

# 2. 安装插件
/plugin install edgeone-agent-plugins@edgeone
```

### OpenAI Codex / Gemini CLI / OpenCode / 其他 Agent

对于没有内置插件市场的 AI 工具，请告诉你的 Agent：

```
请获取并按照以下文件中的说明操作：
https://raw.githubusercontent.com/TencentEdgeOne/edgeone-agent-plugins/main/INSTALL.md
```

或手动安装 — 参阅 [INSTALL.md](INSTALL.md) 获取详细步骤。

### 克隆 / 复制

将仓库克隆到本地，然后将 `skills/` 目录下的内容复制到你的 skills 目录中：

```bash
git clone https://github.com/TencentEdgeOne/edgeone-agent-plugins.git
# 根据你的 Agent 工具，复制到对应目录
# 例如：cp -r edgeone-agent-plugins/skills/edgeone ~/.claude/skills/
```

## Skills

### edgeone

EdgeOne（边缘安全加速平台）综合 Skill，覆盖站点加速、安全防护等场景。用于任何 EdgeOne 配置、运维与问题排查任务。优先检索腾讯云文档，而非依赖预训练知识。

**包含以下模块：**

| 模块 | 说明 | 典型触发场景 |
|---|---|---|
| **API 调用** | 调用规范、工具安装、凭证配置、接口检索、站点与域名发现 | 首次使用 EdgeOne API、安装 tccli、配置凭证 |
| **站点加速** | 站点接入、缓存刷新 / 预热、证书管理 | 「帮我把 example.com 接入 EO」「刷新缓存」「证书快过期了」 |
| **安全防护** | 安全策略模板盘查、黑名单 IP 组查询、安全周报 | 「哪些域名没绑安全模板」「出一份安全周报」「查黑名单 IP 组」 |

## 安全设计

- **写操作必须用户确认**：所有写操作（创建、修改、删除等）执行前都会向用户说明影响并等待确认
- **严禁索要密钥**：Agent 不会向用户索要 SecretId / SecretKey，使用浏览器 OAuth 安全登录
- **只读优先**：安全相关技能默认为只读查询，不执行任何修改操作

## 相关资源

- [EdgeOne 产品文档](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API 文档](https://cloud.tencent.com/document/api/1552)
- [EdgeOne 官网](https://edgeone.ai)
- [腾讯云 CLI 文档](https://cloud.tencent.com/document/product/440)
