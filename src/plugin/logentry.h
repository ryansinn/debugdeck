#pragma once

#include <QDateTime>
#include <QObject>
#include <qqml.h>

/**
 * Plain data class for a single journal log entry.
 * Exposed to QML as a value type via Q_GADGET.
 */
class LogEntry
{
    Q_GADGET
    QML_VALUE_TYPE(logEntry)

    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    Q_PROPERTY(QString   unit      READ unit      CONSTANT)
    Q_PROPERTY(int       priority  READ priority  CONSTANT)
    Q_PROPERTY(QString   message   READ message   CONSTANT)
    Q_PROPERTY(bool      isError   READ isError   CONSTANT)
    Q_PROPERTY(bool      isWarning READ isWarning CONSTANT)

public:
    LogEntry() = default;
    LogEntry(const QDateTime &ts, const QString &unit, int priority, const QString &msg);

    QDateTime timestamp() const { return m_timestamp; }
    QString   unit()      const { return m_unit; }
    int       priority()  const { return m_priority; }
    QString   message()   const { return m_message; }

    /// priority <= 3  (emergency/alert/critical/error)
    bool isError()   const { return m_priority <= 3; }
    /// priority == 4  (warning)
    bool isWarning() const { return m_priority == 4; }

    QString priorityName() const;

private:
    QDateTime m_timestamp;
    QString   m_unit;
    int       m_priority{6};
    QString   m_message;
};

Q_DECLARE_METATYPE(LogEntry)
