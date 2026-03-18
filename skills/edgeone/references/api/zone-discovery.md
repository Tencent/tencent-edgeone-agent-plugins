# 站点与域名发现

EdgeOne 几乎所有 API 操作都需要 **ZoneId**（站点 ID，形如 `zone-2noz78a8ev6k`）。
以下是发现 ZoneId 及反查域名的标准流程。

## 1. 列出所有站点

```sh
tccli teo DescribeZones --region ${REGION}
```

响应中的 `Zones` 数组包含每个站点的 `ZoneId`、`ZoneName`（站点域名）、`Status`（active / pending / deleted）等信息。

## 2. 按站点名精确查询

当用户已知站点域名时，用 Filters 精确查询：

```sh
tccli teo DescribeZones --region ${REGION} \
  --Filters '[{"Name":"zone-name","Values":["example.com"]}]'
```

## 3. 从子域名反查 ZoneId

当用户只提供了子域名（如 `www.example.com`）而不知道 ZoneId 时：

**步骤 A**：先列出所有站点，找到与子域名匹配的根域名（`example.com`）对应的 ZoneId。

**步骤 B**：用 DescribeAccelerationDomains 确认该域名存在于站点下：

```sh
tccli teo DescribeAccelerationDomains --region ${REGION} \
  --ZoneId zone-xxx \
  --Filters '[{"Name":"domain-name","Values":["www.example.com"]}]'
```

## 4. 列出站点下所有域名

```sh
tccli teo DescribeAccelerationDomains --region ${REGION} \
  --ZoneId zone-xxx
```

> **提示**：分页参数 `--Limit 100`（最大 200）+ `--Offset` 处理多页结果。

## 5. ZoneId 缓存建议

同一个会话中，已发现的 ZoneId 应记住复用，避免重复调用 DescribeZones。
