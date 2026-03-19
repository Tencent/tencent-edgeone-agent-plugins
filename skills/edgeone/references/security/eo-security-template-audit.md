---
name: eo-security-template-audit
description: Skill to audit EdgeOne security policy template coverage, identify domains not bound to any security template, and surface potential security gaps.
---

# eo-security-template-audit

盘查 EdgeOne 安全策略模板覆盖范围，找出未绑定模板的域名，识别潜在的安全防护空白。

## 涉及 API

| Action | 说明 |
|---|---|
| DescribeWebSecurityTemplates | 查询站点下所有安全策略模板列表 |
| DescribeWebSecurityTemplate | 查询单个模板的详细配置 |
| DescribeSecurityTemplateBindings | 查询模板与域名的绑定关系 |

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

## 场景 A：盘查模板覆盖范围

**触发**：用户说"哪些域名没有绑安全模板"、"帮我检查模板覆盖情况"、"看看有没有域名漏绑了安全策略"。

按以下顺序调用 3 个接口：

**第一步**：获取所有安全策略模板列表

```sh
tccli teo DescribeWebSecurityTemplates --ZoneId <ZoneId>
```

**第二步**：逐一获取每个模板的详细配置

```sh
tccli teo DescribeWebSecurityTemplate --ZoneId <ZoneId> --TemplateId <TemplateId>
```

**第三步**：查询每个模板的域名绑定关系

```sh
tccli teo DescribeSecurityTemplateBindings --ZoneId <ZoneId> --TemplateId <TemplateId>
```

将绑定关系与站点域名列表交叉比对，得出未覆盖域名清单。

> ⚠️ **注意**：如果无法获取站点完整域名列表，应明确说明"当前仅能基于模板绑定关系输出已知覆盖情况，无法确认是否存在遗漏域名"。

## 场景 B：检查模板防护状态异常

**触发**：用户说"帮我检查安全模板有没有问题"、"有没有模板防护规则是空的"。

在完成场景 A 的数据采集后，重点标记以下异常：

- 防护规则为空或全部关闭的模板（即使已绑定域名，也属于防护空白）
- 已创建但未绑定任何域名的空模板
- 模板中存在过于宽松的放行规则
- 绑定的模板已被删除或处于异常状态

> ⚠️ **注意**：不要凭空判断域名的风险等级，必须结合域名命名、暴露情况等可观测信息给出依据。
> 本技能只做只读查询，不执行任何绑定或修改操作；如果用户希望补绑模板，应明确告知需要在控制台操作或调用写接口，并提示相应风险。

## 输出格式

```markdown
## 安全模板覆盖盘查报告

**站点**：example.com（ZoneId: zone-xxx）
**盘查时间**：2026-03-19
**数据来源**：DescribeWebSecurityTemplates / DescribeWebSecurityTemplate / DescribeSecurityTemplateBindings

### 覆盖摘要
- 当前模板总数：N 个
- 已绑定域名的模板：N 个 / 空模板：N 个
- 已覆盖域名总数：N 个
- **未覆盖域名总数：N 个**

### 未覆盖域名清单

🔴 高风险（需立即处理）
  - example.com

🟡 中风险（本周内处理）
  - test.example.com
  - staging.example.com

⚪ 待确认（需人工判断）
  - internal.example.com

### 模板状态摘要

| 模板名称 | 模板 ID | 绑定域名数 | 防护状态 | 备注 |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

### 处理建议
- 立即处理：高风险未覆盖域名，建议绑定合适的安全模板
- 本周内处理：中风险未覆盖域名，建议评估后绑定
- 持续观察：空模板或防护规则异常的模板，建议人工复核
```