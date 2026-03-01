# ── DebugDeck QML plugin ──────────────────────────────────────────────────────
# qt_add_qml_module is required in Qt 6 for QML_ELEMENT registration + typeinfo
qt_add_qml_module(debugdeckplugin
    URI             com.github.debugdeck
    VERSION         1.0
    PLUGIN_TARGET   debugdeckplugin
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/com/github/debugdeck"
    SOURCES
        journaldwatcher.cpp  journaldwatcher.h
        launcher.cpp         launcher.h
        logentry.cpp         logentry.h
        logmodel.cpp         logmodel.h
        logfiltermodel.cpp   logfiltermodel.h
)

# Qt's QML resolver on Linux prepends "lib" when searching for plugins
# (e.g. libqtquick2plugin.so). Force the same convention for our MODULE target.
set_target_properties(debugdeckplugin PROPERTIES PREFIX "lib")

target_link_libraries(debugdeckplugin PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::DBus
    KF6::CoreAddons
)

if(SYSTEMD_FOUND)
    target_link_libraries(debugdeckplugin PRIVATE ${SYSTEMD_LIBRARIES})
    target_include_directories(debugdeckplugin PRIVATE ${SYSTEMD_INCLUDE_DIRS})
    target_compile_definitions(debugdeckplugin PRIVATE HAVE_SYSTEMD)
endif()

# Install .so + generated qmldir/typeinfo to the Qt QML import path
set(PLUGIN_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/lib/qt6/qml/com/github/debugdeck")

install(TARGETS debugdeckplugin DESTINATION ${PLUGIN_INSTALL_DIR})

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/com/github/debugdeck/qmldir"
    "${CMAKE_CURRENT_BINARY_DIR}/com/github/debugdeck/debugdeckplugin.qmltypes"
    DESTINATION ${PLUGIN_INSTALL_DIR}
    OPTIONAL
)

# Strip the "prefer :/qt/qml/..." line from the installed qmldir.
# Qt 6.10 uses it to load from embedded QRC resources, which breaks
# filesystem-installed plasmoid plugins.
install(CODE "
    set(_qmldir \"${CMAKE_INSTALL_PREFIX}/lib/qt6/qml/com/github/debugdeck/qmldir\")
    if(EXISTS \"\${_qmldir}\")
        file(READ \"\${_qmldir}\" _content)
        string(REGEX REPLACE \"prefer [^\n]*\n\" \"\" _content \"\${_content}\")
        file(WRITE \"\${_qmldir}\" \"\${_content}\")
        message(STATUS \"Patched qmldir: removed 'prefer' directive\")
    endif()
")
