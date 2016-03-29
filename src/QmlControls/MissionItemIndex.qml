import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtQuick.Dialogs          1.2

import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl               1.0

/// Mission item edit control
Rectangle {
    id: _root

//    height: editorLoader.y + editorLoader.height + (_margin * 2)
//    color:  _currentItem ? qgcPal.buttonHighlight : qgcPal.windowShade
//    radius: _radius

    property var    missionItem ///< MissionItem associated with this editor
    property bool   readOnly    ///< true: read only view, false: full editing view
    property var    qgcView     ///< QGCView control used for showing dialogs

    signal clicked
    signal remove
    signal insert(int i)
    signal moveHomeToMapCenter

    property bool   _currentItem:       missionItem.isCurrentItem
    property color  _outerTextColor:    _currentItem ? "black" : qgcPal.text

    readonly property real  _editFieldWidth:    ScreenTools.defaultFontPixelWidth * 16
    readonly property real  _margin:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius:            ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _PointFieldWidth:   ScreenTools.defaultFontPixelWidth * 10
    property real   _distance:          _statusValid ? missionItem.distance : 0
    property bool   _statusValid:       missionItem.command==16&&missionItem.sequenceNumber != 0
    property string _distanceText:      _distance<1000 ? QGroundControl.metersToAppSettingsDistanceUnits(_distance).toFixed(0) + " " + QGroundControl.appSettingsDistanceUnitsString : QGroundControl.metersToAppSettingsDistanceUnits(_distance/1000).toFixed(1) + "k" + QGroundControl.appSettingsDistanceUnitsString

    QGCPalette {
        id: qgcPal
        colorGroupEnabled: enabled
    }


    MouseArea {
        anchors.fill:   waypoint
 //     visible:        !missionItem.isCurrentItem
        onClicked:      _root.clicked()
    }

    QGCLabel {
        id:                     label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.leftMargin:     _margin
        anchors.top:            parent.top
//      anchors.left:           parent.left
        text:                   missionItem.sequenceNumber == 0 ? "Home" : missionItem.commandName
        color:                  _outerTextColor
    }
    Rectangle {
        id:                     waypoint
        width:                  parent.width
        height:                 parent.width
        radius:                 _radius*2
        anchors.top:            label.bottom
        color:                  _currentItem ? Qt.rgba(1,0.52,0,0.85):Qt.rgba(0.1133,0.5664,0.9063,0.85)


        QGCLabel {
            id:                  number
            anchors.top:            parent.top
            width:                  parent.width
            horizontalAlignment:    Text.AlignHCenter
            font.pixelSize:         ScreenTools.defaultFontPixelHeight*2
            font.bold:              true
            fontSizeMode:           Text.HorizontalFit
            color:                  "white"
            text:                   missionItem.sequenceNumber
        }
        Row {
           anchors.bottom:          waypoint.bottom
           anchors.bottomMargin:    _margin
           id:     altitudedisplay
           width:  parent.width*0.9//_largeColumn.width
           spacing:    _margin*2
           anchors.horizontalCenter:  parent.horizontalCenter
           Image{
               width:    ScreenTools.largeFontPixelSize
               height:   ScreenTools.largeFontPixelSize
               source:   "/qmlimages/altitudeRelativewhite.svg"
           }

           QGCLabel {
               width:                  parent.width*0.5
               horizontalAlignment:    Text.AlignHCenter
               font.pixelSize:         ScreenTools.largeFontPixelSize
               font.weight:            Font.DemiBold
               color:                  "white"
//             fontSizeMode:           Text.HorizontalFit
               text:                   missionItem.coordinate.altitude+" m"
           }
        }
           Row {
              anchors.bottom:           altitudedisplay.top
              anchors.bottomMargin:     _margin
              id:                       distancedisplay
              width:                    parent.width*0.9//_largeColumn.width
              spacing:                  _margin*2
              anchors.horizontalCenter:  parent.horizontalCenter
              visible:                  _statusValid
              Image{
                  width:    ScreenTools.largeFontPixelSize
                  height:   ScreenTools.largeFontPixelSize
                  source:   "/qmlimages/distance.svg"
              }

              QGCLabel {
                  width:                  parent.width*0.5
                  height:                 ScreenTools.largeFontPixelSize
                  horizontalAlignment:    Text.AlignHCenter
                  font.pixelSize:         ScreenTools.largeFontPixelSize
                  font.weight:            Font.DemiBold
                  color:                  "white"
//                  fontSizeMode:         Text.HorizontalFit
                  text:                   _distanceText//missionItem.distance
              }
        }
    }


//    Image {
//        id:                     hamburger
//        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
//        anchors.right:          parent.right
//        anchors.verticalCenter: commandPicker.verticalCenter
//        width:                  commandPicker.height
//        height:                 commandPicker.height
//        source:                 "qrc:/qmlimages/Hamburger.svg"
//        visible:                missionItem.isCurrentItem && missionItem.sequenceNumber != 0

//        MouseArea {
//            anchors.fill:   parent
//            onClicked:      hamburgerMenu.popup()

//            Menu {
//                id: hamburgerMenu

//                MenuItem {
//                    text:           "Insert"
//                    onTriggered:    insert(missionItem.sequenceNumber)
//                }

//                MenuItem {
//                    text:           "Delete"
//                    onTriggered:    remove()
//                }

//                MenuSeparator {
//                    visible: missionItem.isSimpleItem
//                }

//                MenuItem {
//                    text:       "Show all values"
//                    checkable:  true
//                    checked:    missionItem.isSimpleItem ? missionItem.rawEdit : false
//                    visible:    missionItem.isSimpleItem

//                    onTriggered:    {
//                        if (missionItem.rawEdit) {
//                            if (missionItem.friendlyEditAllowed) {
//                                missionItem.rawEdit = false
//                            } else {
//                                qgcView.showMessage("Mission Edit", "You have made changes to the mission item which cannot be shown in Simple Mode", StandardButton.Ok)
//                            }
//                        } else {
//                            missionItem.rawEdit = true
//                        }
//                        checked = missionItem.rawEdit
//                    }
//                }
//            }
//        }
//    }

//    QGCButton {
//        id:                     commandPicker
//        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 2
//        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
//        anchors.left:           label.right
//        anchors.right:          hamburger.left
//        visible:                missionItem.sequenceNumber != 0 && missionItem.isCurrentItem && !missionItem.rawEdit && missionItem.isSimpleItem
//        text:                   missionItem.commandName

//        Component {
//            id: commandDialog

//            MissionCommandDialog {
//                missionItem: _root.missionItem
//            }
//        }

//        onClicked:              qgcView.showDialog(commandDialog, "Select Mission Command", qgcView.showDialogDefaultWidth, StandardButton.Cancel)
//    }

//    QGCLabel {
//        anchors.fill:       commandPicker
//        visible:            missionItem.sequenceNumber == 0 || !missionItem.isCurrentItem || !missionItem.isSimpleItem
//        verticalAlignment:  Text.AlignVCenter
//        text:               missionItem.sequenceNumber == 0 ? "Home Position" : (missionItem.isSimpleItem ? missionItem.commandName : "Survey")
//        color:              _outerTextColor
//    }

//    Loader {
//        id:                 editorLoader
//        anchors.leftMargin: _margin
//        anchors.topMargin:  _margin
//        anchors.left:       parent.left
//        anchors.top:        commandPicker.bottom
//        height:             _currentItem && item ? item.height : 0
//        source:             _currentItem ? (missionItem.isSimpleItem ? "qrc:/qml/SimpleItemEditor.qml" : "qrc:/qml/SurveyItemEditor.qml") : ""

//        property real   availableWidth: _root.width - (_margin * 2) ///< How wide the editor should be
//        property var    editorRoot:     _root
//    }
} // Rectangle
