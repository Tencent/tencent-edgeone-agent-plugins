# EdgeOne API 检索

当不确定该调用哪个 API 时，按以下优先级检索。EdgeOne 的 tccli 服务名为 **teo**。

## 1. 检索最佳实践

优先查找是否有匹配当前场景的最佳实践（含完整调用示例）：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/practices.md \
  | grep -i "刷新\|purge"
```

## 2. 检索接口列表

若最佳实践未覆盖，在接口列表中检索（Action 名即 `tccli teo` 的第二个参数）：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/actions.md \
  | grep -i "purge\|缓存"
```

## 3. 阅读接口文档

获取具体接口的参数说明与请求示例：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/action/CreatePurgeTask.md
```

## 4. 阅读最佳实践详情

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/practice/practice-53.md
```

## 5. 阅读数据结构

接口文档中涉及的复杂数据结构可进一步查看：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/model/Task.md
```

## 调用规范

- **调用形式**：`tccli teo <Action> [--param value ...] --region ${REGION}`
- **region**：使用 [README.md](README.md) 用户配置中的 `${REGION}` 值
- **参数格式**：非简单类型必须为标准 JSON，例如：`--Targets '[{"Type":"url","Value":"https://www.example.com/a.txt"}]'`
- **串行调用**：tccli 并行调用存在配置文件竞争问题，请逐个调用
