# EdgeOne API Reference

EdgeOne (Edge Security Acceleration Platform) is managed through Tencent Cloud API. Currently uses **tccli** (Tencent Cloud CLI) as the calling tool, with service name **teo**.

## Files in This Directory

| File | Applicable Scenarios |
|---|---|
| [install.md](install.md) | First-time use, need to install tccli (pipx / Homebrew), prepare Python environment |
| [auth.md](auth.md) | tccli installed but missing credentials, need browser OAuth login, logout, or multi-account management |
| [api-discovery.md](api-discovery.md) | Find API interfaces, retrieve best practices, interface lists, and documentation via cloudcache |
| [zone-discovery.md](zone-discovery.md) | Get site / domain information: ZoneId retrieval, reverse domain lookup, pagination handling |
| [dnspod-integration.md](dnspod-integration.md) | DNSPod hosting access: detect domain hosting status, service authorization, access process |

## Overview

**tccli** is Tencent Cloud's official CLI tool, supporting all cloud API calls.

**Core Elements:**
- **Invocation Form** — `tccli teo <Action> [--param value ...]`
- **Automatic Credentials** — Browser OAuth authorization recommended, see [auth.md](auth.md)
- **API Retrieval** — Query best practices, interface lists, and documentation online via cloudcache

**Invocation Guidelines:**
- **Check documentation before calling**: Except for tool availability verification, **must** first consult interface documentation via [api-discovery.md](api-discovery.md) before calling any API to confirm interface name, required parameters, and data structures. **Never guess parameters from memory**.
- If a field's type is a structure, **must** continue to consult the complete field definitions of that structure, recursively until all nested structures are clarified; do not omit or guess.

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
| Returns JSON normally | Tool installed, credentials valid | Start API operations directly |
| `command not found` / `not found` | tccli not installed | Read [install.md](install.md) to install |
| `secretId is invalid` or authentication error | tccli installed but missing credentials | Read [auth.md](auth.md) to configure credentials |

## Fallback Retrieval Sources

When files in this directory don't cover content, or need to confirm latest values / limits, retrieve via the following sources.
When reference files conflict with official documentation, **official documentation takes precedence**.

| Source | Retrieval Method | Used For |
|---|---|---|
| EdgeOne API Documentation | [cloud.tencent.com/document/api/1552](https://cloud.tencent.com/document/api/1552) | Interface parameters, request examples, data structures |
| teo API Retrieval | cloudcache commands in [api-discovery.md](api-discovery.md) | Dynamically find interfaces, best practices |
| Tencent Cloud CLI Documentation | [cloud.tencent.com/document/product/440](https://cloud.tencent.com/document/product/440) | tccli installation, configuration, usage |
