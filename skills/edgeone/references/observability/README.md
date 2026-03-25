# EdgeOne 可观测性参考

流量日报生成、回源健康巡检、离线日志下载与日志分析的运维指引。

## 快速决策树

```
用户想做什么？
│
├─ 「帮我生成昨天的流量日报」
│  「看看过去 24 小时的带宽峰值」
│  └─ → eo-traffic-daily-report.md  🟢 低风险 · 自动采集 7 层/4 层数据，生成 Markdown 日报
│
├─ 「帮我看看 example.com 的回源情况」
│  「源站健康吗」「CDN 问题还是源站问题」
│  └─ → eo-origin-health-check.md  🟢 低风险 · 回源状态码分布 + 健康比例 + 快速归因
│
├─ 「帮我下载 example.com 昨天下午的日志」
│  「下载近 6 小时的 4 层日志」
│  └─ → eo-log-downloader.md  🟢 低风险 · 自然语言驱动的离线日志下载链接获取
│
├─ 「帮我分析一下日志，502 特别多」
│  「分析一下异常请求都集中在哪些 URI」
│  └─ → eo-log-analyzer.md  🟢 低风险 · 日志下载 + 本地解析 + 模式识别 + 故障推断
│
└─ 不确定该调哪个 API
   └─ → ../api/api-discovery.md
```

## 前置条件

所有操作均需要通过 tccli 调用 API。首次使用前，请先完成：

1. **工具检查** — 阅读 [../api/README.md](../api/README.md) 完成 tccli 安装与凭证配置
2. **获取 ZoneId** — 阅读 [../api/zone-discovery.md](../api/zone-discovery.md) 获取站点 ID

## 本目录文件

| 文件 | 风险等级 | 核心触发场景 |
|---|---|---|
| [eo-traffic-daily-report.md](eo-traffic-daily-report.md) | 🟢 低风险 | 每日定时查询 7 层/4 层流量趋势，生成带宽峰值、请求量、Top 域名/地区的 Markdown 日报 |
| [eo-origin-health-check.md](eo-origin-health-check.md) | 🟢 低风险 | 查询回源状态码分布、源站健康比例，快速定位回源故障归因 |
| [eo-log-downloader.md](eo-log-downloader.md) | 🟢 低风险 | 通过自然语言描述时间范围和域名，自动获取离线日志下载链接 |
| [eo-log-analyzer.md](eo-log-analyzer.md) | 🟢 低风险 | 自动下载日志并本地解析，提取异常明细，给出模式识别结论和故障推断建议 |

## 参考链接

- [EdgeOne 产品文档](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API 文档](https://cloud.tencent.com/document/api/1552)
- [API 调用指引](../api/README.md)
