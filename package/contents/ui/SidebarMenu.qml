import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

MouseArea {
	id: sidebarMenu
	hoverEnabled: true
	z: 1
	// clip: true
	implicitWidth: config.sidebarWidth
	property bool open: false

	onOpenChanged: {
		if (open) {
			forceActiveFocus()
		} else {
			searchView.searchField.forceActiveFocus()
		}
	}

	Rectangle {
		anchors.fill: parent
		visible: !plasmoid.configuration.sidebarFollowsTheme
		color: config.sidebarBackgroundColor
		opacity: parent.open ? 1 : 0
	}

	Rectangle {
		anchors.fill: parent
		visible: plasmoid.configuration.sidebarFollowsTheme
		color: PlasmaCore.Theme.backgroundColor
		opacity: parent.open ? 1 : 0
	}
	KSvg.FrameSvgItem {
		anchors.fill: parent
		visible: plasmoid.configuration.sidebarFollowsTheme
		imagePath: "widgets/frame"
		prefix: "raised"
	}

	property alias showDropShadow: sidebarMenuShadows.visible
	SidebarMenuShadows {
		id: sidebarMenuShadows
		anchors.fill: parent
		visible: !plasmoid.configuration.sidebarFollowsTheme && sidebarMenu.open
	}
}
