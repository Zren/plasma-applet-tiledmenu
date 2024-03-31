import QtQuick
import QtQml.Models as QtModels
import org.kde.plasma.extras as PlasmaExtras

// https://invent.kde.org/plasma/plasma-framework/-/blame/master/src/declarativeimports/plasmaextracomponents/qmenu.h
PlasmaExtras.Menu {
	id: kickerContextMenu
	required property var model

	function toggleOpen() {
		if (kickerContextMenu.status == PlasmaExtras.Menu.Open) {
			kickerContextMenu.close()
		} else if (kickerContextMenu.status == PlasmaExtras.Menu.Closed) {
			kickerContextMenu.openRelative()
		}
	}

	// https://invent.kde.org/plasma/plasma-desktop/-/blame/master/applets/kickoff/package/contents/ui/LeaveButtons.qml
	// https://invent.kde.org/plasma/plasma-desktop/-/blame/master/applets/kickoff/package/contents/ui/ActionMenu.qml
	// https://doc.qt.io/qt-6/qml-qtqml-models-instantiator.html
	property Instantiator _instantiator: QtModels.Instantiator {
		model: kickerContextMenu.model
		delegate: PlasmaExtras.MenuItem {
			icon:  model.iconName || model.decoration
			text: model.name || model.display
			visible: !model.disabled
			onClicked: {
				kickerContextMenu.model.triggerIndex(index)
			}
		}
		onObjectAdded: (index, object) => kickerContextMenu.addMenuItem(object)
		onObjectRemoved: (index, object) => kickerContextMenu.removeMenuItem(object)
	}
	placement: {
		if (searchView.searchOnTop) {
			return PlasmaExtras.Menu.BottomPosedRightAlignedPopup
		} else {
			return PlasmaExtras.Menu.TopPosedRightAlignedPopup
		}
	}
}
