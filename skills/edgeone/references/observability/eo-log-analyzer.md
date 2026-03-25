# eo-log-analyzer

Users describe a fault time period and domain to automatically download logs, parse them locally, extract anomaly details, and provide pattern recognition conclusions with fault inference recommendations. This is an upgrade from [eo-log-downloader.md](eo-log-downloader.md), which only provides download links — this scenario further completes log parsing and analysis.

## APIs Involved

| Action | Description |
|---|---|
| DownloadL7Logs | Retrieve L7 offline log download links |
| DownloadL4Logs | Retrieve L4 offline log download links (when analyzing L4 logs) |

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

## Special Design Notes

- **Read-only operations**: All API calls are read-only queries; log downloading and parsing are performed locally
- **Local file writes only**: Log parsing is completed on the client side locally; raw logs are not uploaded or modified
- **Aggregated summaries for high-traffic domains**: For domains with extremely high request volumes, use aggregated summary analysis (grouped statistics by URI/status code/IP) rather than line-by-line output of full logs, to avoid information overload
- **Cross-scenario integration**: Analysis conclusions can guide the user to use [eo-origin-health-check.md](eo-origin-health-check.md) for origin troubleshooting, or [../security/ip-threat-blacklist.md](../security/ip-threat-blacklist.md) to block anomalous IPs

## Scenario A: Fault Period Log Analysis

**Trigger**: User says "analyze the logs for example.com from 3 PM to 4 PM today", "too many 502 errors, help me figure out what's going on", "analyze the logs and find the anomalies".

### Workflow

**Step 1**: Confirm analysis parameters

- Confirm the target domain (must be specified by the user or obtained from context)
- Parse the time range (natural language to ISO 8601)
- Confirm the anomaly type of interest (default: 4xx + 5xx; the user may also specify a particular status code such as 502)

**Step 2**: Download log files

Call `DownloadL7Logs` to get the log download links for the corresponding time period, then download:
- Use `curl` or `wget` to download log files to a local temporary directory
- Log files are typically in `.gz` compressed format; use `gunzip` to decompress
- Log fields are tab-separated

> If there are many or large log files, prioritize downloading files that cover the user's time period of interest to avoid unnecessary bulk downloads.

**Step 3**: Parse logs and extract anomalies

Perform structured parsing on the decompressed logs:
- Filter anomalous requests by status code (4xx, 5xx)
- Aggregate anomalous request count and ratio by URI
- Aggregate by client IP to identify request concentration
- Aggregate by time window (e.g., 5-minute granularity) to identify anomaly peak periods

**Step 4**: Pattern recognition

Perform pattern analysis on the aggregated data:

| Pattern | Characteristics | Possible Cause |
|---|---|---|
| Single URI concentrated 502 | One URI has a much higher 502 ratio than others | The backend service for that URI is malfunctioning |
| IP-concentrated anomalous requests | A few IPs generate a large number of anomalous requests | Possible crawler, attack, or malfunctioning client |
| Global 5xx spike | All URIs show concentrated 5xx in the same time period | Overall origin server overload or failure |
| Intermittent 504 | 504 errors appear repeatedly in specific time windows | Origin response timeout, possible performance bottleneck |

**Step 5**: Output analysis report

Summarize the anomaly details table, pattern recognition conclusions, and fault inference recommendations.

**Output recommendation**: Present the response as "overview summary + anomalous URI Top N table + pattern recognition conclusions + recommendations".

## Scenario B: Identify Origin Failure Concentration Periods

**Trigger**: User says "show me when origin failures were concentrated recently", "which time period had the most 5xx errors", "help me find the fault peak periods".

### Workflow

**Step 1**: Confirm query parameters

- Confirm the target domain
- Default query range is the last 6 hours; the user may also specify a different time range

**Step 2**: Download and parse logs

Same as Scenario A Steps 2 and 3, but focus on time-window aggregation:
- Use 5-minute or 10-minute granularity to count 5xx requests per time window
- Calculate the 5xx ratio for each window

**Step 3**: Identify peak periods

- Mark the Top 3 time periods with the highest 5xx count
- Calculate the deviation multiplier of peak periods from the average

**Step 4**: Output time distribution

Organize the time distribution into a table, highlight peak periods, and provide further analysis recommendations.

**Output recommendation**: Present the response as "time distribution table + peak period annotations + next-step recommendations".

## Output Format

### Scenario A: Log Analysis Report

```markdown
## Log Analysis Report — <domain>

**Zone**: <zone name> (ZoneId: <zone-id>)
**Analysis Time Period**: <start time> – <end time>
**Total Requests**: <N> | **Anomalous Requests**: <M> (<ratio>%)

### Anomalous URI Top 10

| URI | Anomaly Count | Ratio of Total Anomalies | Primary Error Code | Source IP Concentration |
|---|---|---|---|---|
| ... | ... | ...% | 502 | Dispersed / Concentrated (N IPs) |

### Pattern Recognition

- <pattern 1 description>
- <pattern 2 description>

### Recommendations

1. <recommendation 1> (consider using eo-origin-health-check for origin troubleshooting)
2. <recommendation 2> (consider using ip-threat-blacklist to block anomalous IPs)
```

### Scenario B: Origin Failure Time Distribution

```markdown
## Origin Failure Time Distribution — <domain> (Last <N> Hours)

**Analysis Time Range**: <start time> – <end time>

| Time Period | 5xx Count | Ratio | Remarks |
|---|---|---|---|
| HH:MM–HH:MM | ... | ...% | Peak ⚠️ |
| ... | ... | ...% | |

### Conclusion

- Failures are concentrated in <time period>. Recommend focusing analysis on logs from that period (use Scenario A for deeper analysis).
```

## Notes

> - Log parsing is performed locally on the client; ensure sufficient disk space for temporary log files.
> - Log files for high-traffic domains can be very large; prefer aggregated statistics over line-by-line analysis.
> - If origin errors (e.g., 502 concentrated on certain IPs) are found, use [eo-origin-health-check.md](eo-origin-health-check.md) for origin health inspection.
> - If anomalous requests are concentrated on a few client IPs, use [../security/ip-threat-blacklist.md](../security/ip-threat-blacklist.md) for IP blocking.
