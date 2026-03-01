#pragma once

#include <QObject>
#include <QStringList>
#include <qqml.h>

/**
 * Thin wrapper around QProcess::startDetached so QML can launch
 * arbitrary programs without needing exec: URL hacks.
 */
class Launcher : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Launcher(QObject *parent = nullptr);

    Q_INVOKABLE bool run(const QString &program,
                         const QStringList &args = {}) const;

    /// Convenience: run inside a new xterm window
    Q_INVOKABLE bool runInTerminal(const QString &command) const;
};
