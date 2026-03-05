FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# --- Dépendances système ---
# OpenJDK 11 : requis par Gradle (Qt 5.15 incompatible avec Java 17)
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk-headless \
        python3-pip \
        wget \
        unzip \
        make \
    && rm -rf /var/lib/apt/lists/*

# --- aqtinstall : installeur Qt headless ---
# v3.x a changé la résolution des manifestes XML et ne sait plus parser Qt 5.15.2.
# On épingle à v2.2.3, dernière version stable compatible avec Qt 5.15.2 Android.
RUN pip3 install --no-cache-dir "aqtinstall==2.2.3"

# --- Qt 5.15.2 hôte Linux : moc, rcc, androiddeployqt ---
RUN aqt install-qt --base https://download.qt.io linux desktop 5.15.2 gcc_64 \
        -O /opt/Qt

# --- Qt 5.15.2 cible Android (multi-ABI) ---
# Les paquets per-ABI (android_arm64_v8a) ont été retirés du dépôt en ligne Qt.
# On installe le paquet multi-ABI "android" ; qmake restreint la sortie à arm64-v8a
# via ANDROID_ABIS=arm64-v8a (déjà configuré dans Desktop.pro).
# Le paquet "android" inclut tous les modules (bluetooth, svg, etc.) — pas d'étape séparée.
RUN aqt install-qt --base https://download.qt.io linux android 5.15.2 android \
        -O /opt/Qt

# --- Android cmdline-tools v9.0 (bootstrap) ---
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
         -O /tmp/cmdtools.zip && \
    unzip -q /tmp/cmdtools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools \
       ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdtools.zip

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

# --- Mise à jour cmdline-tools vers la dernière version via sdkmanager ---
RUN yes | sdkmanager --licenses > /dev/null && \
    sdkmanager "cmdline-tools;latest"

# --- Android SDK platform 35, build-tools 36.1.0, NDK r27 LTS ---
# NDK r27 LTS (27.2.12479018) : version LTS 2024, meilleur support arm64
RUN sdkmanager \
        "platform-tools" \
        "platforms;android-35" \
        "build-tools;36.1.0" \
        "ndk;27.2.12479018"

ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/27.2.12479018
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

COPY scripts/build-android.sh /usr/local/bin/build-android.sh
RUN chmod +x /usr/local/bin/build-android.sh

WORKDIR /project
CMD ["/usr/local/bin/build-android.sh"]
