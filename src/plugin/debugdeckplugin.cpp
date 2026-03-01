#include "debugdeckplugin.h"

#include "journaldwatcher.h"
#include "logentry.h"
#include "logfiltermodel.h"
#include "logmodel.h"

#include <QQmlEngine>

DebugDeckPlugin::DebugDeckPlugin(QObject *parent)
    : QQmlEngineExtensionPlugin(parent)
{
}

void DebugDeckPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(uri)
    Q_UNUSED(engine)
    // Qt 6 auto-registration handles QML_ELEMENT / QML_VALUE_TYPE macros.
    // Any extra engine setup (e.g. singleton factories) goes here.
}
