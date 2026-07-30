# RubbageChat 公网测试版部署

公网测试版使用一个 TLS TCP 入口。客户端只连接 `chat.example.com:7502`；
MongoDB 只允许服务端本机访问，客户端包不得包含数据库 URI、证书私钥或服务端配置。

## 1. 生成客户端和服务端包

```powershell
$env:RUBBAGECHAT_OPENSSL_ROOT='C:\path\to\openssl-root'
.\Build-PublicTest.ps1 -ServerHost chat.example.com
```

OpenSSL 根目录需要包含 `bin\libssl-3-x64.dll` 和
`bin\libcrypto-3-x64.dll`。打包脚本会验证 TLS 插件和运行库，缺失时拒绝生成
公网包。

输出：

- `dist\public-test\client`：可分发给测试用户。
- `dist\public-test\server`：只上传到受控服务器。

客户端配置会锁定域名、端口和 TLS。服务端配置启用 `publicMode`，缺少 TLS、
MongoDB 身份认证或误开演示账号时会拒绝启动。

## 2. DNS、防火墙和证书

1. 将 `chat.example.com` 的 A/AAAA 记录指向服务器公网地址。
2. 入站只开放 TCP `7502`；管理端口仅允许管理员 IP。
3. 禁止公网访问 MongoDB `27017` 和兼容文件端口 `7028`。
4. 将完整证书链和私钥放入服务端配置指定的路径。
5. 证书续期后重启 RubbageChatServer，让新证书生效。

客户端必须使用证书包含的域名，不能改用裸 IP。

## 3. MongoDB

MongoDB 必须只绑定 `127.0.0.1` 并启用身份认证。为应用创建仅拥有
`rubbagechat` 数据库 `readWrite` 权限的独立账号，不要使用管理员账号。

将连接串通过服务环境变量注入，避免写入仓库或客户端包：

```powershell
$env:RUBBAGECHAT_MONGO_URI='mongodb://rubbagechat_app:URL_ENCODED_PASSWORD@127.0.0.1:27017/rubbagechat?authSource=rubbagechat&serverSelectionTimeoutMS=3000'
```

建议同时设置：

```powershell
$env:RUBBAGECHAT_PUBLIC_MODE='true'
$env:RUBBAGECHAT_TLS='true'
$env:RUBBAGECHAT_REGISTRATION_ENABLED='true'
```

若测试名额已满，将 `RUBBAGECHAT_REGISTRATION_ENABLED` 改为 `false` 后重启服务。

## 4. 启动前检查

- `development/seedDemoAccounts=false`
- 生产数据库不存在 `100000001`、`100000002` 演示账号
- MongoDB 端口无法从公网访问
- 客户端显示“TLS 安全连接”
- 错误证书、错误域名和明文连接均被客户端拒绝
- 数据库备份可以在隔离环境恢复

## 5. 当前测试版容量边界

当前版本已使用有界业务线程池隔离网络事件循环，附件内容存入独立对象目录，并具备
消息幂等键、会话序列、游标同步和过载拒绝。单实例适合邀请制公网测试。扩展到多实例
前仍需要实现跨实例在线事件总线和集中限流；仓库 Compose 中的 NATS、Redis、MinIO
仅是扩展预留，未接入主链路，不能仅通过启动这些容器宣称完成水平扩容。
