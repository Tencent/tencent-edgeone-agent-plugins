# EdgeOne API Reference

EdgeOne (Edge Security & Acceleration Platform) is managed through Tencent Cloud APIs. Currently using **tccli** (Tencent Cloud CLI) as the calling tool, with the service name **teo**.

## Files in This Directory

| File | Use Case |
|---|---|
| `install.md` | First-time setup: install tccli (pipx / Homebrew), prepare Python environment |
| `auth.md` | tccli is installed but missing credentials — browser OAuth login, logout, or multi-account management |
| `api-discovery.md` | Find API endpoints — search best practices, API lists, and documentation via cloudcache |
| `zone-discovery.md` | Get zone / domain info: ZoneId lookup, reverse domain lookup, pagination handling |

## Overview

**tccli** is Tencent Cloud's official CLI tool that supports calling all cloud APIs.

**Key elements:**
- **Calling format** — `tccli teo <Action> [--param value ...]`
- **Auto credentials** — Browser OAuth authorization is recommended, see `auth.md`
- **API discovery** — Search best practices, API lists, and documentation online via cloudcache

**Calling conventions:**
- **Check documentation before calling**: Except for verifying tool availability, you **must** consult the API documentation via `api-discovery.md` before calling any API to confirm the action name, required parameters, and data structures. **Never guess parameters from memory.**
- If a field's type is a struct, you **must** continue looking up the full field definitions of that struct, recursively until all nested structs have been identified — do not skip or guess.

| Item | Description |
|---|---|
| Calling format | `tccli teo <Action> [--param value ...]` |
| Region | Omit `--region` by default; add `--region <region>` only if the user explicitly specifies a region |
| Parameter format | Non-simple types must be standard JSON |
| Serial calls | tccli has config file contention issues with parallel calls — call one at a time |
| Error capture | Every tccli command **must** end with `2>&1; echo "EXIT_CODE:$?"`, otherwise stderr will be swallowed and the actual error message will be invisible |

## Quick Start

**Before the first API call in each session**, run a tool check:

```sh
tccli cvm DescribeRegions 2>&1; echo "EXIT_CODE:$?"
```

Determine the next step based on the result:

| Result | Meaning | Next Step |
|---|---|---|
| Normal JSON response | Tool is installed, credentials are valid | Proceed with API operations |
| `command not found` / `not found` | tccli is not installed | Read `install.md` to install |
| `secretId is invalid` or auth error | tccli is installed but missing credentials | Read `auth.md` to configure credentials |

## Fallback Retrieval Sources

When files in this directory do not cover the topic, or you need to verify the latest values / limits, search the following sources.
When reference files conflict with official documentation, **the official documentation takes precedence**.

| Source | How to Search | Used For |
|---|---|---|
| EdgeOne API docs | [cloud.tencent.com/document/api/1552](https://cloud.tencent.com/document/api/1552) | API parameters, request examples, data structures |
| teo API discovery | cloudcache commands in `api-discovery.md` | Dynamically find APIs, best practices |
| Tencent Cloud CLI docs | [cloud.tencent.com/document/product/440](https://cloud.tencent.com/document/product/440) | tccli installation, configuration, usage |
