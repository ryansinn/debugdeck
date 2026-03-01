#pragma once

#include "logentry.h"

#include <QAbstractListModel>
#include <qqml.h>

/**
 * Thread-safe list model that stores LogEntry objects.
 * Exposed to QML; has a configurable cap on the number of retained entries.
 */
class LogModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int  count    READ rowCount   NOTIFY countChanged)
    Q_PROPERTY(int  maxRows  READ maxRows    WRITE setMaxRows   NOTIFY maxRowsChanged)
    Q_PROPERTY(int  errorCount   READ errorCount   NOTIFY errorCountChanged)
    Q_PROPERTY(int  warningCount READ warningCount NOTIFY warningCountChanged)

public:
    enum Roles {
        TimestampRole = Qt::UserRole + 1,
        UnitRole,
        PriorityRole,
        PriorityNameRole,
        MessageRole,
        IsErrorRole,
        IsWarningRole,
    };
    Q_ENUM(Roles)

    explicit LogModel(QObject *parent = nullptr);

    // QAbstractListModel
    int      rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int maxRows() const  { return m_maxRows; }
    void setMaxRows(int n);

    int errorCount()   const { return m_errorCount; }
    int warningCount() const { return m_warningCount; }

public Q_SLOTS:
    void appendEntry(const QString &timestamp, const QString &unit,
                     int priority, const QString &message);
    void clear();

Q_SIGNALS:
    void countChanged();
    void maxRowsChanged();
    void errorCountChanged();
    void warningCountChanged();
    /// Fired when a new error-or-worse entry arrives (for alert overlay)
    void newError(const LogEntry &entry);

private:
    void trimToMax();
    void rebuildCounts();

    QList<LogEntry> m_entries;
    int  m_maxRows{5000};
    int  m_errorCount{0};
    int  m_warningCount{0};
};
