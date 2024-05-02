import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.draganddrop as DragAndDrop
import org.kde.kirigami as Kirigami

MouseArea {
	id: launcherIcon

	readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
		|| plasmoid.location == PlasmaCore.Types.RightEdge
		|| plasmoid.location == PlasmaCore.Types.BottomEdge
		|| plasmoid.location == PlasmaCore.Types.LeftEdge)

	Layout.minimumWidth: {
		switch (plasmoid.formFactor) {
		case PlasmaCore.Types.Vertical:
			return 0
		case PlasmaCore.Types.Horizontal:
			return height
		default:
			return Kirigami.Units.gridUnit * 3
		}
	}

	Layout.minimumHeight: {
		switch (plasmoid.formFactor) {
		case PlasmaCore.Types.Vertical:
			return width
		case PlasmaCore.Types.Horizontal:
			return 0
		default:
			return Kirigami.Units.gridUnit * 3
		}
	}

	readonly property int maxSize: Math.max(width, height)
	property int size: {
		if (inPanel) {
			if (plasmoid.configuration.fixedPanelIcon) {
				// Was PlasmaCore.Units.iconSizeHints.panel in Plasma5
				// In Plasma6 https://invent.kde.org/plasma/plasma-desktop/-/merge_requests/1390/diffs
				return 48 // Kickoff uses this hardcoded number
			} else {
				return maxSize
			}
		} else {
			return -1
		}
	}
	Layout.maximumWidth: size
	Layout.maximumHeight: size


	property int iconSize: Math.min(width, height)
	property alias iconSource: icon.source

	Kirigami.Icon {
		id: icon
		anchors.centerIn: parent
		source: "start-here-kde-symbolic"
		width: launcherIcon.iconSize
		height: launcherIcon.iconSize
		active: launcherIcon.containsMouse
		smooth: true
	}
	
	// Debugging
	// Rectangle { anchors.fill: parent; border.color: "#ff0"; color: "transparent"; border.width: 1; }
	// Rectangle { anchors.fill: icon; border.color: "#f00"; color: "transparent"; border.width: 1; }


	hoverEnabled: true
	// cursorShape: Qt.PointingHandCursor

	onClicked: {
		plasmoid.expanded = !plasmoid.expanded
	}

	property alias activateOnDrag: dropArea.enabled
	DragAndDrop.DropArea {
		id: dropArea
		anchors.fill: parent

		onDragEnter: {
			dragHoverTimer.restart()
		}
	}

	onContainsMouseChanged: {
		if (!containsMouse) {
			dragHoverTimer.stop()
		}
	}

	Timer {
		id: dragHoverTimer
		interval: 250 // Same as taskmanager's activationTimer in MouseHandler.qml
		onTriggered: plasmoid.expanded = true
	}
}
