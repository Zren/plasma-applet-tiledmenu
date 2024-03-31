import QtQuick
import QtQuick.Dialogs as QtDialogs
import org.kde.plasma.components as PlasmaComponents3

TileEditorField {
	id: fileField
	property string dialogTitle: ""
	signal dialogOpen(var dialog)

	PlasmaComponents3.Button {
		icon.name: 'document-open'
		onClicked: dialogLoader.active = true

		Loader {
			id: dialogLoader
			active: false
			sourceComponent: QtDialogs.FileDialog {
				id: dialog
				visible: false
				modality: Qt.WindowModal
				onAccepted: {
					fileField.text = selectedFile
					dialogLoader.active = false // visible=false is called before onAccepted
				}
				onRejected: {
					dialogLoader.active = false // visible=false is called before onRejected
				}

				// nameFilters must be set before opening the dialog.
				// If we create the dialog with visible=true, the nameFilters
				// will not be set before it opens.
				Component.onCompleted: {
					fileField.dialogOpen(dialog)
					visible = true
				}
			}
		}
	}
}
