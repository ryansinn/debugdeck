#pragma once

#include <QSortFilterProxyModel>
#include <qqml.h>

/**
 * Proxy that sits on top of LogModel and lets the UI filter by:
 *   - free-text search across message + unit
 *   - minimum priority (0 = emergency … 7 = debug)
 *   - unit / service name allow-list
 */
class LogFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString     searchText    READ searchText    WRITE setSearchText    NOTIFY searchTextChanged)
    Q_PROPERTY(int         minPriority   READ minPriority   WRITE setMinPriority   NOTIFY minPriorityChanged)
    Q_PROPERTY(QStringList filterUnits   READ filterUnits   WRITE setFilterUnits   NOTIFY filterUnitsChanged)
    Q_PROPERTY(bool        errorsOnly    READ errorsOnly    WRITE setErrorsOnly    NOTIFY errorsOnlyChanged)
    Q_PROPERTY(int         count         READ count                                NOTIFY countChanged)

public:
    explicit LogFilterModel(QObject *parent = nullptr);

    int count() const { return rowCount(); }

    QString     searchText()  const { return m_searchText; }
    int         minPriority() const { return m_minPriority; }
    QStringList filterUnits() const { return m_filterUnits; }
    bool        errorsOnly()  const { return m_errorsOnly; }

    void setSearchText(const QString &text);
    void setMinPriority(int p);
    void setFilterUnits(const QStringList &units);
    void setErrorsOnly(bool v);

Q_SIGNALS:
    void searchTextChanged();
    void minPriorityChanged();
    void filterUnitsChanged();
    void errorsOnlyChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    QString     m_searchText;
    int         m_minPriority{7};   // show everything by default
    QStringList m_filterUnits;
    bool        m_errorsOnly{false};
};
