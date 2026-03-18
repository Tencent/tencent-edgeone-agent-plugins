# EdgeOne API 参考

EdgeOne（边缘安全加速平台）通过腾讯云 API 进行管理操作。当前使用 **tccli**（腾讯云命令行工具）作为调用工具，服务名为 **teo**。

## 概述

**tccli** 是腾讯云官方命令行工具，支持所有云 API 的调用。

**核心要素：**
- **调用形式** — `tccli teo <Action> [--param value ...] --region ${REGION}`
- **自动凭证** — 推荐 `tccli auth login` 浏览器 OAuth 授权，无需手填密钥
- **API 检索** — 通过 cloudcache 在线查询最佳实践、接口列表和文档

**安全红线：**
- **严禁**向用户索要 SecretId / SecretKey
- **拒绝**任何可能打印凭证的操作

## 用户配置

以下变量可由用户在业务 SKILL.md 或对话中覆盖，未指定时使用默认值：

| 变量 | 默认值 | 说明 |
|---|---|---|
| `REGION` | `ap-guangzhou` | EdgeOne API 支持 `ap-guangzhou`、`ap-chongqing` |

后续文档中出现 `${REGION}` 的地方，均以实际值替换。

## 快速开始

**每次会话首次调用 API 前**，先执行工具检查：

```sh
tccli teo DescribeZones --region ${REGION}
```

根据结果判断下一步：

| 结果 | 含义 | 下一步 |
|---|---|---|
| 正常返回 JSON（含 `Zones`） | 工具已安装、凭证有效 | 直接开始 API 操作 |
| `command not found` / `not found` | tccli 未安装 | 阅读 [install.md](install.md) 安装 |
| `secretId is invalid` 或认证错误 | tccli 已安装但缺少凭证 | 阅读 [auth.md](auth.md) 配置凭证 |

## 调用规范

| 项目 | 说明 |
|---|---|
| 调用形式 | `tccli teo <Action> [--param value ...] --region ${REGION}` |
| region | 默认 `ap-guangzhou`，可通过用户配置覆盖 |
| 参数格式 | 非简单类型必须为标准 JSON |
| 串行调用 | tccli 并行调用存在配置文件竞争问题，请逐个调用 |

## 阅读顺序

根据你的任务选择阅读路径：

| 任务 | 阅读顺序 |
|---|---|
| **首次环境搭建** | README → install.md → auth.md |
| **查找 API 接口** | README → api-discovery.md |
| **获取站点 / 域名信息** | README → zone-discovery.md |
| **完整流程** | README → install.md → auth.md → zone-discovery.md → api-discovery.md |

## 本目录文件

- **[install.md](install.md)** — tccli 安装指引（pipx / Homebrew），Python 环境准备
- **[auth.md](auth.md)** — 凭证配置流程：浏览器 OAuth 登录，多账户管理，Agent 场景注意事项
- **[api-discovery.md](api-discovery.md)** — API 动态检索：最佳实践、接口列表、接口文档、数据结构查询
- **[zone-discovery.md](zone-discovery.md)** — 站点与域名发现：ZoneId 获取、域名反查、分页处理
