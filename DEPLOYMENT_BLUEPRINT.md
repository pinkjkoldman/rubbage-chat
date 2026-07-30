# RubbageChat 可部署服务器方案

本方案对应 `2.5.0-beta.1`。客户端不要求用户填写 IP：安装包内只保存一个 HTTPS
Bootstrap 地址，启动时获取当前可用的 `TLS TCP` 域名和端口；请求失败时使用本地缓存和
安装包内置域名兜底。更换机房、端口或负载均衡器时只更新 Bootstrap JSON。

## 组件边界

```text
Windows 客户端
  -> HTTPS Bootstrap（短连接、CDN 可缓存）
  -> DNS + TCP 443 负载均衡
  -> RubbageChat Gateway（TLS、限流、心跳）
  -> 有界 ChatCommandService 工作池
  -> MongoDB 副本集（账号、会话、消息、游标、元数据）
  -> 附件对象目录（生产可挂载到独立持久卷）
```

`ChatServer` 只负责连接与在线事件；阻塞的密码哈希和 MongoDB 操作均由有界业务线程池
执行。队列达到 `performance/maxPendingCommands` 后快速返回“服务器繁忙”，不会继续
消耗内存。消息由服务端分配每会话递增 `seq`，客户端通过 `afterSeq` 增量补偿，并以
`clientMessageId` 实现断线重放幂等。

## 生产配置

1. 为 `chat.example.com` 配置 DNS 和 TLS 证书；公网只开放 TCP 443。
2. 将 `deployment/nginx.conf.example` 中的域名和上游地址替换为真实值。
3. 部署 MongoDB 副本集，创建仅有 `rubbagechat` 数据库 `readWrite` 权限的应用账号。
4. 设置服务端环境变量，不要把 URI、证书私钥写入仓库或客户端：

```powershell
$env:RUBBAGECHAT_MONGO_URI='mongodb://app:URL_ENCODED_PASSWORD@mongo1,mongo2,mongo3/rubbagechat?replicaSet=rs0&authSource=rubbagechat'
$env:RUBBAGECHAT_TLS_CERT='C:\ProgramData\RubbageChat\tls\fullchain.pem'
$env:RUBBAGECHAT_TLS_KEY='C:\ProgramData\RubbageChat\tls\privkey.pem'
$env:RUBBAGECHAT_ATTACHMENT_ROOT='D:\RubbageChatData\attachments'
.\Start-ProductionServer.ps1
```

5. 发布 `deployment/bootstrap.json.example` 的实际版本。`expiresAt` 必须是未来七天内的
ISO 8601 时间，客户端只接受 HTTPS 文档和 DNS 服务端地址。
6. 生成锁定网络配置的安装包：

```powershell
.\Build-Installer.ps1 `
  -ServerHost chat.example.com `
  -ServerPort 443 `
  -BootstrapUrl https://config.example.com/.well-known/rubbagechat/client `
  -Tls -LockNetwork
```

## 容量与扩展

单实例通过 `businessWorkers` 控制并发数据库任务；连接数受总量、单 IP 和请求窗口三层
限制。多实例阶段使用 L4 长连接负载均衡和 MongoDB 共享状态。仓库中的 Compose 文件
提供 MongoDB 开发基线，并以 `scale` profile 预留 Redis、NATS JetStream、MinIO；
这些预留组件当前不在主消息链路中，启用前应实现相应适配器和跨实例事件总线，不能仅靠
启动容器宣称完成水平扩容。

## 发布产物

```powershell
.\Build-RubbageChat.ps1
.\Build-ServerPackage.ps1 -SkipBuild
.\Build-Installer.ps1 -BootstrapUrl https://config.example.com/.well-known/rubbagechat/client `
  -ServerHost chat.example.com -ServerPort 443 -Tls -LockNetwork
```

输出：

- `dist/RubbageChatServer-2.5.0-beta.1.zip`：服务端程序、Qt 运行库、配置模板和启动脚本。
- `dist/RubbageChatSetup.exe`：只包含客户端的 Windows 安装包。

正式商业上线前仍需完成代码签名、安装包签名、监控告警、备份恢复演练、隐私合规、
内容治理、跨实例事件总线和第三方推送接入。
