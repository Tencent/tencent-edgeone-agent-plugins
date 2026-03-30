# 证书自动化管理

管理 EdgeOne 域名的 HTTPS 证书：查询证书状态、申请免费证书、部署自有证书。

## 场景 A：查询证书状态

**触发**：用户想查看证书列表、检查过期时间。

### A1：定位目标站点

调用 `DescribeZones`，用 `zone-name` 过滤条件匹配用户指定的站点名称。

根据返回结果分两种情况处理：

**情况一：仅匹配到 1 个站点**

直接使用该站点的 `ZoneId`，进入 A2。

**情况二：匹配到多个同名站点**

向用户展示所有匹配结果，列出关键信息供区分，**等待用户明确选择后**再继续：

```
找到多个名为 "xxx.com" 的站点，请确认要查询哪一个：

  1. ZoneId: zone-aaa  别名: prod   接入模式: NS接入   创建时间: 2024-01-01
  2. ZoneId: zone-bbb  别名: test   接入模式: CNAME接入  创建时间: 2025-06-01

请回复序号或 ZoneId。
```

> 收到用户回复后，使用用户选定的 `ZoneId` 进入 A2。

### A2：查询域名证书信息

调用 `DescribeAccelerationDomains`，从响应的 `AccelerationDomains[].Certificate` 字段读取每条域名的证书信息。

> 可通过 `Filters.domain-name` 指定查询某个域名，不传 Filters 则返回站点下所有域名。

每条域名的 `Certificate` 结构关键字段：

| 字段 | 含义 |
|---|---|
| `Certificate.Mode` | 证书配置模式：`disable` / `eofreecert` / `eofreecert_manual` / `sslcert` |
| `Certificate.List[].CertId` | 证书 ID |
| `Certificate.List[].Alias` | 证书备注名 |
| `Certificate.List[].Type` | 证书类型：`default` / `upload` / `managed` |
| `Certificate.List[].ExpireTime` | 到期时间 |
| `Certificate.List[].Status` | 部署状态：`deployed` / `processing` / `applying` / `failed` / `issued` |
| `Certificate.List[].SignAlgo` | 签名算法 |

**输出建议**：以表格形式展示各域名的证书信息，标注即将过期（≤30 天）或状态异常（`failed` / `applying`）的条目。

## 场景 B：申请并部署免费证书

**触发**：用户说"申请免费证书"、"证书快过期了"、"续签证书"。

### B0：定位目标站点

若用户未直接提供 ZoneId，调用 `DescribeZones` 用 `zone-name` 过滤条件匹配用户指定的站点名称。

- **仅匹配到 1 个站点**：直接使用该站点的 `ZoneId`，进入 B1。
- **匹配到多个同名站点**：向用户展示所有匹配结果，**等待用户明确选择后**再继续（展示格式同场景 A）。

### 接入模式判断

调用 `DescribeZones` 结果同时用于判断接入模式（`Type` 字段），根据结果走不同路线：

| 接入模式 | 免费证书申请方式 |
|---|---|
| NS 接入 / DNSPod 托管 | **自动验证**——直接调用 ModifyHostsCertificate |
| CNAME 接入 | **手动验证**——需先 ApplyFreeCertificate，完成验证后再部署 |

### B1：NS 接入 / DNSPod 托管（自动验证）

调用 `ModifyHostsCertificate`。

> **确认提示**：部署证书会影响域名的 HTTPS 服务，执行前需向用户确认。

### B2：CNAME 接入（手动验证）

需要 4 步：

**步骤 1**：调用 `ApplyFreeCertificate` 发起申请。

**步骤 2**：根据响应中的验证信息，告知用户完成配置。

> 告知用户后**等待用户确认已完成配置**，再继续下一步。

**步骤 3**：调用 `CheckFreeCertificateVerification` 检查验证结果

- 成功：响应中包含证书信息，说明证书已签发
- 失败：需检查验证配置是否正确

**步骤 4**：调用 `ModifyHostsCertificate` 部署免费证书。

