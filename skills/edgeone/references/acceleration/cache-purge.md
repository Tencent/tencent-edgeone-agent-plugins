# 缓存刷新与预热

管理 EdgeOne 节点缓存：查询配额、刷新缓存（URL / 目录 / Host / 全部 /
Cache Tag）、URL 预热、查询任务进度。支持从文件 / 粘贴批量输入 URL。

## 涉及 API

| Action | 说明 |
|---|---|
| CreatePurgeTask | 创建缓存刷新任务 |
| DescribePurgeTasks | 查询缓存刷新任务状态 |
| CreatePrefetchTask | 创建 URL 预热任务 |
| DescribePrefetchTasks | 查询预热任务状态 |
| DescribeContentQuota | 查询刷新 / 预热的每日配额和剩余用量 |
| DescribePrefetchOriginLimit | 查询预热回源限速限制（白名单内测） |

> **命令用法**：本文档只列出 API 名称和流程指引。
> 执行前请通过 `tccli teo <Action> help` 查询完整参数和响应说明。

## 核心交互规范

1. **提交前必查配额**：执行 CreatePurgeTask / CreatePrefetchTask 前，
   先调用 DescribeContentQuota 展示配额剩余量，若剩余不足则提醒用户
2. **批量 URL 输入**：支持用户从文件或粘贴方式批量输入 URL（见场景 E）
3. **轮询任务进度**：提交任务后主动查询进度，直到任务完成或超时

## 场景 A：查询配额

**触发**：用户说"还能刷新多少条"、"查看配额"、"预热额度还剩多少"。

调用 `DescribeContentQuota`，传入 `ZoneId`。

> 需要先获取 ZoneId，
> 参考 [../api/zone-discovery.md](../api/zone-discovery.md)。

**输出建议**：以表格展示各类型配额用量，标注剩余不足 10% 的类型。

## 场景 B：缓存刷新

**触发**：用户说"刷新缓存"、"清除 CDN 缓存"、"purge URL"、
"刷新目录"、"清全站缓存"。

> **前置步骤**：
> 1. 调用 DescribeAccelerationDomains 确认站点下有可用的加速域名
> 2. 调用 DescribeContentQuota（场景 A）展示配额剩余量，
>    若对应类型配额不足则提醒用户

> ⚠️ **确认提示**：缓存刷新会使节点缓存失效，后续请求将回源拉取
> 最新内容，可能增加源站负载。执行前需告知用户影响范围并获得确认。

**调用** `CreatePurgeTask`。支持 5 种刷新类型：
`purge_url`（URL）、`purge_prefix`（目录）、`purge_host`（Host）、
`purge_all`（全站）、`purge_cache_tag`（Cache Tag）。

> ⚠️ **全站刷新**（`purge_all`）是高影响操作：清除该站点所有节点缓存，
> 短时间内大量请求将回源，可能造成源站压力骤增。
> 务必向用户强调影响并获得明确确认。

**后续操作**：告知用户任务已提交并提供 JobId。
若需确认执行结果，转至 [场景 D](#场景-d查询任务进度)。

## 场景 C：URL 预热

**触发**：用户说"预热 URL"、"提前缓存"、"prefetch"、"预加载资源"。

> **前置步骤**：
> 1. 先调用 DescribeContentQuota（场景 A）展示 `prefetch_url` 配额剩余量
> 2.（可选）调用 DescribePrefetchOriginLimit 查询目标域名的回源限速限制

URL 预热会主动将资源从源站拉取到边缘节点缓存，
适合大促、发版前提前预热热点资源。

**调用** `CreatePrefetchTask`。预热仅支持 URL 粒度，
不支持目录或域名级别。

### C2：查询预热回源限速限制（DescribePrefetchOriginLimit）

> 此接口为白名单内测功能，仅在用户提到"预热限速"时使用。

调用 `DescribePrefetchOriginLimit`，传入 `ZoneId`。

**输出建议**：若域名有限速配置，在预热前提醒用户当前带宽上限，
大批量预热可能受此限制影响。

## 场景 D：查询任务进度

**触发**：用户说"刷新完了吗"、"查看任务进度"、"预热状态"。

### D1：查询刷新任务

调用 `DescribePurgeTasks`，传入 `ZoneId`。
推荐通过 Filters 按 `job-id` 过滤。

### D2：查询预热任务

调用 `DescribePrefetchTasks`，参数和 Filters 与刷新任务类似。

**输出建议**：以表格展示任务列表，标注 `failed` 和 `timeout` 的任务。
若有失败任务，建议用户检查 URL 是否正确或稍后重试。

> 预热任务额外有 `invalid` 状态，表示源站响应非 2xx，需检查源站服务。

### D3：提交后自动轮询进度

提交刷新 / 预热任务后，应主动轮询任务状态直到终态：

1. 提交任务后获取 `JobId`
2. 等待 5-10 秒后查询状态
3. 若仍在 `processing`，继续等待并重试（建议间隔 10 秒）
4. 若到达终态（`success` / `failed` / `timeout` / `canceled`），
   汇总结果展示给用户

> 通常 URL 刷新 1-2 分钟完成，目录 / Host 刷新 3-5 分钟，
> 预热时间取决于资源大小和数量。

## 场景 E：批量 URL 输入

**触发**：用户提供大量 URL 列表（从文件读取或直接粘贴多行）。

### E1：从用户粘贴的文本提取 URL

当用户粘贴多行 URL 时：
1. 按行分割文本，每行一个 URL
2. 过滤掉空行和注释行（以 `#` 开头）
3. 确保每个 URL 以 `http://` 或 `https://` 开头
4. 汇总有效 URL 数量，展示给用户确认

### E2：从文件读取 URL 列表

当用户说"从文件导入"、"读取 URL 列表文件"：
1. 读取用户指定的文件（支持 `.txt`、`.csv` 等纯文本格式）
2. 按行解析，过滤空行和注释
3. 展示解析出的 URL 数量和前几条样例，请用户确认

### E3：批量提交注意事项

- **检查配额**：先查 DescribeContentQuota，确保剩余配额 ≥ URL 数量
- **单次上限**：每次提交的 URL 数量受单次批量上限限制，
  超过上限时自动分批提交
- **URL 去重**：提交前去重，避免浪费配额
- **结果汇总**：所有批次提交完成后，汇总 JobId 列表和失败项，
  统一查询进度
