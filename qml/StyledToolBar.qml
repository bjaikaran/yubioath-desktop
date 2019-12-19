import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.1 as PopUpMenu
import QtQml 2.12


ToolBar {
    id: toolBar

    background: Rectangle {
        color: defaultBackground
        opacity: 0.7
    }

    function getToolbarColor(isActive) {
        if (!isActive) {
            return 0
        } else {
            return 0.05
        }
    }

    property bool showSearch: shouldShowSearch()
    property bool showBackBtn: navigator.depth > 1
    property bool showTitleLbl: !!navigator.currentItem
                                && !!navigator.currentItem.title
    property alias moreBtn: moreBtn
    property alias addCredentialBtn: addCredentialBtn
    property alias searchField: searchField

    function shouldShowSearch() {        
        return !!(navigator.currentItem
                  && navigator.currentItem.objectName === 'credentialsView'
                  && entries.count > 0 && !settings.otpMode)
    }

    function shouldShowSettings() {
        return !!(navigator.currentItem && navigator.currentItem.objectName !== 'settingsView'
                  && navigator.currentItem.objectName !== 'newCredentialView')
    }

    function shouldShowInfo() {
        return !!(navigator.currentItem && navigator.currentItem.objectName === 'settingsView')
    }

    function shouldShowCredentialOptions() {
        return !!(app.currentCredentialCard && navigator.currentItem
                  && navigator.currentItem.objectName === 'credentialsView')
    }

    function shouldShowToolbar() {
        return !!(navigator.currentItem && navigator.currentItem.objectName !== 'loadingView')
    }

    function changeActiveKey(index, modelData) {
        yubiKey.refreshDevicesDefault()
        yubiKey.selectCurrentSerial(modelData.serial,
                                    function (resp) {
                                        if (resp.success) {
                                            entries.clear()
                                            yubiKey.currentDevice = modelData
                                            yubiKey.calculateAll()
                                        } else {
                                            console.log("select device failed", resp.error_id)
                                        }
                                    })
    }

    RowLayout {
        spacing: 0
        anchors.fill: parent
        visible: shouldShowToolbar()
        Layout.alignment: Qt.AlignTop


        ToolButton {
            id: backBtn
            visible: showBackBtn
            onClicked: navigator.home()
            icon.source: "../images/back.svg"
            icon.color: primaryColor
            opacity: hovered ? fullEmphasis : lowEmphasis
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: false
            }
        }

        ToolButton {
            id: moreBtn
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            visible: !backBtn.visible && shouldShowSettings()
            onClicked: dropDownMenu.open()

            Keys.onReturnPressed: navigator.goToSettings()
            Keys.onEnterPressed: navigator.goToSettings()

            KeyNavigation.left: navigator
            KeyNavigation.backtab: navigator
            KeyNavigation.right: searchField
            KeyNavigation.tab: searchField

            Accessible.role: Accessible.Button
            Accessible.name: "More"
            Accessible.description: "More dropdown menu"

            ToolTip {
                text: qsTr("More")
                delay: 1000
                parent: moreBtn
                visible: parent.hovered
                Material.foreground: toolTipForeground
                Material.background: toolTipBackground
            }

            icon.source: "../images/more.svg"
            icon.color: primaryColor
            opacity: hovered ? fullEmphasis : lowEmphasis

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: false
            }

            Menu {
                id: dropDownMenu
                y: 40

                Instantiator {
                    id: dropDownMenuInstantiator
                    model: yubiKey.availableDevices
                    onObjectAdded: dropDownMenu.insertItem(index + 4, object)
                    onObjectRemoved: dropDownMenu.removeItem(object)
                    delegate: MenuItem {
                        text: modelData.name
                        icon.source: !!yubiKey.currentDevice
                                     && modelData.serial === yubiKey.currentDevice.serial ? "../images/check.svg" : "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAABCAQAAAB0m0auAAAADElEQVR42mNkIBIAAABSAAI2VLqiAAAAAElFTkSuQmCC"
                        icon.color: primaryColor
                        opacity: highEmphasis
                        icon.width: 20
                        icon.height: 20
                        enabled: modelData.selectable
                        onTriggered: changeActiveKey(index, modelData)
                        Label {
                            y: 22
                            x: 50
                            text: qsTr("#%1").arg(modelData.serial)
                            font.pixelSize: 10
                            color: primaryColor
                            opacity: lowEmphasis
                            visible: !modelData.nameUnique && modelData.serial
                        }
                        height: implicitHeight + (modelData.nameUnique ? 0 : 10)
                        topPadding: modelData.nameUnique ? null : -(height - implicitHeight)/2
                    }
                }
                MenuItem {
                    icon.source: "../images/info.svg"
                    icon.color: primaryColor
                    opacity: highEmphasis
                    icon.width: 20
                    icon.height: 20
                    text: qsTr("Information")
                    onTriggered: navigator.about()
                }
                MenuItem {
                    icon.source: "../images/cogwheel.svg"
                    icon.color: primaryColor
                    opacity: highEmphasis
                    icon.width: 20
                    icon.height: 20
                    text: qsTr("Settings")
                    onTriggered: navigator.goToSettings()
                }
                MenuSeparator {
                }
            }

        }

        Label {
            id: titleLbl
            visible: showTitleLbl
            text: showTitleLbl ? navigator.currentItem.title : ""
            font.pixelSize: 16
            Layout.leftMargin: moreBtn.visible || (!!navigator.currentItem && navigator.currentItem.objectName === 'settingsView') ? -32 : 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            color: primaryColor
            opacity: lowEmphasis
        }

        ToolButton {
            id: searchBtn
            visible: showSearch
            Layout.minimumHeight: 30
            Layout.maximumHeight: 30
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            background: Rectangle {
                color: primaryColor
                opacity: getToolbarColor(searchBtn.hovered)
                height: 30
                radius: 4
            }

            TextField {
                id: searchField
                visible: showSearch
                selectByMouse: true
                selectedTextColor: defaultBackground
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: qsTr("Quick find")
                placeholderTextColor: isDark() ? "#B7B7B7" : "#767676"
                leftPadding: 28
                rightPadding: 8
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
                color: primaryColor
                opacity: hovered || activeFocus ? fullEmphasis : lowEmphasis
                background: Rectangle {
                    color: primaryColor
                    height: 30
                    radius: 4
                    opacity: getToolbarColor(searchField.focus)
                }

                Accessible.role: Accessible.EditableText
                Accessible.searchEdit: true
                onTextChanged: forceActiveFocus()
                onVisibleChanged: {
                    if (!visible) {
                        exitSearchMode(true)
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.IBeamCursor
                    onClicked: {
                        contextMenu.open();
                    }
                    onPressAndHold: {
                        if (mouse.source === Qt.MouseEventNotSynthesized) {
                            contextMenu.open();
                        }
                    }
                }

                PopUpMenu.Menu {
                    id: contextMenu

                    PopUpMenu.MenuItem {
                        text: qsTr("Cut")
                        onTriggered: {
                            searchField.cut()
                        }
                    }
                    PopUpMenu.MenuItem {
                        text: qsTr("Copy")
                        onTriggered: {
                            searchField.copy()
                        }
                    }
                    PopUpMenu.MenuItem {
                        text: qsTr("Paste")
                        onTriggered: {
                            searchField.paste()
                        }
                    }
                }

                function exitSearchMode(clearInput) {
                    if (clearInput) {
                        text = ""
                    }
                    focus = false
                    Keys.forwardTo = navigator
                    navigator.forceActiveFocus()
                }

                KeyNavigation.backtab: moreBtn
                KeyNavigation.left: moreBtn
                KeyNavigation.tab: shouldShowCredentialOptions(
                                       ) ? copyCredentialBtn : addCredentialBtn
                KeyNavigation.right: shouldShowCredentialOptions(
                                       ) ? copyCredentialBtn : addCredentialBtn
                Keys.onEscapePressed: exitSearchMode(true)
                Keys.onDownPressed: exitSearchMode(false)
                Keys.onReturnPressed: {
                    if (currentCredentialCard) {
                        currentCredentialCard.calculateCard(true)
                    }
                }
                Keys.onEnterPressed: {
                    if (currentCredentialCard) {
                        currentCredentialCard.calculateCard(true)
                    }
                }

                StyledImage {
                    id: searchIcon
                    x: 5
                    y: 6
                    iconHeight: 20
                    iconWidth: 20
                    source: "../images/search.svg"
                    color: primaryColor
                    opacity: searchField.hovered || searchField.activeFocus ? fullEmphasis : lowEmphasis

                }
            }
        }

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            ToolButton {
                id: copyCredentialBtn
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: shouldShowCredentialOptions()

                onClicked: app.currentCredentialCard.calculateCard(true)
                Keys.onReturnPressed: app.currentCredentialCard.calculateCard(true)
                Keys.onEnterPressed: app.currentCredentialCard.calculateCard(true)

                KeyNavigation.left: searchField
                KeyNavigation.backtab: searchField
                KeyNavigation.right: deleteCredentialBtn
                KeyNavigation.tab: deleteCredentialBtn

                Accessible.role: Accessible.Button
                Accessible.name: "Copy"
                Accessible.description: "Copy to clipboard"

                ToolTip {
                    text: qsTr("Copy code to clipboard")
                    delay: 1000
                    parent: copyCredentialBtn
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

            ToolButton {
                id: deleteCredentialBtn
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: shouldShowCredentialOptions()

                onClicked: app.currentCredentialCard.deleteCard()
                Keys.onReturnPressed: app.currentCredentialCard.deleteCard()
                Keys.onEnterPressed: app.currentCredentialCard.deleteCard()

                KeyNavigation.left: copyCredentialBtn
                KeyNavigation.right: addCredentialBtn
                KeyNavigation.tab: addCredentialBtn

                Accessible.role: Accessible.Button
                Accessible.name: "Delete"
                Accessible.description: "Delete account"

                ToolTip {
                    text: qsTr("Delete account")
                    delay: 1000
                    parent: deleteCredentialBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/delete.svg"
                icon.color: primaryColor
                opacity: hovered ? fullEmphasis : lowEmphasis

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

            ToolButton {
                id: addCredentialBtn
                visible: !!yubiKey.currentDevice
                         && yubiKey.currentDeviceValidated
                         && navigator.currentItem
                         && navigator.currentItem.objectName === 'credentialsView'

                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                onClicked: yubiKey.scanQr()
                Keys.onReturnPressed: yubiKey.scanQr()
                Keys.onEnterPressed: yubiKey.scanQr()

                KeyNavigation.left: app.currentCredentialCard ? deleteCredentialBtn : searchField
                KeyNavigation.backtab: app.currentCredentialCard ? deleteCredentialBtn : searchField
                KeyNavigation.right: navigator
                KeyNavigation.tab: navigator

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Add")
                Accessible.description: qsTr("Add account")

                ToolTip {
                    text: qsTr("Add a new account")
                    delay: 1000
                    parent: addCredentialBtn
                    visible: parent.hovered
                    Material.foreground: toolTipForeground
                    Material.background: toolTipBackground
                }

                icon.source: "../images/add.svg"
                icon.color: primaryColor
                opacity: hovered ? fullEmphasis : lowEmphasis

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

        }
    }
}
