# 配置 TCCLI 凭证

## 登录方式

使用**浏览器授权登录**，无需手填 SecretId/SecretKey，凭证会自动写入本地：

```sh
tccli auth login
```

执行后 TCCLI 会在本机起一个临时端口，并打印 OAuth 授权链接（通常也会自动用默认浏览器打开）。用户在浏览器中完成登录与授权后，TCCLI 收到回调即写入凭证并退出。

- 若浏览器未自动打开，请将终端中打印的链接复制到浏览器中手动打开。
- 成功后会提示：「登录成功, 密钥凭证已被写入: ...」

---

## Agent 操作规范

**执行 `tccli auth login` 时：**

- 该命令会**一直阻塞**，直到用户完成浏览器登录（或超时）。
- Agent 应明确告知用户：「请打开终端/工具输出中显示的授权链接，在浏览器中完成登录」

---

## 多账户与登出

| 操作 | 命令 |
|------|------|
| 登录默认账户 | `tccli auth login` |
| 登录指定账户 | `tccli auth login --profile user1` |
| 登出默认账户 | `tccli auth logout` |
| 登出指定账户 | `tccli auth logout --profile user1` |

凭证文件说明：
- 默认账户凭证保存在 `default.credential`
- 指定账户凭证保存在 `<profile名>.credential`（如 `user1.credential`）