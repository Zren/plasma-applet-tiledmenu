import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras

ColumnLayout {
	// inherits tileGridPresets from Loader
	// inherits maxWidth from Loader

	spacing: Kirigami.Units.largeSpacing

	PlasmaExtras.Heading {
		Layout.alignment: Qt.AlignHCenter
		Layout.maximumWidth: maxWidth
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
		text: i18n("Getting Started")
	}
	PlasmaComponents3.Label {
		Layout.alignment: Qt.AlignHCenter
		Layout.maximumWidth: maxWidth
		wrapMode: Text.Wrap

		text: {
			var tips = [
				i18n("Drag apps onto the grid."),
				i18n("Drag folders from the file manager here."),
				i18n("Meta + Right Click to resize the menu."),
			]
			var str = '<ul>'
			for (var i = 0; i < tips.length; i++) {
				var tip = tips[i]
				str += '<li>' + tip + '</li>'
			}
			str += '</ul>'
			return str
		}
	}

	PlasmaComponents3.Button {
		Layout.alignment: Qt.AlignHCenter
		text: i18n("Use Default Tile Layout")
		onClicked: tileGridPresets.addDefault()
	}
}
