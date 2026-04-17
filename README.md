# Tencent EdgeOne Agent Plugins

[中文](README.zh-CN.md) | English

Tencent EdgeOne Agent Plugins is a collection of tools that help AI Agents perform configuration, operations, and troubleshooting on the [Tencent Cloud EdgeOne](https://edgeone.ai) platform.

## Installation

### Claude Code / Codebuddy

Install via the plugin marketplace:

```bash
# 1. Register the marketplace
/plugin marketplace add git@github.com:Tencent/tencent-edgeone-agent-plugins.git

# 2. Install the plugin
/plugin install edgeone@tencent-edgeone
```

### OpenAI Codex / Gemini CLI / Cursor / OpenCode / Other Agents

For AI tools without a built-in plugin marketplace, tell your Agent:

```
Please fetch and follow the instructions in:
https://raw.githubusercontent.com/Tencent/tencent-edgeone-agent-plugins/main/INSTALL.md
```

You can also clone the repository and install manually:

```bash
git clone https://github.com/Tencent/tencent-edgeone-agent-plugins.git
# Copy to the appropriate directory for your Agent tool
# e.g.: cp -r tencent-edgeone-agent-plugins/skills/tencent-edgeone-skill ~/.claude/skills/
```

For detailed installation instructions, see [INSTALL.md](INSTALL.md).

## Skills

### tencent-edgeone-skill

A comprehensive Skill for the Tencent Cloud EdgeOne (Edge Security & Acceleration Platform), covering edge acceleration (DNS, certificates, caching, rule engine, L4 proxy, load balancing), edge security (DDoS protection, Web protection, Bot management), edge media (real-time video / image processing), edge development (Edge Functions, EdgeOne Pages), and more.

> This Skill uses the [Tencent Cloud CLI](https://cloud.tencent.com/document/product/440) to call Tencent Cloud APIs. The Tencent Cloud CLI must be installed before use — if it is not yet installed, the Agent will automatically install it after the Skill starts.

**Included modules:**
 
| Module | Scenarios | Typical Triggers |
|---|---|---|
| **Acceleration** | <ul><li>Site onboarding wizard</li><li>Cache purge / prefetch</li><li>Certificate automation</li></ul> | <ul><li>"Onboard example.com to EO"</li><li>"Purge all cache under /static/"</li><li>"Certificate is expiring, help me renew"</li></ul> |
| **Security** | <ul><li>Security report generation</li><li>Security template coverage audit</li><li>Domain blocklist IP group identification</li><li>Threat IP analysis & blocking</li></ul> | <ul><li>"Generate a security status report for this week"</li><li>"Which domains have no security template?"</li><li>"Check the blocklist IP groups for this domain"</li><li>"Analyze recent attack IPs and block them"</li></ul> |
| **Observability** | <ul><li>Traffic trend daily report</li><li>Origin health check</li><li>Offline log download</li><li>Log parsing & fault analysis</li></ul> | <ul><li>"Generate yesterday's traffic report"</li><li>"Is the origin down?"</li><li>"Download logs for example.com from yesterday afternoon"</li><li>"Too many 502s, help me analyze the logs"</li></ul> |

#### Skill File Structure

The edgeone skill uses progressive disclosure — a multi-level index guides the Agent to read documents on demand:

```
tencent-edgeone-skill/
├── SKILL.md                              # tencent-edgeone-skill skill entry point
└── references/                           # skill reference docs
    ├── api/                              # API calling module
    │   ├── README.md                     # module entry
    │   ├── install.md                    # scenario: tccli installation
    │   └── ...
    ├── acceleration/                     # site acceleration module
    │   ├── README.md                     # module entry
    │   ├── cache-purge.md               # scenario: cache purge / prefetch
    │   └── ...
    ├── security/                         # security protection module
    │   ├── README.md                     # module entry
    │   ├── security-report.md           # scenario: security report
    │   └── ...
    └── ...                               # other modules...
```

## Security Design

- **Write operations require user confirmation**: All write operations (create, modify, delete, etc.) will explain the impact and wait for user confirmation before execution.
- **Never asks for secret keys**: The Agent will never ask for your SecretId / SecretKey — it uses browser-based OAuth for secure login.
- **Read-only by default**: Security-related Skills default to read-only queries and do not perform any modifications.

## Resources

- [EdgeOne Product Documentation](https://cloud.tencent.com/document/product/1552)
- [EdgeOne API Documentation](https://cloud.tencent.com/document/api/1552)
- [EdgeOne Official Website](https://edgeone.ai)
- [Tencent Cloud CLI Documentation](https://cloud.tencent.com/document/product/440)
