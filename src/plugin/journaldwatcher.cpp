#include "journaldwatcher.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QSocketNotifier>
#include <QTimeZone>

// ─────────────────────────────────────────────────────────────────────────────
//  journalctl is invoked with --output=json --follow so each line is a
//  complete JSON object that we can parse directly.
// ─────────────────────────────────────────────────────────────────────────────

JournaldWatcher::JournaldWatcher(QObject *parent)
    : QObject(parent)
{
}

JournaldWatcher::~JournaldWatcher()
{
    stop();
}

bool JournaldWatcher::isRunning() const
{
    return m_process && m_process->state() != QProcess::NotRunning;
}

QStringList JournaldWatcher::units() const      { return m_units; }
QStringList JournaldWatcher::priorities() const { return m_priorities; }

void JournaldWatcher::setUnits(const QStringList &units)
{
    if (m_units == units) return;
    m_units = units;
    Q_EMIT unitsChanged();
}

void JournaldWatcher::setPriorities(const QStringList &priorities)
{
    if (m_priorities == priorities) return;
    m_priorities = priorities;
    Q_EMIT prioritiesChanged();
}

// ── start / stop ─────────────────────────────────────────────────────────────

void JournaldWatcher::start()
{
    stop();

    m_process = new QProcess(this);
    m_process->setReadChannel(QProcess::StandardOutput);

    connect(m_process, &QProcess::readyReadStandardOutput,
            this, &JournaldWatcher::onReadyRead);
    connect(m_process, &QProcess::errorOccurred,
            this, &JournaldWatcher::onProcessError);
    connect(m_process, &QProcess::stateChanged, this, [this]{
        Q_EMIT runningChanged();
    });

    m_process->start(QStringLiteral("journalctl"), buildArgs());
    Q_EMIT runningChanged();
}

void JournaldWatcher::stop()
{
    if (!m_process)
        return;
    m_process->terminate();
    if (!m_process->waitForFinished(2000))
        m_process->kill();
    m_process->deleteLater();
    m_process = nullptr;
    Q_EMIT runningChanged();
}

void JournaldWatcher::clear()
{
    // No-op on the watcher itself; the model handles clearing stored entries.
}

// ── private helpers ───────────────────────────────────────────────────────────

QStringList JournaldWatcher::buildArgs() const
{
    QStringList args;
    args << QStringLiteral("--output=json")
         << QStringLiteral("--follow")
         << QStringLiteral("--no-pager")
         << QStringLiteral("-n") << QStringLiteral("200"); // seed with last 200 lines

    for (const QString &u : m_units)
        args << QStringLiteral("-u") << u;

    // journalctl priority filter: show up to (and including) the given level
    // default: show everything (7 = debug)
    int lowestPrio = 7;
    if (!m_priorities.isEmpty()) {
        for (const QString &p : m_priorities)
            lowestPrio = qMax(lowestPrio, p.toInt());
    }
    args << QStringLiteral("-p") << QStringLiteral("0..%1").arg(lowestPrio);

    return args;
}

void JournaldWatcher::onReadyRead()
{
    while (m_process && m_process->canReadLine()) {
        const QByteArray line = m_process->readLine().trimmed();
        if (!line.isEmpty())
            parseLine(line);
    }
}

void JournaldWatcher::parseLine(const QByteArray &line)
{
    // journalctl --output=json emits one JSON object per line
    const QJsonDocument doc = QJsonDocument::fromJson(line);
    if (doc.isNull() || !doc.isObject())
        return;

    const QJsonObject obj = doc.object();

    // __REALTIME_TIMESTAMP is microseconds since epoch
    const qint64 us       = obj.value(QStringLiteral("__REALTIME_TIMESTAMP")).toString().toLongLong();
    const QDateTime ts    = QDateTime::fromMSecsSinceEpoch(us / 1000, QTimeZone::UTC).toLocalTime();

    const QString unit    = obj.value(QStringLiteral("_SYSTEMD_UNIT")).toString(
                                obj.value(QStringLiteral("SYSLOG_IDENTIFIER")).toString(QStringLiteral("kernel")));
    const int     prio    = obj.value(QStringLiteral("PRIORITY")).toString(QStringLiteral("6")).toInt();
    const QString message = obj.value(QStringLiteral("MESSAGE")).toString();

    Q_EMIT entryReceived(ts.toString(Qt::ISODateWithMs), unit, prio, message);
}

void JournaldWatcher::onProcessError(QProcess::ProcessError error)
{
    qWarning("[DebugDeck] journalctl process error: %d", static_cast<int>(error));
    Q_EMIT runningChanged();
}
