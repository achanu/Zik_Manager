#!/bin/bash
# Script de build Android — exécuté à l'intérieur du conteneur.
# Produit /output/ZikManager.apk (APK debug signé avec la debug keystore Java).
set -e

QMAKE=/opt/Qt/6.11.0/android_arm64_v8a/bin/qmake
ANDROID_DEPLOY_QT=/opt/Qt/6.11.0/gcc_64/bin/androiddeployqt
BUILD_DIR=/build
OUTPUT_DIR=/output

mkdir -p "${BUILD_DIR}" "${OUTPUT_DIR}"

# --- Build libParrotZik (static lib) ---
echo "==> qmake libParrotZik..."
mkdir -p "${BUILD_DIR}/libParrotZik"
cd "${BUILD_DIR}/libParrotZik"
"${QMAKE}" /project/libParrotZik/libParrotZik.pro \
    -spec android-clang \
    CONFIG+=release \
    ANDROID_ABIS=arm64-v8a

echo "==> make libParrotZik..."
make -j"$(nproc)"

# Qt6 Android names the static lib libParrotZik_arm64-v8a.a — copy it
# to libParrotZik.a so Desktop's -lParrotZik linker flag finds it.
cp "${BUILD_DIR}/libParrotZik/libParrotZik_arm64-v8a.a" \
   "${BUILD_DIR}/libParrotZik/libParrotZik.a"

# --- Build Desktop app ---
echo "==> qmake Desktop..."
mkdir -p "${BUILD_DIR}/Desktop"
cd "${BUILD_DIR}/Desktop"
"${QMAKE}" /project/Desktop/Desktop.pro \
    -spec android-clang \
    CONFIG+=release \
    ANDROID_ABIS=arm64-v8a

echo "==> make Desktop..."
make -j"$(nproc)"

# Copie la .so compilée dans {android-build}/libs/arm64-v8a/ où androiddeployqt la cherche.
echo "==> make install..."
make install INSTALL_ROOT="${BUILD_DIR}/android-build"

# androiddeployqt lit le JSON généré par qmake pour l'app Desktop.
# Le nom du fichier est dérivé de TARGET = zik-manager dans Desktop.pro.
DEPLOY_JSON="${BUILD_DIR}/Desktop/android-zik-manager-deployment-settings.json"

echo "==> androiddeployqt..."
"${ANDROID_DEPLOY_QT}" \
    --input  "${DEPLOY_JSON}" \
    --output "${BUILD_DIR}/android-build" \
    --android-platform android-36 \
    --min-sdk-version 31 \
    --jdk    "${JAVA_HOME}" \
    --qml-import-paths /opt/Qt/6.11.0/android_arm64_v8a/qml \
    --gradle

APK="${BUILD_DIR}/android-build/build/outputs/apk/debug/android-build-debug.apk"
cp "${APK}" "${OUTPUT_DIR}/ZikManager.apk"
echo "==> APK prêt : ${OUTPUT_DIR}/ZikManager.apk"
