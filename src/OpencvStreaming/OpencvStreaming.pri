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

LinuxBuild {
    CONFIG += link_pkgconfig
    packagesExist(gstreamer-1.0) {
        PKGCONFIG   += gstreamer-1.0  gstreamer-video-1.0
        CONFIG      += VideoEnabled
    }
} else:MacBuild {
    #- gstreamer framework installed by the gstreamer devel installer
    GST_ROOT = /Library/Frameworks/GStreamer.framework
    exists($$GST_ROOT) {
        CONFIG      += VideoEnabled
        INCLUDEPATH += $$GST_ROOT/Headers
        LIBS        += -F/Library/Frameworks -framework GStreamer
    }
} else:iOSBuild {
    #- gstreamer framework installed by the gstreamer iOS SDK installer (default to home directory)
    GST_ROOT = $$(HOME)/Library/Developer/GStreamer/iPhone.sdk/GStreamer.framework
    exists($$GST_ROOT) {
        CONFIG      += VideoEnabled
        INCLUDEPATH += $$GST_ROOT/Headers
        LIBS        += -F$$(HOME)/Library/Developer/GStreamer/iPhone.sdk -framework GStreamer -liconv -lresolv
    }
} else:WindowsBuild {
    #- opencv installed by default under  d:/opencv
    OPENCV_ROOT = D:/opencv/build/x86/vc12
    exists($$OPENCV_ROOT) {
        CONFIG      += OpencvEnabled
        INCLUDEPATH +=  $$OPENCV_ROOT/../../include/opencv \
                        $$OPENCV_ROOT/../../include/opencv2 \
                        $$OPENCV_ROOT/../../include
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

    DESTDIR_WIN = $$replace(DESTDIR, "/", "\\")

    for(COPY_FILE, COPY_FILE_LIST) {
        QMAKE_POST_LINK += $$escape_expand(\\n) $$QMAKE_COPY \"$$COPY_FILE\" \"$$DESTDIR_WIN\"
    }
    QMAKE_POST_LINK += $$escape_expand(\\n)
 }

} else:AndroidBuild {
    #- gstreamer assumed to be installed in $$PWD/../../android/gstreamer-1.0-android-armv7-1.5.2
    GST_ROOT = $$PWD/../../gstreamer-1.0-android-armv7-1.5.2
    exists($$GST_ROOT) {
        QMAKE_CXXFLAGS  += -pthread
        CONFIG          += VideoEnabled

        # We want to link these plugins statically
        LIBS += -L$$GST_ROOT/lib/gstreamer-1.0/static \
            -lgstvideo-1.0 \
            -lgstcoreelements \
            -lgstudp \
            -lgstrtp \
            -lgstx264 \
            -lgstlibav \
            -lgstvideoparsersbad

        # Rest of GStreamer dependencies
        LIBS += -L$$GST_ROOT/lib \
            -lgstfft-1.0 -lm  \
            -lgstnet-1.0 -lgio-2.0 \
            -lgstaudio-1.0 -lgstcodecparsers-1.0 -lgstbase-1.0 \
            -lgstreamer-1.0 -lgsttag-1.0 -lgstrtp-1.0 -lgstpbutils-1.0 \
            -lgstvideo-1.0 -lavformat -lavcodec -lavresample -lavutil -lx264 \
            -lbz2 -lgobject-2.0 \
            -Wl,--export-dynamic -lgmodule-2.0 -pthread -lglib-2.0 -lorc-0.4 -liconv -lffi -lintl

        INCLUDEPATH += \
            $$GST_ROOT/include/gstreamer-1.0 \
            $$GST_ROOT/lib/gstreamer-1.0/include \
            $$GST_ROOT/include/glib-2.0 \
            $$GST_ROOT/lib/glib-2.0/include
    }
}

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
