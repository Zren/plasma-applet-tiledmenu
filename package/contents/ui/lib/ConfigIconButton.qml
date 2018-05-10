import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0 as QQC2

// QtQuick2 button using Kirigami theme
//    /usr/lib/x86_64-linux-gnu/qt5/qml/QtQuick/Controls.2/org.kde.desktop/Button.qml
//    import org.kde.qqc2desktopstyle.private 1.0 as StylePrivate
//    https://github.com/KDE/qqc2-desktop-style/blob/master/plugin/kquickstyleitem.cpp#L1162

// The normal 'button' elementType centers the IconLabel,
// with no way to set the alignment or the minimum width.
// So we use toolbutton which left aligns.
QQC2.Button {
	id: iconButton
	
	property string iconName: ""

	Component.onCompleted: {
		background.elementType = 'toolbutton'

		// icon.name is a Qt 5.10 feature
		// So to be backward compatible with Kubuntu which has Qt 5.9, we need to do this.
		if (iconButton.hasOwnProperty("icon") && iconName && !icon.name) {
			icon.name = iconName
		}
	}
}
