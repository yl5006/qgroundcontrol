#include <QEventLoop>
#include "updater.h"
class WaitForSignalHelper : public QObject
{
    Q_OBJECT
public:
    WaitForSignalHelper( updater * object, const char* signal );

    // return false if signal wait timed-out
    bool wait(int timeoutMs );

public slots:
    void timeout();

private:
    bool m_bTimeout;
    QEventLoop m_eventLoop;
};
