#include "logmodel.h"

#include <QDateTime>

LogModel::LogModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int LogModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_entries.size();
}

QVariant LogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};

    const LogEntry &e = m_entries.at(index.row());

    switch (role) {
    case TimestampRole:   return e.timestamp();
    case UnitRole:        return e.unit();
    case PriorityRole:    return e.priority();
    case PriorityNameRole:return e.priorityName();
    case MessageRole:     return e.message();
    case IsErrorRole:     return e.isError();
    case IsWarningRole:   return e.isWarning();
    default:              return {};
    }
}

QHash<int, QByteArray> LogModel::roleNames() const
{
    return {
        { TimestampRole,    "timestamp"    },
        { UnitRole,         "unit"         },
        { PriorityRole,     "priority"     },
        { PriorityNameRole, "priorityName" },
        { MessageRole,      "message"      },
        { IsErrorRole,      "isError"      },
        { IsWarningRole,    "isWarning"    },
    };
}

void LogModel::setMaxRows(int n)
{
    if (n == m_maxRows)
        return;
    m_maxRows = qMax(100, n);
    trimToMax();
    Q_EMIT maxRowsChanged();
}

void LogModel::appendEntry(const QString &timestamp, const QString &unit,
                            int priority, const QString &message)
{
    const QDateTime ts = QDateTime::fromString(timestamp, Qt::ISODateWithMs);
    LogEntry entry(ts.isValid() ? ts : QDateTime::currentDateTime(), unit, priority, message);

    beginInsertRows({}, m_entries.size(), m_entries.size());
    m_entries.append(entry);
    endInsertRows();

    if (entry.isError()) {
        ++m_errorCount;
        Q_EMIT errorCountChanged();
        Q_EMIT newError(entry);
    } else if (entry.isWarning()) {
        ++m_warningCount;
        Q_EMIT warningCountChanged();
    }

    Q_EMIT countChanged();
    trimToMax();
}

void LogModel::clear()
{
    beginResetModel();
    m_entries.clear();
    m_errorCount = 0;
    m_warningCount = 0;
    endResetModel();
    Q_EMIT countChanged();
    Q_EMIT errorCountChanged();
    Q_EMIT warningCountChanged();
}

void LogModel::trimToMax()
{
    if (m_entries.size() <= m_maxRows)
        return;

    const int excess = m_entries.size() - m_maxRows;
    beginRemoveRows({}, 0, excess - 1);
    m_entries.remove(0, excess);
    endRemoveRows();
    rebuildCounts();
    Q_EMIT countChanged();
}

void LogModel::rebuildCounts()
{
    int errors = 0, warnings = 0;
    for (const auto &e : std::as_const(m_entries)) {
        if (e.isError())        ++errors;
        else if (e.isWarning()) ++warnings;
    }
    if (m_errorCount != errors) {
        m_errorCount = errors;
        Q_EMIT errorCountChanged();
    }
    if (m_warningCount != warnings) {
        m_warningCount = warnings;
        Q_EMIT warningCountChanged();
    }
}
