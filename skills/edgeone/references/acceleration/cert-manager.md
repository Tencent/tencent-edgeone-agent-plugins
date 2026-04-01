# Certificate Automation Management

Manage HTTPS certificates for EdgeOne domains: query certificate status, apply for free certificates, deploy custom certificates.

## Scenario A: Query Certificate Status

**Trigger**: User wants to view the certificate list or check expiration dates.

Call `DescribeDefaultCertificates`.

> You need to obtain the ZoneId first — see [../api/zone-discovery.md](../api/zone-discovery.md).

**Output suggestion**: Display the certificate list in a table, marking certificates expiring soon (≤ 30 days).

## Scenario B: Apply for and Deploy a Free Certificate

**Trigger**: User says "apply for a free certificate", "certificate is expiring", "renew certificate".

### Access Mode Determination

| Access Mode | Free Certificate Application Method |
|---|---|
| NS access / DNSPod hosting | **Auto verification** — directly call `ModifyHostsCertificate` |
| CNAME access | **Manual verification** — first call `ApplyFreeCertificate`, complete verification, then deploy |

> Call `DescribeZones` to query the access mode, and determine which route to follow based on the response.

### B1: NS Access / DNSPod Hosting (Auto Verification)

Call `ModifyHostsCertificate`.

> **Confirmation prompt**: Deploying a certificate will affect the domain's HTTPS service — confirm with the user before execution.

### B2: CNAME Access (Manual Verification)

Requires 4 steps:

**Step 1**: Call `ApplyFreeCertificate` to initiate the application.

**Step 2**: Based on the verification info in the response, inform the user to complete the configuration.

> After informing the user, **wait for user confirmation that the configuration is complete** before continuing to the next step.

**Step 3**: Call `CheckFreeCertificateVerification` to check the verification result

- Success: The response contains certificate info, indicating the certificate has been issued
- Failure: The verification configuration needs to be checked

**Step 4**: Call `ModifyHostsCertificate` to deploy the free certificate.

> **Confirmation prompt**: Deploying a certificate will affect the domain's HTTPS service — confirm with the user before execution.

## Scenario C: Deploy a Custom Certificate

**Trigger**: User says "configure custom certificate", "uploaded certificate", or provides a CertId.

The user must first upload the certificate to the [SSL Certificate Console](https://console.cloud.tencent.com/ssl) and obtain the CertId.

Call `ModifyHostsCertificate`.

> **No automatic deployment**: You **must** confirm the deployment domain and certificate ID with the user before execution.

## Scenario D: Batch Certificate Inspection

**Trigger**: User says "check certificates for all domains", "which certificates are expiring soon".

### Process

1. Use `DescribeZones` to get all zones
2. Call `DescribeDefaultCertificates` for each zone
3. Summarize output, marking the following anomalies:
   - Certificates with deployment failures
   - Certificates expiring within ≤ 30 days
   - Domains without deployed certificates

### Suggested Output Format

> **Language note**: Adapt the report language to match the user's language. The template below is an example — output should be in the same language the user is using.

```markdown
## Certificate Inspection Report

| Zone | Domain | Certificate ID | Expiry Date | Days Remaining | Status |
|---|---|---|---|---|---|
| example.com | *.example.com | teo-xxx | 2026-04-15 | 29 days | Expiring Soon |
| example.com | api.example.com | teo-yyy | 2026-09-01 | 168 days | Normal |
```
