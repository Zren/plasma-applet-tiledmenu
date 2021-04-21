import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.3 as Kirigami

MouseArea {
	id: control
	hoverEnabled: true

	property alias hovered: control.containsMouse
	property string iconName: ""
	property var iconSource: null
	property string text: ""

	Kirigami.MnemonicData.enabled: control.enabled && control.visible
	Kirigami.MnemonicData.label: control.text

	property font font: PlasmaCore.Theme.defaultFont
	property real minimumWidth: 0
	property real minimumHeight: 0
	property bool flat: true

	property int paddingTop: styleLoader.item ? styleLoader.item.paddingTop : 0
	property int paddingLeft: styleLoader.item ? styleLoader.item.paddingLeft : 0
	property int paddingRight: styleLoader.item ? styleLoader.item.paddingRight : 0
	property int paddingBottom: styleLoader.item ? styleLoader.item.paddingBottom : 0

	Loader {
		id: styleLoader
		anchors.fill: parent
		asynchronous: true
		// source: "AppToolButtonStyle.qml"
		source: "HoverOutlineButtonStyle.qml"
		property var mouseArea: control
	}
}
