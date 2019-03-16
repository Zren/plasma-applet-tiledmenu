import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

SidebarMenu {
	id: sidebarContextMenu
	visible: open
	open: false
	anchors.left: parent.right
	anchors.bottom: parent.bottom
	implicitWidth: content.implicitWidth
	implicitHeight: content.implicitHeight
	z: 2

	default property alias _contentChildren: content.data

	ColumnLayout {
		id: content
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
