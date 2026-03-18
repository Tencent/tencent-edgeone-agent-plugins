# API 调用环境准备

EdgeOne API 通过 **tccli**（腾讯云命令行工具）调用。

**前提**：系统已安装 Python 3.8+。

先检查是否已安装 Python 3.8+：

```sh
python3 --version
```

若命令不存在或版本低于 3.8，按系统类型安装：

```sh
# macOS（通过 Homebrew）
brew install python@3

# Ubuntu / Debian
sudo apt update && sudo apt install -y python3 python3-pip

# Windows（通过 winget）
winget install Python.Python.3.12
# 或从官网下载安装包：https://www.python.org/downloads/
```

安装后再次运行 `python3 --version` 确认版本 ≥ 3.8。

**安装 tccli**：

```sh
# 方式一：pipx（推荐，自动隔离环境，不污染全局 Python）
pipx install tccli

# pipx 未安装？先装 pipx：
#   macOS:   brew install pipx && pipx ensurepath
#   Linux:   pip install --user pipx && pipx ensurepath
#   Windows: pip install --user pipx && pipx ensurepath

# 若从 3.0.252.3 以下版本升级，需先卸载再装：
# pipx uninstall tccli && pipx install tccli

# 方式二：macOS Homebrew
brew tap tencentcloud/tccli
brew install tccli
# 更新：brew upgrade tccli
```

验证安装：

```sh
tccli --version
```
