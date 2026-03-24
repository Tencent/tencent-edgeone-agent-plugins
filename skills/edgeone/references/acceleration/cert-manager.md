# 证书自动化管理

管理 EdgeOne 域名的 HTTPS 证书：查询证书状态、申请免费证书、部署自有证书。

## 场景 A：查询证书状态

**触发**：用户想查看证书列表、检查过期时间。

调用 `DescribeDefaultCertificates`。

> 需要先获取 ZoneId，参考 [../api/zone-discovery.md](../api/zone-discovery.md)。

**输出建议**：以表格形式展示证书列表，标注即将过期（≤30 天）的证书。

## 场景 B：申请并部署免费证书

**触发**：用户说"申请免费证书"、"证书快过期了"、"续签证书"。

### 接入模式判断

| 接入模式 | 免费证书申请方式 |
|---|---|
| NS 接入 / DNSPod 托管 | **自动验证**——直接调用 ModifyHostsCertificate |
| CNAME 接入 | **手动验证**——需先 ApplyFreeCertificate，完成验证后再部署 |

> 调用 DescribeZones 查询接入模式，根据响应判断走哪条路线。

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

用户需先将证书上传至 [SSL 证书控制台](https://console.cloud.tencent.com/ssl)，获取 CertId。

调用 `ModifyHostsCertificate`。

> **禁止自动部署**：**必须**向用户确认部署域名和证书 ID 后才能执行。

## 场景 D：批量证书巡检

**触发**：用户说"检查所有域名的证书"、"哪些证书快过期了"。

### 流程

1. 用 DescribeZones 获取所有站点
2. 对每个站点调用 DescribeDefaultCertificates
3. 汇总输出，标注以下异常：
   - 部署失败的证书
   - 距到期 ≤30 天的证书
   - 未部署证书的域名

### 输出格式建议

```markdown
## 证书巡检报告

| 站点 | 域名 | 证书 ID | 到期时间 | 剩余天数 | 状态 |
|---|---|---|---|---|---|
| example.com | *.example.com | teo-xxx | 2026-04-15 | 29 天 | 即将过期 |
| example.com | api.example.com | teo-yyy | 2026-09-01 | 168 天 | 正常 |
```
