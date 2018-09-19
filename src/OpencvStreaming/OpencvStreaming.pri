# -------------------------------------------------
# QGroundControl - Micro Air Vehicle Groundstation
# Please see our website at <http://qgroundcontrol.org>
# Maintainer:
# Lorenz Meier <lm@inf.ethz.ch>
# (c) 2009-2015 QGroundControl Developers
#
# This file is part of the open groundstation project
# QGroundControl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# QGroundControl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with QGroundControl. If not, see <http://www.gnu.org/licenses/>.
#
# Author: yaoling <yaoling@ewatt.com>
# -------------------------------------------------

#
#-- Depends on opencv, which can be found at: http://gstreamer.freedesktop.org/download/
#
WindowsBuild {
    #- opencv installed by default under   v
    OPENCV_ROOT = D:/opencv/build/x86/vc12
    exists($$OPENCV_ROOT) {
        CONFIG      += OpencvEnabled
        DEFINES += QGC_DISABLE_UVC
        INCLUDEPATH +=  $$OPENCV_ROOT/../../include/opencv \
                        $$OPENCV_ROOT/../../include/opencv2 \
                        $$OPENCV_ROOT/../../include

        INCLUDEPATH +=  $$PWD/include

        LIBS+=$$PWD/vs2015_x86/lib/libusb.lib
        LIBS+=$$PWD/vs2015_x86/lib/Mana_Lynmax4D.lib
        LIBS+=$$PWD/vs2015_x86/lib/Mana_Lynmax4Dd.lib

        LIBS+=$$OPENCV_ROOT/lib/opencv_ml249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_calib3d249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_contrib249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_core249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_features2d249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_flann249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_gpu249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_highgui249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_imgproc249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_legacy249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_objdetect249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_video249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_nonfree249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_ocl249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_photo249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_stitching249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_superres249.lib
        LIBS+=$$OPENCV_ROOT/lib/opencv_videostab249.lib

    COPY_FILE_LIST = \
        $$OPENCV_ROOT\\bin\\opencv_ml249.dll \
        $$OPENCV_ROOT\\bin\\opencv_calib3d249.dll \
        $$OPENCV_ROOT\\bin\\opencv_contrib249.dll \
        $$OPENCV_ROOT\\bin\\opencv_core249.dll \
        $$OPENCV_ROOT\\bin\\opencv_features2d249.dll \
        $$OPENCV_ROOT\\bin\\opencv_flann249.dll \
        $$OPENCV_ROOT\\bin\\opencv_gpu249.dll \
        $$OPENCV_ROOT\\bin\\opencv_highgui249.dll \
        $$OPENCV_ROOT\\bin\\opencv_imgproc249.dll \
        $$OPENCV_ROOT\\bin\\opencv_legacy249.dll \
        $$OPENCV_ROOT\\bin\\opencv_objdetect249.dll \
        $$OPENCV_ROOT\\bin\\opencv_video249.dll \
        $$OPENCV_ROOT\\bin\\opencv_nonfree249.dll \
        $$OPENCV_ROOT\\bin\\opencv_ocl249.dll \
        $$OPENCV_ROOT\\bin\\opencv_photo249.dll \
        $$OPENCV_ROOT\\bin\\opencv_stitching249.dll \
        $$OPENCV_ROOT\\bin\\opencv_superres249.dll \
        $$OPENCV_ROOT\\bin\\opencv_videostab249.dll \
        $$PWD\\vs2015_x86\\bin\\avcodec-57.dll \
        $$PWD\\vs2015_x86\\bin\\avdevice-57.dll \
        $$PWD\\vs2015_x86\\bin\\avfilter-6.dll \
        $$PWD\\vs2015_x86\\bin\\avformat-57.dll \
        $$PWD\\vs2015_x86\\bin\\avutil-55.dll \
        $$PWD\\vs2015_x86\\bin\\libusb0_x86.dll \
        $$PWD\\vs2015_x86\\bin\\Mana_Lynmax4D.dll \
        $$PWD\\vs2015_x86\\bin\\Mana_Lynmax4Dd.dll \
        $$PWD\\vs2015_x86\\bin\\postproc-54.dll \
        $$PWD\\vs2015_x86\\bin\\swresample-2.dll \
        $$PWD\\vs2015_x86\\bin\\swscale-4.dll \

    DESTDIR_WIN = $$replace(DESTDIR, "/", "\\")

    for(COPY_FILE, COPY_FILE_LIST) {
        QMAKE_POST_LINK += $$escape_expand(\\n) $$QMAKE_COPY \"$$COPY_FILE\" \"$$DESTDIR_WIN\"
    }
    QMAKE_POST_LINK += $$escape_expand(\\n)
    }
}

