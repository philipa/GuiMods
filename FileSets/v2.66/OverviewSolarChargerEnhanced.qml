////// MODIFIED to hide Blue Solar icon
import QtQuick 1.1

Item {
    id: root

    default property alias values: blueSolarChargerBox.values
    property alias title: blueSolarChargerBox.title
    property bool showChargerIcon: true

    width: 155
    height: 115

    MbIcon {
        id: blueSolarChargerIcon

        iconId: "overview-bluesolar-charger"
        anchors.bottom: root.bottom
        visible: showChargerIcon
    }

    OverviewBox {
        id: blueSolarChargerBox

        height: root.height
        title: qsTr("PV Power")
        titleColor: "#F4B350"
        color: "#F39C12"

        anchors {
            bottom: root.bottom
            left: blueSolarChargerIcon.left; leftMargin: showChargerIcon ? 43 : 0
            right: parent.right
        }
    }

////// moved sun icon to flow overview so it can be put below text, etc

    MbIcon {
        anchors {
            bottom: blueSolarChargerBox.bottom; bottomMargin: 3
            left: parent.left; leftMargin: 2
        }
        iconId: "overview-victron-logo-small"
////// MODIFIED to hide Blue Solar icon
        visible: false
    }
}
