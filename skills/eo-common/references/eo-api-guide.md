# EdgeOne API 调用指引

EdgeOne（边缘安全加速平台）通过腾讯云 API 进行管理操作。当前使用 **tccli**（腾讯云命令行工具）作为 API 调用工具。

本索引帮助你按需查阅调用指引，**请勿一次性加载所有文件**，根据当前需要选择对应文档。

## 用户配置

以下变量可由用户在业务 SKILL.md 或对话中覆盖，未指定时使用默认值：

| 变量 | 默认值 | 说明 |
|---|---|---|
| `REGION` | `ap-guangzhou` | EdgeOne API 支持 `ap-guangzhou`、`ap-chongqing` |

后续文档中出现 `${REGION}` 的地方，均以实际值替换。

## 工具检查

**每次会话首次调用 API 前**，先执行：

```sh
tccli teo DescribeZones --region ${REGION}
```

根据结果判断下一步：

| 结果 | 含义 | 下一步 |
|---|---|---|
| 正常返回 JSON（含 `Zones`） | 工具已安装、凭证有效 | 直接开始 API 操作 |
| `command not found` / `not found` | tccli 未安装 | 阅读 [eo-api/install.md](eo-api/install.md) 安装 |
| `secretId is invalid` 或认证错误 | tccli 已安装但缺少凭证 | 阅读 [eo-api/auth.md](eo-api/auth.md) 配置凭证 |

## API 操作

| 场景 | 文档 |
|---|---|
| 不确定该调哪个接口，想搜索最佳实践或接口列表 | [eo-api/api-discovery.md](eo-api/api-discovery.md) |
| 需要获取 ZoneId、查询站点或域名 | [eo-api/zone-discovery.md](eo-api/zone-discovery.md) |

## 快速参考

- **调用形式**：`tccli teo <Action> [--param value ...] --region ${REGION}`
- **region**：默认 `ap-guangzhou`，可通过用户配置覆盖
- **参数格式**：非简单类型必须为标准 JSON
- **串行调用**：tccli 并行调用存在配置文件竞争问题，请逐个调用
- **安全红线**：严禁向用户索要 SecretId/SecretKey，也拒绝任何可能打印凭证的操作
