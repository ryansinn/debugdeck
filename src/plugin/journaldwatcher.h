#pragma once

#include <QObject>
#include <QProcess>
#include <QSocketNotifier>
#include <QStringList>
#include <qqml.h>

#ifdef HAVE_SYSTEMD
#include <systemd/sd-journal.h>
#endif

class JournaldWatcher : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(QStringList units  READ units  WRITE setUnits  NOTIFY unitsChanged)
    Q_PROPERTY(QStringList priorities READ priorities WRITE setPriorities NOTIFY prioritiesChanged)

public:
    enum Priority {
        Emergency = 0,
        Alert     = 1,
        Critical  = 2,
        Error     = 3,
        Warning   = 4,
        Notice    = 5,
        Info      = 6,
        Debug     = 7
    };
    Q_ENUM(Priority)

    explicit JournaldWatcher(QObject *parent = nullptr);
    ~JournaldWatcher() override;

    bool isRunning() const;

    QStringList units() const;
    void setUnits(const QStringList &units);

    QStringList priorities() const;
    void setPriorities(const QStringList &priorities);

public Q_SLOTS:
    void start();
    void stop();
    void clear();

Q_SIGNALS:
    void runningChanged();
    void unitsChanged();
    void prioritiesChanged();
    /// Emitted for every new log line; fields: timestamp, unit, priority (int), message
    void entryReceived(const QString &timestamp,
                       const QString &unit,
                       int priority,
                       const QString &message);

private Q_SLOTS:
    void onReadyRead();
    void onProcessError(QProcess::ProcessError error);

private:
    QStringList buildArgs() const;
    void parseLine(const QByteArray &line);

    QProcess   *m_process{nullptr};
    QStringList m_units;
    QStringList m_priorities;

#ifdef HAVE_SYSTEMD
    void startNative();
    QSocketNotifier *m_journalNotifier{nullptr};
    sd_journal      *m_journal{nullptr};
#endif
};
