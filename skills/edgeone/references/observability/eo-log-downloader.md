# eo-log-downloader

Users describe a time range and domain in natural language to automatically retrieve the corresponding offline log download links, eliminating the tedious steps of manually selecting time ranges and domains in the console.

## APIs Involved

| Action | Description |
|---|---|
| DownloadL7Logs | Retrieve L7 offline log download links |
| DownloadL4Logs | Retrieve L4 offline log download links |

> **Command usage**: This document only lists API names and workflow guidance.
> Before execution, consult the API documentation via [api-discovery.md](../api/api-discovery.md) to confirm complete parameters and response descriptions.

## Prerequisites

1. All Tencent Cloud API calls are executed via `tccli`. If no valid credentials are configured in the environment, guide the user to log in first:

```sh
tccli auth login
```

> The terminal will print an authorization link after execution and remain blocked until the user completes browser authorization, after which the command ends automatically.
> Never ask the user for `SecretId` / `SecretKey`, and do not execute any commands that could expose credential contents.

2. ZoneId must be obtained first. Refer to [../api/zone-discovery.md](../api/zone-discovery.md).

## Scenario A: Download L7 Logs by Time and Domain

**Trigger**: User says "get me the logs for example.com from yesterday afternoon", "download the last 6 hours of logs for example.com", "help me download the logs".

### Workflow

**Step 1**: Parse time range

- Convert the user's natural language time description to ISO 8601 format start and end times
- Example: "yesterday from 2 PM to 4 PM" → `2026-03-24T14:00:00+08:00` to `2026-03-24T16:00:00+08:00`
- If the user only says "last N hours", calculate backward from the current time
- If the user does not specify a time range, ask for confirmation

**Step 2**: Confirm domain

- If the user specified a domain, use it directly
- If the user did not specify a domain, ask for confirmation (the `Domains` parameter can be omitted to download logs for all domains, but inform the user first)

**Step 3**: Retrieve log download links

Call `DownloadL7Logs` with:
- `StartTime` / `EndTime`: Start and end times parsed in Step 1
- `ZoneIds`: Zone ID
- `Domains`: Target domain list (optional)
- If there are many results, use `Limit` and `Offset` for pagination (default Limit=20, max 300)

**Step 4**: Organize output

Organize the returned log file list into a clickable download link table with directly accessible download links.

**Output recommendation**: Present the response as "query parameter summary + download link table" with directly clickable download links.

## Scenario B: Download L4 Logs

**Trigger**: User says "download L4 logs", "get me the L4 logs", "download the layer 4 proxy logs".

### Workflow

**Step 1**: Parse time range

Same as Scenario A Step 1.

**Step 2**: Confirm L4 proxy instance

- If the user specified a ProxyId, use it directly
- If the user did not specify, ask whether to download logs for all L4 instances

**Step 3**: Retrieve log download links

Call `DownloadL4Logs` with:
- `StartTime` / `EndTime`: Start and end times
- `ZoneIds`: Zone ID
- `ProxyIds`: L4 instance ID list (optional)
- Handle pagination (default Limit=20, max 300)

**Step 4**: Organize output

Same as Scenario A Step 4.

**Output recommendation**: Same format as Scenario A, with log type labeled as "L4 logs".

## Output Format

```markdown
## Log Download Links

**Zone**: <zone name> (ZoneId: <zone-id>)
**Domain**: <domain> / All domains
**Time Range**: <start time> – <end time>
**Log Type**: L7 Access Logs / L4 Proxy Logs

| Log File | Size | Log Start Time | Log End Time | Download Link |
|---|---|---|---|---|
| ... | ... MB | ... | ... | [Download](url) |

Total: N log files.
```

## Notes

> - Offline logs have a certain delay; logs for very recent time periods may not yet be generated. If results are empty, suggest the user retry later.
> - Download links have a limited validity period; please download promptly.
> - For further log content analysis (anomaly detection, pattern recognition, etc.), use [eo-log-analyzer.md](eo-log-analyzer.md).
