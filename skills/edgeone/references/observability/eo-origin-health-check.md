# eo-origin-health-check

Query the origin status code distribution and origin health ratio for a specified domain over the last hour to quickly determine whether the issue lies with the CDN or the origin server.

## APIs Involved

| Action | Description |
|---|---|
| DescribeTimingL7AnalysisData | Query L7 time-series data (response status code analysis at edge nodes) |
| DescribeTimingL7OriginPullData | Query L7 origin-pull time-series data (origin status code distribution, origin traffic/bandwidth) |
| DescribeOriginGroupHealthStatus | Query origin group health status under a load balancing instance (requires load balancing feature) |

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

## Scenario A: Query Origin Status Code Distribution

**Trigger**: User says "check the origin status for example.com", "are there any origin issues", "is the origin healthy".

### Workflow

**Step 1**: Confirm query parameters

- Confirm the target domain (must be specified by the user or obtained from context)
- Default query range is the last 1 hour; the user may also specify a different time range
- Recommend avoiding the most recent 10 minutes (API data has a delay)

**Step 2**: Query origin status code distribution

Call `DescribeTimingL7OriginPullData` with:
- `DimensionName=origin-status-code-category`: Group by origin status code category (2xx/3xx/4xx/5xx)
- `MetricNames=["l7Flow_request_hy"]`: Origin-pull request count
- Use the `domain` key in `Filters` to filter for the target domain
- Use `min` granularity for easier identification of anomaly periods

**Step 3**: Calculate health metrics

- Health ratio = 2xx requests / total origin requests × 100%
- Anomaly ratio = (4xx + 5xx) requests / total origin requests × 100%
- If 5xx ratio > 5%, mark as ⚠️ Anomaly

**Step 4**: Query origin group health status (optional)

If the user's zone has load balancing configured, call `DescribeOriginGroupHealthStatus` to query origin group health status and get the specific health condition of each origin server.

> Note: `DescribeOriginGroupHealthStatus` requires the `LBInstanceId` parameter (load balancing instance ID) and is only available when load balancing is in use. Skip this step if the user does not use load balancing.

**Output recommendation**: Present the response as "health score + status code distribution table + origin group status (if available)", with anomaly indicators highlighted.

## Scenario B: Quick Fault Root Cause Analysis

**Trigger**: User says "is it a CDN issue or an origin issue", "help me troubleshoot the origin failure", "where are the 5xx errors coming from".

### Workflow

**Step 1**: Collect edge node status code data

Call `DescribeTimingL7AnalysisData` to query the response status codes from edge nodes to clients:
- `MetricNames=["l7Flow_request"]`
- Filter for 5xx errors via `statusCode` in `Filters`
- Filter for the target domain via `domain` in `Filters`

**Step 2**: Collect origin status code data

Call `DescribeTimingL7OriginPullData` to query origin status codes:
- `DimensionName=origin-status-code-category`
- `MetricNames=["l7Flow_request_hy"]`
- Filter for the target domain via `domain` in `Filters`

**Step 3**: Comparative analysis for root cause

Compare edge 5xx with origin 5xx:

| Edge 5xx | Origin 5xx | Preliminary Conclusion |
|---|---|---|
| High | High (with similar ratio) | Issue is most likely on the origin server side |
| High | Low or none | Issue is likely on the CDN node side |
| Low | High | Origin failures exist but CDN cache is serving as fallback |

**Step 4**: Provide root cause conclusion and recommendations

- Clearly label as "origin issue", "CDN issue", or "further investigation needed"
- Provide next-step recommendations (e.g., use [eo-log-analyzer.md](eo-log-analyzer.md) for deeper log analysis)

**Output recommendation**: Present the response as "edge vs origin comparison table + root cause conclusion + recommendations".

## Output Format

### Scenario A: Origin Health Inspection Report

```markdown
## Origin Health Inspection — <domain> (Last <N> Hours)

**Zone**: <zone name> (ZoneId: <zone-id>)
**Query Time Range**: <start time> – <end time>
**Health Score**: <score> (✅ Healthy / ⚠️ Anomaly Detected / 🔴 Critical Anomaly)

### Origin Status Code Distribution

| Status Code Category | Request Count | Ratio |
|---|---|---|
| 2xx | ... | ...% |
| 3xx | ... | ...% |
| 4xx | ... | ...% |
| 5xx | ... | ...% ⚠️ |

### Origin Group Health Status (if load balancing is enabled)

| Origin Group | Status | Unhealthy Origins |
|---|---|---|
| ... | ... | ... |

### Quick Root Cause

- <one-sentence root cause conclusion>
- Recommendation: <next step>
```

### Scenario B: Fault Root Cause Analysis

```markdown
## 5xx Fault Root Cause Analysis — <domain>

**Query Time Range**: <start time> – <end time>

### Edge vs Origin Comparison

| Metric | Edge Node | Origin |
|---|---|---|
| 5xx Ratio | ...% | ...% |
| Primary Error Codes | ... | ... |

### Root Cause Conclusion

<conclusion description>

### Recommendations

1. <recommendation 1>
2. <recommendation 2>
```
