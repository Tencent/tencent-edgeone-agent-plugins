# EdgeOne Agent Skills 安装指引

## 前置条件

- 已安装 **Git**

## 安装步骤

### 第一步：克隆仓库

将 EdgeOne Agent Skills 仓库克隆到本地：

```bash
# macOS / Linux
git clone https://github.com/user/edgeone-agent-plugins.git ~/.edgeone-skills

# Windows (PowerShell)
git clone https://github.com/user/edgeone-agent-plugins.git "$env:USERPROFILE\.edgeone-skills"
```

### 第二步：创建 Skill 链接

根据你使用的 AI 工具，将 skill 文件链接到对应的目录。

#### OpenAI Codex

```bash
# macOS / Linux
mkdir -p ~/.agents/skills
ln -s ~/.edgeone-skills/skills/edgeone ~/.agents/skills/edgeone

# Windows (PowerShell, 需要管理员权限)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\edgeone" "$env:USERPROFILE\.edgeone-skills\skills\edgeone"
```

#### Gemini CLI

```bash
# macOS / Linux
mkdir -p ~/.gemini/skills
ln -s ~/.edgeone-skills/skills/edgeone ~/.gemini/skills/edgeone

# Windows (PowerShell, 需要管理员权限)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.gemini\skills"
cmd /c mklink /J "$env:USERPROFILE\.gemini\skills\edgeone" "$env:USERPROFILE\.edgeone-skills\skills\edgeone"
```

#### OpenCode

```bash
# macOS / Linux
mkdir -p ~/.opencode/skills
ln -s ~/.edgeone-skills/skills/edgeone ~/.opencode/skills/edgeone

# Windows (PowerShell, 需要管理员权限)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.opencode\skills"
cmd /c mklink /J "$env:USERPROFILE\.opencode\skills\edgeone" "$env:USERPROFILE\.edgeone-skills\skills\edgeone"
```

#### Claude Code（手动安装）

```bash
# macOS / Linux
mkdir -p ~/.claude/skills
ln -s ~/.edgeone-skills/skills/edgeone ~/.claude/skills/edgeone

# Windows (PowerShell, 需要管理员权限)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills"
cmd /c mklink /J "$env:USERPROFILE\.claude\skills\edgeone" "$env:USERPROFILE\.edgeone-skills\skills\edgeone"
```

#### Cursor

Cursor 使用本地插件目录加载插件，需要链接整个仓库（而非仅 `skills/edgeone`）：

```bash
# macOS / Linux
ln -s ~/.edgeone-skills ~/.cursor/plugins/local/edgeone-agent-plugins

# Windows (PowerShell, 需要管理员权限)
cmd /c mklink /J "$env:USERPROFILE\.cursor\plugins\local\edgeone-agent-plugins" "$env:USERPROFILE\.edgeone-skills"
```

> **注意**：Cursor 也可以通过直接克隆到插件目录来安装，跳过第一步：
> ```bash
> git clone https://github.com/TencentEdgeOne/edgeone-agent-plugins.git ~/.cursor/plugins/local/edgeone-agent-plugins
> ```

#### 其他 Agent 工具

如果你使用的工具不在上述列表中，请将 `skills/edgeone` 目录复制或链接到该工具的 skill 加载目录下。通常是 `~/.<tool-name>/skills/` 或类似路径，请参考你的工具文档。

### 第三步：重启你的 Agent

退出并重新启动你的 AI 工具，使其发现新安装的 skill。

## 验证安装

安装完成后，可以通过以下方式验证：

```bash
# 检查符号链接是否有效
ls -la ~/.agents/skills/edgeone  # Codex
ls -la ~/.gemini/skills/edgeone  # Gemini CLI
ls -la ~/.claude/skills/edgeone  # Claude Code
```

然后在你的 Agent 中尝试以下对话来触发 skill：

- 「帮我查一下 EdgeOne 站点列表」
- 「帮我把 example.com 接入 EdgeOne」
- 「出一份安全周报」

如果 Agent 能够识别并加载 EdgeOne skill，说明安装成功。

## 更新

进入仓库目录拉取最新代码即可，符号链接会自动指向更新后的内容：

```bash
cd ~/.edgeone-skills
git pull
```

## 卸载

```bash
# 删除符号链接（以 Codex 为例，其他工具替换对应路径）
rm ~/.agents/skills/edgeone

# （可选）删除克隆的仓库
rm -rf ~/.edgeone-skills
```
