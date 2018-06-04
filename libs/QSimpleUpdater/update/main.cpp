//#include <QCoreApplication>
#include <QSimpleUpdater.h>
#include <QApplication>
#include <QSettings>
#include <QDebug>
#pragma execution_character_set("utf-8")
static const QString DEFS_URL = "http://91aerfa.vip:7070/update/updates.json";
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QString version="0.1";
    a.setApplicationName("易瓦特");
    a.setOrganizationName("GroundStation.org");
    a.setApplicationVersion("1.0");
    if(argc>1)
    {
        qDebug() <<argv[1];
        version=argv[1];
    }
     else
    {
        QSettings::setDefaultFormat(QSettings::IniFormat);
        QSettings settings;
        version=settings.value("appVersion","0.0").toString();
        qDebug() << "Settings location" << settings.fileName() << "version?:" << version;
    }

//    QSettings::setDefaultFormat(QSettings::IniFormat);
//    QSettings settings;
//    version=settings.value("appVersion","0.0").toString();

    QSimpleUpdater *m_updater = QSimpleUpdater::getInstance();

    m_updater = QSimpleUpdater::getInstance();

    m_updater->setModuleVersion (DEFS_URL, version);
    m_updater->setNotifyOnFinish (DEFS_URL, false);
    m_updater->setNotifyOnUpdate (DEFS_URL, false);
    m_updater->setDownloaderEnabled (DEFS_URL, true);
    /* Check for updates when the "Check For Updates" button is clicked */

    m_updater->checkForUpdates (DEFS_URL);

    return a.exec();
}

