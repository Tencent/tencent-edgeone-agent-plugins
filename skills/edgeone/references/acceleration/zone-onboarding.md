# 站点一键接入向导

端到端完成域名接入 EdgeOne：建站 → 验证归属权 → 绑定套餐 → 配置源站 →
添加加速域名 → 申请并部署证书。

## 涉及 API

| Action | 说明 |
|---|---|
| CreateZone | 创建站点（NS / CNAME / 无域名接入） |
| DescribeIdentifications | 查询站点归属权验证状态与验证方式详情 |
| VerifyOwnership | 触发站点或域名归属权验证 |
| DescribePlans | 查询账号下的套餐列表（筛选可绑定套餐） |
| BindZoneToPlan | 将未绑定套餐的站点绑定到目标套餐 |
| CreateOriginGroup | 创建源站组（多源站 / 负载均衡场景） |
| CreateAccelerationDomain | 在站点下添加加速域名并配置源站 |
| ModifyHostsCertificate | 为域名部署证书（免费 / 自有） |
| DescribeAccelerationDomains | 查询站点下的加速域名列表 |
| DescribeZones | 查询站点列表与接入状态 |

> 证书的完整 API（DescribeDefaultCertificates / ApplyFreeCertificate /
> CheckFreeCertificateVerification 等）参考 [cert-manager.md](cert-manager.md)。

> **命令用法**：本文档只列出 API 名称和流程指引。
> 执行前请通过 [api-discovery.md](../api/api-discovery.md) 中的方式查阅接口文档，确认完整参数和响应说明。

## 端到端流程总览

```
1. 创建站点（CreateZone）
   ├─ NS 接入：切换 DNS 服务器 → VerifyOwnership 检查切换状态
   └─ CNAME 接入：添加 TXT 记录或文件验证 → VerifyOwnership 验证归属权
       ↓
2.（如创建时未绑定套餐）绑定套餐（BindZoneToPlan）
       ↓
3.（可选）创建源站组（CreateOriginGroup）
       ↓
4. 添加加速域名（CreateAccelerationDomain）
       ↓
5. 配置 CNAME 解析
       ↓
6. 申请并部署 HTTPS 证书（详见 cert-manager.md）
       ↓
   完成接入 ✅
```

> 可随时通过 DescribeIdentifications 查询验证状态。
> 证书相关查询与操作参考 [cert-manager.md](cert-manager.md)。

## 场景 A：创建站点

**触发**：用户说"把 example.com 接入 EdgeOne"、"创建站点"、"新建站点"。

> ⚠️ **确认提示**：创建站点会消耗套餐的站点配额，
> 执行前需向用户确认接入模式和服务区域。

**调用** `CreateZone`。用户需提供：站点域名、接入模式（`full` NS 接入 /
`partial` CNAME 接入 / `noDomainAccess` 无域名接入）、服务区域（`global` /
`mainland` / `overseas`）。建议创建时直接传入 PlanId。

> 不传 PlanId 时站点处于 `init` 状态，需后续通过 BindZoneToPlan 绑定。

### NS 接入的下一步

