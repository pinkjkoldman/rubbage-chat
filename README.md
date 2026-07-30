# RubbageChat

RubbageChat 是一个使用 Qt 6、QML、Qt Network 和 MongoDB 实现的桌面即时通信软件。服务端负责身份、好友关系、会话、消息和附件的最终状态，客户端只保存界面与连接设置。

## 功能

- 注册、登录、退出和切换账号
- 好友搜索、申请、接受、拒绝和删除
- 实时消息、离线历史、未读状态和会话选项
- 会话/消息全文检索、独立会话草稿和消息快捷复制
- 基于系统字体、4/8 px 网格和统一 12/24 px 圆角的简洁界面
- 可滚动的分区设置中心、分类快捷定位与即时状态反馈
- 文件上传、授权下载和 SHA-256 校验
- 个人资料、密码修改和会话失效
- PBKDF2-HMAC-SHA256 密码存储
- Token 会话认证、请求限流、心跳和可选 TLS
- 本机 MongoDB 持久化
- Windows 安装包

## 目录

```text
apps/
  client/              QML 客户端与应用控制模块
  server/              TCP 会话模块与 MongoDB 持久化模块
libs/
  protocol/            客户端和服务端共享的帧协议
tests/
  protocol/            跨网络接口的端到端协议测试
installer/             Windows 安装脚本
third_party/           MongoDB C/C++ 静态驱动
```

详细设计见 [ARCHITECTURE.md](ARCHITECTURE.md)，部署方法见 [RUBBAGECHAT_DEPLOYMENT.md](RUBBAGECHAT_DEPLOYMENT.md)。

## 构建

默认开发环境：

- Qt 6.11 MinGW 64 位：`D:\Qt\6.11.0\mingw_64`
- MinGW 13.1：`D:\Qt\Tools\mingw1310_64`
- MongoDB 8.x：`127.0.0.1:27017`

```powershell
.\Build-RubbageChat.ps1
.\Start-RubbageChat.ps1
```

所有可运行文件生成在 `deploy`。协议测试必须从该目录运行：

```powershell
.\deploy\RubbageChatProtocolSmokeTest.exe
```

生成安装包：

```powershell
.\Build-Installer.ps1
```

输出文件为 `dist\RubbageChatSetup.exe`。

## 演示账号

新数据库首次启动时创建：

- `100000001` / `rubbagechat`
- `100000002` / `rubbagechat`

生产部署前应修改或删除演示账号。
