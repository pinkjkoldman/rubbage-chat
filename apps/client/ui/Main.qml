import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Effects
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
    readonly property color bg: dark ? "#0f1115" : "#f6f5f3"
    readonly property color panel: dark ? "#171a20" : "#ffffff"
    readonly property color panelAlt: dark ? "#1f232c" : "#f0eeeb"
    readonly property color line: dark ? "#2c313d" : "#e4e1dc"
    readonly property color textMain: dark ? "#f6f7f9" : "#1c1f26"
    readonly property color textMuted: dark ? "#98a0af" : "#6d7280"
    readonly property color accent: dark ? "#6ea8ff" : "#2563eb"
    readonly property color accentDeep: "#1d4ed8"
    readonly property color accentSurface: "#2563eb"
    readonly property color accentGlow: "#4f8dff"
    readonly property color accentSoft: dark ? "#1b2a4d" : "#e7effe"
    readonly property color good: "#2fbf71"
    readonly property color danger: "#ef4444"
    readonly property color navBg: dark ? "#0b0d12" : "#15181f"
    readonly property color navHover: "#1d212b"
    readonly property color navSelected: "#2b303d"
    readonly property color navMuted: "#8a92a2"
    readonly property color accentText: "#ffffff"
    readonly property color auraA: dark ? "#16233f" : "#e3edff"
    readonly property color auraB: dark ? "#131c31" : "#e7e4ff"
    readonly property color auraC: dark ? "#122630" : "#dceff5"
    readonly property color glass: dark ? "#d9171a20" : "#e8ffffff"
    readonly property color glassLine: dark ? "#332c313d" : "#2ee4e1dc"
    readonly property int radiusControl: 14
    readonly property int radiusPanel: 24
    readonly property int radiusApp: 28
    readonly property int radiusCard: 20
    readonly property int radiusPill: 999
    readonly property int space1: 4
    readonly property int space2: 8
    readonly property int space3: 16
    readonly property int space4: 24
    readonly property int space5: 32
    readonly property int space6: 40
    readonly property int titleWeight: Font.Bold
    readonly property int bodyWeight: Font.Normal
    property int section: 0
    property int settingsCategory: 0
    property bool emojiOpen: false
    property var drafts: ({})
    property string editingMessageId: ""
    property string replyPreview: ""
    signal settingsSectionRequested(int index)

    function normalizedQuery(value) {
        return value.trim().toLowerCase()
    }

    function avatarHue(seed) {
        const s = String(seed || "")
        let h = 0
        for (let i = 0; i < s.length; ++i)
            h = (h * 31 + s.charCodeAt(i)) % 3600
        return (h % 360) / 360
    }

    function sidebarMatches(item, query, targetSection) {
        let needle = normalizedQuery(query)
        if (!needle.length)
            return true
        let searchable = (item.name || "") + " " + (item.account || "") + " "
            + (targetSection === 0 ? (item.lastMessage || "") : (item.signature || ""))
        return searchable.toLowerCase().includes(needle)
    }

    function sidebarMatchCount(items, query, targetSection) {
        let count = 0
        for (let i = 0; i < items.length; ++i) {
            if (sidebarMatches(items[i], query, targetSection))
                ++count
        }
        return count
    }

    function messageMatches(item, query) {
        let needle = normalizedQuery(query)
        return !needle.length || (item.body || "").toLowerCase().includes(needle)
    }

    function messageMatchCount(items, query) {
        let count = 0
        for (let i = 0; i < items.length; ++i) {
            if (messageMatches(items[i], query))
                ++count
        }
        return count
    }

    function deliveryLabel(status) {
        if (status === "queued")
            return "等待网络"
        if (status === "sending")
            return "发送中"
        if (status === "delivered")
            return "已送达"
        if (status === "read")
            return "已读"
        return "已发送"
    }

    function draftFor(account) {
        return drafts[account] || ""
    }

    function setDraft(account, value) {
        if (!account.length)
            return
        let next = Object.assign({}, drafts)
        if (value.trim().length)
            next[account] = value
        else
            delete next[account]
        drafts = next
    }

    function submitComposer(text, account) {
        if (editingMessageId.length) {
            appController.editMessage(editingMessageId, text)
            editingMessageId = ""
            return true
        }
        let sent = appController.sendMessage(text)
        if (sent)
            replyPreview = ""
        return sent
    }

    color: bg

    component PrimaryButton: Button {
        id: primaryButton
        implicitHeight: 48
        scale: down ? 0.975 : 1
        font.pixelSize: 14
        font.weight: root.titleWeight
        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
        contentItem: Text {
            text: primaryButton.text
            color: root.accentText
            font: primaryButton.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: root.radiusControl
            opacity: primaryButton.enabled ? 1 : 0.45
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0
                    color: primaryButton.down || primaryButton.hovered
                        ? root.accentDeep : root.accentSurface
                }
                GradientStop {
                    position: 1
                    color: primaryButton.down || primaryButton.hovered
                        ? root.accentSurface : root.accentGlow
                }
            }
        }
    }

    component GhostButton: Button {
        id: ghostButton
        implicitHeight: 40
        scale: down ? 0.975 : 1
        font.pixelSize: 13
        font.weight: root.bodyWeight
        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
        contentItem: Text {
            text: ghostButton.text
            color: ghostButton.highlighted ? root.danger : root.textMain
            font: ghostButton.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: root.radiusControl
            color: ghostButton.down
                ? root.line : ghostButton.hovered ? root.panelAlt : "transparent"
            border.color: ghostButton.highlighted ? root.accent : root.line
            border.width: ghostButton.highlighted ? 1.5 : 1
            Behavior on color { ColorAnimation { duration: 160 } }
            Behavior on border.color { ColorAnimation { duration: 160 } }
        }
    }

    component AppTextField: TextField {
        id: field
        implicitHeight: 48
        color: root.textMain
        placeholderTextColor: root.textMuted
        selectionColor: root.accent
        selectedTextColor: "white"
        leftPadding: root.space3
        rightPadding: root.space3
        font.pixelSize: 14
        font.weight: root.bodyWeight
        background: Rectangle {
            radius: root.radiusControl
            color: root.panelAlt
            border.color: field.activeFocus ? root.accent : root.line
            border.width: field.activeFocus ? 1.5 : 1
            Behavior on border.color { ColorAnimation { duration: 180 } }
            Behavior on color { ColorAnimation { duration: 180 } }
            states: State {
                name: "hover"
                when: field.hovered && !field.activeFocus
                PropertyChanges { target: field; background.color: root.panel }
            }
        }
    }

    component AppSwitch: Switch {
        id: appSwitch
        implicitWidth: 44
        implicitHeight: 24
        padding: 0
        contentItem: Item {}
        indicator: Rectangle {
            implicitWidth: 44
            implicitHeight: 24
            radius: 12
            color: appSwitch.checked ? root.accent : root.line
            Behavior on color { ColorAnimation { duration: 180 } }

            Rectangle {
                width: 20
                height: 20
                radius: 10
                y: 2
                x: appSwitch.checked ? 22 : 2
                color: root.accentText
                Behavior on x {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    component AppComboBox: ComboBox {
        id: appComboBox
        implicitWidth: 136
        implicitHeight: 40
        leftPadding: root.space3
        rightPadding: root.space5
        font.pixelSize: 13
        font.weight: root.bodyWeight
        contentItem: Text {
            text: appComboBox.displayText
            color: root.textMain
            font: appComboBox.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        indicator: Text {
            anchors.right: parent.right
            anchors.rightMargin: root.space3
            anchors.verticalCenter: parent.verticalCenter
            text: "⌄"
            color: root.textMuted
            font.pixelSize: 14
        }
        background: Rectangle {
            radius: root.radiusControl
            color: root.panelAlt
            border.color: appComboBox.activeFocus ? root.accent : root.line
        }
    }

    component DialogHeader: Label {
        required property string label
        text: label
        color: root.textMain
        font.pixelSize: 20
        font.weight: root.titleWeight
        leftPadding: root.space4
        rightPadding: root.space4
        topPadding: root.space4
        bottomPadding: root.space3
        background: Rectangle { color: root.panel }
    }

    component ElevatedSurface: Rectangle {
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.dark ? "#99000000" : "#260f172a"
            shadowOpacity: 0.7
            shadowBlur: 0.72
            shadowVerticalOffset: 8
        }
    }

    component AuroraBackdrop: Canvas {
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        onPaint: {
            const ctx = getContext("2d")
            if (!ctx)
                return
            ctx.reset()
            const w = width
            const h = height
            const base = ctx.createLinearGradient(0, 0, w, h)
            base.addColorStop(0, root.bg)
            base.addColorStop(1, root.auraB)
            ctx.fillStyle = base
            ctx.fillRect(0, 0, w, h)

            const orbs = [
                { x: w * 0.12, y: h * 0.10, r: Math.max(w, h) * 0.34, c: root.auraA },
                { x: w * 0.86, y: h * 0.16, r: Math.max(w, h) * 0.30, c: root.auraB },
                { x: w * 0.72, y: h * 0.82, r: Math.max(w, h) * 0.36, c: root.auraC }
            ]
            for (const orb of orbs) {
                ctx.globalAlpha = root.dark ? 0.42 : 0.72
                ctx.fillStyle = orb.c
                ctx.beginPath()
                ctx.arc(orb.x, orb.y, orb.r, 0, Math.PI * 2)
                ctx.fill()
            }
            ctx.globalAlpha = 1
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: appController
            function onSettingsChanged() { requestPaint() }
        }
    }

    component Avatar: Rectangle {
        id: avatarRoot
        property string label: "O"
        property string seed: label
        property bool online: false
        property int avatarSize: 44
        readonly property real hue: root.avatarHue(seed)
        width: avatarSize
        height: avatarSize
        radius: avatarSize / 2
        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.hsla(avatarRoot.hue, 0.62, root.dark ? 0.42 : 0.87, 1)
            }
            GradientStop {
                position: 1
                color: Qt.hsla((avatarRoot.hue + 0.07) % 1.0, 0.68,
                    root.dark ? 0.30 : 0.77, 1)
            }
        }
        Text {
            anchors.centerIn: parent
            text: avatarRoot.label.length
                ? avatarRoot.label.slice(0, 1).toUpperCase() : "O"
            color: root.dark
                ? Qt.hsla(avatarRoot.hue, 0.9, 0.82, 1)
                : Qt.hsla(avatarRoot.hue, 0.8, 0.30, 1)
            font.pixelSize: avatarRoot.avatarSize * 0.38
            font.weight: root.titleWeight
        }
        Rectangle {
            visible: avatarRoot.online && appController.showOnlineStatus
            width: Math.max(10, avatarRoot.avatarSize * 0.25)
            height: width
            radius: width / 2
            color: root.good
            border.color: root.panel
            border.width: 2
            anchors.right: avatarRoot.right
            anchors.bottom: avatarRoot.bottom
        }
    }

    component NavGlyph: Item {
        id: glyphRoot
        property string kind: "chat"
        property color glyphColor: "#ffffff"
        property int glyphSize: 20
        width: glyphSize
        height: glyphSize

        Canvas {
            id: glyphCanvas
            anchors.fill: parent
            antialiasing: true
            property color pen: glyphRoot.glyphColor
            property string shape: glyphRoot.kind
            property int span: glyphRoot.glyphSize
            onPenChanged: requestPaint()
            onShapeChanged: requestPaint()
            onSpanChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = pen
                ctx.fillStyle = pen
                ctx.lineWidth = Math.max(1.4, span * 0.085)
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                ctx.save()
                ctx.scale(span / 24, span / 24)

                if (shape === "chat") {
                    ctx.beginPath()
                    ctx.moveTo(7.5, 4.5)
                    ctx.lineTo(16.5, 4.5)
                    ctx.arcTo(21, 4.5, 21, 9, 4.5)
                    ctx.lineTo(21, 12.5)
                    ctx.arcTo(21, 17, 16.5, 17, 4.5)
                    ctx.lineTo(11, 17)
                    ctx.lineTo(7.5, 20.5)
                    ctx.lineTo(7.5, 17)
                    ctx.arcTo(3, 17, 3, 12.5, 4.5)
                    ctx.lineTo(3, 9)
                    ctx.arcTo(3, 4.5, 7.5, 4.5, 4.5)
                    ctx.closePath()
                    ctx.stroke()
                    var dots = [8.2, 12, 15.8]
                    for (var di = 0; di < dots.length; ++di) {
                        ctx.beginPath()
                        ctx.arc(dots[di], 10.8, 1.15, 0, Math.PI * 2)
                        ctx.fill()
                    }
                } else if (shape === "people") {
                    ctx.beginPath()
                    ctx.arc(12, 8.2, 3.7, 0, Math.PI * 2)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(12, 21.6, 6.8, Math.PI * 1.08, Math.PI * 1.92)
                    ctx.stroke()
                } else if (shape === "bell") {
                    ctx.beginPath()
                    ctx.moveTo(5.2, 16.5)
                    ctx.lineTo(5.2, 11)
                    ctx.bezierCurveTo(5.2, 5.8, 8.1, 3.6, 12, 3.6)
                    ctx.bezierCurveTo(15.9, 3.6, 18.8, 5.8, 18.8, 11)
                    ctx.lineTo(18.8, 16.5)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(3.6, 16.5)
                    ctx.lineTo(20.4, 16.5)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(12, 19.8, 1.5, 0, Math.PI * 2)
                    ctx.fill()
                } else if (shape === "gear") {
                    for (var t = 0; t < 8; ++t) {
                        var a = t * Math.PI / 4 + Math.PI / 8
                        ctx.beginPath()
                        ctx.moveTo(12 + Math.cos(a) * 7.4,
                            12 + Math.sin(a) * 7.4)
                        ctx.lineTo(12 + Math.cos(a) * 10.2,
                            12 + Math.sin(a) * 10.2)
                        ctx.stroke()
                    }
                    ctx.beginPath()
                    ctx.arc(12, 12, 7.4, 0, Math.PI * 2)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(12, 12, 3.1, 0, Math.PI * 2)
                    ctx.stroke()
                }
                ctx.restore()
            }
        }
    }

    Loader {
        id: rootLoader
        anchors.fill: parent
        sourceComponent: appController.authenticated ? shellComponent : authComponent
        opacity: status === Loader.Ready ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 220 }
        }
    }

    Component {
        id: authComponent

        Item {
            AuroraBackdrop {}

            Rectangle {
                width: parent.width * 0.46
                height: parent.height
                visible: parent.width >= 1040
                color: "transparent"

                Column {
                    anchors.centerIn: parent
                    width: Math.min(448, parent.width - 96)
                    spacing: root.space4

                    Row {
                        spacing: root.space3
                        ElevatedSurface {
                            width: 60
                            height: 60
                            radius: root.radiusCard
                            gradient: Gradient {
                                GradientStop { position: 0; color: root.accentSurface }
                                GradientStop { position: 1; color: root.accentGlow }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "R"
                                color: root.accentText
                                font.pixelSize: 26
                                font.weight: root.titleWeight
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: "RubbageChat"
                                color: root.textMain
                                font.pixelSize: 22
                                font.weight: root.titleWeight
                            }
                            Text {
                                text: "澄澈的对话空间"
                                color: root.textMuted
                                font.pixelSize: 12
                                font.weight: root.bodyWeight
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        text: "让每一次对话\n都清晰而自在"
                        color: root.textMain
                        font.pixelSize: 40
                        font.weight: root.titleWeight
                        lineHeight: 1.2
                    }
                    Text {
                        width: parent.width
                        text: "消息、联系人和设置都在同一个简洁空间里。"
                        color: root.textMuted
                        font.pixelSize: 16
                        font.weight: root.bodyWeight
                        wrapMode: Text.WordWrap
                    }
                    Row {
                        spacing: root.space2
                        Repeater {
                            model: ["实时消息", "离线送达", "MongoDB 历史"]
                            delegate: Rectangle {
                                height: 34
                                radius: root.radiusPill
                                color: root.glass
                                border.color: root.glassLine
                                Row {
                                    anchors.centerIn: parent
                                    spacing: root.space2
                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: root.accentSurface
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: root.accentText
                                            font.pixelSize: 11
                                        }
                                    }
                                    Text {
                                        text: modelData
                                        color: root.textMuted
                                        font.pixelSize: 13
                                        font.weight: root.bodyWeight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ElevatedSurface {
                id: authCard
                width: Math.min(436, parent.width - 64)
                height: authMode === 0 ? 544 : 636
                radius: root.radiusApp
                color: root.glass
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: parent.width >= 1040
                    ? Math.max(72, (parent.width * 0.54 - width) / 2)
                    : (parent.width - width) / 2
                border.color: root.glassLine
                border.width: 1

                Rectangle {
                    width: 52
                    height: 4
                    radius: 2
                    color: root.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 14
                }

                property int authMode: 0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.space6
                    spacing: root.space3

                    Text {
                        Layout.topMargin: root.space2
                        text: authCard.authMode === 0 ? "欢迎回来" : "创建 RubbageChat 账号"
                        color: root.textMain
                        font.pixelSize: 28
                        font.weight: root.titleWeight
                    }
                    Text {
                        text: authCard.authMode === 0 ? "登录后继续你的对话" : "注册后会获得一个 9 位账号"
                        color: root.textMuted
                        font.pixelSize: 14
                        font.weight: root.bodyWeight
                    }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: root.space2
                            spacing: root.space2
                            Repeater {
                                model: ["登录", "注册"]
                                delegate: Button {
                                    id: authModeButton
                                    Layout.fillWidth: true
                                    implicitHeight: 40
                                    text: modelData
                                    contentItem: Text {
                                        text: authModeButton.text
                                        color: authCard.authMode === index ? root.accent : root.textMuted
                                        font.weight: authCard.authMode === index
                                            ? root.titleWeight : root.bodyWeight
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        radius: root.radiusControl
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
                            Layout.topMargin: root.space2
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
                            font.weight: root.bodyWeight
                        }
                        Item { Layout.fillHeight: true }
                        Text {
                            Layout.fillWidth: true
                            text: "账号、好友与聊天数据由服务端 MongoDB 统一保存"
                            color: root.textMuted
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 12
                            font.weight: root.bodyWeight
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

    Component {
        id: shellComponent

        Item {
            AuroraBackdrop {}

            Rectangle {
                id: appFrame
                anchors.fill: parent
                anchors.margins: 14
                radius: root.radiusApp
                color: root.panel
                border.color: root.line
                border.width: 1
                clip: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.dark ? "#a0000000" : "#30101824"
                    shadowOpacity: 0.75
                    shadowBlur: 0.85
                    shadowVerticalOffset: 12
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.leftMargin: 12
                        Layout.topMargin: 12
                        Layout.bottomMargin: 12
                        Layout.rightMargin: 12
                        Layout.preferredWidth: 88
                        Layout.fillHeight: true
                        radius: root.radiusCard
                        color: root.panelAlt
                        border.color: root.line
                        border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: root.space4
                    anchors.bottomMargin: root.space4
                    spacing: root.space2

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: root.radiusControl
                        gradient: Gradient {
                            GradientStop { position: 0; color: root.accentSurface }
                            GradientStop { position: 1; color: root.accentGlow }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: appController.currentUserName.slice(0, 1).toUpperCase()
                            color: root.accentText
                            font.pixelSize: 19
                            font.weight: root.titleWeight
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: profileDialog.open()
                        }
                        ToolTip.visible: containsMouse
                        ToolTip.text: "编辑个人资料"
                    }

                    Item {
                        Layout.preferredHeight: root.space3
                        Layout.preferredWidth: 1
                    }

                    Repeater {
                        model: [
                            {kind: "chat", label: "消息"},
                            {kind: "people", label: "联系人"},
                            {kind: "bell", label: "通知"},
                            {kind: "gear", label: "设置"}
                        ]
                        delegate: Item {
                            Layout.alignment: Qt.AlignHCenter
                            width: 64
                            height: 56

                            Rectangle {
                                anchors.fill: parent
                                radius: root.radiusControl
                                color: root.section === index
                                    ? root.navSelected
                                    : navMouse.containsMouse ? root.navHover : "transparent"
                                Behavior on color { ColorAnimation { duration: 180 } }
                            }
                            Rectangle {
                                visible: root.section === index
                                width: 3
                                height: 24
                                radius: 2
                                anchors.left: parent.left
                                anchors.leftMargin: 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.accent
                            }
                            NavGlyph {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: root.space2
                                kind: modelData.kind
                                glyphSize: 20
                                glyphColor: root.section === index
                                    ? root.accentText : root.navMuted
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: root.space2
                                text: modelData.label
                                color: root.section === index
                                    ? root.accentText : root.navMuted
                                font.pixelSize: 10
                                font.weight: root.bodyWeight
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
                                    color: root.accentText
                                    font.pixelSize: 10
                                    font.weight: root.titleWeight
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
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 32
                        radius: root.radiusControl
                        color: root.navSelected
                        Row {
                            anchors.centerIn: parent
                            spacing: root.space1
                            Rectangle {
                                width: 7
                                height: 7
                                radius: 4
                                color: appController.connected ? root.good : root.danger
                            }
                            Text {
                                text: appController.connected ? "在线" : "重连"
                                color: root.accentText
                                font.pixelSize: 10
                                font.weight: root.bodyWeight
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                Layout.rightMargin: 12
                Layout.preferredWidth: root.section === 3 ? 280 : 336
                Layout.fillHeight: true
                radius: root.radiusCard
                color: root.glass
                border.color: root.glassLine
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.space4
                    spacing: root.space3

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: ["消息", "联系人", "通知", "设置"][root.section]
                            color: root.textMain
                            font.pixelSize: 24
                            font.weight: root.titleWeight
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            id: addFriendButton
                            visible: root.section === 1
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            text: "+"
                            font.pixelSize: 22
                            contentItem: Text {
                                text: addFriendButton.text
                                color: root.accentText
                                font: addFriendButton.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: root.radiusControl
                                color: addFriendButton.hovered
                                    ? root.accentDeep : root.accentSurface
                            }
                            onClicked: addFriendDialog.open()
                            ToolTip.visible: hovered
                            ToolTip.text: "添加好友"
                        }
                    }

                    AppTextField {
                        id: sidebarSearch
                        visible: root.section < 2
                        Layout.fillWidth: true
                        implicitHeight: 44
                        placeholderText: root.section === 0 ? "搜索会话" : "搜索联系人"
                        rightPadding: text.length ? 40 : 14

                        Button {
                            id: clearSidebarSearchButton
                            visible: sidebarSearch.text.length > 0
                            anchors.right: parent.right
                            anchors.rightMargin: root.space2
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28
                            height: 28
                            text: "×"
                            contentItem: Text {
                                text: clearSidebarSearchButton.text
                                color: root.textMuted
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: root.radiusControl
                                color: clearSidebarSearchButton.hovered
                                    ? root.line : "transparent"
                            }
                            onClicked: sidebarSearch.clear()
                        }
                    }

                    ListView {
                        id: sidebarList
                        visible: root.section < 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: root.space1
                        model: root.section === 0 ? appController.conversations : appController.contacts

                        delegate: Item {
                            width: sidebarList.width
                            height: delegateVisible ? (appController.compactMode ? 64 : 80) : 0
                            visible: delegateVisible
                            property bool delegateVisible: root.sidebarMatches(
                                modelData, sidebarSearch.text, root.section)

                            Rectangle {
                                anchors.fill: parent
                                radius: root.radiusControl
                                color: appController.selectedPeerAccount === modelData.account
                                    ? root.accentSoft : itemMouse.containsMouse ? root.panelAlt : "transparent"
                                Behavior on color { ColorAnimation { duration: 180 } }
                            }
                            Rectangle {
                                visible: appController.selectedPeerAccount === modelData.account
                                width: 3
                                height: 28
                                radius: 2
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.accent
                            }
                            Avatar {
                                anchors.left: parent.left
                                anchors.leftMargin: root.space2
                                anchors.verticalCenter: parent.verticalCenter
                                avatarSize: appController.compactMode ? 38 : 44
                                label: modelData.initial
                                seed: modelData.account
                                online: modelData.online
                            }
                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: appController.compactMode ? 56 : 64
                                anchors.right: parent.right
                                anchors.rightMargin: root.space2
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: root.space1
                                Row {
                                    width: parent.width
                                    spacing: root.space2
                                    Text {
                                        width: parent.width - 56
                                        text: (modelData.pinned ? "⌃ " : "") + modelData.name
                                        color: root.textMain
                                        font.pixelSize: 14
                                        font.weight: root.titleWeight
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        visible: root.section === 0
                                        width: 50
                                        text: modelData.time
                                        color: root.textMuted
                                        font.pixelSize: 10
                                        font.weight: root.bodyWeight
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                                Row {
                                    width: parent.width
                                     Text {
                                         width: parent.width - 28
                                         text: root.section === 0
                                             ? (root.draftFor(modelData.account).length
                                                 ? "草稿：" + root.draftFor(modelData.account).trim()
                                                 : modelData.lastMessage)
                                             : modelData.online ? "在线" : modelData.signature
                                         color: root.section === 0
                                             && root.draftFor(modelData.account).length
                                             ? root.textMain : root.textMuted
                                        font.pixelSize: 12
                                        font.weight: root.bodyWeight
                                        elide: Text.ElideRight
                                    }
                                    Rectangle {
                                        visible: root.section === 0 && modelData.unread > 0
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: modelData.muted
                                            ? root.textMuted : root.accentSurface
                                        Text {
                                            anchors.centerIn: parent
                                            text: Math.min(99, modelData.unread)
                                            color: root.accentText
                                            font.pixelSize: 10
                                            font.weight: root.titleWeight
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
                                spacing: root.space2
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.section === 0 ? "还没有会话" : "还没有联系人"
                                    color: root.textMain
                                    font.pixelSize: 15
                                    font.weight: root.titleWeight
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.section === 0 ? "添加好友后开始聊天" : "点击右上角 + 添加好友"
                                    color: root.textMuted
                                    font.pixelSize: 12
                                    font.weight: root.bodyWeight
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: root.space2
                            visible: sidebarSearch.text.length > 0
                                && sidebarList.count > 0
                                && root.sidebarMatchCount(sidebarList.model,
                                    sidebarSearch.text, root.section) === 0
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "没有匹配结果"
                                color: root.textMain
                                font.pixelSize: 15
                                font.weight: root.titleWeight
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "试试昵称、账号或消息内容"
                                color: root.textMuted
                                font.pixelSize: 12
                                font.weight: root.bodyWeight
                            }
                            GhostButton {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "清除搜索"
                                onClicked: sidebarSearch.clear()
                            }
                        }
                    }

                    Shortcut {
                        sequence: "Ctrl+K"
                        enabled: root.section < 2
                        onActivated: sidebarSearch.forceActiveFocus()
                    }

                    ColumnLayout {
                        visible: root.section === 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: root.space3
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 88
                            radius: root.radiusControl
                            color: root.panelAlt
                            Column {
                                anchors.fill: parent
                                anchors.margins: root.space3
                                spacing: root.space2
                                Text {
                                    text: appController.notificationCount + " 条待处理"
                                    color: root.textMain
                                    font.pixelSize: 16
                                    font.weight: root.titleWeight
                                }
                                Text {
                                    text: "好友申请会离线保存"
                                    color: root.textMuted
                                    font.pixelSize: 12
                                    font.weight: root.bodyWeight
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }

                    ColumnLayout {
                        visible: root.section === 3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: root.space2

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: root.radiusControl
                            color: root.panelAlt
                            Row {
                                anchors.fill: parent
                                anchors.margins: root.space3
                                spacing: root.space3
                                Avatar {
                                    avatarSize: 48
                                    label: appController.currentUserName
                                    seed: appController.currentUserAccount
                                    online: appController.connected
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 150
                                    spacing: root.space1
                                    Text {
                                        text: appController.currentUserName
                                        color: root.textMain
                                        font.pixelSize: 15
                                        font.weight: root.titleWeight
                                    }
                                    Text {
                                        text: appController.currentUserAccount
                                        color: root.textMuted
                                        font.pixelSize: 11
                                        font.weight: root.bodyWeight
                                    }
                                    Text {
                                        width: parent.width
                                        text: appController.currentUserSignature
                                        color: root.textMuted
                                        font.pixelSize: 11
                                        font.weight: root.bodyWeight
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
                            model: ["外观", "聊天", "通知", "隐私", "账号"]
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 48
                                radius: root.radiusControl
                                color: root.settingsCategory === index
                                    ? root.accentSoft
                                    : settingsMouse.containsMouse ? root.panelAlt : "transparent"
                                Behavior on color { ColorAnimation { duration: 160 } }
                                Rectangle {
                                    width: 3
                                    height: 24
                                    radius: 2
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: root.accent
                                    opacity: root.settingsCategory === index ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 160 } }
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: root.space3
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData
                                    color: root.settingsCategory === index ? root.accent : root.textMain
                                    font.pixelSize: 13
                                    font.weight: root.settingsCategory === index
                                        ? root.titleWeight : root.bodyWeight
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: root.space3
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "›"
                                    color: root.settingsCategory === index ? root.accent : root.textMuted
                                    font.pixelSize: 20
                                }
                                MouseArea {
                                    id: settingsMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.settingsSectionRequested(index)
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
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                Layout.rightMargin: 12
                radius: root.radiusCard
                color: root.bg
                clip: true

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    sourceComponent: root.section === 0 ? chatView
                        : root.section === 1 ? contactView
                        : root.section === 2 ? requestView
                        : settingsComponent
                    opacity: status === Loader.Ready ? 1 : 0
                    transform: Translate {
                        y: contentLoader.status === Loader.Ready ? 0 : 8
                        Behavior on y {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }
                }
            }
                }
            }
        }
    }

    Component {
        id: chatView
        Item {
            id: chatPage
            property bool messageSearchOpen: false

            Column {
                anchors.centerIn: parent
                spacing: root.space3
                visible: !appController.selectedPeerAccount.length
                ElevatedSurface {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 88
                    height: 88
                    radius: root.radiusCard
                    gradient: Gradient {
                        GradientStop { position: 0; color: root.accentSurface }
                        GradientStop { position: 1; color: root.accentGlow }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "R"
                        color: root.accentText
                        font.pixelSize: 34
                        font.weight: root.titleWeight
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "选择一个联系人开始聊天"
                    color: root.textMain
                    font.pixelSize: 18
                    font.weight: root.titleWeight
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "消息会先写入服务端 MongoDB，对方上线后可读取完整历史"
                    color: root.textMuted
                    font.pixelSize: 13
                    font.weight: root.bodyWeight
                }
            }

            ColumnLayout {
                anchors.fill: parent
                visible: appController.selectedPeerAccount.length > 0
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: root.panel
                    border.color: root.line
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.space4
                        anchors.rightMargin: root.space4
                        Avatar {
                            avatarSize: 42
                            label: appController.selectedPeerName
                            seed: appController.selectedPeerAccount
                            online: appController.selectedPeerOnline
                        }
                        ColumnLayout {
                            Layout.leftMargin: root.space2
                            spacing: root.space1
                            Text {
                                text: appController.selectedPeerName
                                color: root.textMain
                                font.pixelSize: 16
                                font.weight: root.titleWeight
                            }
                            Text {
                                text: appController.selectedPeerOnline ? "在线" : "离线"
                                color: appController.selectedPeerOnline ? root.good : root.textMuted
                                font.pixelSize: 11
                                font.weight: root.bodyWeight
                            }
                        }
                        Item { Layout.fillWidth: true }
                        GhostButton {
                            text: "⌕"
                            Layout.preferredWidth: 42
                            highlighted: chatPage.messageSearchOpen
                            onClicked: {
                                chatPage.messageSearchOpen = !chatPage.messageSearchOpen
                                if (chatPage.messageSearchOpen)
                                    Qt.callLater(function() { messageSearch.forceActiveFocus() })
                                else
                                    messageSearch.clear()
                            }
                            ToolTip.visible: hovered
                            ToolTip.text: "搜索聊天记录（Ctrl+F）"
                        }
                        GhostButton {
                            text: "⋯"
                            Layout.preferredWidth: 42
                            onClicked: {
                                conversationMenu.peerAccount = appController.selectedPeerAccount
                                conversationMenu.popup()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    implicitHeight: chatPage.messageSearchOpen ? 64 : 0
                    opacity: chatPage.messageSearchOpen ? 1 : 0
                    enabled: chatPage.messageSearchOpen
                    clip: true
                    color: root.panel
                    border.color: root.line
                    Behavior on implicitHeight {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 160 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.space4
                        anchors.rightMargin: root.space4
                        spacing: root.space2

                        AppTextField {
                            id: messageSearch
                            Layout.fillWidth: true
                            implicitHeight: 40
                            placeholderText: "搜索当前聊天记录"
                            onAccepted: messageList.positionViewAtBeginning()
                        }
                        Text {
                            text: messageSearch.text.length
                                ? root.messageMatchCount(appController.messages,
                                    messageSearch.text) + " 条"
                                : appController.messages.length + " 条消息"
                            color: root.textMuted
                            font.pixelSize: 12
                            font.weight: root.bodyWeight
                        }
                        GhostButton {
                            text: "关闭"
                            onClicked: {
                                messageSearch.clear()
                                chatPage.messageSearchOpen = false
                            }
                        }
                    }
                }

                ListView {
                    id: messageList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: root.space4
                    spacing: root.space2
                    clip: true
                    model: appController.messages

                    delegate: Item {
                        id: messageRow
                        width: messageList.width
                        height: messageVisible
                            ? dayHeader.height + bubble.height
                                + (reactionBadge.visible ? reactionBadge.height + 4 : 0)
                                + root.space3
                            : 0
                        visible: messageVisible
                        opacity: 0
                        transform: Translate { id: messageShift; y: 6 }
                        property bool messageVisible: !chatPage.messageSearchOpen
                            || root.messageMatches(modelData, messageSearch.text)
                        property bool showDayHeader: messageVisible
                            && (modelData.dayLabel || "").length > 0
                            && (index === 0
                                || (appController.messages[index - 1].dayLabel || "")
                                    !== modelData.dayLabel)
                        Component.onCompleted: messageEntrance.start()
                        ParallelAnimation {
                            id: messageEntrance
                            NumberAnimation {
                                target: messageRow
                                property: "opacity"
                                to: 1
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: messageShift
                                property: "y"
                                to: 0
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            id: dayHeader
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            height: messageRow.showDayHeader ? 32 : 0
                            visible: messageRow.showDayHeader
                            text: modelData.dayLabel || ""
                            color: root.textMuted
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 11
                            font.weight: root.bodyWeight
                        }

                        Rectangle {
                            id: bubble
                            anchors.top: dayHeader.bottom
                            anchors.right: modelData.mine ? parent.right : undefined
                            anchors.left: modelData.mine ? undefined : parent.left
                            width: Math.min(Math.max(96,
                                Math.max(messageText.implicitWidth,
                                    replyPreviewText.implicitWidth) + 32),
                                parent.width * 0.68)
                            height: bubbleContent.implicitHeight + 20
                            radius: 18
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop {
                                    position: 0
                                    color: modelData.mine ? root.accentSurface : root.panel
                                }
                                GradientStop {
                                    position: 1
                                    color: modelData.mine ? root.accentGlow : root.panel
                                }
                            }
                            border.color: chatPage.messageSearchOpen
                                && messageSearch.text.length
                                ? root.accent
                                : modelData.mine ? root.accent : root.line
                            border.width: chatPage.messageSearchOpen
                                && messageSearch.text.length ? 2 : 1
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: root.dark ? "#66000000" : "#160f172a"
                                shadowOpacity: 0.65
                                shadowBlur: 0.4
                                shadowVerticalOffset: 3
                            }

                            Column {
                                id: bubbleContent
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: root.space2

                                Rectangle {
                                    width: parent.width
                                    height: visible ? replyPreviewText.implicitHeight + 16 : 0
                                    visible: (modelData.replyPreview || "").length > 0
                                    radius: root.radiusControl
                                    color: modelData.mine ? "#22ffffff" : root.panelAlt

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: 3
                                        radius: 2
                                        color: modelData.mine ? "#aaffffff" : root.accent
                                    }
                                    Text {
                                        id: replyPreviewText
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 8
                                        anchors.topMargin: 8
                                        anchors.bottomMargin: 8
                                        text: modelData.replyPreview || ""
                                        color: modelData.mine ? root.accentText : root.textMuted
                                        opacity: modelData.mine ? 0.82 : 1
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        wrapMode: Text.Wrap
                                        font.pixelSize: 11
                                        font.weight: root.bodyWeight
                                    }
                                }

                                Text {
                                    id: messageText
                                    width: parent.width
                                    text: modelData.body
                                    color: modelData.mine ? root.accentText : root.textMain
                                    font.pixelSize: 14
                                    font.weight: root.bodyWeight
                                    wrapMode: Text.Wrap
                                }

                                RowLayout {
                                    width: parent.width
                                    height: 12
                                    spacing: root.space1

                                    Text {
                                        visible: modelData.edited
                                        text: "已编辑"
                                        color: modelData.mine ? root.accentText : root.textMuted
                                        opacity: modelData.mine ? 0.7 : 1
                                        font.pixelSize: 9
                                        font.weight: root.bodyWeight
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: modelData.time
                                            + (modelData.mine && !modelData.recalled
                                                ? " · " + root.deliveryLabel(modelData.status)
                                                : "")
                                        color: modelData.mine ? root.accentText : root.textMuted
                                        opacity: modelData.mine ? 0.72 : 1
                                        font.pixelSize: 9
                                        font.weight: root.bodyWeight
                                    }
                                }
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
                            TapHandler {
                                acceptedButtons: Qt.RightButton
                                onTapped: function(eventPoint, button) {
                                    messageMenu.messageBody = modelData.body
                                    messageMenu.messageId = modelData.id || ""
                                    messageMenu.mine = modelData.mine || false
                                    messageMenu.recalled = modelData.recalled || false
                                    messageMenu.canDownload = modelData.type === "file"
                                        && modelData.attachmentId.length > 0
                                    messageMenu.attachmentId = modelData.attachmentId || ""
                                    messageMenu.popup()
                                }
                            }
                        }

                        Rectangle {
                            id: bubbleTail
                            visible: !modelData.recalled
                            width: 14
                            height: 14
                            radius: 4
                            rotation: modelData.mine ? 45 : -45
                            color: modelData.mine ? root.accentGlow : root.panel
                            z: -1
                            anchors.top: bubble.top
                            anchors.topMargin: 14
                            anchors.right: modelData.mine ? bubble.right : undefined
                            anchors.rightMargin: modelData.mine ? -7 : 0
                            anchors.left: modelData.mine ? undefined : bubble.left
                            anchors.leftMargin: modelData.mine ? 0 : -7
                        }

                        Rectangle {
                            id: reactionBadge
                            anchors.top: bubble.bottom
                            anchors.topMargin: -4
                            anchors.right: modelData.mine ? bubble.right : undefined
                            anchors.left: modelData.mine ? undefined : bubble.left
                            visible: (modelData.reactionSummary || "").length > 0
                            width: reactionText.implicitWidth + 18
                            height: visible ? 26 : 0
                            radius: 13
                            color: root.panel
                            border.color: root.line

                            Text {
                                id: reactionText
                                anchors.centerIn: parent
                                text: modelData.reactionSummary || ""
                                color: root.textMain
                                font.pixelSize: 12
                                font.weight: root.bodyWeight
                            }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: root.space2
                        visible: chatPage.messageSearchOpen
                            && messageSearch.text.length > 0
                            && root.messageMatchCount(appController.messages,
                                messageSearch.text) === 0
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "没有找到相关消息"
                            color: root.textMain
                            font.pixelSize: 15
                            font.weight: root.titleWeight
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "换一个关键词试试"
                            color: root.textMuted
                            font.pixelSize: 12
                            font.weight: root.bodyWeight
                        }
                    }

                    onCountChanged: Qt.callLater(function() { positionViewAtEnd() })
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.emojiOpen ? 200 : 160
                    color: root.panel
                    border.color: root.line

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: root.space3
                        spacing: root.space2

                        Flow {
                            visible: root.emojiOpen
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 40 : 0
                            spacing: root.space2
                            Repeater {
                                model: ["😀", "😂", "🥰", "😎", "👍", "🎉", "❤️", "🙏"]
                                delegate: Button {
                                    id: emojiButton
                                    width: 40
                                    height: 40
                                    text: modelData
                                    font.pixelSize: 18
                                    background: Rectangle {
                                        radius: root.radiusControl
                                        color: emojiButton.hovered
                                            ? root.panelAlt : "transparent"
                                    }
                                    onClicked: composer.insert(composer.cursorPosition, modelData)
                                }
                            }
                        }

                        RowLayout {
                            visible: root.editingMessageId.length > 0
                                || root.replyPreview.length > 0
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 36 : 0
                            Layout.leftMargin: 14
                            Layout.rightMargin: 14
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: root.radiusControl
                                color: root.accentSoft
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: root.space2
                                    text: root.editingMessageId.length
                                        ? "正在编辑消息"
                                        : "回复：" + root.replyPreview
                                    elide: Text.ElideRight
                                    color: root.textMain
                                    font.pixelSize: 12
                                    font.weight: root.bodyWeight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            GhostButton {
                                text: "取消"
                                Layout.preferredWidth: 64
                                onClicked: {
                                    root.editingMessageId = ""
                                    root.replyPreview = ""
                                    appController.clearReply()
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 14
                            Layout.rightMargin: 14
                            Layout.topMargin: 4
                            Layout.bottomMargin: 8
                            spacing: root.space2

                            Button {
                                id: attachmentButton
                                text: "＋"
                                Layout.preferredWidth: 40
                                Layout.alignment: Qt.AlignBottom
                                enabled: !appController.fileTransferActive
                                contentItem: Text {
                                    text: attachmentButton.text
                                    color: root.textMuted
                                    font.pixelSize: 21
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: root.radiusControl
                                    color: attachmentButton.hovered
                                        ? root.panelAlt : "transparent"
                                }
                                onClicked: attachmentDialog.open()
                                ToolTip.visible: hovered
                                ToolTip.text: "发送文件（最大 6 MB）"
                            }
                            Button {
                                id: emojiToggleButton
                                text: "☺"
                                Layout.preferredWidth: 40
                                Layout.alignment: Qt.AlignBottom
                                contentItem: Text {
                                    text: emojiToggleButton.text
                                    color: root.textMuted
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: root.radiusControl
                                    color: emojiToggleButton.hovered
                                        ? root.panelAlt : "transparent"
                                }
                                onClicked: root.emojiOpen = !root.emojiOpen
                                ToolTip.visible: hovered
                                ToolTip.text: "表情"
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                TextArea {
                                    id: composer
                                    property string draftAccount: ""
                                    placeholderText: appController.enterToSend
                                        ? "输入消息，Enter 发送，Shift+Enter 换行"
                                        : "输入消息，Ctrl+Enter 发送"
                                    color: root.textMain
                                    placeholderTextColor: root.textMuted
                                    font.pixelSize: 14
                                    font.weight: root.bodyWeight
                            wrapMode: TextArea.Wrap
                            background: Rectangle {
                                color: root.panel
                                radius: root.radiusControl
                                border.color: composer.activeFocus ? root.accent : root.line
                                border.width: composer.activeFocus ? 1.5 : 1
                            }
                                    onTextChanged: root.setDraft(draftAccount, text)
                                    Keys.onPressed: function(event) {
                                        let enter = event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                        let shouldSend = appController.enterToSend
                                            ? enter && !(event.modifiers & Qt.ShiftModifier)
                                            : enter && (event.modifiers & Qt.ControlModifier)
                                        if (shouldSend) {
                                            if (root.submitComposer(text, draftAccount)) {
                                                text = ""
                                                root.setDraft(draftAccount, "")
                                            }
                                            event.accepted = true
                                        }
                                    }

                                    Connections {
                                        target: appController
                                        function onSelectedPeerChanged() {
                                            composer.draftAccount =
                                                appController.selectedPeerAccount
                                            composer.text = root.draftFor(
                                                composer.draftAccount)
                                            Qt.callLater(function() {
                                                composer.cursorPosition =
                                                    composer.length
                                            })
                                        }
                                    }

                                    Component.onCompleted: {
                                        draftAccount = appController.selectedPeerAccount
                                        text = root.draftFor(draftAccount)
                                    }
                                }
                            }
                            PrimaryButton {
                                text: "发送"
                                Layout.preferredWidth: 74
                                Layout.alignment: Qt.AlignBottom
                                enabled: composer.text.trim().length > 0
                                    && composer.length <= 4000
                                onClicked: {
                                    if (root.submitComposer(composer.text,
                                            composer.draftAccount)) {
                                        composer.text = ""
                                        root.setDraft(composer.draftAccount, "")
                                        composer.forceActiveFocus()
                                    }
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 16
                            Layout.leftMargin: 14
                            Layout.rightMargin: 14
                            Layout.bottomMargin: 8
                            Text {
                                text: root.draftFor(appController.selectedPeerAccount).length
                                    ? "草稿已保留"
                                    : "消息将同步到所有登录会话"
                                color: root.textMuted
                                font.pixelSize: 10
                                font.weight: root.bodyWeight
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: composer.length + " / 4000"
                                color: composer.length > 4000
                                    ? root.danger : root.textMuted
                                font.pixelSize: 10
                                font.weight: root.bodyWeight
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
                                font.weight: root.bodyWeight
                            }
                            ProgressBar {
                                Layout.fillWidth: true
                                value: appController.fileTransferProgress
                            }
                            Text {
                                text: Math.round(appController.fileTransferProgress * 100) + "%"
                                color: root.textMuted
                                font.pixelSize: 10
                                font.weight: root.bodyWeight
                            }
                        }
                    }
                }
            }

            Shortcut {
                sequence: StandardKey.Find
                onActivated: {
                    chatPage.messageSearchOpen = true
                    Qt.callLater(function() { messageSearch.forceActiveFocus() })
                }
            }
            Shortcut {
                sequence: "Escape"
                enabled: chatPage.messageSearchOpen
                onActivated: {
                    messageSearch.clear()
                    chatPage.messageSearchOpen = false
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
                spacing: root.space3
                visible: !appController.selectedPeerAccount.length
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "联系人"
                    color: root.textMain
                    font.pixelSize: 24
                    font.weight: root.titleWeight
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "从左侧选择联系人，或添加新的好友"
                    color: root.textMuted
                    font.pixelSize: 14
                    font.weight: root.bodyWeight
                }
                PrimaryButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 136
                    text: "添加好友"
                    onClicked: addFriendDialog.open()
                }
            }

            ElevatedSurface {
                visible: appController.selectedPeerAccount.length > 0
                anchors.centerIn: parent
                width: 448
                height: 424
                radius: root.radiusPanel
                color: root.panel
                border.color: root.line
                Column {
                    anchors.fill: parent
                    anchors.margins: root.space5
                    spacing: root.space4
                    Avatar {
                        anchors.horizontalCenter: parent.horizontalCenter
                        avatarSize: 88
                        label: appController.selectedPeerName
                        seed: appController.selectedPeerAccount
                        online: appController.selectedPeerOnline
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: appController.selectedPeerName
                        color: root.textMain
                        font.pixelSize: 24
                        font.weight: root.titleWeight
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "账号 " + appController.selectedPeerAccount
                        color: root.textMuted
                        font.pixelSize: 13
                        font.weight: root.bodyWeight
                    }
                    Rectangle { width: parent.width; height: 1; color: root.line }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: root.space2
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
                anchors.margins: root.space5
                spacing: root.space3

                Text {
                    text: "好友申请"
                    color: root.textMain
                    font.pixelSize: 24
                    font.weight: root.titleWeight
                }
                Text {
                    text: "接受后，双方联系人列表会自动更新。"
                    color: root.textMuted
                    font.pixelSize: 13
                    font.weight: root.bodyWeight
                }
                ListView {
                    id: requestsList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: root.space3
                    clip: true
                    spacing: root.space2
                    model: appController.requests
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 88
                        radius: root.radiusControl
                        color: root.panel
                        border.color: root.line
                        Avatar {
                            anchors.left: parent.left
                            anchors.leftMargin: root.space3
                            anchors.verticalCenter: parent.verticalCenter
                            label: modelData.initial
                            seed: modelData.account
                            online: modelData.online
                        }
                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 76
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: root.space1
                            Text {
                                text: modelData.name
                                color: root.textMain
                                font.pixelSize: 15
                                font.weight: root.titleWeight
                            }
                            Text {
                                text: modelData.account + " · " + modelData.signature
                                color: root.textMuted
                                font.pixelSize: 12
                                font.weight: root.bodyWeight
                            }
                        }
                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: root.space3
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
                        height: requestsList.count === 0 ? 200 : 0
                        Text {
                            anchors.centerIn: parent
                            text: "没有待处理的好友申请"
                            color: root.textMuted
                            font.pixelSize: 14
                            font.weight: root.bodyWeight
                        }
                    }
                }
            }
        }
    }

    Component {
        id: settingsComponent
        Item {
            id: settingsPage

            ListView {
                id: settingsView
                anchors.fill: parent
                clip: true
                interactive: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 2600
                spacing: root.space5
                model: [
                    {title: "外观", subtitle: "主题与信息密度", kind: "appearance", badge: "外"},
                    {title: "聊天", subtitle: "消息发送方式", kind: "chat", badge: "聊"},
                    {title: "通知", subtitle: "控制新消息提醒", kind: "notifications", badge: "通"},
                    {title: "隐私", subtitle: "在线状态与服务端数据", kind: "privacy", badge: "隐"},
                    {title: "账号", subtitle: "个人资料与切换账号", kind: "account", badge: "账"}
                ]

                function scrollToSection(index) {
                    root.settingsCategory = index
                    settingsScrollAnimation.stop()
                    const previousPosition = contentY
                    positionViewAtIndex(index, ListView.Beginning)
                    const targetPosition = contentY
                    contentY = previousPosition
                    settingsScrollAnimation.from = previousPosition
                    settingsScrollAnimation.to = targetPosition
                    settingsScrollAnimation.start()
                }

                function updateVisibleCategory() {
                    const selected = indexAt(width / 2,
                        contentY + Math.min(160, height * 0.28))
                    if (selected >= 0)
                        root.settingsCategory = selected
                }

                onMovementEnded: updateVisibleCategory()
                onFlickEnded: updateVisibleCategory()

                NumberAnimation {
                    id: settingsScrollAnimation
                    target: settingsView
                    property: "contentY"
                    duration: 220
                    easing.type: Easing.OutCubic
                }

                Connections {
                    target: root
                    function onSettingsSectionRequested(index) {
                        settingsView.scrollToSection(index)
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 8
                }

                header: Item {
                    id: settingsHeader
                    width: settingsView.width
                    height: 120

                    Column {
                        width: Math.min(768, parent.width - 64)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: root.space5
                        spacing: root.space1

                        Text {
                            text: "偏好设置"
                            color: root.textMain
                            font.pixelSize: 24
                            font.weight: root.titleWeight
                        }
                        Text {
                            text: "所有更改都会自动保存在这台设备上"
                            color: root.textMuted
                            font.pixelSize: 12
                            font.weight: root.bodyWeight
                        }
                    }
                }
                footer: Item {
                    width: settingsView.width
                    height: root.space5
                }
                delegate: Item {
                    width: settingsView.width
                    height: modelData.kind === "appearance" ? 192
                        : modelData.kind === "account" ? 192 : 136

                    ElevatedSurface {
                        width: Math.min(768, parent.width - 64)
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: root.radiusPanel
                        color: root.panel
                        border.color: root.line

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: root.space4
                            spacing: root.space2
                            RowLayout {
                            Layout.fillWidth: true
                            spacing: root.space3
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: root.radiusControl
                                color: root.accentSoft
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.badge
                                    color: root.accent
                                    font.pixelSize: 14
                                    font.weight: root.titleWeight
                                }
                            }
                            ColumnLayout {
                                spacing: root.space1
                                Text {
                                    text: modelData.title
                                    color: root.textMain
                                    font.pixelSize: 17
                                    font.weight: root.titleWeight
                                }
                                Text {
                                    text: modelData.subtitle
                                    color: root.textMuted
                                    font.pixelSize: 12
                                    font.weight: root.bodyWeight
                                }
                            }
                            Item { Layout.fillWidth: true }
                        }

                        RowLayout {
                            visible: modelData.kind === "appearance"
                            Layout.fillWidth: true
                            Layout.topMargin: root.space2
                            Text {
                                text: "主题"
                                color: root.textMain
                                font.pixelSize: 13
                                font.weight: root.bodyWeight
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                Layout.preferredWidth: 300
                                Layout.preferredHeight: 40
                                radius: root.radiusControl
                                color: root.panelAlt
                                border.color: root.line

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: root.space1
                                    spacing: root.space1

                                    Repeater {
                                        model: [
                                            {label: "浅色", value: "light"},
                                            {label: "深色", value: "dark"},
                                            {label: "跟随系统", value: "system"}
                                        ]
                                        delegate: Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            radius: 8
                                            color: appController.theme === modelData.value
                                                ? root.accentSurface : themeMouse.containsMouse
                                                    ? root.accentSoft : "transparent"
                                            Behavior on color {
                                                ColorAnimation { duration: 160 }
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                color: appController.theme === modelData.value
                                                    ? root.accentText : root.textMain
                                                font.pixelSize: 12
                                                font.weight: appController.theme === modelData.value
                                                    ? root.titleWeight : root.bodyWeight
                                            }
                                            MouseArea {
                                                id: themeMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: appController.theme = modelData.value
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        RowLayout {
                            visible: modelData.kind === "appearance"
                            Layout.fillWidth: true
                            Text {
                                text: "紧凑列表"
                                color: root.textMain
                                font.pixelSize: 13
                                font.weight: root.bodyWeight
                            }
                            Item { Layout.fillWidth: true }
                            AppSwitch {
                                checked: appController.compactMode
                                onToggled: appController.compactMode = checked
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "chat"
                            Layout.fillWidth: true
                            Layout.topMargin: root.space2
                            ColumnLayout {
                                Text {
                                    text: "Enter 发送"
                                    color: root.textMain
                                    font.pixelSize: 13
                                    font.weight: root.bodyWeight
                                }
                                Text {
                                    text: appController.enterToSend ? "Shift+Enter 换行" : "Ctrl+Enter 发送"
                                    color: root.textMuted
                                    font.pixelSize: 11
                                    font.weight: root.bodyWeight
                                }
                            }
                            Item { Layout.fillWidth: true }
                            AppSwitch {
                                checked: appController.enterToSend
                                onToggled: appController.enterToSend = checked
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "notifications"
                            Layout.fillWidth: true
                            Layout.topMargin: root.space2
                            ColumnLayout {
                                Text {
                                    text: "新消息与好友申请提醒"
                                    color: root.textMain
                                    font.pixelSize: 13
                                    font.weight: root.bodyWeight
                                }
                                Text {
                                    text: "关闭后仍会保留未读数量"
                                    color: root.textMuted
                                    font.pixelSize: 11
                                    font.weight: root.bodyWeight
                                }
                            }
                            Item { Layout.fillWidth: true }
                            AppSwitch {
                                checked: appController.notificationsEnabled
                                onToggled: appController.notificationsEnabled = checked
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "privacy"
                            Layout.fillWidth: true
                            Layout.topMargin: root.space2
                            ColumnLayout {
                                Text {
                                    text: "显示在线状态"
                                    color: root.textMain
                                    font.pixelSize: 13
                                    font.weight: root.bodyWeight
                                }
                                Text {
                                    text: "控制本机界面是否展示在线标记"
                                    color: root.textMuted
                                    font.pixelSize: 11
                                    font.weight: root.bodyWeight
                                }
                            }
                            Item { Layout.fillWidth: true }
                            AppSwitch {
                                checked: appController.showOnlineStatus
                                onToggled: appController.showOnlineStatus = checked
                            }
                        }

                        RowLayout {
                            visible: modelData.kind === "account"
                            Layout.fillWidth: true
                            Layout.topMargin: root.space2
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
                            font.weight: root.bodyWeight
                        }
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

    Menu {
        id: messageMenu
        property string messageBody: ""
        property string messageId: ""
        property bool mine: false
        property bool recalled: false
        property bool canDownload: false
        property string attachmentId: ""
        MenuItem {
            text: "复制消息"
            enabled: messageMenu.messageBody.length > 0
            onTriggered: appController.copyText(messageMenu.messageBody)
        }
        MenuItem {
            text: "回复"
            enabled: messageMenu.messageId.length > 0 && !messageMenu.recalled
            onTriggered: {
                root.replyPreview = messageMenu.messageBody
                appController.replyToMessage(messageMenu.messageId,
                    messageMenu.messageBody)
                composer.forceActiveFocus()
            }
        }
        MenuItem {
            text: "回应 👍"
            enabled: messageMenu.messageId.length > 0 && !messageMenu.recalled
            onTriggered: appController.reactToMessage(
                messageMenu.messageId, "👍")
        }
        MenuItem {
            text: "编辑"
            visible: messageMenu.mine && !messageMenu.recalled
            enabled: messageMenu.messageId.length > 0
            onTriggered: {
                root.editingMessageId = messageMenu.messageId
                composer.text = messageMenu.messageBody
                composer.forceActiveFocus()
            }
        }
        MenuItem {
            text: "撤回"
            visible: messageMenu.mine && !messageMenu.recalled
            enabled: messageMenu.messageId.length > 0
            onTriggered: appController.recallMessage(messageMenu.messageId)
        }
        MenuItem {
            visible: messageMenu.canDownload
            text: "下载附件"
            onTriggered: appController.downloadAttachment(messageMenu.attachmentId)
        }
    }

    Dialog {
        id: addFriendDialog
        width: 432
        height: 384
        anchors.centerIn: parent
        modal: true
        title: "添加好友"
        standardButtons: Dialog.NoButton
        padding: root.space4
        header: DialogHeader { label: addFriendDialog.title }
        background: ElevatedSurface {
            radius: root.radiusPanel
            color: root.panel
            border.color: root.line
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: root.space3
            Text {
                text: "通过 9 位账号查找用户"
                color: root.textMuted
                font.pixelSize: 13
                font.weight: root.bodyWeight
            }
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
                    Layout.preferredWidth: 80
                    text: "搜索"
                    onClicked: appController.searchUser(friendSearchField.text)
                }
            }
            Rectangle {
                visible: appController.searchResult.account !== undefined
                    && appController.searchResult.account !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: root.radiusControl
                color: root.panelAlt
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: root.space3
                    Avatar {
                        label: appController.searchResult.initial || ""
                        seed: appController.searchResult.account || ""
                        online: appController.searchResult.online || false
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text {
                            text: appController.searchResult.name || ""
                            color: root.textMain
                            font.pixelSize: 15
                            font.weight: root.titleWeight
                        }
                        Text {
                            text: appController.searchResult.account || ""
                            color: root.textMuted
                            font.pixelSize: 12
                            font.weight: root.bodyWeight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: appController.searchResult.signature || ""
                            color: root.textMuted
                            font.pixelSize: 11
                            font.weight: root.bodyWeight
                            elide: Text.ElideRight
                        }
                    }
                    PrimaryButton {
                        Layout.preferredWidth: 88
                        text: appController.searchResult.isFriend ? "已是好友" : "添加"
                        enabled: !appController.searchResult.isFriend
                        onClicked: appController.sendFriendRequest(appController.searchResult.account)
                    }
                }
            }
            Item { Layout.fillHeight: true }
            GhostButton {
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 80
                text: "关闭"
                onClicked: addFriendDialog.close()
            }
        }
    }

    Dialog {
        id: profileDialog
        width: 432
        height: 400
        anchors.centerIn: parent
        modal: true
        title: "个人资料"
        standardButtons: Dialog.NoButton
        padding: root.space4
        header: DialogHeader { label: profileDialog.title }
        onOpened: {
            profileName.text = appController.currentUserName
            profileSignature.text = appController.currentUserSignature
        }
        background: ElevatedSurface {
            radius: root.radiusPanel
            color: root.panel
            border.color: root.line
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: root.space3
            Avatar {
                Layout.alignment: Qt.AlignHCenter
                avatarSize: 70
                label: appController.currentUserName
                seed: appController.currentUserAccount
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
                font.weight: root.bodyWeight
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
        width: 432
        height: 224
        anchors.centerIn: parent
        modal: true
        title: "切换账号"
        standardButtons: Dialog.NoButton
        padding: root.space4
        header: DialogHeader { label: switchAccountDialog.title }
        background: ElevatedSurface {
            radius: root.radiusPanel
            color: root.panel
            border.color: root.line
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: root.space3
            Text {
                Layout.fillWidth: true
                text: "将断开当前会话并返回登录界面，服务端聊天记录不会删除。"
                wrapMode: Text.WordWrap
                color: root.textMuted
                font.pixelSize: 13
                font.weight: root.bodyWeight
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
        width: 416
        height: 424
        anchors.centerIn: parent
        modal: true
        title: "修改密码"
        standardButtons: Dialog.NoButton
        padding: root.space4
        header: DialogHeader { label: passwordDialog.title }
        onClosed: {
            currentPassword.text = ""
            newPassword.text = ""
            confirmPassword.text = ""
        }
        background: ElevatedSurface {
            radius: root.radiusPanel
            color: root.panel
            border.color: root.line
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: root.space3
            Text {
                text: "修改后，下次登录请使用新密码。"
                color: root.textMuted
                font.pixelSize: 12
                font.weight: root.bodyWeight
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
        width: 432
        height: 224
        anchors.centerIn: parent
        modal: true
        title: "删除联系人"
        standardButtons: Dialog.NoButton
        padding: root.space4
        header: DialogHeader { label: removeFriendDialog.title }
        background: ElevatedSurface {
            radius: root.radiusPanel
            color: root.panel
            border.color: root.line
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: root.space3
            Text {
                Layout.fillWidth: true
                text: "确定从双方联系人列表中删除 " + appController.selectedPeerName + "？既有聊天记录仍保留在服务端。"
                wrapMode: Text.WordWrap
                color: root.textMuted
                font.weight: root.bodyWeight
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
        width: 432
        height: 224
        anchors.centerIn: parent
        modal: true
        title: "清空聊天记录"
        standardButtons: Dialog.NoButton
        padding: root.space4
        header: DialogHeader { label: clearConversationDialog.title }
        background: ElevatedSurface {
            radius: root.radiusPanel
            color: root.panel
            border.color: root.line
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: root.space3
            Text {
                Layout.fillWidth: true
                text: "该操作会在服务端隐藏当前账号此前的会话记录，且无法撤销。"
                wrapMode: Text.WordWrap
                color: root.textMuted
                font.weight: root.bodyWeight
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

    ElevatedSurface {
        id: toast
        visible: opacity > 0
        opacity: appController.toastMessage.length > 0 ? 1 : 0
        z: 1000
        width: Math.min(520, toastText.implicitWidth + 56)
        height: 48
        radius: root.radiusControl
        color: appController.toastError ? root.danger : root.navBg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.space4
        border.color: appController.toastError ? root.danger : "transparent"
        transform: Translate {
            y: toast.opacity > 0.5 ? 0 : 12
            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }
        Text {
            id: toastText
            anchors.centerIn: parent
            text: appController.toastMessage
            color: root.accentText
            font.pixelSize: 13
            font.weight: root.bodyWeight
        }
        Timer {
            interval: 3200
            running: appController.toastMessage.length > 0
            onTriggered: appController.clearToast()
        }
        MouseArea {
            anchors.fill: parent
            onClicked: appController.clearToast()
        }
    }
}
