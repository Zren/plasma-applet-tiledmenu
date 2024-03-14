import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3

// https://invent.kde.org/frameworks/plasma-framework/-/blame/master/src/declarativeimports/plasmacomponents3/GroupBox.qml
PlasmaComponents3.GroupBox {
	id: control
	property bool checkable: false
	property bool checked: false

	label: RowLayout {
		x: control.leftPadding
		y: control.topInset
		width: control.availableWidth

		Loader {
			id: checkBoxLoader
			active: control.checkable
			sourceComponent: PlasmaComponents3.CheckBox {
				id: checkBox
				Layout.fillWidth: true
				enabled: control.enabled
				text: control.title
				checked: control.checked
				onCheckedChanged: control.checked = checked
			}
		}
		PlasmaComponents3.Label {
			Layout.fillWidth: true
			enabled: control.enabled
			visible: !control.checkable

			text: control.title
			font: control.font
			// color: SystemPaletteSingleton.text(control.enabled) // TODO: Fix Label color upstream
			elide: Text.ElideRight
			horizontalAlignment: Text.AlignLeft
			verticalAlignment: Text.AlignVCenter
		}
	}
}
