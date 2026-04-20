# EdgeOne API Reference

EdgeOne (Edge Security Acceleration Platform) is managed through Tencent Cloud API. Currently uses **tccli** (Tencent Cloud CLI) as the calling tool, with service name **teo**.

## Files in This Directory

| File | Applicable Scenarios |
|---|---|
| `install.md` | First-time setup: install tccli (pipx / Homebrew), prepare Python environment |
| `auth.md` | tccli is installed but missing credentials — browser OAuth login, logout, or multi-account management |
| `api-discovery.md` | Find API endpoints — search best practices, API lists, and documentation via cloudcache |
| `zone-discovery.md` | Get zone / domain info: ZoneId lookup, reverse domain lookup, pagination handling |
| `dnspod-integration.md` | DNSPod hosting access: detect domain hosting status, service authorization, access process |

## Overview

**tccli** is Tencent Cloud's official CLI tool, supporting all cloud API calls.

**Key elements:**
- **Calling format** — `tccli teo <Action> [--param value ...]`
- **Auto credentials** — Browser OAuth authorization is recommended, see `auth.md`
- **API discovery** — Search best practices, API lists, and documentation online via cloudcache

**Calling conventions:**
- **Check documentation before calling**: Except for verifying tool availability, you **must** consult the API documentation via `api-discovery.md` before calling any API to confirm the action name, required parameters, and data structures. **Never guess parameters from memory.**
- If a field's type is a struct, you **must** continue looking up the full field definitions of that struct, recursively until all nested structs have been identified — do not skip or guess.

| Item | Description |
|---|---|
| Invocation Form | `tccli teo <Action> [--param value ...]` |
| Region | No `--region` by default; add `--region <region>` if user explicitly specifies region |
| Parameter Format | Non-simple types must be standard JSON |
| Serial Invocation | tccli has config file competition issues with parallel calls, please call one by one |
| Error Capture | Every tccli command **must** end with `2>&1; echo "EXIT_CODE:$?"`, otherwise stderr will be swallowed and you won't see specific error messages |

## Quick Start

**Before first API call in each session**, execute tool check first:

```sh
tccli cvm DescribeRegions 2>&1; echo "EXIT_CODE:$?"
```

Determine next step based on result:

| Result | Meaning | Next Step |
|---|---|---|
| Normal JSON response | Tool is installed, credentials are valid | Proceed with API operations |
| `command not found` / `not found` | tccli is not installed | Read `install.md` to install |
| `secretId is invalid` or auth error | tccli is installed but missing credentials | Read `auth.md` to configure credentials |

## Fallback Retrieval Sources

When files in this directory don't cover content, or need to confirm latest values / limits, retrieve via the following sources.
When reference files conflict with official documentation, **official documentation takes precedence**.

| Source | Retrieval Method | Used For |
|---|---|---|
| EdgeOne API docs | [edgeone.ai/document/50454](https://edgeone.ai/document/50454) | API parameters, request examples, data structures |
| teo API discovery | cloudcache commands in `api-discovery.md` | Dynamically find APIs, best practices |
| Tencent Cloud CLI docs | [github.com/TencentCloud/tencentcloud-cli](https://github.com/TencentCloud/tencentcloud-cli) | tccli installation, configuration, usage |