告知用户需要到域名注册商处将 DNS 服务器修改为响应中返回的 NameServers，
然后转至 [场景 B](#场景-b验证归属权) 验证。

### CNAME 接入的下一步

告知用户两种验证方式（任选其一），从响应中获取验证信息：

1. **DNS 验证**：在 DNS 添加 TXT 记录
2. **文件验证**：在源站根目录放置验证文件

等待用户确认配置完成后，转至 [场景 B](#场景-b验证归属权) 验证。

## 场景 B：验证归属权

**触发**：用户说"验证站点"、"检查 DNS 切换"、"归属权验证"，
或创建站点后的后续步骤。

### B1：查询验证状态（DescribeIdentifications）

在触发验证前，先调用 `DescribeIdentifications` 查询当前验证状态，
通过 Filters 按 `zone-name` 过滤。

**决策**：
- 若 `Status` 为 `finished`，无需再验证，直接进入下一步
- 若 `Status` 为 `pending`，根据响应中的验证信息
  告知用户配置 DNS TXT 记录或文件验证

### B2：触发验证（VerifyOwnership）

等用户确认已完成 DNS / 文件配置后，调用 `VerifyOwnership`，
传入站点域名。

**NS 接入场景**：验证 DNS 服务器是否已切换成功。
DNS 切换通常需要 24-48 小时全球生效，如果验证失败，建议用户稍后重试。

**CNAME 接入场景**：验证 TXT 记录或文件是否正确配置。
若站点通过归属权验证，后续添加域名无需再验证。

## 场景 C：绑定套餐

**触发**：创建站点时未传 PlanId，站点处于 `init` 状态，
需要绑定套餐激活。

> ⚠️ **确认提示**：绑定套餐后站点将正式激活并开始计费，
> 执行前需向用户确认。

### C1：查询可绑定套餐（DescribePlans）

用户需提供 PlanId。如果用户不知道自己的套餐 ID，
先调用 `DescribePlans` 查询账号下的套餐列表。

#### 筛选逻辑

从返回的套餐列表中，按以下条件过滤出可用套餐：

1. **可绑定**：`Bindable == "true"`
2. **状态正常**：`Status == "normal"`
3. **配额充足**：已绑定站点数 < 站点配额上限

> 只有同时满足以上 3 个条件的套餐才能用于绑定。

#### 套餐选择策略

- 若筛选后 **仅 1 个套餐**：直接向用户确认后使用
- 若筛选后 **多个套餐**：向用户展示可用套餐列表并请用户选择，
  展示时包含套餐类型、服务区域、站点配额使用情况，方便用户判断
- 若筛选后 **无可用套餐**：告知用户当前账号没有可绑定的套餐，
  建议前往 [EdgeOne 控制台](https://console.cloud.tencent.com/edgeone)
  购买或升级套餐

### C2：绑定套餐（BindZoneToPlan）

调用 `BindZoneToPlan`，传入 `ZoneId` 和 `PlanId`。

## 场景 D：创建源站组（可选）

**触发**：用户有多个源站 IP 需要负载均衡、或需要统一管理源站。

> ⚠️ **确认提示**：创建源站组会在站点下新增源站配置，
> 执行前需向用户确认。

**调用** `CreateOriginGroup`，需提供站点 ID、源站组名称、
源站组类型（`HTTP` 或 `GENERAL`）和源站记录列表。

## 场景 E：添加加速域名

**触发**：用户说"添加域名"、"配置加速域名"、"接入子域名"。

> ⚠️ **确认提示**：添加域名后需要配置 CNAME 解析才能生效，
> 执行前告知用户。

**调用** `CreateAccelerationDomain`，需提供站点 ID、加速域名和源站信息。

**下一步**：告知用户需要在 DNS 添加 CNAME 记录，将域名指向
EdgeOne 分配的 CNAME 地址（可通过 `DescribeAccelerationDomains`
查询 `Cname` 字段获取）。

## 场景 F：申请并部署 HTTPS 证书

**触发**：域名添加完成后，用户说"配置 HTTPS"、"申请证书"，
或作为接入流程的最后一步。

> 证书的完整管理（CNAME 手动验证、部署自有证书、批量巡检等）
> 参考 [cert-manager.md](cert-manager.md)。

### F1：NS 接入 / DNSPod 托管（自动验证，一步完成）

调用 `ModifyHostsCertificate`，Mode 设为 `eofreecert`。

> ⚠️ **确认提示**：部署证书会影响域名的 HTTPS 服务，
> 执行前需向用户确认。

### F2：CNAME 接入（手动验证）

CNAME 接入需要先申请证书、完成域名验证、再部署，流程较长。
请参考 [cert-manager.md 场景 B2](cert-manager.md#b2cname-接入手动验证)
的完整步骤。

## 场景 G：查看接入状态

**触发**：用户说"查看站点状态"、"域名接入好了没"。

调用 `DescribeZones`，通过 Filters 按 `zone-name` 过滤目标站点。

> 参考 [../api/zone-discovery.md](../api/zone-discovery.md) 获取更多查询方式。

关注 `Status` 字段：`active` 已激活、`pending` 等待验证、
`init` 未绑定套餐、`deleted` 已删除。
