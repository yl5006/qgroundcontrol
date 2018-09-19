#ifndef UPDATER_H
#define UPDATER_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
class updater : public QObject
{
    Q_OBJECT
public:
    explicit updater(QObject *parent = nullptr);

    QString changelog() const;
    QString moduleName() const;
    QStringList downloadUrl() const;
    QString platformKey() const;
    QString moduleVersion() const;
    QString latestVersion() const;


    bool updateAvailable() const;

signals:
    void checkingFinished (const QString& url);
    void downloadFinished (const QString& url, const QString& filepath);

public slots:
    void checkForUpdates();
    void setModuleVersion (const QString& version);
private slots:
    void onReply (QNetworkReply* reply);
    void setUpdateAvailable (const bool& available);
private:
    bool compare (const QString& x, const QString& y);

private:
     QNetworkAccessManager* m_manager;
     QNetworkReply* m_reply;

     QString m_url;
     bool m_updateAvailable;

     QString m_openUrl;
     QString m_platform;
     QString m_changelog;
     QString m_moduleName;
     QStringList m_downloadUrl;
     QString m_moduleVersion;
     QString m_latestVersion;
};

#endif // UPDATER_H
