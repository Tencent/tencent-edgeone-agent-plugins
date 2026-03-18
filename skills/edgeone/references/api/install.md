# API 调用环境准备

EdgeOne API 通过 **tccli**（腾讯云命令行工具）调用。

## 1. 选择安装方式

| 方式 | 适用场景 | 前置依赖 |
|---|---|---|
| **pipx** | 所有平台，自动隔离环境 | Python 3.8+ |
| **Homebrew** | macOS | 无需 Python |

- macOS 且已有 Homebrew → 可直接走 Homebrew 路线，跳到 [步骤 3](#3-安装-tccli)
- 其他情况 → 走 pipx 路线，继续步骤 2

## 2. 确保 Python 环境（pipx 路线）

```sh
python3 --version
```

若版本 ≥ 3.8，跳到下一步。若命令不存在或版本过低，按系统安装：

```sh
# macOS（通过 Homebrew）
brew install python@3

# Ubuntu / Debian
apt update && apt install -y python3 python3-pip

# Windows（通过 winget）
winget install Python.Python.3.12
# 或从官网下载：https://www.python.org/downloads/
```

安装后运行 `python3 --version` 确认版本 ≥ 3.8。

## 3. 安装 pipx（pipx 路线）

```sh
pipx --version
```

若已安装则跳到下一步，否则按系统安装：

```sh
# macOS
brew install pipx && pipx ensurepath

# Linux
pip install --user pipx && pipx ensurepath

# Windows
pip install --user pipx && pipx ensurepath
```

## 4. 安装 tccli

### pipx 路线

```sh
pipx install tccli

# 若从 3.0.252.3 以下版本升级，需先卸载再装：
# pipx uninstall tccli && pipx install tccli
```

### Homebrew 路线（仅 macOS）

```sh
brew tap tencentcloud/tccli
brew install tccli
# 更新：brew upgrade tccli
```

### 验证

```sh
tccli --version
```
