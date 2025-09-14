# Dockerfile para compilaciones Android de CubaLink23
# Este Dockerfile evita problemas de configuración local y garantiza compilaciones consistentes

FROM ubuntu:22.04

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=3.24.5
ENV ANDROID_SDK_VERSION=34
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0
ENV JAVA_VERSION=17

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configurar Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH=$PATH:$JAVA_HOME/bin

# Crear directorio para Android SDK
RUN mkdir -p /opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_HOME/platform-tools
ENV PATH=$PATH:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION

# Descargar e instalar Android SDK
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/commandlinetools.zip && \
    unzip /tmp/commandlinetools.zip -d /opt/android-sdk/ && \
    rm /tmp/commandlinetools.zip && \
    mkdir -p /opt/android-sdk/cmdline-tools/latest && \
    mv /opt/android-sdk/cmdline-tools/bin /opt/android-sdk/cmdline-tools/latest/ && \
    mv /opt/android-sdk/cmdline-tools/lib /opt/android-sdk/cmdline-tools/latest/

# Aceptar licencias de Android SDK
RUN yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses

# Instalar componentes de Android SDK
RUN /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-$ANDROID_SDK_VERSION" \
    "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
    "sources;android-$ANDROID_SDK_VERSION"

# Descargar e instalar Flutter
RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_VERSION-stable.tar.xz -O /tmp/flutter.tar.xz && \
    tar -xf /tmp/flutter.tar.xz -C /opt && \
    rm /tmp/flutter.tar.xz
ENV PATH=$PATH:/opt/flutter/bin

# Verificar instalación de Flutter
RUN flutter doctor --android-licenses --verbose

# Crear usuario para compilación (evita problemas de permisos)
RUN useradd -m -s /bin/bash flutter && \
    usermod -aG sudo flutter && \
    echo "flutter ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configurar directorio de trabajo
WORKDIR /workspace

# Cambiar a usuario flutter
USER flutter

# Configurar Flutter para el usuario
RUN flutter config --no-analytics && \
    flutter config --enable-web && \
    flutter config --enable-android

# Exponer puerto para hot reload (opcional)
EXPOSE 8080

# Comando por defecto
CMD ["/bin/bash"]
