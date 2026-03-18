# EdgeOne API 检索

EdgeOne 的 tccli 服务名为 **teo**。
通常 references 文件已指明需要调用的 API 名称，直接查阅接口文档即可；
仅在 references 未覆盖时使用兜底检索。

---

## 主流程：已知 API 名称

### 1. 阅读接口文档

获取具体接口的参数说明与请求示例：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/action/CreatePurgeTask.md
```

### 2. 阅读数据结构

接口文档中涉及的复杂数据结构可进一步查看：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/model/Task.md
```

---

## 兜底：不确定该调哪个 API

当 references 未指明接口、或需要探索未覆盖的场景时，按以下顺序检索：

### 1. 检索接口列表

在接口列表中搜索关键词（Action 名即 `tccli teo` 的第二个参数）：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/actions.md \
  | grep -i "purge\|缓存"
```

### 2. 检索最佳实践

查找是否有匹配当前场景的最佳实践（含完整调用示例）：

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/practices.md \
  | grep -i "刷新\|purge"
```

### 3. 阅读最佳实践详情

```sh
curl -s https://cloudcache.tencentcs.com/capi/refs/service/teo/practice/practice-53.md
```

---

## 调用规范

- **调用形式**：`tccli teo <Action> [--param value ...]`
- **Region**：默认不带 `--region`；若用户明确指定了地域则加上 `--region <region>`
- **参数格式**：非简单类型必须为标准 JSON，例如：`--Targets '[{"Type":"url","Value":"https://www.example.com/a.txt"}]'`
- **串行调用**：tccli 并行调用存在配置文件竞争问题，请逐个调用
