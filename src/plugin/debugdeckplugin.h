#pragma once

#include <QQmlEngineExtensionPlugin>

class DebugDeckPlugin : public QQmlEngineExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlEngineExtensionInterface_iid)

public:
    explicit DebugDeckPlugin(QObject *parent = nullptr);
    void initializeEngine(QQmlEngine *engine, const char *uri) override;
};
