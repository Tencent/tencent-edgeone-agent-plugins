# EdgeOne Agent Plugins

[中文](README.zh-CN.md) | English

EdgeOne Agent Plugins is a collection of tools that help AI Agents perform configuration, operations, and troubleshooting on the [Tencent Cloud EdgeOne](https://edgeone.ai) platform.

## Installation

### Claude Code / Codebuddy

Install via the plugin marketplace:

```bash
# 1. Register the marketplace
/plugin marketplace add TencentEdgeOne/edgeone-agent-plugins

# 2. Install the plugin
/plugin install edgeone-agent-plugins@edgeone
```

### OpenAI Codex / Gemini CLI / Cursor / OpenCode / Other Agents

For AI tools without a built-in plugin marketplace, tell your Agent:

```
Please fetch and follow the instructions in:
https://raw.githubusercontent.com/TencentEdgeOne/edgeone-agent-plugins/main/INSTALL.md
```

You can also clone the repository and install manually:

```bash
git clone https://github.com/TencentEdgeOne/edgeone-agent-plugins.git
# Copy to the appropriate directory for your Agent tool
# e.g.: cp -r edgeone-agent-plugins/skills/edgeone ~/.claude/skills/
```

For detailed installation instructions, see [INSTALL.md](INSTALL.md).

## Skills

### edgeone

A comprehensive Skill for the Tencent Cloud EdgeOne (Edge Security & Acceleration Platform), covering edge acceleration (DNS, certificates, caching, rule engine, L4 proxy, load balancing), edge security (DDoS protection, Web protection, Bot management), edge media (real-time video / image processing), edge development (Edge Functions, EdgeOne Pages), and more.

> This Skill uses the [Tencent Cloud CLI](https://cloud.tencent.com/document/product/440) to call Tencent Cloud APIs. The Tencent Cloud CLI must be installed before use — if it is not yet installed, the Agent will automatically install it after the Skill starts.

**Included modules:**

| Module | Description | Typical Triggers |
|---|---|---|
| **Site Acceleration** | Site onboarding, cache purge / prefetch, certificate management | "Onboard example.com to EO", "Purge cache", "Certificate is expiring" |
| **Security Protection** | Security policy template audit, blocklist IP group query, security report | "Which domains have no security template?", "Generate a security report", "Check blocklist IP groups" |

## Security Design

- **Write operations require user confirmation**: All write operations (create, modify, delete, etc.) will explain the impact and wait for user confirmation before execution.
- **Never asks for secret keys**: The Agent will never ask for your SecretId / SecretKey — it uses browser-based OAuth for secure login.
- **Read-only by default**: Security-related Skills default to read-only queries and do not perform any modifications.

## Resources

- [EdgeOne Product Documentation](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API Documentation](https://cloud.tencent.com/document/api/1552)
- [EdgeOne Official Website](https://edgeone.ai)
- [Tencent Cloud CLI Documentation](https://cloud.tencent.com/document/product/440)
