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
/plugin install edgeone-agent-plugins@tencent-edgeone
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

腾讯云 EdgeOne（边缘安全加速平台）综合 Skill，可支持通过该 skill 完成 EdgeOne 内的站点接入、域名配置、 HTTPS 证书管理、缓存管理以及安全分析、可观测性等相关操作。

> 本 Skill 通过 [腾讯云 CLI](https://cloud.tencent.com/document/product/440) 调用腾讯云 API 来实现相关能力。使用前需要安装腾讯云 CLI，如果您尚未安装，Agent 会在启动 Skill 后自动完成安装。

#### 能力一览

edgeone **包含以下能力：**

| 模块 | 场景 | 典型触发场景 |
|---|---|---|
| **站点加速** | <ul><li>站点接入向导</li><li>缓存刷新 / 预热</li><li>证书自动化管理</li></ul> | <ul><li>「帮我把 example.com 接入 EO」</li><li>「刷新 /static/ 下所有缓存」</li><li>「证书快过期了，帮我续期」</li></ul> |
| **安全防护** | <ul><li>安全周报生成</li><li>安全模板覆盖度审计</li><li>域名黑名单 IP 组识别</li><li>威胁 IP 分析与封禁</li></ul> | <ul><li>「出一份本周安全状况报告」</li><li>「哪些域名没绑安全模板」</li><li>「查一下这个域名的黑名单 IP 组」</li><li>「分析最近的攻击 IP，帮我封禁」</li></ul> |
| **可观测性** | <ul><li>流量趋势日报</li><li>回源健康检查</li><li>离线日志下载</li><li>日志解析与故障分析</li></ul> | <ul><li>「生成昨天的流量日报」</li><li>「回源是不是挂了」</li><li>「下载 example.com 昨天下午的日志」</li><li>「502 太多了，帮我分析一下日志」</li></ul> |

#### Skill 文件结构

edgeone 通过设计多级索引引导 Agent 按需读取文档，组织如下：

```
edgeone/
├── SKILL.md                              # edgeone skill 入口
└── references/                           # skill 的参考文档
    ├── api/                              # API 调用模块
    │   ├── README.md                     # 模块入口
    │   ├── install.md                    # 场景：tccli 安装
    │   └── ...
    ├── acceleration/                     # 站点加速模块
    │   ├── README.md                     # 模块入口
    │   ├── cache-purge.md                # 场景：缓存刷新/预热
    │   └── ...
    ├── security/                         # 安全防护模块
    │   ├── README.md                     # 模块入口
    │   ├── security-report.md            # 场景：安全周报
    │   └── ...
    └── ...                               # 其他模块...
```

## 安全设计

- **写操作必须用户确认**：所有写操作（创建、修改、删除等）执行前都会向用户说明影响并等待确认
- **严禁索要密钥**：Agent 不会向用户索要 SecretId / SecretKey，使用浏览器 OAuth 安全登录
- **只读优先**：安全相关 Skill 默认为只读查询，不执行任何修改操作

## 相关资源

- [EdgeOne 产品文档](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API 文档](https://cloud.tencent.com/document/api/1552)
- [EdgeOne 官网](https://edgeone.ai)
- [腾讯云 CLI 文档](https://cloud.tencent.com/document/product/440)
