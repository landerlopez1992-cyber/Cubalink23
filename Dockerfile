# Usar imagen con Flutter y Android SDK preinstalado
FROM ubuntu:20.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Instalar Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configurar Android SDK
ENV ANDROID_HOME="/android-sdk"
ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Descargar Android SDK
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm commandlinetools-linux-9477386_latest.zip

# Aceptar licencias y instalar componentes
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos del proyecto
COPY pubspec.yaml pubspec.lock ./
COPY lib/ ./lib/
COPY assets/ ./assets/
COPY android/ ./android/

# Obtener dependencias
RUN flutter pub get

# Compilar APK
RUN flutter build apk --release

# Exponer el directorio de build
VOLUME ["/app/build/app/outputs/flutter-apk"]

# Comando por defecto
CMD ["ls", "-la", "/app/build/app/outputs/flutter-apk/"]
