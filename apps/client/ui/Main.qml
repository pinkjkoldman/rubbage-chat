import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root
    visible: true
    width: 1220
    height: 780
    minimumWidth: 980
    minimumHeight: 660
    title: "RubbageChat"

    readonly property bool dark: appController.effectiveDark
    readonly property color bg: dark ? "#0f1420" : "#f4f7fb"
    readonly property color panel: dark ? "#171e2d" : "#ffffff"
    readonly property color panelAlt: dark ? "#1d2638" : "#f7f9fc"
    readonly property color line: dark ? "#2b364b" : "#e8edf5"
    readonly property color textMain: dark ? "#edf2ff" : "#182033"
    readonly property color textMuted: dark ? "#94a2b9" : "#7a879d"
    readonly property color accent: "#5b6cff"
    readonly property color accentSoft: dark ? "#273255" : "#eef0ff"
    readonly property color good: "#35c58a"
    readonly property color danger: "#ee5f70"
    property int section: 0
    property bool emojiOpen: false

    color: bg

    component PrimaryButton: Button {
        id: primaryButton
        implicitHeight: 44
        font.pixelSize: 14
        font.weight: Font.DemiBold
        contentItem: Text {
            text: primaryButton.text
            color: "white"
            font: primaryButton.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 12
            color: primaryButton.down ? "#4658e6" : primaryButton.hovered ? "#6878ff" : root.accent
            opacity: primaryButton.enabled ? 1 : 0.45
        }
    }

    component GhostButton: Button {
        id: ghostButton
        implicitHeight: 38
        font.pixelSize: 13
        font.weight: Font.DemiBold
        contentItem: Text {
            text: ghostButton.text
            color: ghostButton.highlighted ? root.danger : root.textMain
            font: ghostButton.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 10
            color: ghostButton.down ? root.line : ghostButton.hovered ? root.panelAlt : "transparent"
            border.color: root.line
        }
    }

    component AppTextField: TextField {
        id: field
        implicitHeight: 44
        color: root.textMain
        placeholderTextColor: root.textMuted
        selectionColor: root.accent
        selectedTextColor: "white"
        leftPadding: 14
        rightPadding: 14
        font.pixelSize: 14
        background: Rectangle {
            radius: 12
            color: root.panelAlt
            border.color: field.activeFocus ? root.accent : root.line
            border.width: field.activeFocus ? 1.5 : 1
        }
    }

    component Avatar: Rectangle {
        property string label: "O"
        property bool online: false
        property int avatarSize: 44
        width: avatarSize
        height: avatarSize
        radius: avatarSize / 2
        color: root.accentSoft
        Text {
            anchors.centerIn: parent
            text: parent.label.length ? parent.label.slice(0, 1).toUpperCase() : "O"
            color: root.accent
            font.pixelSize: parent.avatarSize * 0.38
            font.weight: Font.Bold
        }
        Rectangle {
            visible: parent.online && appController.showOnlineStatus
            width: Math.max(10, parent.avatarSize * 0.25)
            height: width
            radius: width / 2
            color: root.good
            border.color: root.panel
            border.width: 2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: appController.authenticated ? shellComponent : authComponent
    }

    Component {
        id: authComponent

        Item {
            Rectangle {
                anchors.fill: parent
                color: root.bg

                Rectangle {
                    width: parent.width * 0.46
                    height: parent.height
                    color: root.dark ? "#18213a" : "#edf1ff"
                    visible: parent.width >= 1040

                    Column {
                        anchors.centerIn: parent
                        width: Math.min(420, parent.width - 80)
                        spacing: 22

                        Rectangle {
                            width: 68
                            height: 68
                            radius: 22
                            color: root.accent
                            Text {
                                anchors.centerIn: parent
                                text: "R"
                                color: "white"
                                font.pixelSize: 32
                                font.bold: true
                            }
                        }
                        Text {
                            width: parent.width
                            text: "让每一次对话\n都清晰而自在"
                            color: root.textMain
                            font.pixelSize: 38
                            font.weight: Font.Bold
                            lineHeight: 1.18
                        }
                        Text {
                            width: parent.width
                            text: "消息、联系人和设置都在同一个简洁空间里。"
                            color: root.textMuted
                            font.pixelSize: 16
                            wrapMode: Text.WordWrap
                        }
                        Row {
                            spacing: 18
                            Repeater {
                                model: ["实时消息", "离线送达", "MongoDB 历史"]
                                delegate: Row {
                                    spacing: 7
                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: root.good
                                        Text { anchors.centerIn: parent; text: "✓"; color: "white"; font.pixelSize: 11 }
                                    }
                                    Text { text: modelData; color: root.textMuted; font.pixelSize: 13 }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: authCard
                    width: Math.min(420, parent.width - 80)
                    height: authMode === 0 ? 500 : 595
                    radius: 24
                    color: root.panel
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width >= 1040
                        ? Math.max(70, (parent.width * 0.54 - width) / 2)
                        : (parent.width - width) / 2
                    border.color: root.line

                    property int authMode: 0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 38
                        spacing: 15

                        Text {
                            text: authCard.authMode === 0 ? "欢迎回来" : "创建 RubbageChat 账号"
                            color: root.textMain
                            font.pixelSize: 28
                            font.weight: Font.Bold
                        }
                        Text {
                            text: authCard.authMode === 0 ? "登录后继续你的对话" : "注册后会获得一个 9 位账号"
                            color: root.textMuted
                            font.pixelSize: 14
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            spacing: 6
                            Repeater {
                                model: ["登录", "注册"]
                                delegate: Button {
                                    Layout.fillWidth: true
                                    implicitHeight: 38
                                    text: modelData
                                    contentItem: Text {
                                        text: parent.text
                                        color: authCard.authMode === index ? root.accent : root.textMuted
                                        font.weight: Font.DemiBold
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        radius: 10
                                        color: authCard.authMode === index ? root.accentSoft : "transparent"
                                    }
                                    onClicked: authCard.authMode = index
                                }
                            }
                        }

                        AppTextField {
                            id: nameField
                            visible: authCard.authMode === 1
                            Layout.fillWidth: true
                            placeholderText: "昵称（2-20 个字符）"
                            maximumLength: 20
                        }
                        AppTextField {
                            id: accountField
                            visible: authCard.authMode === 0
                            Layout.fillWidth: true
                            placeholderText: "9 位账号"
                            inputMethodHints: Qt.ImhDigitsOnly
                            maximumLength: 9
                            text: appController.lastRegisteredAccount
                        }
                        AppTextField {
                            id: passwordField
                            Layout.fillWidth: true
                            placeholderText: "密码"
                            echoMode: TextInput.Password
                            maximumLength: 72
                            onAccepted: {
                                if (authCard.authMode === 0)
                                    appController.login(accountField.text, text)
                            }
                        }
                        AppTextField {
                            id: confirmField
                            visible: authCard.authMode === 1
                            Layout.fillWidth: true
                            placeholderText: "再次输入密码"
                            echoMode: TextInput.Password
                            maximumLength: 72
                        }

                        PrimaryButton {
                            Layout.fillWidth: true
                            Layout.topMargin: 5
                            text: authCard.authMode === 0 ? "登录" : "注册账号"
                            onClicked: {
                                if (authCard.authMode === 0)
                                    appController.login(accountField.text, passwordField.text)
                                else
                                    appController.registerAccount(nameField.text, passwordField.text, confirmField.text)
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: authCard.authMode === 0
                            text: "演示账号  100000001  ·  密码  rubbagechat"
                            color: root.textMuted
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 12
                        }
                        Item { Layout.fillHeight: true }
                        Text {
                            Layout.fillWidth: true
                            text: "账号、好友与聊天数据由服务端 MongoDB 统一保存"
                            color: root.textMuted
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 12
                        }
                    }

                    Connections {
                        target: appController
                        function onLastRegisteredAccountChanged() {
                            authCard.authMode = 0
                            accountField.text = appController.lastRegisteredAccount
                            passwordField.text = ""
                            passwordField.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: shellComponent

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 78
                Layout.fillHeight: true
                color: root.dark ? "#111827" : "#172033"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 18
                    anchors.bottomMargin: 18
                    spacing: 10

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 46
                        height: 46
                        radius: 15
                        color: root.accent
                        Text {
                            anchors.centerIn: parent
                            text: appController.currentUserName.slice(0, 1).toUpperCase()
                            color: "white"
                            font.pixelSize: 19
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: profileDialog.open()
                        }
                        ToolTip.visible: containsMouse
                        ToolTip.text: "编辑个人资料"
                    }

                    Item { height: 12; width: 1 }

                    Repeater {
                        model: [
                            {icon: "●", label: "消息"},
                            {icon: "♟", label: "联系人"},
                            {icon: "♢", label: "通知"},
                            {icon: "⚙", label: "设置"}
                        ]
                        delegate: Item {
                            Layout.alignment: Qt.AlignHCenter
                            width: 54
                            height: 52

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: root.section === index ? "#2f3f62" : navMouse.containsMouse ? "#222e46" : "transparent"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: 7
                                text: modelData.icon
                                color: root.section === index ? "white" : "#9eabc2"
                                font.pixelSize: 18
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 5
                                text: modelData.label
                                color: root.section === index ? "white" : "#9eabc2"
                                font.pixelSize: 10
                            }
                            Rectangle {
                                visible: index === 2 && appController.notificationCount > 0
                                width: 18
                                height: 18
                                radius: 9
                                color: root.danger
                                anchors.right: parent.right
                                anchors.top: parent.top
                                Text {
                                    anchors.centerIn: parent
                                    text: Math.min(9, appController.notificationCount)
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.section = index
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44
                        height: 28
                        radius: 14
                        color: appController.connected ? "#193e38" : "#3d2932"
                        Row {
                            anchors.centerIn: parent
                            spacing: 5
                            Rectangle {
                                width: 7
                                height: 7
                                radius: 4
                                color: appController.connected ? root.good : root.danger
                            }
                            Text {
                                text: appController.connected ? "在线" : "重连"
                                color: "white"
                                font.pixelSize: 9
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: root.section === 3 ? 260 : 318
                Layout.fillHeight: true
                color: root.panel
                border.color: root.line

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: ["消息", "联系人", "通知", "设置"][root.section]
                            color: root.textMain
                            font.pixelSize: 24
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            visible: root.section === 1
                            width: 36
                            height: 36
                            text: "+"
                            font.pixelSize: 22
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle { radius: 11; color: root.accent }
                            onClicked: addFriendDialog.open()
                            ToolTip.visible: hovered
                            ToolTip.text: "添加好友"
                        }
                    }

                    AppTextField {
                        id: sidebarSearch
                        visible: root.section < 2
                        Layout.fillWidth: true
                        implicitHeight: 40
                        placeholderText: root.section === 0 ? "搜索会话" : "搜索联系人"
                    }

                    ListView {
                        id: sidebarList
                        visible: root.section < 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: root.section === 0 ? appController.conversations : appController.contacts

                        delegate: Item {
                            width: sidebarList.width
                            height: delegateVisible ? (appController.compactMode ? 58 : 70) : 0
                            visible: delegateVisible
                            property bool delegateVisible: !sidebarSearch.text.length
                                || modelData.name.toLowerCase().includes(sidebarSearch.text.toLowerCase())
                                || modelData.account.includes(sidebarSearch.text)

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: appController.selectedPeerAccount === modelData.account
                                    ? root.accentSoft : itemMouse.containsMouse ? root.panelAlt : "transparent"
                            }
                            Avatar {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                avatarSize: appController.compactMode ? 38 : 44
                                label: modelData.initial
                                online: modelData.online
                            }
                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: appController.compactMode ? 58 : 64
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                Row {
                                    width: parent.width
                                    spacing: 6
                                    Text {
                                        width: parent.width - 56
                                        text: (modelData.pinned ? "⌃ " : "") + modelData.name
                                        color: root.textMain
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        visible: root.section === 0
                                        width: 50
                                        text: modelData.time
                                        color: root.textMuted
                                        font.pixelSize: 10
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                                Row {
                                    width: parent.width
                                    Text {
                                        width: parent.width - 28
                                        text: root.section === 0 ? modelData.lastMessage
                                            : modelData.online ? "在线" : modelData.signature
                                        color: root.textMuted
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }
                                    Rectangle {
                                        visible: root.section === 0 && modelData.unread > 0
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: modelData.muted ? root.textMuted : root.accent
                                        Text {
                                            anchors.centerIn: parent
                                            text: Math.min(99, modelData.unread)
                                            color: "white"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: function(mouse) {
                                    appController.selectPeer(modelData.account)
                                    if (mouse.button === Qt.RightButton) {
                                        conversationMenu.peerAccount = modelData.account
                                        conversationMenu.popup()
                                    } else {
                                        root.section = 0
                                    }
                                }
                            }
                        }

                        footer: Item {
                            width: sidebarList.width
                            height: sidebarList.count === 0 ? 180 : 0
                            visible: height > 0
                            Column {
                                anchors.centerIn: parent
                                spacing: 10
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.section === 0 ? "还没有会话" : "还没有联系人"
                                    color: root.textMain
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.section === 0 ? "添加好友后开始聊天" : "点击右上角 + 添加好友"
                                    color: root.textMuted
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.section === 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12
                        Rectangle {
                            Layout.fillWidth: true
                            height: 82
                            radius: 15
                            color: root.panelAlt
                            Column {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 6
                                Text {
                                    text: appController.notificationCount + " 条待处理"
                                    color: root.textMain
                                    font.pixelSize: 16
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: "好友申请会离线保存"
                                    color: root.textMuted
                                    font.pixelSize: 12
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }

                    ColumnLayout {
                        visible: root.section === 3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            height: 112
                            radius: 16
                            color: root.panelAlt
                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 12
                                Avatar {
                                    avatarSize: 48
                                    label: appController.currentUserName
                                    online: appController.connected
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 150
                                    spacing: 4
                                    Text {
                                        text: appController.currentUserName
                                        color: root.textMain
                                        font.pixelSize: 15
                                        font.weight: Font.Bold
                                    }
                                    Text { text: appController.currentUserAccount; color: root.textMuted; font.pixelSize: 11 }
                                    Text {
                                        width: parent.width
                                        text: appController.currentUserSignature
                                        color: root.textMuted
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: profileDialog.open()
                            }
                        }

                        Repeater {
                            model: ["外观", "聊天", "通知", "隐私", "网络", "账号"]
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 42
                                radius: 10
                                color: settingsMouse.containsMouse ? root.panelAlt : "transparent"
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData
                                    color: root.textMain
                                    font.pixelSize: 13
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "›"
                                    color: root.textMuted
                                    font.pixelSize: 20
                                }
                                MouseArea {
                                    id: settingsMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: settingsView.positionViewAtIndex(index, ListView.Beginning)
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.bg

                Loader {
                    anchors.fill: parent
                    sourceComponent: root.section === 0 ? chatView
                        : root.section === 1 ? contactView
                        : root.section === 2 ? requestView
                        : settingsComponent
                }
            }
        }
    }

    Component {
        id: chatView
        Item {
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: !appController.selectedPeerAccount.length
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 76
                    height: 76
                    radius: 24
                    color: root.accentSoft
                    Text { anchors.centerIn: parent; text: "···"; color: root.accent; font.pixelSize: 28 }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "选择一个联系人开始聊天"
                    color: root.textMain
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "消息会先写入服务端 MongoDB，对方上线后可读取完整历史"
                    color: root.textMuted
                    font.pixelSize: 13
                }
            }

            ColumnLayout {
                anchors.fill: parent
                visible: appController.selectedPeerAccount.length > 0
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    color: root.panel
                    border.color: root.line
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 22
                        anchors.rightMargin: 16
                        Avatar {
                            avatarSize: 42
                            label: appController.selectedPeerName
                            online: appController.selectedPeerOnline
                        }
                        ColumnLayout {
                            Layout.leftMargin: 4
                            spacing: 2
                            Text {
                                text: appController.selectedPeerName
                                color: root.textMain
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }
                            Text {
                                text: appController.selectedPeerOnline ? "在线" : "离线"
                                color: appController.selectedPeerOnline ? root.good : root.textMuted
                                font.pixelSize: 11
                            }
                        }
                        Item { Layout.fillWidth: true }
                        GhostButton {
                            text: "⋯"
                            width: 42
                            onClicked: {
                                conversationMenu.peerAccount = appController.selectedPeerAccount
                                conversationMenu.popup()
                            }
                        }
                    }
                }

                ListView {
                    id: messageList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 16
                    spacing: 8
                    clip: true
                    model: appController.messages

                    delegate: Item {
                        width: messageList.width
                        height: bubble.height + 18
                        Rectangle {
                            id: bubble
                            anchors.right: modelData.mine ? parent.right : undefined
                            anchors.left: modelData.mine ? undefined : parent.left
                            width: Math.min(messageText.implicitWidth + 28, parent.width * 0.7)
                            height: messageText.implicitHeight + 30
                            radius: 16
                            color: modelData.mine ? root.accent : root.panel
                            border.color: modelData.mine ? root.accent : root.line
                            Text {
                                id: messageText
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                anchors.topMargin: 9
                                anchors.bottomMargin: 16
                                text: modelData.body
                                color: modelData.mine ? "white" : root.textMain
                                font.pixelSize: 14
                                wrapMode: Text.Wrap
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 4
                                text: modelData.time
                                color: modelData.mine ? "#dce0ff" : root.textMuted
                                font.pixelSize: 9
                            }
                            TapHandler {
                                enabled: modelData.type === "file"
                                    && modelData.attachmentId.length > 0
                                cursorShape: Qt.PointingHandCursor
                                onTapped: appController.downloadAttachment(
                                    modelData.attachmentId)
                            }
                            ToolTip.visible: bubbleHover.hovered
                                && modelData.type === "file"
                            ToolTip.text: "点击下载附件"
                            HoverHandler { id: bubbleHover }
                        }
                    }

                    onCountChanged: Qt.callLater(function() { positionViewAtEnd() })
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.emojiOpen ? 182 : 142
                    color: root.panel
                    border.color: root.line

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Flow {
                            visible: root.emojiOpen
                            Layout.fillWidth: true
                            height: visible ? 36 : 0
                            spacing: 7
                            Repeater {
                                model: ["😀", "😂", "🥰", "😎", "👍", "🎉", "❤️", "🙏"]
                                delegate: Button {
                                    width: 34
                                    height: 34
                                    text: modelData
                                    font.pixelSize: 18
                                    background: Rectangle { radius: 9; color: parent.hovered ? root.panelAlt : "transparent" }
                                    onClicked: composer.insert(composer.cursorPosition, modelData)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            Button {
                                text: "＋"
                                width: 40
                                Layout.alignment: Qt.AlignBottom
                                enabled: !appController.fileTransferActive
                                contentItem: Text {
                                    text: parent.text
                                    color: root.textMuted
                                    font.pixelSize: 21
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle { radius: 10; color: parent.hovered ? root.panelAlt : "transparent" }
                                onClicked: attachmentDialog.open()
                                ToolTip.visible: hovered
                                ToolTip.text: "发送文件（最大 100 MB）"
                            }
                            Button {
                                text: "☺"
                                width: 40
                                Layout.alignment: Qt.AlignBottom
                                contentItem: Text {
                                    text: parent.text
                                    color: root.textMuted
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle { radius: 10; color: parent.hovered ? root.panelAlt : "transparent" }
                                onClicked: root.emojiOpen = !root.emojiOpen
                                ToolTip.visible: hovered
                                ToolTip.text: "表情"
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                TextArea {
                                    id: composer
                                    placeholderText: appController.enterToSend
                                        ? "输入消息，Enter 发送，Shift+Enter 换行"
                                        : "输入消息，Ctrl+Enter 发送"
                                    color: root.textMain
                                    placeholderTextColor: root.textMuted
                                    font.pixelSize: 14
                                    wrapMode: TextArea.Wrap
                                    background: Rectangle {
                                        color: root.panelAlt
                                        radius: 12
                                        border.color: composer.activeFocus ? root.accent : root.line
                                    }
                                    Keys.onPressed: function(event) {
                                        let enter = event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                        let shouldSend = appController.enterToSend
                                            ? enter && !(event.modifiers & Qt.ShiftModifier)
                                            : enter && (event.modifiers & Qt.ControlModifier)
                                        if (shouldSend) {
                                            appController.sendMessage(text)
                                            text = ""
                                            event.accepted = true
                                        }
                                    }
                                }
                            }
                            PrimaryButton {
                                text: "发送"
                                width: 74
                                Layout.alignment: Qt.AlignBottom
                                onClicked: {
                                    appController.sendMessage(composer.text)
                                    composer.text = ""
                                    composer.forceActiveFocus()
                                }
                            }
                        }
                        RowLayout {
                            visible: appController.fileTransferActive
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 20 : 0
                            Text {
                                text: appController.fileTransferLabel
                                color: root.textMuted
                                font.pixelSize: 10
                            }
                            ProgressBar {
                                Layout.fillWidth: true
                                value: appController.fileTransferProgress
                            }
                            Text {
                                text: Math.round(appController.fileTransferProgress * 100) + "%"
                                color: root.textMuted
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }

    FileDialog {
        id: attachmentDialog
        title: "选择要发送的文件"
        fileMode: FileDialog.OpenFile
        onAccepted: appController.sendFile(selectedFile)
    }

    Component {
        id: contactView
        Item {
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: !appController.selectedPeerAccount.length
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "联系人"
                    color: root.textMain
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "从左侧选择联系人，或添加新的好友"
                    color: root.textMuted
                    font.pixelSize: 14
                }
                PrimaryButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 130
                    text: "添加好友"
                    onClicked: addFriendDialog.open()
                }
            }

            Rectangle {
                visible: appController.selectedPeerAccount.length > 0
                anchors.centerIn: parent
                width: 440
                height: 420
                radius: 24
                color: root.panel
                border.color: root.line
                Column {
                    anchors.fill: parent
                    anchors.margins: 32
                    spacing: 18
                    Avatar {
                        anchors.horizontalCenter: parent.horizontalCenter
                        avatarSize: 88
                        label: appController.selectedPeerName
                        online: appController.selectedPeerOnline
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: appController.selectedPeerName
                        color: root.textMain
                        font.pixelSize: 24
                        font.weight: Font.Bold
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "账号 " + appController.selectedPeerAccount
                        color: root.textMuted
                        font.pixelSize: 13
                    }
                    Rectangle { width: parent.width; height: 1; color: root.line }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10
                        PrimaryButton {
                            width: 132
                            text: "发送消息"
                            onClicked: root.section = 0
                        }
                        GhostButton {
                            width: 132
                            text: "删除联系人"
                            highlighted: true
                            onClicked: removeFriendDialog.open()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: requestView
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                Text {
                    text: "好友申请"
                    color: root.textMain
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
                Text {
                    text: "接受后，双方联系人列表会自动更新。"
                    color: root.textMuted
                    font.pixelSize: 13
                }
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 10
                    model: appController.requests
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 88
                        radius: 16
                        color: root.panel
                        border.color: root.line
                        Avatar {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            label: modelData.initial
                            online: modelData.online
                        }
                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 76
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text { text: modelData.name; color: root.textMain; font.pixelSize: 15; font.bold: true }
                            Text { text: modelData.account + " · " + modelData.signature; color: root.textMuted; font.pixelSize: 12 }
                        }
                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            GhostButton {
                                width: 72
                                text: "拒绝"
                                onClicked: appController.rejectFriendRequest(modelData.account)
                            }
                            PrimaryButton {
                                width: 72
                                height: 38
                                text: "同意"
                                onClicked: appController.acceptFriendRequest(modelData.account)
                            }
                        }
                    }
                    footer: Item {
                        width: parent.width
                        height: parent.parent.count === 0 ? 200 : 0
                        Text {
                            anchors.centerIn: parent
                            text: "没有待处理的好友申请"
                            color: root.textMuted
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }

    Component {
        id: settingsComponent
        ScrollView {
            id: settingsScroll
            contentWidth: availableWidth
            ListView {
                id: settingsView
                width: settingsScroll.availableWidth
                height: contentHeight + 56
                interactive: false
                spacing: 14
                model: [
                    {title: "外观", subtitle: "主题与信息密度", kind: "appearance"},
                    {title: "聊天", subtitle: "消息发送方式", kind: "chat"},
                    {title: "通知", subtitle: "控制新消息提醒", kind: "notifications"},
                    {title: "隐私", subtitle: "在线状态与服务端数据", kind: "privacy"},
                    {title: "网络", subtitle: "服务器地址与通信端口", kind: "network"},
                    {title: "账号", subtitle: "个人资料与切换账号", kind: "account"}
                ]
                header: Item { width: 1; height: 20 }
                delegate: Rectangle {
                    width: Math.min(720, settingsView.width - 56)
                    height: modelData.kind === "appearance" ? 150
                        : modelData.kind === "network" ? 218
                        : modelData.kind === "account" ? 180 : 126
                    x: (settingsView.width - width) / 2
                    radius: 20
                    color: root.panel
                    border.color: root.line

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 8
                        Text {
                            text: modelData.title
                            color: root.textMain
                            font.pixelSize: 17
                            font.weight: Font.Bold
                        }
                        Text {
                            text: modelData.subtitle
                            color: root.textMuted
                            font.pixelSize: 12
                        }

                        RowLayout {
                            visible: modelData.kind === "appearance"
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            Text { text: "主题"; color: root.textMain; font.pixelSize: 13 }
                            Item { Layout.fillWidth: true }
                            ComboBox {
                                model: ["浅色", "深色", "跟随系统"]
                                currentIndex: appController.theme === "light" ? 0 : appController.theme === "dark" ? 1 : 2
                                onActivated: appController.theme = ["light", "dark", "system"][currentIndex]
                            }
                        }
                        RowLayout {
                            visible: modelData.kind === "appearance"
                            Layout.fillWidth: true
                            Text { text: "紧凑列表"; color: root.textMain; font.pixelSize: 13 }
                            Item { Layout.fillWidth: true }
                            Switch {
                                checked: appController.compactMode
                                onToggled: appController.compactMode = checked
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "chat"
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            ColumnLayout {
                                Text { text: "Enter 发送"; color: root.textMain; font.pixelSize: 13 }
                                Text {
                                    text: appController.enterToSend ? "Shift+Enter 换行" : "Ctrl+Enter 发送"
                                    color: root.textMuted
                                    font.pixelSize: 11
                                }
                            }
                            Item { Layout.fillWidth: true }
                            Switch {
                                checked: appController.enterToSend
                                onToggled: appController.enterToSend = checked
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "notifications"
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            ColumnLayout {
                                Text { text: "新消息与好友申请提醒"; color: root.textMain; font.pixelSize: 13 }
                                Text { text: "关闭后仍会保留未读数量"; color: root.textMuted; font.pixelSize: 11 }
                            }
                            Item { Layout.fillWidth: true }
                            Switch {
                                checked: appController.notificationsEnabled
                                onToggled: appController.notificationsEnabled = checked
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "privacy"
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            ColumnLayout {
                                Text { text: "显示在线状态"; color: root.textMain; font.pixelSize: 13 }
                                Text { text: "控制本机界面是否展示在线标记"; color: root.textMuted; font.pixelSize: 11 }
                            }
                            Item { Layout.fillWidth: true }
                            Switch {
                                checked: appController.showOnlineStatus
                                onToggled: appController.showOnlineStatus = checked
                            }
                        }

                        ColumnLayout {
                            visible: modelData.kind === "network"
                            Layout.fillWidth: true
                            Layout.topMargin: 6
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                AppTextField {
                                    id: serverHostField
                                    Layout.fillWidth: true
                                    placeholderText: "服务器地址，例如 100.64.0.10"
                                    text: appController.serverHost
                                }
                                AppTextField {
                                    id: chatPortField
                                    Layout.preferredWidth: 112
                                    placeholderText: "消息端口"
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    text: appController.chatPort.toString()
                                }
                                AppTextField {
                                    id: filePortField
                                    Layout.preferredWidth: 112
                                    placeholderText: "文件端口"
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    text: appController.filePort.toString()
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: appController.connected
                                        ? "已连接 " + appController.serverHost + ":" + appController.chatPort
                                        : "未连接；保存后会立即重连"
                                    color: appController.connected ? root.good : root.textMuted
                                    font.pixelSize: 11
                                }
                                PrimaryButton {
                                    width: 104
                                    text: "保存并重连"
                                    onClicked: appController.applyNetworkSettings(
                                        serverHostField.text,
                                        parseInt(chatPortField.text),
                                        parseInt(filePortField.text))
                                }
                            }
                            Text {
                                text: "配置写入程序目录的 rubbagechat.ini；环境变量配置优先。"
                                color: root.textMuted
                                font.pixelSize: 11
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "account"
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            GhostButton {
                                Layout.fillWidth: true
                                text: "编辑个人资料"
                                onClicked: profileDialog.open()
                            }
                            GhostButton {
                                Layout.fillWidth: true
                                text: "修改密码"
                                onClicked: passwordDialog.open()
                            }
                            GhostButton {
                                Layout.fillWidth: true
                                text: "切换账号"
                                onClicked: switchAccountDialog.open()
                            }
                        }
                        Text {
                            visible: modelData.kind === "account"
                            text: "账号 " + appController.currentUserAccount + " · "
                                + (appController.connected ? "服务器已连接" : "服务器重连中")
                            color: root.textMuted
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }

    Menu {
        id: conversationMenu
        property string peerAccount: ""
        MenuItem {
            text: appController.conversationOptions(conversationMenu.peerAccount).pinned ? "取消置顶" : "置顶会话"
            onTriggered: appController.togglePinned(conversationMenu.peerAccount)
        }
        MenuItem {
            text: appController.conversationOptions(conversationMenu.peerAccount).muted ? "开启提醒" : "消息免打扰"
            onTriggered: appController.toggleMuted(conversationMenu.peerAccount)
        }
        MenuSeparator {}
        MenuItem {
            text: "清空当前聊天记录"
            onTriggered: clearConversationDialog.open()
        }
    }

    Dialog {
        id: addFriendDialog
        width: 430
        height: 350
        anchors.centerIn: parent
        modal: true
        title: "添加好友"
        standardButtons: Dialog.NoButton
        background: Rectangle { radius: 20; color: root.panel; border.color: root.line }

        ColumnLayout {
            anchors.fill: parent
            spacing: 14
            Text { text: "通过 9 位账号查找用户"; color: root.textMuted; font.pixelSize: 13 }
            RowLayout {
                Layout.fillWidth: true
                AppTextField {
                    id: friendSearchField
                    Layout.fillWidth: true
                    placeholderText: "输入 9 位账号"
                    inputMethodHints: Qt.ImhDigitsOnly
                    maximumLength: 9
                    onAccepted: appController.searchUser(text)
                }
                PrimaryButton {
                    width: 76
                    text: "搜索"
                    onClicked: appController.searchUser(friendSearchField.text)
                }
            }
            Rectangle {
                visible: appController.searchResult.account !== undefined
                    && appController.searchResult.account !== ""
                Layout.fillWidth: true
                height: 112
                radius: 16
                color: root.panelAlt
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    Avatar {
                        label: appController.searchResult.initial || ""
                        online: appController.searchResult.online || false
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: appController.searchResult.name || ""; color: root.textMain; font.pixelSize: 15; font.bold: true }
                        Text { text: appController.searchResult.account || ""; color: root.textMuted; font.pixelSize: 12 }
                        Text {
                            Layout.fillWidth: true
                            text: appController.searchResult.signature || ""
                            color: root.textMuted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                    PrimaryButton {
                        width: 84
                        text: appController.searchResult.isFriend ? "已是好友" : "添加"
                        enabled: !appController.searchResult.isFriend
                        onClicked: appController.sendFriendRequest(appController.searchResult.account)
                    }
                }
            }
            Item { Layout.fillHeight: true }
            GhostButton {
                Layout.alignment: Qt.AlignRight
                width: 80
                text: "关闭"
                onClicked: addFriendDialog.close()
            }
        }
    }

    Dialog {
        id: profileDialog
        width: 430
        height: 360
        anchors.centerIn: parent
        modal: true
        title: "个人资料"
        standardButtons: Dialog.NoButton
        onOpened: {
            profileName.text = appController.currentUserName
            profileSignature.text = appController.currentUserSignature
        }
        background: Rectangle { radius: 20; color: root.panel; border.color: root.line }
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            Avatar {
                Layout.alignment: Qt.AlignHCenter
                avatarSize: 70
                label: appController.currentUserName
                online: appController.connected
            }
            AppTextField {
                id: profileName
                Layout.fillWidth: true
                placeholderText: "昵称"
                maximumLength: 20
            }
            AppTextField {
                id: profileSignature
                Layout.fillWidth: true
                placeholderText: "个性签名（最多 80 个字符）"
                maximumLength: 80
            }
            Text {
                text: "账号 " + appController.currentUserAccount
                color: root.textMuted
                font.pixelSize: 11
            }
            Item { Layout.fillHeight: true }
            RowLayout {
                Layout.fillWidth: true
                GhostButton { Layout.fillWidth: true; text: "取消"; onClicked: profileDialog.close() }
                PrimaryButton {
                    Layout.fillWidth: true
                    text: "保存"
                    onClicked: {
                        appController.updateProfile(profileName.text, profileSignature.text)
                        profileDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: switchAccountDialog
        anchors.centerIn: parent
        modal: true
        title: "切换账号"
        standardButtons: Dialog.NoButton
        background: Rectangle { radius: 18; color: root.panel; border.color: root.line }
        ColumnLayout {
            anchors.fill: parent
            spacing: 14
            Text {
                Layout.fillWidth: true
                text: "将断开当前会话并返回登录界面，服务端聊天记录不会删除。"
                wrapMode: Text.WordWrap
                color: root.textMuted
                font.pixelSize: 13
            }
            RowLayout {
                Layout.fillWidth: true
                GhostButton { Layout.fillWidth: true; text: "取消"; onClicked: switchAccountDialog.close() }
                PrimaryButton {
                    Layout.fillWidth: true
                    text: "切换账号"
                    onClicked: {
                        switchAccountDialog.close()
                        appController.logout()
                    }
                }
            }
        }
    }

    Dialog {
        id: passwordDialog
        width: 410
        height: 390
        anchors.centerIn: parent
        modal: true
        title: "修改密码"
        standardButtons: Dialog.NoButton
        onClosed: {
            currentPassword.text = ""
            newPassword.text = ""
            confirmPassword.text = ""
        }
        background: Rectangle { radius: 18; color: root.panel; border.color: root.line }
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            Text {
                text: "修改后，下次登录请使用新密码。"
                color: root.textMuted
                font.pixelSize: 12
            }
            AppTextField {
                id: currentPassword
                Layout.fillWidth: true
                placeholderText: "当前密码"
                echoMode: TextInput.Password
            }
            AppTextField {
                id: newPassword
                Layout.fillWidth: true
                placeholderText: "新密码（8-72 个字符）"
                echoMode: TextInput.Password
            }
            AppTextField {
                id: confirmPassword
                Layout.fillWidth: true
                placeholderText: "再次输入新密码"
                echoMode: TextInput.Password
            }
            Item { Layout.fillHeight: true }
            RowLayout {
                Layout.fillWidth: true
                GhostButton { Layout.fillWidth: true; text: "取消"; onClicked: passwordDialog.close() }
                PrimaryButton {
                    Layout.fillWidth: true
                    text: "保存新密码"
                    onClicked: {
                        appController.changePassword(currentPassword.text, newPassword.text, confirmPassword.text)
                        passwordDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: removeFriendDialog
        anchors.centerIn: parent
        modal: true
        title: "删除联系人"
        standardButtons: Dialog.NoButton
        background: Rectangle { radius: 18; color: root.panel; border.color: root.line }
        ColumnLayout {
            anchors.fill: parent
            spacing: 14
            Text {
                Layout.fillWidth: true
                text: "确定从双方联系人列表中删除 " + appController.selectedPeerName + "？既有聊天记录仍保留在服务端。"
                wrapMode: Text.WordWrap
                color: root.textMuted
            }
            RowLayout {
                Layout.fillWidth: true
                GhostButton { Layout.fillWidth: true; text: "取消"; onClicked: removeFriendDialog.close() }
                GhostButton {
                    Layout.fillWidth: true
                    highlighted: true
                    text: "删除"
                    onClicked: {
                        appController.removeFriend(appController.selectedPeerAccount)
                        removeFriendDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: clearConversationDialog
        anchors.centerIn: parent
        modal: true
        title: "清空聊天记录"
        standardButtons: Dialog.NoButton
        background: Rectangle { radius: 18; color: root.panel; border.color: root.line }
        ColumnLayout {
            anchors.fill: parent
            spacing: 14
            Text {
                Layout.fillWidth: true
                text: "该操作会在服务端隐藏当前账号此前的会话记录，且无法撤销。"
                wrapMode: Text.WordWrap
                color: root.textMuted
            }
            RowLayout {
                Layout.fillWidth: true
                GhostButton { Layout.fillWidth: true; text: "取消"; onClicked: clearConversationDialog.close() }
                GhostButton {
                    Layout.fillWidth: true
                    highlighted: true
                    text: "确认清空"
                    onClicked: {
                        appController.clearCurrentConversation()
                        clearConversationDialog.close()
                    }
                }
            }
        }
    }

    Rectangle {
        id: toast
        visible: appController.toastMessage.length > 0
        z: 1000
        width: Math.min(520, toastText.implicitWidth + 56)
        height: 48
        radius: 14
        color: appController.toastError ? "#3b2029" : root.dark ? "#26324a" : "#182033"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        border.color: appController.toastError ? root.danger : "transparent"
        Text {
            id: toastText
            anchors.centerIn: parent
            text: appController.toastMessage
            color: "white"
            font.pixelSize: 13
        }
        Timer {
            interval: 3200
            running: toast.visible
            onTriggered: appController.clearToast()
        }
        MouseArea {
            anchors.fill: parent
            onClicked: appController.clearToast()
        }
    }
}