#WindowsBuild {
#    #- opencv installed by default under   v
#    OPENCV_ROOT = $$PWD
#    exists($$OPENCV_ROOT) {
#        CONFIG      += OpencvEnabled
#        INCLUDEPATH +=  $$OPENCV_ROOT/include/3rdparty \
#                        $$OPENCV_ROOT/include
#        LIBS+=$$OPENCV_ROOT/vs2015_x86/lib/libusb.lib
#        LIBS+=$$OPENCV_ROOT/vs2015_x86/lib/Mana_Lynmax4D.lib
#        LIBS+=$$OPENCV_ROOT/vs2015_x86/lib/Mana_Lynmax4Dd.lib
#        LIBS+=$$OPENCV_ROOT/vs2015_x86/lib/opencv_world330.lib
#        LIBS+=$$OPENCV_ROOT/vs2015_x86/lib/opencv_world330d.lib

#    COPY_FILE_LIST = \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\avcodec-57.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\avdevice-57.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\avfilter-6.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\avformat-57.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\avutil-55.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\libusb0_x86.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\Mana_Lynmax4D.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\Mana_Lynmax4Dd.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\opencv_world330.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\opencv_world330d.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\postproc-54.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\swresample-2.dll \
#        $$OPENCV_ROOT\\vs2015_x86\\bin\\swscale-4.dll \


#    DESTDIR_WIN = $$replace(DESTDIR, "/", "\\")

#    for(COPY_FILE, COPY_FILE_LIST) {
#        QMAKE_POST_LINK += $$escape_expand(\\n) $$QMAKE_COPY \"$$COPY_FILE\" \"$$DESTDIR_WIN\"
#    }
#    QMAKE_POST_LINK += $$escape_expand(\\n)
#    }
#}


OpencvEnabled {
    message("Including support for video Opencv streaming")
    DEFINES += \
         QGC_OPENCV_STREAMING
#        GST_PLUGIN_BUILD_STATIC \
#        QTGLVIDEOSINK_NAME=qt5glvideosink \
#        QGC_VIDEOSINK_PLUGIN=qt5videosink
#    INCLUDEPATH += \
    #-- Opencv (gutted to our needs)
HEADERS += \
    $$PWD/opencvaction.h \
    $$PWD/opencvcamera.h \
    $$PWD/opencvcannyaction.h \
    $$PWD/opencvcapture.h \
    $$PWD/opencvcommonaction.h \
    $$PWD/opencvfacedetectaction.h \
    $$PWD/opencvfacerecognizer.h \
    $$PWD/opencvshowframe.h \
    $$PWD/typedef.h

SOURCES += \
    $$PWD/opencvaction.cpp \
    $$PWD/opencvcamera.cpp \
    $$PWD/opencvcannyaction.cpp \
    $$PWD/opencvcapture.cpp \
    $$PWD/opencvcommonaction.cpp \
    $$PWD/opencvfacedetectaction.cpp \
    $$PWD/opencvfacerecognizer.cpp \
    $$PWD/opencvshowframe.cpp
}

SOURCES += \
    $$PWD/tracker.cpp

HEADERS += \
    $$PWD/tracker.h
