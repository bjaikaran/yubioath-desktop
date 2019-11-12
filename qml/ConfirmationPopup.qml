import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

Dialog {
    padding: 16
    margins: 0
    spacing: 0
    modal: true
    focus: true

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: app.width * 0.9 > 600 ? 600 : app.width * 0.9

    background: Rectangle {
        color: defaultBackground
        radius: 4
    }

    onClosed: {
        navigator.focus = true
    }

    onAccepted: {
        acceptedCb()
        close()
        navigator.focus = true
    }

    onRejected: {
        close()
        navigator.focus = true
    }

    Component.onCompleted: btnCancel.forceActiveFocus()

    property var acceptedCb
    property bool warning: true
    property bool buttons: true
    property bool copySecret: false
    property string heading
    property string message
    property string description
    property string buttonCancel: qsTr("Cancel")
    property string buttonAccept: qsTr("Accept")

    ColumnLayout {
        width: parent.width

        Label {
            text: heading
            font.pixelSize: 14
            font.weight: Font.Medium
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }

        Pane {
            padding: 12
            rightPadding: 16
            bottomPadding: 8
            visible: message
            width: parent.width
            Layout.minimumWidth: parent.width
            Layout.maximumWidth: parent.width
            Layout.topMargin: 16
            background: Rectangle {
                color: warning ? yubicoRed : yubicoGreen
                radius: 4
            }

            RowLayout {
                spacing: 0
                width: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                StyledImage {
                    source: warning ? "../images/warning.svg" : "../images/info.svg"
                    color: yubicoWhite
                    iconWidth: 32
                    iconHeight: 32
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.maximumWidth: 32
                }

                Label {
                    text: message
                    color: yubicoWhite
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    lineHeight: 1.2
                    leftPadding: 12
                    wrapMode: Text.WordWrap
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                }
            }
        }

        Label {
            Layout.topMargin: 16
            text: description
            color: primaryColor
            opacity: highEmphasis
            font.pixelSize: 13
            lineHeight: 1.2
            visible: description
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }

        RowLayout {
            visible: copySecret
            CheckBox {
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                id: hideAccountReminder
                font.pixelSize: 13
                text: qsTr("Don't show again")
                leftPadding: 0
                KeyNavigation.backtab: copySecretBtn
                KeyNavigation.tab: copySecretBtn
                indicator.width: 16
                indicator.height: 16
                Material.foreground: primaryColor
                opacity: highEmphasis
                checked: settings.hideRecoveryReminder
                onCheckStateChanged: settings.hideRecoveryReminder = checked
            }

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                id: infoBtn
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.topMargin: -8
                Layout.bottomMargin: -8
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                Keys.onReturnPressed: Qt.openUrlExternally("https://support.yubico.com/support/solutions/articles/15000006419-using-your-yubikey-with-authenticator-codes")
                onClicked: Qt.openUrlExternally("https://support.yubico.com/support/solutions/articles/15000006419-using-your-yubikey-with-authenticator-codes")

                Accessible.role: Accessible.Button
                Accessible.name: "Help"
                Accessible.description: "Help"

                ToolTip {
                    text: qsTr("Read more about how recovery works\non Yubico website.")
                    delay: 1000
                    parent: infoBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/help.svg"
                icon.color: primaryColor
                opacity: hovered ? fullEmphasis : lowEmphasis

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

            ToolButton {
                id: copySecretBtn
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.topMargin: -8
                Layout.rightMargin: -8
                Layout.bottomMargin: -8
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                Keys.onReturnPressed: accept()
                onClicked: accept()

                Accessible.role: Accessible.Button
                Accessible.name: "Copy"
                Accessible.description: "Copy secret key to clipboard"

                ToolTip {
                    text: qsTr("Copy secret key to clipboard and\nstore it somewhere safe")
                    delay: 1000
                    parent: copySecretBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/copy.svg"
                icon.color: primaryColor
                opacity: hovered ? fullEmphasis : lowEmphasis

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }
        }
        DialogButtonBox {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.topMargin: 0
            Layout.bottomMargin: -16
            Layout.rightMargin: -8
            padding: 0
            visible: buttons

            StyledButton {
                id: btnAccept
                text: qsTr(buttonAccept)
                flat: true
                enabled: true
                critical: warning
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                KeyNavigation.tab: btnCancel
                Keys.onReturnPressed: accept()
                onClicked: accept()
            }

            StyledButton {
                id: btnCancel
                text: qsTr(buttonCancel)
                flat: true
                critical: warning
                enabled: true
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                KeyNavigation.tab: btnAccept
                Keys.onReturnPressed: reject()
                onClicked: reject()
            }
        }
    }
}
