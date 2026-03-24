# EdgeOne API 参考

EdgeOne（边缘安全加速平台）通过腾讯云 API 进行管理操作。当前使用 **tccli**（腾讯云命令行工具）作为调用工具，服务名为 **teo**。

## 本目录文件

| 文件 | 适用场景 |
|---|---|
| [install.md](install.md) | 首次使用，需要安装 tccli（pipx / Homebrew）、准备 Python 环境 |
| [auth.md](auth.md) | tccli 已安装但缺少凭证，需要浏览器 OAuth 登录，登出，或多账户管理 |
| [api-discovery.md](api-discovery.md) | 查找 API 接口，通过 cloudcache 检索最佳实践、接口列表和文档 |
| [zone-discovery.md](zone-discovery.md) | 获取站点 / 域名信息：ZoneId 获取、域名反查、分页处理 |

## 概述

**tccli** 是腾讯云官方命令行工具，支持所有云 API 的调用。

**核心要素：**
- **调用形式** — `tccli teo <Action> [--param value ...]`
- **自动凭证** — 推荐浏览器 OAuth 授权，详见 [auth.md](auth.md)
- **API 检索** — 通过 cloudcache 在线查询最佳实践、接口列表和文档

**调用规范：**
- **先查文档再调用**：除了验证工具可用性之外，调用任何 API 前**必须**先通过 [api-discovery.md](api-discovery.md) 查阅接口文档，确认接口名称、必填参数和数据结构。**严禁凭记忆猜测参数**。
- 若某个字段的类型是结构体，**必须**继续查阅该结构体的完整字段定义，递归直到所有嵌套结构体都已查明，不得遗漏或凭猜测填写。

| 项目 | 说明 |
|---|---|
| 调用形式 | `tccli teo <Action> [--param value ...]` |
| Region | 默认不带 `--region`；若用户明确指定了地域则加上 `--region <region>` |
| 参数格式 | 非简单类型必须为标准 JSON |
| 串行调用 | tccli 并行调用存在配置文件竞争问题，请逐个调用 |
| 错误捕获 | 每条 tccli 命令**必须**以 `2>&1; echo "EXIT_CODE:$?"` 结尾，否则 stderr 会被吞掉，无法看到具体错误消息 |

## 快速开始

**每次会话首次调用 API 前**，先执行工具检查：

```sh
tccli cvm DescribeRegions 2>&1; echo "EXIT_CODE:$?"
```

根据结果判断下一步：

| 结果 | 含义 | 下一步 |
|---|---|---|
| 正常返回 JSON | 工具已安装、凭证有效 | 直接开始 API 操作 |
| `command not found` / `not found` | tccli 未安装 | 阅读 [install.md](install.md) 安装 |
| `secretId is invalid` 或认证错误 | tccli 已安装但缺少凭证 | 阅读 [auth.md](auth.md) 配置凭证 |

## 兜底检索来源

当本目录文件未覆盖、或需要确认最新数值 / 限制时，通过以下来源检索。
当 reference 文件与官方文档不一致时，**以官方文档为准**。

| 来源 | 检索方式 | 用于 |
|---|---|---|
| EdgeOne API 文档 | [cloud.tencent.com/document/api/1552](https://cloud.tencent.com/document/api/1552) | 接口参数、请求示例、数据结构 |
| teo API 检索 | [api-discovery.md](api-discovery.md) 中的 cloudcache 命令 | 动态查找接口、最佳实践 |
| 腾讯云 CLI 文档 | [cloud.tencent.com/document/product/440](https://cloud.tencent.com/document/product/440) | tccli 安装、配置、用法 |
