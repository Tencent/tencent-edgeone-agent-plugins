# Cache Purge & Prefetch

Manage EdgeOne node cache: query quotas, purge cache (URL / prefix / Host / all / Cache Tag), URL prefetch, and check task progress. Supports bulk URL input from files or pasted text.

## Core Interaction Guidelines

1. **Check quota before submitting**: Before calling `CreatePurgeTask` / `CreatePrefetchTask`, first call `DescribeContentQuota` to show remaining quota — alert the user if quota is insufficient
2. **Bulk URL input**: Supports user bulk URL input from files or pasted text (see Scenario E)
3. **Poll task progress**: After submitting a task, proactively query progress until the task completes or times out

## Scenario A: Query Quota

**Trigger**: User says "how many purges do I have left", "check quota", "how much prefetch quota remains".

Call `DescribeContentQuota`.

**Output suggestion**: Display quota usage for each type in a table, marking types with less than 10% remaining.

## Scenario B: Cache Purge

**Trigger**: User says "purge cache", "clear CDN cache", "purge URL", "purge directory", "clear all site cache".

> **Prerequisites**:
> 1. Call `DescribeAccelerationDomains` to confirm the zone has available acceleration domains
> 2. Call `DescribeContentQuota` (Scenario A) to show remaining quota — alert the user if the corresponding type's quota is insufficient

> **No automatic purging**: Cache purge invalidates node cache, causing subsequent requests to pull from the origin, which may increase origin load. You **must** explain the purge type and impact scope to the user and wait for explicit confirmation before executing.

**Call** `CreatePurgeTask`. Supports 5 purge types: `purge_url` (URL), `purge_prefix` (prefix/directory), `purge_host` (Host), `purge_all` (entire site), `purge_cache_tag` (Cache Tag).

> **Full-site purge** (`purge_all`) is a high-impact operation: it clears all node cache for the zone, and a large number of requests will hit the origin in a short time, potentially causing a spike in origin load. You **must** clearly warn the user about the impact and wait for confirmation.

**Follow-up**: Inform the user that the task has been submitted and provide the JobId. If execution results need to be confirmed, go to [Scenario D](#scenario-d-check-task-progress).

## Scenario C: URL Prefetch

**Trigger**: User says "prefetch URL", "pre-cache", "prefetch", "preload resources".

> **Prerequisites**:
> 1. First call `DescribeContentQuota` (Scenario A) to show `prefetch_url` quota remaining
> 2. (Optional) Call `DescribePrefetchOriginLimit` to check the target domain's origin pull rate limit

URL prefetch proactively pulls resources from the origin to edge node cache — ideal for warming up hot resources before sales events or releases.

**Call** `CreatePrefetchTask`. Prefetch only supports URL granularity, not directory or domain level.

### C2: Query Prefetch Origin Rate Limit (`DescribePrefetchOriginLimit`)

> This API is a whitelisted beta feature — use only when the user mentions "prefetch rate limit".

Call `DescribePrefetchOriginLimit`.

**Output suggestion**: If the domain has a rate limit configuration, remind the user of the current bandwidth cap before prefetching — bulk prefetch may be affected by this limit.

## Scenario D: Check Task Progress

**Trigger**: User says "is the purge done", "check task progress", "prefetch status".

### D1: Query Purge Tasks

Call `DescribePurgeTasks`.

### D2: Query Prefetch Tasks

Call `DescribePrefetchTasks`

**Output suggestion**: Display tasks in a table, marking `failed` and `timeout` tasks. For failed tasks, suggest the user verify URLs are correct or retry later.

> Prefetch tasks have an additional `invalid` status, indicating the origin responded with a non-2xx code — check the origin service.

### D3: Auto-Poll Progress After Submission

After submitting a purge / prefetch task, proactively poll task status until it reaches a terminal state:

1. Obtain the `JobId` after submitting the task
2. Wait 5–10 seconds before querying status
3. If still `processing`, continue waiting and retry (recommended interval: 10 seconds)
4. If a terminal state is reached (`success` / `failed` / `timeout` / `canceled`), summarize results and present to the user

> Typically, URL purge completes in 1–2 minutes, prefix / Host purge in 3–5 minutes, and prefetch time depends on resource size and quantity.

## Scenario E: Bulk URL Input

**Trigger**: User provides a large list of URLs (read from a file or pasted as multiple lines).

### E1: Extract URLs from User-Pasted Text

When the user pastes multiple lines of URLs:
1. Split the text by lines, one URL per line
2. Filter out blank lines and comment lines (starting with `#`)
3. Ensure each URL starts with `http://` or `https://`
4. Summarize the valid URL count and present to the user for confirmation

### E2: Read URL List from File

When the user says "import from file", "read URL list file":
1. Read the user-specified file (supports `.txt`, `.csv`, and other plain text formats)
2. Parse line by line, filter blank lines and comments
3. Display the number of parsed URLs and the first few as examples, ask the user to confirm

### E3: Bulk Submission Notes

- **Check quota**: First query `DescribeContentQuota`, ensure remaining quota ≥ URL count
- **Per-batch limit**: The number of URLs per submission is limited by the per-batch cap — automatically split into batches when the limit is exceeded
- **URL deduplication**: Deduplicate before submission to avoid wasting quota
- **Result summary**: After all batches are submitted, aggregate the JobId list and failed items, and query progress collectively
