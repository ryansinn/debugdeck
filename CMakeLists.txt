cmake_minimum_required(VERSION 3.20)
project(debugdeck VERSION 0.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# ── ECM & KDE install dirs ────────────────────────────────────────────────────
find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)
include(ECMQmlModule)

# ── Required Qt6 / KF6 / Plasma ──────────────────────────────────────────────
find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick DBus)
find_package(KF6 REQUIRED COMPONENTS CoreAddons I18n Notifications)
find_package(Plasma REQUIRED)

# ── Optional: libsystemd (for direct journal fd access) ──────────────────────
find_package(PkgConfig REQUIRED)
pkg_check_modules(SYSTEMD libsystemd)
if(SYSTEMD_FOUND)
    message(STATUS "libsystemd found – enabling native journal support")
else()
    message(STATUS "libsystemd NOT found – falling back to journalctl subprocess")
endif()

add_subdirectory(src)

# ── Install the Plasma plasmoid package ──────────────────────────────────────
install(
    DIRECTORY package/
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/com.github.debugdeck
)

# ── Install KNotification event description ──────────────────────────────────
install(
    FILES data/debugdeck.notifyrc
    DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR}
)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
