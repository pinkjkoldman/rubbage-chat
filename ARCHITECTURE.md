# RubbageChat 架构

## 2.5 关键模块

- `EndpointDiscovery`：只暴露一个“解析可用服务端”操作，封装 HTTPS Bootstrap、
  文档校验、七天有效期、缓存与内置兜底。
- `ReliableOutbox`：原子持久化未确认文字消息；重连后复用 `clientMessageId` 重放。
- `ChatCommandService`：有界线程池和过载保护，所有阻塞业务工作离开 TCP 事件循环。
- `MongoChatStore`：维护会话严格递增 `seq`、同步游标、回执、设备会话和消息变更。
- 附件对象目录：MongoDB 只存储文件元数据和 SHA-256，文件内容写入可挂载持久卷。

## 设计目标

系统采用服务端权威模型。用户身份、会话、好友关系、消息和附件只由服务端修改并持久化到 MongoDB；客户端提交意图并渲染服务端返回的快照。

## 模块

### Client Application

位置：`apps/client`

`ChatController` 是 QML 使用的唯一 C++ 接口。它隐藏连接、TLS、请求关联、重连、状态快照、文件编码和下载校验。QML 不直接访问 Socket、MongoDB 或协议帧。

接口约束：

- 所有业务请求异步完成。
- 登录前只允许注册、登录和网络配置。
- 认证后的请求自动附带会话 Token。
- TLS 校验失败时断开连接，不忽略证书错误。

### Chat Server

位置：`apps/server/network`

`ChatServer` 是网络会话模块。它负责帧解析、身份认证、限流、在线状态、事件推送和操作分派。发送者身份始终由 Token 得出，不信任客户端传入的账号字段。

### Mongo Chat Store

位置：`apps/server/storage`

`MongoChatStore` 封装全部业务持久化规则，包括账号分配、密码派生、会话、好友关系、消息顺序、附件授权和会话选项。网络模块不拼接 MongoDB 查询。

目前只有 MongoDB 一个生产适配器，因此没有额外引入抽象存储接口；当出现第二个真实适配器时，再在此处建立存储 seam。

### Chat Protocol

位置：`libs/protocol`

`ChatProtocol` 是客户端、服务端和测试共享的协议模块。接口仅包含：

- JSON 请求信封构造
- 大端序长度前缀编码
- 流式帧提取和大小限制

业务规则不进入协议模块。

### Protocol Tests

位置：`tests/protocol`

测试通过与真实客户端相同的 TCP/JSON 接口验证注册、认证、好友、消息、附件、历史和越权拦截，不读取 MongoDB 内部状态。

## 数据流

```text
QML
  -> ChatController
  -> ChatProtocol
  -> TCP/TLS
  -> ChatServer
  -> MongoChatStore
  -> MongoDB
```

响应沿相反方向返回；在线接收者同时获得服务端事件，离线接收者下次登录后从 MongoDB 历史中恢复。

## 安全约束

- 密码使用随机盐和 PBKDF2-HMAC-SHA256。
- 数据库只保存 Token 的 SHA-256 摘要。
- MongoDB 仅绑定服务端本机地址，不暴露到公网。
- 公网部署必须启用 TLS 或置于可信 VPN 内。
- 附件在上传前限制大小，下载时再次检查会话成员权限。
