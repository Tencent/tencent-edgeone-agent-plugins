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

运行 `skills` 目录（本 README.md 的上一级）下的 `pack.sh`：

```bash
./pack.sh                  # 构建所有业务 skill 到 dist/
./pack.sh eo-acceleration  # 只构建指定 skill
```

构建过程：
1. 将业务 skill（`SKILL.md` + 自身 `references/`）拷贝到 `dist/<skill>/`
2. 将 `eo-common/references/*` 注入到 `dist/<skill>/references/`（不覆盖同名文件）

构建产物示例（以 `eo-acceleration` 为例）：

```
dist/eo-acceleration/
├── SKILL.md                             ← 业务 skill 自身入口
└── references/
    ├── cert-manager.md                  ← 业务 skill references
    ├── ...
    ├── eo-api-guide.md                  ← eo-common 注入（索引）
    └── eo-api/                          ← eo-common 注入（详细指引）
        ├── install.md                   ← tccli 安装指引
        ├── auth.md                      ← tccli 凭证配置
        ├── api-discovery.md             ← teo API 动态检索
        └── zone-discovery.md            ← ZoneId 发现
```

> - Agent 阅读路径：`SKILL.md` → `eo-api-guide.md` → 按需路由到 `eo-api/` 下的子文件。
> - 若业务 skill 自身 `references/` 下存在同名文件，则保留业务 skill 版本，不会被 eo-common 覆盖。

## 安全红线

所有文件均遵循：

- **严禁**向用户索要 SecretId / SecretKey
- **拒绝**任何可能打印凭证的操作
- 推荐使用 `tccli auth login` 浏览器授权，而非手动填写密钥
