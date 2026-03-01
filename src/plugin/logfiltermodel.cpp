#include "logfiltermodel.h"
#include "logmodel.h"

LogFilterModel::LogFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setFilterRole(LogModel::MessageRole);
    setDynamicSortFilter(true);
    connect(this, &QAbstractItemModel::modelReset,       this, &LogFilterModel::countChanged);
    connect(this, &QAbstractItemModel::rowsInserted,     this, &LogFilterModel::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved,      this, &LogFilterModel::countChanged);
    connect(this, &QAbstractItemModel::layoutChanged,    this, &LogFilterModel::countChanged);
}

void LogFilterModel::setSearchText(const QString &text)
{
    if (m_searchText == text)
        return;
    beginFilterChange();
    m_searchText = text;
    endFilterChange(QSortFilterProxyModel::Direction::Rows);
    Q_EMIT searchTextChanged();
}

void LogFilterModel::setMinPriority(int p)
{
    const int clamped = qBound(0, p, 7);
    if (m_minPriority == clamped)
        return;
    beginFilterChange();
    m_minPriority = clamped;
    endFilterChange(QSortFilterProxyModel::Direction::Rows);
    Q_EMIT minPriorityChanged();
}

void LogFilterModel::setFilterUnits(const QStringList &units)
{
    if (m_filterUnits == units)
        return;
    beginFilterChange();
    m_filterUnits = units;
    endFilterChange(QSortFilterProxyModel::Direction::Rows);
    Q_EMIT filterUnitsChanged();
}

void LogFilterModel::setErrorsOnly(bool v)
{
    if (m_errorsOnly == v)
        return;
    beginFilterChange();
    m_errorsOnly = v;
    if (v)
        m_minPriority = 3; // error threshold
    endFilterChange(QSortFilterProxyModel::Direction::Rows);
    Q_EMIT errorsOnlyChanged();
}

bool LogFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    const QAbstractItemModel *src = sourceModel();
    if (!src)
        return true;

    const QModelIndex idx = src->index(sourceRow, 0, sourceParent);

    // Priority filter
    const int prio = src->data(idx, LogModel::PriorityRole).toInt();
    if (prio > m_minPriority)
        return false;

    // Errors-only shortcut
    if (m_errorsOnly && prio > 3)
        return false;

    // Unit filter (if list is non-empty, entry's unit must be in it)
    if (!m_filterUnits.isEmpty()) {
        const QString unit = src->data(idx, LogModel::UnitRole).toString();
        if (!m_filterUnits.contains(unit, Qt::CaseInsensitive))
            return false;
    }

    // Free-text search across message + unit
    if (!m_searchText.isEmpty()) {
        const QString msg  = src->data(idx, LogModel::MessageRole).toString();
        const QString unit = src->data(idx, LogModel::UnitRole).toString();
        if (!msg.contains(m_searchText, Qt::CaseInsensitive) &&
            !unit.contains(m_searchText, Qt::CaseInsensitive))
            return false;
    }

    return true;
}
