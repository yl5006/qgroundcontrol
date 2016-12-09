import QtQuick          2.2
import QtQuick.Layouts  1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.Controls      1.0

GridLayout {
    property var factList   ///< List of Facts to show
    columns: 2
    rows: factList.length
    flow: GridLayout.TopToBottom
    property bool  showHelpdig:   false
    Repeater {
        model: parent.factList

        QGCLabel { text: modelData.shortDescription + ":" }
    }

    Repeater {
        model: parent.factList

        FactTextField {
            Layout.fillWidth:   true
            fact:               modelData
            showHelp:           showHelpdig
        }
    }
}