> **确认提示**：部署证书会影响域名的 HTTPS 服务，执行前需向用户确认。

## 场景 C：部署自有证书

**触发**：用户说"配置自有证书"、"上传的证书"、提供了 CertId。

### C0：定位目标站点

若用户未直接提供 ZoneId，调用 `DescribeZones` 用 `zone-name` 过滤条件匹配用户指定的站点名称。

- **仅匹配到 1 个站点**：直接使用该站点的 `ZoneId`，进入下一步。
- **匹配到多个同名站点**：向用户展示所有匹配结果，**等待用户明确选择后**再继续（展示格式同场景 A）。

### C1：查询适用于目标域名的 SSL 证书

若用户未提供 CertId，或希望从已有证书中选择，调用 `ssl:DescribeCertificates` 查询证书列表，再筛选出适用于目标域名的证书。

**调用参数建议**：
- `SearchKey`：传入目标域名（如 `a-1.qcdntest.com`），可模糊匹配域名字段，缩小返回范围
- `CertificateType`：传 `SVR`，只查服务器证书（排除客户端 CA 证书）
- `Limit`：建议传 `1000` 确保不遗漏

**筛选规则**：对返回的每张证书，检查 `SubjectAltName` 列表中是否有条目匹配目标域名：

| 匹配类型 | 说明 | 示例 |
|---|---|---|
| 精确匹配 | `SubjectAltName` 中有与目标域名完全相同的条目 | `a-1.qcdntest.com` |
| 通配符匹配 | `SubjectAltName` 中有 `*.xxx` 条目，且目标域名是其直接子域名（只有一级） | `*.qcdntest.com` 匹配 `a-1.qcdntest.com` |

**可用性判断**：筛选出匹配证书后，结合以下字段标注每张证书的可用状态：

| 字段 | 含义 | 可用条件 |
|---|---|---|
| `Status` | 证书状态 | 必须为 `1`（已通过） |
| `CertEndTime` | 到期时间 | 距今 > 0 天（未过期） |
| `Deployable` | 是否可部署 | 必须为 `true` |

**输出建议**：以表格展示所有匹配证书，标注可用性：

```
适用于 a-1.qcdntest.com 的证书：

证书ID       备注名         到期时间              剩余天数   状态      可部署   可用性
------------ -------------- -------------------- --------- -------- -------- ------
zVq87w0D     my-cert        2032-09-23 05:10:56  2371 天   已通过    ✅       ✅ 可用
QxbtGBIM     old-cert       2025-01-01 00:00:00  -86 天    已过期    ❌       ❌ 已过期
```

若未找到任何匹配证书，告知用户需先前往 [SSL 证书控制台](https://console.cloud.tencent.com/ssl) 上传或申请覆盖该域名的证书。

### C2：部署证书

用户从 C1 结果中选定证书后，调用 `ModifyHostsCertificate`（`Mode=sslcert`，`ServerCertInfo[{CertId}]`）。

> **禁止自动部署**：**必须**向用户确认部署域名和证书 ID 后才能执行。

## 场景 D：批量证书巡检

**触发**：用户说"检查所有域名的证书"、"哪些证书快过期了"。

### 流程

1. 调用 `DescribeZones` 获取所有站点
2. 对每个站点调用 `DescribeAccelerationDomains`，读取响应中每条 `AccelerationDomains[].Certificate` 字段获取证书信息
3. 汇总输出，标注以下异常：
   - `Certificate.List[].Status` 为 `failed` 或 `applying` 的证书
   - `Certificate.List[].ExpireTime` 距今 ≤30 天的证书
   - `Certificate.Mode` 为 `disable` 或 `Certificate` 为 null 的域名（未配置证书）

### 输出格式建议

```markdown
## 证书巡检报告

| 站点 | 域名 | 证书 ID | 到期时间 | 剩余天数 | 状态 |
|---|---|---|---|---|---|
| example.com | *.example.com | teo-xxx | 2026-04-15 | 29 天 | 即将过期 |
| example.com | api.example.com | teo-yyy | 2026-09-01 | 168 天 | 正常 |
```
