import QtQuick
import QtQuick.Layouts

SidebarMenu {
	id: sidebarContextMenu
	visible: open
	open: false
	anchors.left: parent.left
	anchors.bottom: parent.top
	implicitWidth: content.implicitWidth
	implicitHeight: content.implicitHeight
	z: 2

	default property alias _contentChildren: content.data

	ColumnLayout {
		id: content
		spacing: 0
	}

	// onVisibleChanged: {
	// 	if (sidebarContextMenu.visible) {
	// 		sidebarContextMenu.focus = true
	// 	}
	// }

	onFocusChanged: {
		// console.log('sidebarContextMenu.onFocusChanged', focus)
		if (!sidebarContextMenu.focus) {
			sidebarContextMenu.open = false
		}
	}

	onActiveFocusChanged: {
		// console.log('sidebarContextMenu.onActiveFocusChanged', activeFocus)
		if (!sidebarContextMenu.activeFocus) {
			sidebarContextMenu.open = false
		}
	}
}
