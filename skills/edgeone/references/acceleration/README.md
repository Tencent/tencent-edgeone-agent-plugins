# EdgeOne 站点加速参考

站点接入、域名管理、缓存刷新 / 预热、HTTPS 证书的配置与运维指引。

## 本目录文件

| 文件 | 风险等级 | 触发场景（用户说…） |
|---|---|---|
| [zone-onboarding.md](zone-onboarding.md) | 中高风险 | 「帮我把 example.com 接入 EO」「新建一个站点」「接入后申请免费证书」 |
| [cache-purge.md](cache-purge.md) | 中风险 | 「刷新 /static/ 下所有缓存」「预热这批 URL」「查一下刷新任务进度」 |
| [cert-manager.md](cert-manager.md) | 中风险 | 「证书快到期了帮我续签」「给这批域名绑定新证书」「检查证书状态」 |

