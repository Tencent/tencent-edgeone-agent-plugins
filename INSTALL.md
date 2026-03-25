# EdgeOne Agent Plugins Installation Guide

## Prerequisites

- **Git** installed

## Installation Steps

### Step 1: Clone the Repository

Clone the EdgeOne Agent Plugins repository to your local machine:

```bash
# macOS / Linux
git clone https://github.com/TencentEdgeOne/edgeone-agent-plugins.git ~/.edgeone-agent-plugins

# Windows (PowerShell)
git clone https://github.com/TencentEdgeOne/edgeone-agent-plugins.git "$env:USERPROFILE\.edgeone-agent-plugins"
```

### Step 2: Create Skill Symlinks

Link the skill files to the appropriate directory based on the AI tool you are using.

#### OpenAI Codex

```bash
# macOS / Linux
mkdir -p ~/.agents/skills
ln -s ~/.edgeone-agent-plugins/skills/edgeone ~/.agents/skills/edgeone

# Windows (PowerShell, requires administrator privileges)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\edgeone" "$env:USERPROFILE\.edgeone-agent-plugins\skills\edgeone"
```

#### Gemini CLI

```bash
# macOS / Linux
mkdir -p ~/.gemini/skills
ln -s ~/.edgeone-agent-plugins/skills/edgeone ~/.gemini/skills/edgeone

# Windows (PowerShell, requires administrator privileges)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.gemini\skills"
cmd /c mklink /J "$env:USERPROFILE\.gemini\skills\edgeone" "$env:USERPROFILE\.edgeone-agent-plugins\skills\edgeone"
```

#### OpenCode

```bash
# macOS / Linux
mkdir -p ~/.opencode/skills
ln -s ~/.edgeone-agent-plugins/skills/edgeone ~/.opencode/skills/edgeone

# Windows (PowerShell, requires administrator privileges)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.opencode\skills"
cmd /c mklink /J "$env:USERPROFILE\.opencode\skills\edgeone" "$env:USERPROFILE\.edgeone-agent-plugins\skills\edgeone"
```

#### Claude Code (Manual Installation)

```bash
# macOS / Linux
mkdir -p ~/.claude/skills
ln -s ~/.edgeone-agent-plugins/skills/edgeone ~/.claude/skills/edgeone

# Windows (PowerShell, requires administrator privileges)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills"
cmd /c mklink /J "$env:USERPROFILE\.claude\skills\edgeone" "$env:USERPROFILE\.edgeone-agent-plugins\skills\edgeone"
```

#### Cursor

Cursor loads plugins from a local plugin directory, so you need to symlink the entire repository (not just `skills/edgeone`):

```bash
# macOS / Linux
ln -s ~/.edgeone-agent-plugins ~/.cursor/plugins/local/edgeone-agent-plugins

# Windows (PowerShell, requires administrator privileges)
cmd /c mklink /J "$env:USERPROFILE\.cursor\plugins\local\edgeone-agent-plugins" "$env:USERPROFILE\.edgeone-agent-plugins"
```

> **Note**: You can also install Cursor by cloning directly into the plugin directory, skipping Step 1:
> ```bash
> git clone https://github.com/TencentEdgeOne/edgeone-agent-plugins.git ~/.cursor/plugins/local/edgeone-agent-plugins
> ```

#### Other Agent Tools

If your tool is not listed above, copy or symlink the `skills/edgeone` directory to the tool's skill loading directory. This is typically `~/.<tool-name>/skills/` or a similar path — refer to your tool's documentation for details.

### Step 3: Restart Your Agent

Quit and restart your AI tool so it can discover the newly installed skill.

## Verify Installation

After installation, you can verify it by running:

```bash
# Check that the symlink is valid
ls -la ~/.agents/skills/edgeone  # Codex
ls -la ~/.gemini/skills/edgeone  # Gemini CLI
ls -la ~/.claude/skills/edgeone  # Claude Code
```

Then try the following prompts in your Agent to trigger the skill:

- "List my EdgeOne sites"
- "Onboard example.com to EdgeOne"
- "Generate a security weekly report"

If the Agent recognizes and loads the EdgeOne skill, the installation was successful.

## Update

Navigate to the repository directory and pull the latest code — the symlink will automatically point to the updated content:

```bash
cd ~/.edgeone-agent-plugins
git pull
```

## Uninstall

```bash
# Remove the symlink (using Codex as an example; replace the path for other tools)
rm ~/.agents/skills/edgeone

# (Optional) Remove the cloned repository
rm -rf ~/.edgeone-agent-plugins
```
