# EdgeOne Agent Plugins

中文 | [English](README.md)

EdgeOne Agent Plugins 是帮助 AI Agent 在 [腾讯云 EdgeOne](https://edgeone.ai) 平台上进行配置、运维与问题排查的工具集合。

## 安装

### Claude Code / Codebuddy

通过插件市场安装：

```bash
# 1. 注册市场
/plugin marketplace add TencentEdgeOne/edgeone-agent-plugins

# 2. 安装插件
/plugin install edgeone-agent-plugins@edgeone
```

### OpenAI Codex / Gemini CLI / Cursor / OpenCode / 其他 Agent

对于没有内置插件市场的 AI 工具，请告诉你的 Agent：

```
请获取并按照以下文件中的说明操作：
https://raw.githubusercontent.com/TencentEdgeOne/edgeone-agent-plugins/main/INSTALL.md
```

也可以手动克隆仓库后安装：

```bash
git clone https://github.com/TencentEdgeOne/edgeone-agent-plugins.git
# 根据你的 Agent 工具，复制到对应目录
# 例如：cp -r edgeone-agent-plugins/skills/edgeone ~/.claude/skills/
```

详细的安装方式请参阅 [INSTALL.md](INSTALL.md)。

## Skills

### edgeone

腾讯云 EdgeOne（边缘安全加速平台）综合 Skill，覆盖边缘加速（DNS、证书、缓存、规则引擎、四层代理、负载均衡）、边缘安全（DDoS 防护、Web 防护、Bot 管理）、边缘媒体（视频 / 图片即时处理）、边缘开发（边缘函数、EdgeOne Pages）等平台能力。

> 本 Skill 通过 [腾讯云 CLI](https://cloud.tencent.com/document/product/440) 调用腾讯云 API 来实现相关能力。使用前需要安装腾讯云 CLI，如果您尚未安装，Agent 会在启动 Skill 后自动完成安装。

**包含以下能力：**

| 模块 | 说明 | 典型触发场景 |
|---|---|---|
| **站点加速** | 站点接入、缓存刷新 / 预热、证书管理 | 「帮我把 example.com 接入 EO」「刷新缓存」「证书快过期了」 |
| **安全防护** | 安全策略模板盘查、黑名单 IP 组查询、安全周报 | 「哪些域名没绑安全模板」「出一份安全周报」「查黑名单 IP 组」 |
| **可观测性** | 流量日报、回源健康检查、离线日志下载与分析 | 「生成昨天的流量日报」「回源是否正常」「下载昨天下午的日志」「分析日志，502 太多了」 |

## 安全设计

- **写操作必须用户确认**：所有写操作（创建、修改、删除等）执行前都会向用户说明影响并等待确认
- **严禁索要密钥**：Agent 不会向用户索要 SecretId / SecretKey，使用浏览器 OAuth 安全登录
- **只读优先**：安全相关 Skill 默认为只读查询，不执行任何修改操作

## 相关资源

- [EdgeOne 产品文档](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API 文档](https://cloud.tencent.com/document/api/1552)
- [EdgeOne 官网](https://edgeone.ai)
- [腾讯云 CLI 文档](https://cloud.tencent.com/document/product/440)
