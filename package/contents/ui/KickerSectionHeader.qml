import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
	id: sectionDelegate

	width: parent.width
	// height: childrenRect.height
	implicitHeight: listView.iconSize

	property bool enableJumpToSection: false

	PlasmaComponents.Label {
		id: sectionHeading
		anchors {
			left: parent.left
			leftMargin: units.smallSpacing
			verticalCenter:  parent.verticalCenter
		}
		text: {
			if (section == appsModel.recentAppsSectionKey) {
				return appsModel.recentAppsSectionLabel
			} else {
				return section
			}
		}
		font.bold: true
		font.pointSize: 14 * units.devicePixelRatio

		property bool centerOverIcon: sectionHeading.contentWidth <= listView.iconSize
		width: centerOverIcon ? listView.iconSize : parent.width
		horizontalAlignment: centerOverIcon ? Text.AlignHCenter : Text.AlignLeft
	}

	HoverOutlineEffect {
		id: hoverOutlineEffect
		anchors.fill: parent
		visible: enableJumpToSection && control.containsMouse
		hoverRadius: width/2
		pressedRadius: width
		property alias control: sectionDelegate
	}

	hoverEnabled: true
	onClicked: {
		if (enableJumpToSection) {
			if (appsModel.order == "alphabetical") {
				jumpToLetterView.show()
			} else { // appsModel.order = "categories"
				jumpToLetterView.show()
			}
		}
	}
}
