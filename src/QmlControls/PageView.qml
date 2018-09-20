import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Layouts          1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Rectangle {
    id:     _root
    height: pageFlickable.y + pageFlickable.height + _margins
    color:  "transparent"//qgcPal.window
    radius: ScreenTools.defaultFontPixelWidth * 0.5

    property var    qgcView         ///< QGCView to use for showing dialogs
    property real   maxHeight       ///< Maximum height that should be taken, smaller than this is ok

    property real   _margins:           ScreenTools.defaultFontPixelWidth / 2
    property real   _pageWidth:         _root.width
    property var    _instrumentPages:   QGroundControl.corePlugin.instrumentPages
    property int    checkindex:         0
    QGCPalette { id:qgcPal; colorGroupEnabled: parent.enabled }
    Component.onCompleted: {
         pageWidgetLoader.source = _instrumentPages[0].url
         checkindex = 0
    }

    Rectangle {
        id:         selectdis
        height:     ScreenTools.defaultFontPixelHeight*3
        width:      parent.width
        color:      qgcPal.window
        radius:     ScreenTools.defaultFontPixelHeight
        Row{
          anchors.top:  parent.top
          anchors.left: parent.left
          anchors.leftMargin: ScreenTools.defaultFontPixelHeight
          height:       ScreenTools.defaultFontPixelHeight*3
          spacing:      ScreenTools.defaultFontPixelHeight
          Repeater{
                    model:  _instrumentPages
                    QGCColoredImage   {
                        anchors.verticalCenter: parent.verticalCenter
                        source:     modelData.icon
                        height:     ScreenTools.defaultFontPixelHeight*2
                        width:      height
                        color:      checkindex == index? qgcPal.buttonHighlight : qgcPal.button
                        QGCMouseArea {
                            fillItem:   parent
                            onClicked:  {
                                checkindex  =  index
                                pageFlickable.visible = true
                                pageWidgetLoader.source = modelData.url
                            }

                        }
                    }
           }
        }
    }
/*
    QGCComboBox {
        id:             pageCombo
        anchors.top:    selectdis.bottom
        anchors.topMargin: ScreenTools.defaultFontPixelHeight
        anchors.left:   parent.left
        anchors.right:  parent.right
        model:          _instrumentPages
        textRole:       "title"
        centeredLabel:  true
        pointSize:      ScreenTools.smallFontPointSize

        Image {
            anchors.leftMargin:     _margins
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            source:                 qgcPal.globalTheme == QGCPalette.Light ? "/res/gear-black.svg" : "/res/gear-white.svg"
            mipmap:                 true
            width:                  parent.height -(_margins * 2)
            sourceSize.width:       width
            fillMode:               Image.PreserveAspectFit
            visible:                pageWidgetLoader.item ? (pageWidgetLoader.item.showSettingsIcon ? pageWidgetLoader.item.showSettingsIcon : false) : false

            QGCMouseArea {
                fillItem:   parent
                onClicked:  pageWidgetLoader.item.showSettings()
            }
        }
    }
*/  Rectangle {
         anchors.fill: pageFlickable
         color:      qgcPal.window
         visible:   pageFlickable.visible
    }
    ImageButton {
        height:     ScreenTools.defaultFontPixelHeight
        width:      height
        anchors.margins: ScreenTools.defaultFontPixelHeight
        anchors.bottom: pageFlickable.bottom
        anchors.right:  pageFlickable.right
        visible:        pageFlickable.visible
        z:              pageFlickable.z +1
        imageResource:          "/qmlimages/hide.svg"
        onClicked:          {
            pageFlickable.visible = false
        }
    }
    QGCFlickable {
        id:                 pageFlickable
        anchors.topMargin:     _margins*8
        anchors.top:        selectdis.bottom
        anchors.left:       parent.left
        anchors.right:      parent.right
        height:             Math.min(_maxHeight, pageWidgetLoader.height)
        contentHeight:      pageWidgetLoader.height
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        property real _maxHeight: maxHeight - y - _margins

        Loader {
            id:     pageWidgetLoader
       //     source: _instrumentPages[pageCombo.currentIndex].url

            property var    qgcView:    _root.qgcView
            property real   pageWidth:  parent.width
        }
    }
}
