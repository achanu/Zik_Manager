FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# --- Dépendances système ---
# OpenJDK 17 : requis par Gradle 8.x utilisé par Qt 6.8
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jdk-headless \
        python3-pip \
        wget \
        unzip \
        make \
    && rm -rf /var/lib/apt/lists/*

# --- aqtinstall : installeur Qt headless ---
RUN pip3 install --no-cache-dir aqtinstall

# --- Qt 6.8.1 hôte Linux : moc, rcc, androiddeployqt ---
RUN aqt install-qt linux desktop 6.8.1 linux_gcc_64 \
        -O /opt/Qt

# --- Qt 6.8.1 cible Android arm64-v8a ---
# Qt 6 revient aux paquets per-ABI ; pas besoin de multi-ABI.
RUN aqt install-qt linux android 6.8.1 android_arm64_v8a \
        -O /opt/Qt

# --- Modules Qt additionnels pour Android arm64 ---
# qtconnectivity = QtBluetooth ; qt5compat = remplacement QtGraphicalEffects
RUN aqt install-qt linux android 6.8.1 android_arm64_v8a \
        -m qtconnectivity qt5compat -O /opt/Qt

# --- Modules Qt additionnels pour l'hôte Linux (outils de build) ---
RUN aqt install-qt linux desktop 6.8.1 linux_gcc_64 \
        -m qtconnectivity qt5compat -O /opt/Qt

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
RUN sdkmanager \
        "platform-tools" \
        "platforms;android-35" \
        "build-tools;36.1.0" \
        "ndk;27.2.12479018"

ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/27.2.12479018
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

COPY scripts/build-android.sh /usr/local/bin/build-android.sh
RUN chmod +x /usr/local/bin/build-android.sh

WORKDIR /project
CMD ["/usr/local/bin/build-android.sh"]
