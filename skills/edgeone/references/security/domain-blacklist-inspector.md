---
name: eo-domain-blacklist-inspector
description: Skill to query the security policy of a specified domain in EdgeOne, identify which IP group is responsible for blacklist blocking logic, and surface the IP entries within that group.
---

# eo-domain-blacklist-inspector

查询 EdgeOne 指定域名关联的安全策略，解析策略规则中 `action=block` 的 IP 组引用，输出黑名单 IP 组映射报告。

> **定位说明**：本 Skill 是写操作（如 `eo-ip-threat-blacklist`）的**前置诊断步骤**。在向黑名单 IP 组写入条目之前，应先用本 Skill 查清楚目标黑名单组 ID，避免误操作错误的 IP 组。

## 涉及 API

| Action | 说明 |
|---|---|
| DescribeSecurityPolicy | 查询域名关联的安全策略配置 |
| DescribeSecurityIPGroup | 查询站点下所有 IP 组列表 |
| DescribeSecurityIPGroupContent | 查询指定 IP 组的详细条目 |

> **命令用法**：本文档只列出 API 名称和流程指引。
> 执行前请通过 [api-discovery.md](../api/api-discovery.md) 中的方式查阅接口文档，确认完整参数和响应说明。

## 前置条件

1. 所有腾讯云 API 调用统一通过 `tccli` 执行，执行前请确认已完成登录鉴权。

2. 需要先获取 ZoneId，参考 [../api/zone-discovery.md](../api/zone-discovery.md)。
3. 用户必须明确提供目标域名（如 `example.com`）；如果用户只说"这个域名"而未给出具体值，需要先追问确认。

## 执行流程

**触发**：用户说"查一下 example.com 的安全策略里哪个 IP 组是黑名单"、"这个域名的拦截 IP 组是哪个"、"帮我看看 example.com 的 IP 封禁列表"、"我要往黑名单加 IP，先帮我查一下黑名单组"。

按以下顺序调用接口，构建黑名单 IP 组映射报告：

### 第一步：获取域名关联的安全策略

调用 `DescribeSecurityPolicy` 接口，从返回结果中提取所有规则，重点关注 **`action=block`（拦截/封禁）** 的规则，记录这些规则引用的 IP 组 ID。

### 第二步：获取站点下所有 IP 组列表

调用 `DescribeSecurityIPGroup` 接口，将第一步中识别出的 IP 组 ID 与此列表对照，补全 IP 组名称等元信息。

### 第三步：查询黑名单 IP 组的详细条目

对第一步中识别出的每个黑名单 IP 组，逐一调用 `DescribeSecurityIPGroupContent` 接口查询其详细内容。

### 黑名单 IP 组识别规则

**以规则动作为主要判断依据**：

- **确认为黑名单组**：被安全策略中 `action=block` 的规则直接引用的 IP 组
- **辅助参考**：IP 组名称包含 `blacklist`、`blocklist`、`deny`、`黑名单`、`封禁` 等语义关键词，可作为辅助说明，但不能作为唯一判断依据

> ⚠️ **注意**：
> - 不要仅凭 IP 组名称判断，必须结合安全策略中的规则动作进行确认。
> - 如果存在多个 IP 组均被 `action=block` 规则引用，应全部列出并说明各自对应的规则上下文。
> - 如果无法明确判断，如实说明并列出所有被拦截规则引用的 IP 组供用户人工确认。

## 输出格式

```markdown
## 黑名单 IP 组查询结果

**域名**：example.com（ZoneId: zone-xxx）
**查询时间**：YYYY-MM-DD
**数据来源**：DescribeSecurityPolicy / DescribeSecurityIPGroup / DescribeSecurityIPGroupContent

### 黑名单 IP 组（action=block 规则引用）

> 以下 IP 组被安全策略中的拦截规则直接引用，是本域名的黑名单 IP 组：

| IP 组名称 | **IP 组 ID** | 条目数 | 关联规则 ID | 规则动作 |
|---|---|---|---|---|
| blacklist-prod | **ipg-xxxxxxxx** | 42 | rule-001 | Block |

> 如需向上述 IP 组写入条目，请使用 IP 组 ID：`ipg-xxxxxxxx`

### IP 组详细条目

**blacklist-prod**（ipg-xxxxxxxx）

| 序号 | IP / CIDR | 备注 |
|---|---|---|
| 1 | 1.2.3.4 | ... |
| 2 | 5.6.7.8/24 | ... |

> 如果条目超过 20 条，展示前 20 条并注明"共 N 条，仅展示前 20 条"。

### 安全策略关联规则摘要

| 规则 ID | 规则名称 | 动作 | 引用 IP 组 | 备注 |
|---|---|---|---|---|
| rule-001 | 黑名单拦截 | Block | blacklist-prod | ... |

### 补充说明（如有）

- 异常条目说明（如 IP 组为空、存在过于宽泛的 CIDR 如 `0.0.0.0/0` 等）
- 其他值得关注的拦截规则
```

> **只读声明**：本技能仅执行查询操作，不进行任何 IP 组修改或策略变更。如需修改黑名单，请在控制台操作或调用相应写接口，操作前请确认影响范围。
