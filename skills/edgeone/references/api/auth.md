# API 凭证配置

调用 EdgeOne API 需要腾讯云账号凭证。**推荐浏览器授权登录**，无需手填 SecretId/SecretKey。

```sh
tccli auth login
```

执行后会在本机起一个临时端口，并打印 OAuth 授权链接；通常也会自动用默认浏览器打开该链接。用户在浏览器中完成登录与授权后，腾讯云回调到本地端口，凭证自动写入。若浏览器未自动打开，请将终端打印的链接复制到浏览器中打开。成功后会提示「登录成功, 密钥凭证已被写入: ...」。

验证凭证是否可用：

```sh
tccli teo DescribeZones --region ${REGION}
```

**Agent 场景**：当 Agent 执行 `tccli auth login` 时，该命令会**一直阻塞**直到用户完成浏览器登录（或超时）。Agent 应明确告知用户：「请打开终端输出中显示的授权链接，在浏览器中完成登录；完成后该命令会自动结束。」

**多账户与登出**

- 默认凭证保存在 `default.credential`。指定账户名：`tccli auth login --profile user1`。
- 登出默认账户：`tccli auth logout`；登出指定账户：`tccli auth logout --profile user1`。
