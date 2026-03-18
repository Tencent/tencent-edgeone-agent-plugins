# eo-common — EdgeOne Skill 公共基础模块

EdgeOne 系列 skill 共享的基础 reference 文件。

> **注意**：eo-common **不是**一个独立的 skill（没有 `SKILL.md`），它是一个源码层面共享的模块。
> 构建时通过 `pack.sh` 将其 `references/` 注入到每个业务 skill 中。

## 文件结构

```
eo-common/
├── README.md                            ← 本文件
└── references/
    ├── eo-api-guide.md                  ← 入口索引：工具检查 + 用户配置 + 路由表
    └── eo-api/
        ├── install.md                   ← tccli 安装指引（pipx / Homebrew）
        ├── auth.md                      ← 凭证配置（浏览器 OAuth 登录）
        ├── api-discovery.md             ← teo API 动态检索（cloudcache）
        └── zone-discovery.md            ← ZoneId 发现与域名反查
```

## 各文件职责

| 文件 | 职责 |
|---|---|
| `eo-api-guide.md` | 索引入口。定义用户可配置变量（`REGION` 等），指导 agent 做首次工具检查，路由到子文件 |
| `eo-api/install.md` | tccli 安装方式（pipx 推荐 / Homebrew 备选），适用于 macOS / Linux / Windows |
| `eo-api/auth.md` | 凭证配置流程：`tccli auth login` 浏览器授权，多账户管理，Agent 场景阻塞提示 |
| `eo-api/api-discovery.md` | 通过 cloudcache 检索 teo 最佳实践、接口列表、接口文档、数据结构 |
| `eo-api/zone-discovery.md` | ZoneId 发现：列出站点、按域名查询、子域名反查、域名列表、缓存建议 |

## 使用方式

### 业务 skill 中引用

构建后 eo-common 的文件会出现在业务 skill 的 `references/` 目录下，
业务 skill 的 `SKILL.md` 直接引用即可：

```markdown
首次使用前，请阅读 [references/eo-api-guide.md](references/eo-api-guide.md) 完成工具检查。
```

### 构建注入

在 `edgeone-skills` 仓库中运行 `pack.sh`：

```bash
./pack.sh                  # 构建所有业务 skill 到 dist/
./pack.sh eo-acceleration  # 只构建指定 skill
```

构建过程：
1. 将业务 skill（`SKILL.md` + 自身 `references/`）拷贝到 `dist/<skill>/`
2. 将 `eo-common/references/*` 注入到 `dist/<skill>/references/`（不覆盖同名文件）

### 用户可配置变量

在 `eo-api-guide.md` 中定义，业务 skill 或用户对话中可覆盖：

| 变量 | 默认值 | 说明 |
|---|---|---|
| `REGION` | `ap-guangzhou` | EdgeOne API 区域，支持 `ap-guangzhou`、`ap-chongqing` |

## Agent 阅读路径

```
业务 SKILL.md
  └─→ references/eo-api-guide.md        ← 工具检查 + 用户配置
        ├─→ eo-api/install.md            ← 按需：tccli 未安装时
        ├─→ eo-api/auth.md              ← 按需：凭证无效时
        ├─→ eo-api/api-discovery.md      ← 按需：不确定调哪个接口时
        └─→ eo-api/zone-discovery.md     ← 按需：需要 ZoneId 时
```

## 安全红线

所有文件均遵循：

- **严禁**向用户索要 SecretId / SecretKey
- **拒绝**任何可能打印凭证的操作
- 推荐使用 `tccli auth login` 浏览器授权，而非手动填写密钥
