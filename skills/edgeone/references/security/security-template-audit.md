---
name: eo-security-template-audit
description: Skill to audit EdgeOne security policy template coverage, identify domains not bound to any security template, and surface potential security gaps. Use this skill whenever the user asks about security template coverage, wants to check which domains are missing security templates, mentions template binding audits, or asks questions like 'which domains have no security template', 'check template coverage', or 'find unprotected domains'.
---

# eo-security-template-audit

盘查 EdgeOne 安全策略模板覆盖范围，输出模板与绑定资源的映射关系，找出未绑定模板的域名，适合安全审计场景。

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

## 执行流程

**触发**：用户说"哪些域名没有绑安全模板"、"帮我检查模板覆盖情况"、"看看有没有域名漏绑了安全策略"、"帮我做安全模板审计"、"哪些域名没有安全防护"、"模板绑定情况怎么样"、"帮我盘查一下安全模板"、"有没有域名没绑模板"。

按以下顺序调用接口，逐步构建模板-绑定资源映射表：

### 第一步：获取所有安全策略模板列表

```sh
tccli teo DescribeWebSecurityTemplates --ZoneId <ZoneId>
```

记录每个模板的 `TemplateId` 和 `TemplateName`，作为后续查询的输入。

### 第二步：逐一获取每个模板的详细配置

```sh
tccli teo DescribeWebSecurityTemplate --ZoneId <ZoneId> --TemplateId <TemplateId>
```

关注以下字段，用于后续状态标注：
- 模板是否启用（整体开关状态）
- 各防护模块（WAF、CC、Bot 等）是否有规则配置

### 第三步：查询每个模板的域名绑定关系

```sh
tccli teo DescribeSecurityTemplateBindings --ZoneId <ZoneId> --TemplateId <TemplateId>
```

收集每个模板绑定的域名列表，汇总为全局的"已覆盖域名集合"。

### 第四步：获取站点完整域名列表

为了识别未覆盖域名，需要获取站点下的完整域名列表：

```sh
tccli teo DescribeZoneRelatedDomains --ZoneId <ZoneId>
```

> 如果该接口不可用或返回为空，可尝试通过 [api-discovery.md](../api/api-discovery.md) 查找其他获取域名列表的接口（如 `DescribeAccelerationDomains`）。

### 第五步：交叉比对，识别未覆盖域名

将"已覆盖域名集合"（第三步汇总结果）与站点完整域名列表做差集，得出未绑定任何模板的域名清单。

> ⚠️ **注意**：如果无法获取站点完整域名列表，应明确说明"当前仅能基于模板绑定关系输出已知覆盖情况，无法确认是否存在遗漏域名"，不要凭空推断。

## 输出格式

```markdown
## 安全模板覆盖盘查报告

**站点**：example.com（ZoneId: zone-xxx）
**盘查时间**：YYYY-MM-DD
**数据来源**：DescribeWebSecurityTemplates / DescribeWebSecurityTemplate / DescribeSecurityTemplateBindings

### 模板-绑定资源映射表

| 模板名称 | 模板 ID | 绑定域名数 | 绑定域名列表 | 模板状态 |
|---|---|---|---|---|
| 生产环境模板 | template-xxx | 3 | a.com, b.com, c.com | ✅ 正常 |
| 测试环境模板 | template-yyy | 0 | —（未绑定任何域名） | ⚠️ 空模板 |

### 覆盖摘要

- 当前模板总数：N 个
- 已绑定域名的模板：N 个 / 空模板（未绑定任何域名）：N 个
- 已覆盖域名总数：N 个
- **未覆盖域名总数：N 个**

### 未覆盖域名清单

> 以下域名未绑定任何安全策略模板，存在防护空白：

- example.com
- test.example.com
- staging.example.com

（如无法获取完整域名列表，此处注明"数据不完整，仅展示已知覆盖情况"）

### 处理建议

- 未覆盖域名：建议评估后绑定合适的安全模板
- 空模板：建议确认是否为预留模板，如无用途可考虑清理
```

> **只读声明**：本技能仅执行查询操作，不进行任何绑定或修改。如需补绑模板，请在控制台操作或调用相应写接口，操作前请确认影响范围。
