#!/bin/bash
# Script de build Android — exécuté à l'intérieur du conteneur.
# Produit /output/ZikManager.apk (APK debug signé avec la debug keystore Java).
set -e

QMAKE=/opt/Qt/6.8.1/android_arm64_v8a/bin/qmake
ANDROID_DEPLOY_QT=/opt/Qt/6.8.1/gcc_64/bin/androiddeployqt
BUILD_DIR=/build
OUTPUT_DIR=/output

mkdir -p "${BUILD_DIR}" "${OUTPUT_DIR}"

echo "==> qmake..."
cd "${BUILD_DIR}"
"${QMAKE}" /project/zik_manager.pro \
    -spec android-clang \
    CONFIG+=release \
    ANDROID_ABIS=arm64-v8a

echo "==> make..."
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
    --android-platform android-35 \
    --jdk    "${JAVA_HOME}" \
    --gradle

APK="${BUILD_DIR}/android-build/build/outputs/apk/debug/android-build-debug.apk"
cp "${APK}" "${OUTPUT_DIR}/ZikManager.apk"
echo "==> APK prêt : ${OUTPUT_DIR}/ZikManager.apk"
