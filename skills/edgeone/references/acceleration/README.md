# EdgeOne 站点加速参考

站点接入、域名管理、缓存刷新 / 预热、HTTPS 证书的配置与运维指引。

## 快速决策树

```
用户想做什么？
│
├─ 「帮我把 example.com 接入 EO」
│  「新建一个站点并配置好源站」
│  「接入站点后帮我申请免费证书」
│  └─ → zone-onboarding.md  🟠 中高风险 · 分步引导，每步告知当前操作
│
├─ 「刷新 /static/ 下所有缓存」
│  「预热这批 URL 列表」
│  「查一下刷新任务进度」
│  └─ → cache-purge.md  🟡 中风险 · 提交前显示配额剩余量
│
├─ 「我的证书快到期了，帮我续签」
│  「给这批域名绑定新证书」
│  「检查所有域名的证书状态」
│  └─ → cert-manager.md  🟡 中风险 · 自动扫描 30 天内到期证书
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
| [zone-onboarding.md](zone-onboarding.md) | 🟠 中高风险 | 新客户接入 EdgeOne，完整走完建站到证书部署全流程 |
| [cache-purge.md](cache-purge.md) | 🟡 中风险 | 新版本发布后刷新 CDN 缓存，或对重要资源进行预热 |
| [cert-manager.md](cert-manager.md) | 🟡 中风险 | 证书到期检测与续签，批量为域名绑定新证书 |

## 参考链接

- [EdgeOne 产品文档](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API 文档](https://cloud.tencent.com/document/api/1552)
- [API 调用指引](../api/README.md)
