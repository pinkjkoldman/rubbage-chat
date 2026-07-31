# RubbageChat

当前版本：`2.5.0-beta.1`。客户端支持 HTTPS Bootstrap 免 IP 配置、本地可靠发件箱、
幂等断线重发、消息序列/游标同步、已送达与已读回执、回复、编辑、撤回、表情回应和
多设备会话。服务端使用有界业务线程池隔离网络事件循环与 MongoDB/密码哈希工作，
附件正文保存在独立对象目录，MongoDB 仅保存授权元数据。

完整服务器拓扑、环境变量、反向代理和发布步骤见
[DEPLOYMENT_BLUEPRINT.md](DEPLOYMENT_BLUEPRINT.md)。

RubbageChat 是一个基于 Qt 6、QML、Qt Network 与 MongoDB 的桌面即时通信产品，包含可安装的 Windows 客户端、可视化服务端控制台、无界面服务器模式和公网测试发布脚本。

## 产品能力

- 注册、登录、退出和账号切换
- 好友搜索、申请、接受、拒绝和删除
- 实时消息、离线历史、未读状态与会话选项
- 会话/消息全文搜索、独立草稿和快捷复制
- 消息日期分栏（今天/昨天/具体日期）、已送达与已读状态标签
- 表情回应汇总徽章、回复卡片（引用样式）与已编辑标记
- 「澄境」界面体系：极光渐变背景、玻璃质感浮动面板、圆角工作台布局与
  带尾巴的消息气泡，支持浅色/深色两套主题
- 文件上传、授权下载与 SHA-256 校验
- 个人资料、密码修改与会话失效
- PBKDF2-HMAC-SHA256 密码存储与 Token 会话认证
- 请求限流、连接限制、心跳、TLS 1.2+ 与公网模式启动校验
- 可视化服务端：服务启停、连接数、认证数、业务线程池队列深度、请求统计、安全配置和活动日志
- Windows 客户端安装器、桌面快捷方式、开始菜单入口与标准卸载项

## 目录

```text
apps/
  client/              QML 客户端与应用控制模块
  server/              可视化服务端与 MongoDB 持久化模块
libs/
  protocol/            客户端和服务端共享的帧协议
tests/
  protocol/            跨网络接口的端到端协议测试
installer/             Windows 客户端安装脚本
third_party/           MongoDB C/C++ 静态驱动
```

详细设计见 [ARCHITECTURE.md](ARCHITECTURE.md)，架构评估见
[docs/ARCHITECTURE_REVIEW.md](docs/ARCHITECTURE_REVIEW.md)，
产品视角的界面重设计见 [docs/UI_REDESIGN_PM.md](docs/UI_REDESIGN_PM.md)，
公网部署见 [PUBLIC_TEST_DEPLOYMENT.md](PUBLIC_TEST_DEPLOYMENT.md)。

## 构建

默认开发环境：

- Qt 6.11 MinGW 64 位：`D:\Qt\6.11.0\mingw_64`
- MinGW 13.1：`D:\Qt\Tools\mingw1310_64`
- MongoDB 8.x：`127.0.0.1:27017`

```powershell
.\Build-RubbageChat.ps1
```

构建结果位于 `deploy`。

## 启动

双击 `deploy\RubbageChatServer.exe` 打开可视化服务端控制台。用于 Windows Server 或进程管理器部署时，可使用无界面模式：

```powershell
.\deploy\RubbageChatServer.exe --headless
```

客户端：

```powershell
.\deploy\RubbageChat.exe
```

本机开发环境也可以继续使用：

```powershell
.\Start-RubbageChat.ps1
```

## 客户端安装包

生成默认本机连接配置的安装包：

```powershell
.\Build-Installer.ps1
```

生成连接公网测试服务器、启用 TLS 并内置 Bootstrap 的安装包：

```powershell
.\Build-Installer.ps1 -ServerHost chat.example.com -Tls -LockNetwork
```

输出文件为 `dist\RubbageChatSetup.exe`。安装器只包含客户端，不携带服务端、MongoDB 配置或测试程序。

## 公网测试包

生成相互隔离的客户端和服务端目录：

```powershell
.\Build-PublicTest.ps1 -ServerHost chat.example.com
```

输出位于 `dist\public-test`。部署前必须配置 MongoDB 认证 URI、域名证书、防火墙与反向代理/负载均衡策略，完整步骤见 [PUBLIC_TEST_DEPLOYMENT.md](PUBLIC_TEST_DEPLOYMENT.md)。

## 验证

服务端启动后运行：

```powershell
.\deploy\RubbageChatProtocolSmokeTest.exe
```

开发环境可通过 `development/seedDemoAccounts=true` 创建演示账号：

- `100000001` / `rubbagechat`
- `100000002` / `rubbagechat`

首次初始化会自动建立两个演示账号的好友关系，并写入一条带回复与表情回应的欢迎消息，
便于直接体验消息气泡、回复卡片、日期分栏和回应徽章。

公网模式禁止创建演示账号。
