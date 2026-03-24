# 站点与域名发现

EdgeOne 几乎所有 API 操作都需要 **ZoneId**（站点 ID，形如 `zone-xxx123abc456`）。
以下是发现 ZoneId 及反查域名的标准流程。

## 涉及 API

| Action | 说明 | 接口文档 |
|---|---|---|
| DescribeZones | 查询站点列表 | `curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/action/DescribeZones.md` |
| DescribeAccelerationDomains | 查询加速域名列表 | `curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/action/DescribeAccelerationDomains.md` |

调用前先查阅上方接口文档，获取 Filters、分页等参数的准确用法。

## 1. 列出所有站点

调用 **DescribeZones**，响应中 `Zones` 数组包含每个站点的 `ZoneId`、`ZoneName`（站点域名）、`Status` 等信息。

## 2. 按站点名精确查询

当用户已知站点域名时，调用 **DescribeZones** 并通过 `Filters`（`zone-name`）精确匹配。

## 3. 从子域名反查 ZoneId

当用户只提供了子域名（如 `www.example.com`）而不知道 ZoneId 时：

1. 先调用 **DescribeZones** 列出所有站点，找到与子域名匹配的根域名对应的 ZoneId
2. 再调用 **DescribeAccelerationDomains** 并通过 `Filters`（`domain-name`）确认该域名存在于站点下

## 4. 列出站点下所有域名

调用 **DescribeAccelerationDomains** 并传入 `ZoneId`。注意使用分页参数处理多页结果。

## 5. ZoneId 缓存建议

同一个会话中，已发现的 ZoneId 应记住复用，避免重复调用 DescribeZones。
