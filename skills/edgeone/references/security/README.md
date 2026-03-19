# EdgeOne 安全防护参考

安全策略配置快照、模板覆盖盘查、域名 IP 组黑名单识别的配置与运维指引。

## 快速决策树

```
用户想做什么？
│
├─ 「帮我出一份本周的安全防护状态报告」
│  「查一下现在的安全配置」
│  └─ → eo-security-weekly-report.md  🟢 低风险 · 顺序采集后优先输出结论，附精简快照
│
├─ 「哪些域名没有绑安全模板」
│  「帮我检查模板覆盖情况」
│  └─ → eo-security-template-audit.md  🟢 低风险 · 列出未绑定域名，提示人工确认
│
├─ 「查一下 example.com 的安全策略里哪个 IP 组是黑名单」
│  「这个域名的拦截 IP 组是哪个」
│  └─ → eo-domain-blacklist-inspector.md  🟢 低风险 · 只读查询，识别黑名单 IP 组
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
| [eo-security-weekly-report.md](eo-security-weekly-report.md) | 🟢 低风险 | 定期生成安全防护配置快照，感知策略是否出现异常变更 |
| [eo-security-template-audit.md](eo-security-template-audit.md) | 🟢 低风险 | 盘查安全策略模板覆盖范围，找出未绑定模板的域名 |
| [eo-domain-blacklist-inspector.md](eo-domain-blacklist-inspector.md) | 🟢 低风险 | 查询指定域名关联的安全策略，识别承担黑名单拦截逻辑的 IP 组 |

## 参考链接

- [EdgeOne 产品文档](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API 文档](https://cloud.tencent.com/document/api/1552)
- [API 调用指引](../api/README.md)
