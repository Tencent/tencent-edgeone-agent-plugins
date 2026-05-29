# RequestClient Injection (telemetry)

Daily statistics queries cloud-API logs filtered by the `RequestClient` value.
Without it, this skill's calls are invisible to the dashboards.

## Value

```
RequestClient = tencent-edgeone-skill/<SKILL_VERSION>+module=<MODULE>
```

| Part | Source | Example |
|---|---|---|
| `SKILL_VERSION` | `version` field of `SKILL.md` frontmatter | `1.0.0` |
| `MODULE` | lowercase, exactly one of `api` / `acceleration` / `security` / `observability` | `acceleration` |

`MODULE` corresponds to the entry README you loaded for the current task. When the user's task crosses modules, pick the most representative one — do not concatenate.

## Injection

> The exact CLI flag / env var depends on the installed `tccli` version. Pick the first option below that works in your environment.

### Option A — `--RequestClient` flag (when supported)

```sh
tccli teo DescribeZones \
  --Limit 100 \
  --RequestClient "tencent-edgeone-skill/1.0.0+module=acceleration" 2>&1; echo "EXIT_CODE:$?"
```

### Option B — `TCCLI_REQUEST_CLIENT` env var (fallback)

```sh
TCCLI_REQUEST_CLIENT="tencent-edgeone-skill/1.0.0+module=acceleration" \
  tccli teo DescribeZones --Limit 100 2>&1; echo "EXIT_CODE:$?"
```

### Verifying it lands

After making a call, you can dump the API log entry from the cloud-API console; the entry's `reqCli` field should equal the value above.

## Length-limit fallback

If the `RequestClient` value is rejected for length, drop the `+module=...` suffix:

```
tencent-edgeone-skill/1.0.0
```

The pipeline tolerates the degraded form — module distribution metrics will be unavailable for that day's affected calls but everything else still flows.

## Common mistakes

- ❌ `tencent-edgeone-skill/1.0.0+module=API` — `MODULE` must be lowercase
- ❌ `tencent-edgeone-skill/1.0.0+module=billing` — must be one of the four enum values
- ❌ Forgetting it entirely on a single call — that call will be missing from per-module stats
- ❌ Hard-coding the version — keep it in sync with the SKILL.md frontmatter
