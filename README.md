# edgeone-agent-plugins

EdgeOne（边缘安全加速平台）综合插件，覆盖站点加速、安全防护等配置、运维与问题排查任务。

## 项目结构

```
edgeone-agent-plugins/
├── .claude-plugin/
│   └── plugin.json          # Claude Plugin 清单文件（必须）
├── skills/
│   └── edgeone/
│       ├── SKILL.md          # Skill 入口与指引
│       └── references/       # 参考文档
│           ├── api/          # API 调用规范、工具安装、凭证配置
│           ├── acceleration/ # 站点接入、缓存刷新、证书管理
│           └── security/     # 安全策略模板、黑名单查询、安全周报
├── install.sh                # 一键安装脚本
└── README.md
```

## 安装

### 作为 Claude Plugin 安装

运行安装脚本，将插件软链到 `~/.claude/plugins/`：

```bash
bash install.sh
```

安装后重启 Claude Code，即可通过插件市场或命令使用本插件。

### 作为 Skill 安装

`install.sh` 同时会将 `skills/edgeone` 软链到各客户端的 skills 目录：

| 客户端 | 安装路径 |
|---|---|
| Claude | `~/.claude/skills/edgeone` |
| Codex | `~/.codex/skills/edgeone` |
| Cursor | `~/.cursor/skills/edgeone` |
| CodeBuddy | `~/.codebuddy/skills/edgeone` |

## 功能模块

| 模块 | 说明 |
|---|---|
| API 调用 | 调用规范、tccli 安装、凭证配置、接口检索、站点与域名发现 |
| 站点加速 | 站点接入、缓存刷新 / 预热、证书管理 |
| 安全防护 | 安全策略模板盘查、黑名单 IP 组查询、安全周报 |