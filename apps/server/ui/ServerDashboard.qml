import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root
    width: 1180
    height: 780
    minimumWidth: 980
    minimumHeight: 680
    visible: true
    title: qsTr("RubbageChat Server")
    color: "#F5F7FB"

    readonly property color ink: "#172033"
    readonly property color muted: "#697386"
    readonly property color line: "#E5E9F2"
    readonly property color indigo: "#5B5CE2"
    readonly property color green: "#20A779"
    readonly property color navy: "#121827"

    Component.onCompleted: serverController.startServer()

    Rectangle {
        id: sidebar
        width: 248
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: root.navy

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 0

            Row {
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    radius: 12
                    color: root.indigo

                    Text {
                        anchors.centerIn: parent
                        text: "R"
                        color: "white"
                        font.pixelSize: 19
                        font.weight: Font.Bold
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "RubbageChat"
                        color: "white"
                        font.pixelSize: 17
                        font.weight: Font.Bold
                    }
                    Text {
                        text: qsTr("SERVER CONSOLE")
                        color: "#7F8AA3"
                        font.pixelSize: 10
                        font.letterSpacing: 1.2
                        font.weight: Font.DemiBold
                    }
                }
            }

            Item { width: 1; height: 48 }

            Text {
                text: qsTr("OVERVIEW")
                color: "#69758E"
                font.pixelSize: 10
                font.letterSpacing: 1.4
                font.weight: Font.DemiBold
            }

            Item { width: 1; height: 12 }

            Rectangle {
                width: parent.width
                height: 48
                radius: 12
                color: "#242B48"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: root.indigo
                    }
                    Text {
                        text: qsTr("Service dashboard")
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }
            }

            Item { width: 1; height: 20 }

            Rectangle {
                width: parent.width
                height: 1
                color: "#252C3D"
            }

            Item { width: 1; height: 24 }

            Text {
                text: qsTr("RUNTIME")
                color: "#69758E"
                font.pixelSize: 10
                font.letterSpacing: 1.4
                font.weight: Font.DemiBold
            }

            Item { width: 1; height: 16 }

            Column {
                width: parent.width
                spacing: 14

                Repeater {
                    model: [
                        { label: qsTr("Public mode"), value: serverController.publicMode ? qsTr("Enabled") : qsTr("Disabled") },
                        { label: qsTr("Transport"), value: serverController.tlsEnabled ? "TLS 1.2+" : "TCP" },
                        { label: qsTr("Listen port"), value: String(serverController.listenPort) },
                        { label: qsTr("Business workers"), value: String(serverController.businessWorkers) }
                    ]

                    Row {
                        width: parent.width

                        Text {
                            width: parent.width * 0.54
                            text: modelData.label
                            color: "#7F8AA3"
                            font.pixelSize: 12
                            font.weight: Font.Normal
                        }
                        Text {
                            width: parent.width * 0.46
                            text: modelData.value
                            color: "#DCE2F0"
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true; width: 1; height: 1 }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 28
            spacing: 8

            Text {
                text: qsTr("PRODUCT VERSION")
                color: "#69758E"
                font.pixelSize: 10
                font.letterSpacing: 1.2
                font.weight: Font.DemiBold
            }
            Text {
                text: "2.5.0-beta.1"
                color: "#B5BED1"
                font.pixelSize: 12
                font.weight: Font.Normal
            }
        }
    }

    ScrollView {
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            implicitWidth: Math.max(732, root.width - sidebar.width)
            implicitHeight: contentColumn.implicitHeight + 64

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 32
                spacing: 32

                RowLayout {
                    width: parent.width
                    spacing: 20

                    Column {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: qsTr("Server overview")
                            color: root.ink
                            font.pixelSize: 28
                            font.weight: Font.Bold
                        }
                        Text {
                            text: qsTr("Monitor connections, security and service activity.")
                            color: root.muted
                            font.pixelSize: 14
                            font.weight: Font.Normal
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: statusRow.width + 24
                        Layout.preferredHeight: 36
                        radius: 18
                        color: serverController.running ? "#E7F7F1" : "#EEF1F6"

                        Row {
                            id: statusRow
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: serverController.running ? root.green : "#8C96A9"
                            }
                            Text {
                                text: serverController.running ? qsTr("Service online") : qsTr("Service stopped")
                                color: serverController.running ? "#157A59" : "#5D6678"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    Button {
                        id: serviceButton
                        text: serverController.running ? qsTr("Stop server") : qsTr("Start server")
                        implicitWidth: 128
                        implicitHeight: 44
                        onClicked: serverController.running
                            ? serverController.stopServer()
                            : serverController.startServer()

                        background: Rectangle {
                            radius: 12
                            color: serviceButton.down
                                ? (serverController.running ? "#E8EBF1" : "#4C4DC8")
                                : (serverController.running ? "white" : root.indigo)
                            border.color: serverController.running ? root.line : "transparent"
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                        contentItem: Text {
                            text: serviceButton.text
                            color: serverController.running ? root.ink : "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Rectangle {
                    visible: serverController.lastError.length > 0 && !serverController.running
                    width: parent.width
                    height: visible ? errorText.implicitHeight + 32 : 0
                    radius: 12
                    color: "#FFF1F0"
                    border.color: "#FFD7D3"

                    Text {
                        id: errorText
                        anchors.fill: parent
                        anchors.margins: 16
                        text: serverController.lastError
                        color: "#A33A32"
                        wrapMode: Text.Wrap
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        font.weight: Font.Normal
                    }
                }

                GridLayout {
                    width: parent.width
                    columns: 5
                    columnSpacing: 16
                    rowSpacing: 16

                    Repeater {
                        model: [
                            { label: qsTr("Active connections"), value: serverController.activeConnections, tone: "#5B5CE2" },
                            { label: qsTr("Authenticated"), value: serverController.authenticatedConnections, tone: "#20A779" },
                            { label: qsTr("Total requests"), value: serverController.totalRequests, tone: "#3478F6" },
                            { label: qsTr("Rejected"), value: serverController.rejectedRequests, tone: "#E16B62" },
                            { label: qsTr("Queue / ") + serverController.maxPendingCommands, value: serverController.pendingCommands, tone: "#E4A344" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 132
                            radius: 16
                            color: "white"
                            border.color: root.line

                            Column {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 12

                                Rectangle {
                                    width: 28
                                    height: 6
                                    radius: 3
                                    color: modelData.tone
                                }
                                Text {
                                    text: String(modelData.value)
                                    color: root.ink
                                    font.pixelSize: 28
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: modelData.label
                                    color: root.muted
                                    font.pixelSize: 12
                                    font.weight: Font.Normal
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: 20

                    Rectangle {
                        Layout.preferredWidth: Math.max(280, parent.width * 0.36)
                        Layout.fillHeight: true
                        implicitHeight: 316
                        radius: 16
                        color: "white"
                        border.color: root.line

                        Column {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 0

                            Text {
                                text: qsTr("Configuration")
                                color: root.ink
                                font.pixelSize: 17
                                font.weight: Font.Bold
                            }
                            Text {
                                text: qsTr("Effective runtime settings")
                                color: root.muted
                                font.pixelSize: 12
                                font.weight: Font.Normal
                            }
                            Item { width: 1; height: 24 }

                            Repeater {
                                model: [
                                    { label: qsTr("Database"), value: serverController.databaseTarget },
                                    { label: qsTr("TLS encryption"), value: serverController.tlsEnabled ? qsTr("Enabled") : qsTr("Disabled") },
                                    { label: qsTr("Public mode"), value: serverController.publicMode ? qsTr("Enabled") : qsTr("Disabled") },
                                    { label: qsTr("Registration"), value: serverController.registrationEnabled ? qsTr("Open") : qsTr("Closed") }
                                ]

                                Item {
                                    width: parent.width
                                    height: 52

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.label
                                        color: root.muted
                                        font.pixelSize: 12
                                        font.weight: Font.Normal
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width * 0.58
                                        text: modelData.value
                                        elide: Text.ElideMiddle
                                        horizontalAlignment: Text.AlignRight
                                        color: root.ink
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                    }
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: 1
                                        color: root.line
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 316
                        radius: 16
                        color: "white"
                        border.color: root.line

                        Column {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 16

                            Row {
                                width: parent.width

                                Column {
                                    width: parent.width - 80
                                    spacing: 3
                                    Text {
                                        text: qsTr("Activity")
                                        color: root.ink
                                        font.pixelSize: 17
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: qsTr("Latest service events")
                                        color: root.muted
                                        font.pixelSize: 12
                                        font.weight: Font.Normal
                                    }
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: serverController.recentLogs.length + qsTr(" events")
                                    color: root.muted
                                    font.pixelSize: 11
                                    font.weight: Font.Normal
                                }
                            }

                            ListView {
                                width: parent.width
                                height: 224
                                clip: true
                                spacing: 0
                                model: serverController.recentLogs

                                delegate: Item {
                                    required property var modelData
                                    width: ListView.view.width
                                    height: 52

                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: modelData.level === "error" ? "#E16B62"
                                            : modelData.level === "warning" ? "#E4A344"
                                            : modelData.level === "success" ? root.green
                                            : "#9AA4B7"
                                    }
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 20
                                        anchors.right: timeLabel.left
                                        anchors.rightMargin: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.message
                                        elide: Text.ElideRight
                                        color: root.ink
                                        font.pixelSize: 12
                                        font.weight: Font.Normal
                                    }
                                    Text {
                                        id: timeLabel
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.time
                                        color: "#9AA4B7"
                                        font.pixelSize: 11
                                        font.weight: Font.Normal
                                    }
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: 1
                                        color: root.line
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: serverController.recentLogs.length === 0
                                    text: qsTr("No service activity yet")
                                    color: root.muted
                                    font.pixelSize: 12
                                    font.weight: Font.Normal
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
