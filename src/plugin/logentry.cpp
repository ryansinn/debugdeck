#include "logentry.h"

LogEntry::LogEntry(const QDateTime &ts, const QString &unit, int priority, const QString &msg)
    : m_timestamp(ts)
    , m_unit(unit)
    , m_priority(qBound(0, priority, 7))
    , m_message(msg)
{
}

QString LogEntry::priorityName() const
{
    static const char *names[] = {
        "EMERG", "ALERT", "CRIT", "ERR", "WARNING", "NOTICE", "INFO", "DEBUG"
    };
    return QString::fromLatin1(names[qBound(0, m_priority, 7)]);
}
