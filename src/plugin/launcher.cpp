#include "launcher.h"

#include <QProcess>

Launcher::Launcher(QObject *parent)
    : QObject(parent)
{
}

bool Launcher::run(const QString &program, const QStringList &args) const
{
    return QProcess::startDetached(program, args);
}

bool Launcher::runInTerminal(const QString &command) const
{
    // Try common terminal emulators in preference order
    const QStringList terms = {
        QStringLiteral("konsole"),
        QStringLiteral("xterm"),
        QStringLiteral("alacritty"),
        QStringLiteral("kitty"),
        QStringLiteral("gnome-terminal"),
    };

    for (const QString &term : terms) {
        QStringList args;
        if (term == QLatin1String("konsole"))
            args = { QStringLiteral("--noclose"), QStringLiteral("-e"),
                     QStringLiteral("bash"), QStringLiteral("-c"), command };
        else if (term == QLatin1String("gnome-terminal"))
            args = { QStringLiteral("--"), QStringLiteral("bash"),
                     QStringLiteral("-c"), command + QStringLiteral("; read") };
        else
            args = { QStringLiteral("-e"), QStringLiteral("bash"),
                     QStringLiteral("-c"), command + QStringLiteral("; read") };

        if (QProcess::startDetached(term, args))
            return true;
    }
    return false;
}
