#include "updater.h"
#include <QJsonValue>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDesktopServices>
#include <QProcess>
static const QString DEFS_URL = "http://91aerfa.vip:7070/update/updates.json";

updater::updater(QObject *parent) : QObject(parent)
{
    m_url = DEFS_URL;
    m_openUrl = "";
    m_changelog = "";
    m_manager = new QNetworkAccessManager();
    m_updateAvailable = false;
#if defined Q_OS_WIN
    m_platform = "windows";
#elif defined Q_OS_MAC
    m_platform = "osx";
#elif defined Q_OS_LINUX
    m_platform = "linux";
#elif defined Q_OS_ANDROID
    m_platform = "android";
#elif defined Q_OS_IOS
    m_platform = "ios";
#endif
    connect (m_manager,    SIGNAL (finished (QNetworkReply*)),
             this,           SLOT (onReply  (QNetworkReply*)));
}
QString updater::changelog() const {
    return m_changelog;
}

QString updater::moduleName() const {
    return m_moduleName;
}

QString updater::platformKey() const {
    return m_platform;
}

QStringList updater::downloadUrl() const {
    return m_downloadUrl;
}

QString updater::latestVersion() const {
    return m_latestVersion;
}

QString updater::moduleVersion() const {
    return m_moduleVersion;
}

void updater::setModuleVersion (const QString& version) {
    m_moduleVersion = version;
}

bool updater::updateAvailable() const {
    return m_updateAvailable;
}

void updater::setUpdateAvailable (const bool& available) {
    m_updateAvailable = available;
}

void updater::checkForUpdates() {
    m_manager->get (QNetworkRequest (m_url));
}

void updater::onReply (QNetworkReply* reply) {
    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument document = QJsonDocument::fromJson (reply->readAll());

        if (document.isNull())
            return;

        QJsonObject updates = document.object().value ("updates").toObject();
        QJsonObject platform = updates.value (platformKey()).toObject();

        m_openUrl = platform.value ("open-url").toString();
        m_changelog = platform.value ("changelog").toString();
        m_downloadUrl.append(platform.value ("download-url").toString());
        m_latestVersion = platform.value ("latest-version").toString();

        setUpdateAvailable (compare (latestVersion(), moduleVersion()));
    }
     emit checkingFinished (m_url);
}


bool updater::compare (const QString& x, const QString& y) {
    QStringList versionsX = x.split (".");
    QStringList versionsY = y.split (".");

    int count = qMin (versionsX.count(), versionsY.count());

    for (int i = 0; i < count; ++i) {
        int a = QString (versionsX.at (i)).toInt();
        int b = QString (versionsY.at (i)).toInt();

        if (a > b)
            return true;

        else if (b > a)
            return false;
    }

    return versionsY.count() < versionsX.count();
}
