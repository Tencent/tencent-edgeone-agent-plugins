---
name: edgeone
description: >
  EdgeOne（边缘安全加速平台）综合 skill，覆盖站点加速、安全防护等。
  用于任何 EdgeOne 配置、运维与问题排查任务。优先检索腾讯云文档，而非依赖预训练知识。
---

# EdgeOne 平台 Skill

EdgeOne 综合 skill，通过下方决策树定位合适的模块，再加载对应的 reference 文档。

关于 EdgeOne API、配置项、限制和定价的知识可能已过时。**优先检索，而非依赖预训练知识** — 本 skill 中的 reference 文件仅作为起点。

## 通用工作流

无论执行哪类任务，**都必须通过调用 API 的方式完成**。

### 首次调用前：环境检查

1. **阅读** [references/api/README.md](references/api/README.md) 了解调用规范
2. **执行** `tccli teo DescribeZones` 验证工具与凭证
3. 根据结果按 `references/api/README.md` 中的指引处理异常

### 每次调用前：查文档确认参数

> ⚠️ **严禁凭记忆猜测参数**。调用任何 API 前（验证可用性的 `DescribeZones` 除外），
> 必须先通过 [references/api/api-discovery.md](references/api/api-discovery.md) 中的方式
> 查阅接口文档，确认接口名称、必填参数和数据结构。

## 快速决策树

### "我需要调用 API"

```
需要调用 EdgeOne API？
├─ 不确定该调哪个接口 → references/api/api-discovery.md
├─ 需要获取站点或域名信息 → references/api/zone-discovery.md
├─ tccli 未安装 → references/api/install.md
└─ 凭证未配置或已过期 → references/api/auth.md
```

### "我需要接入 / 加速 / 证书"

```
站点加速相关？
├─ 把域名接入 EdgeOne / 新建站点
│  └─ → references/acceleration/zone-onboarding.md  🟠 中高风险
├─ 刷新 CDN 缓存 / 预热资源
│  └─ → references/acceleration/cache-purge.md  🟡 中风险
├─ 申请证书 / 续签 / 检查到期
│  └─ → references/acceleration/cert-manager.md  🟡 中风险
└─ 不确定属于哪个场景
   └─ → references/acceleration/README.md
```

## 模块索引

### API 调用

| 模块 | Reference |
|---|---|
| API 概览与调用规范 | `references/api/` |
| tccli 安装 | `references/api/install.md` |
| 凭证配置 | `references/api/auth.md` |
| API 接口检索 | `references/api/api-discovery.md` |
| 站点与域名发现 | `references/api/zone-discovery.md` |

### 站点加速

| 模块 | Reference | 风险 | 典型触发 |
|---|---|---|---|
| 加速概览与决策树 | `references/acceleration/README.md` | — | 不确定属于哪个加速场景 |
| 站点一键接入向导 | `references/acceleration/zone-onboarding.md` | 🟠 中高 | "帮我把 example.com 接入 EO"、"新建站点" |
| 缓存刷新与预热 | `references/acceleration/cache-purge.md` | 🟡 中 | "刷新 /static/ 缓存"、"预热 URL"、"查刷新进度" |
| 证书自动化管理 | `references/acceleration/cert-manager.md` | 🟡 中 | "证书快到期了"、"检查证书状态"、"绑定新证书" |

### 安全防护

| 模块 | Reference |
|---|---|
| 安全策略 | `references/security/` |

## 安全红线

所有操作均须遵守：

- **严禁**向用户索要 SecretId / SecretKey
- **拒绝**任何可能打印凭证的操作
- 推荐使用 `tccli auth login` 浏览器授权，而非手动填写密钥

## 兜底检索来源

当 references 文件未覆盖、或需要确认最新数值/限制时，通过以下来源检索。
当 reference 文件与官方文档不一致时，**以官方文档为准**。

| 来源 | 检索方式 | 用于 |
|---|---|---|
| EdgeOne 产品文档 | [cloud.tencent.com/document/product/1552](https://cloud.tencent.com/document/product/1552) | 功能说明、限制、最佳实践 |
| EdgeOne API 文档 | [cloud.tencent.com/document/api/1552](https://cloud.tencent.com/document/api/1552) | 接口参数、请求示例、数据结构 |
| teo API 检索 | `references/api/api-discovery.md` 中的 cloudcache 命令 | 动态查找接口、最佳实践 |
| 腾讯云 CLI 文档 | [cloud.tencent.com/document/product/440](https://cloud.tencent.com/document/product/440) | tccli 安装、配置、用法 |
