import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
	id: radioButtonGroup

	property alias group: group
	QQC2.ButtonGroup {
		id: group
	}

	// The main reason we put all the RadioButtons in
	// a ColumnLayout is to shrink the spacing between the buttons.
	spacing: Kirigami.Units.smallSpacing

	// Assign buddyFor to the first RadioButton so that
	// the Kirigami label aligns with it.
	Kirigami.FormData.buddyFor: visibleChildren.length >= 1 ? visibleChildren[0] : null
}
