---
name: eo-domain-blacklist-inspector
description: Skill to query the security policy of a specified domain in EdgeOne, identify which IP group is responsible for blacklist blocking logic, and surface the IP entries within that group.
---

# eo-domain-blacklist-inspector

查询 EdgeOne 指定域名关联的安全策略，识别哪个 IP 组承担黑名单拦截逻辑，并展示该 IP 组的具体条目。

## 涉及 API

| Action | 说明 |
|---|---|
| DescribeSecurityPolicy | 查询域名关联的安全策略配置 |
| DescribeSecurityIPGroup | 查询站点下所有 IP 组列表 |
| DescribeSecurityIPGroupContent | 查询指定 IP 组的详细条目 |

> **命令用法**：本文档只列出 API 名称和流程指引。
> 执行前请通过 [api-discovery.md](../api/api-discovery.md) 中的方式查阅接口文档，确认完整参数和响应说明。

## 前置条件

1. 所有腾讯云 API 调用统一通过 `tccli` 执行。如果环境中尚未配置可用凭证，必须先引导用户完成登录：

```sh
tccli auth login
```

> 执行后终端会打印授权链接，在用户完成浏览器授权前保持阻塞，授权成功后命令自动结束。
> 严禁向用户索要 `SecretId` / `SecretKey`，也不要执行可能暴露凭证内容的命令。

2. 需要先获取 ZoneId，参考 [../api/zone-discovery.md](../api/zone-discovery.md)。
3. 用户必须明确提供目标域名（如 `example.com`）；如果用户只说"这个域名"而未给出具体值，需要先追问确认。

## 场景 A：查询域名黑名单 IP 组

**触发**：用户说"查一下 example.com 的安全策略里哪个 IP 组是黑名单"、"这个域名的拦截 IP 组是哪个"。

按以下顺序调用 3 个接口：

**第一步**：获取域名关联的安全策略

```sh
tccli teo DescribeSecurityPolicy --ZoneId <ZoneId> --Entity <域名>
```

**第二步**：获取站点下所有 IP 组列表

```sh
tccli teo DescribeSecurityIPGroup --ZoneId <ZoneId>
```

**第三步**：根据前两步结果定位黑名单 IP 组 ID，查询其详细内容

```sh
tccli teo DescribeSecurityIPGroupContent --ZoneId <ZoneId> --GroupId <GroupId>
```

### 黑名单 IP 组识别规则

满足以下任一条件的 IP 组，标记为**承担黑名单拦截逻辑**：

- 被安全策略中动作为"拦截/封禁（Block）"的规则直接引用
- IP 组名称包含 `blacklist`、`blocklist`、`deny`、`黑名单`、`封禁` 等语义关键词，且被任意拦截规则引用

> ⚠️ **注意**：不要仅凭 IP 组名称判断，必须结合安全策略中的规则动作进行确认。
> 如果存在多个 IP 组均满足条件，应全部列出并说明各自对应的规则上下文。
> 如果无法明确判断，如实说明并列出所有被拦截规则引用的 IP 组供用户人工确认。

## 场景 B：检查 IP 组内容异常

**触发**：用户说"帮我看看 example.com 的 IP 封禁列表"、"检查一下黑名单 IP 组有没有问题"。

在完成场景 A 的数据采集后，重点标记以下异常：

- IP 组为空（黑名单规则生效但无任何条目）
- 存在过于宽泛的 CIDR（如 `0.0.0.0/0`、`10.0.0.0/8`）
- 测试用 IP 组长期生效
- 多个 IP 组同时承担拦截逻辑但职责不清晰

> ⚠️ **注意**：本技能只做只读查询，不执行任何 IP 组修改或策略变更操作。
> 如果用户希望修改黑名单，应明确告知需要在控制台操作或调用写接口，并提示相应风险。

## 输出格式

```markdown
## 黑名单 IP 组查询结果

**域名**：example.com（ZoneId: zone-xxx）
**查询时间**：2026-03-19
**数据来源**：DescribeSecurityPolicy / DescribeSecurityIPGroup / DescribeSecurityIPGroupContent

### 结论
域名 example.com 的安全策略中，承担黑名单拦截逻辑的 IP 组为：

- IP 组名称：blacklist-prod
- IP 组 ID：ipg-xxxxxxxx
- 关联规则：规则 ID xxx，动作：Block，触发条件：来源 IP 命中 IP 组

### IP 组详细内容

| 序号 | IP / CIDR | 备注 |
|---|---|---|
| 1 | 1.2.3.4 | ... |
| 2 | 10.0.0.0/8 | ... |

> 如果条目超过 20 条，展示前 20 条并注明"共 N 条，仅展示前 20 条"。

### 安全策略关联规则摘要

| 规则 ID | 规则名称 | 动作 | 引用 IP 组 | 备注 |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

### 补充说明（如有）
- 异常条目说明（如过于宽泛的 CIDR、空组等）
- 其他值得关注的拦截规则
```