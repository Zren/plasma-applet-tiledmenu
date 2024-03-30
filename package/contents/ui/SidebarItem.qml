import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

FlatButton {
	id: sidebarItem
	Layout.fillWidth: true
	Layout.minimumWidth: expanded ? config.sidebarMinOpenWidth : implicitWidth
	property var sidebarMenu: parent.parent // Column.SidebarMenu
	expanded: sidebarMenu ? sidebarMenu.open : false
	labelVisible: expanded
	property bool closeOnClick: true

	QQC2.ToolTip {
		id: control
		visible: sidebarItem.hovered && !sidebarItem.expanded
		text: sidebarItem.text
		delay: 0
		x: parent.width + rightPadding
		y: (parent.height - height) / 2
	}

	Loader {
		id: hoverOutlineEffectLoader
		anchors.fill: parent
		source: "HoverOutlineButtonEffect.qml"
		asynchronous: true
		property var mouseArea: sidebarItem.__behavior
		active: !!mouseArea && mouseArea.containsMouse
		visible: active
		property var __mouseArea: mouseArea
	}
}
