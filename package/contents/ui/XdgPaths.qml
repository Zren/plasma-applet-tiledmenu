import QtQuick 2.0
import Qt.labs.platform 1.0 // StandardPaths (Qt 5.8+)

QtObject {
	id: xdgPaths

	readonly property string documents: StandardPaths.displayName(StandardPaths.DocumentsLocation)
	readonly property string download: StandardPaths.displayName(StandardPaths.DownloadLocation)
	readonly property string music: StandardPaths.displayName(StandardPaths.MusicLocation)
	readonly property string pictures: StandardPaths.displayName(StandardPaths.PicturesLocation)
	readonly property string movies: StandardPaths.displayName(StandardPaths.MoviesLocation)
}
