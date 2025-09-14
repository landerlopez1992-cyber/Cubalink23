# 🔐 CONFIGURACIÓN DE GOOGLE OAUTH EN SUPABASE

## 📋 PASOS PARA CONFIGURAR GOOGLE OAUTH

### 1️⃣ **Configurar en Google Cloud Console**

#### Crear Proyecto:
1. Ir a https://console.cloud.google.com
2. Crear nuevo proyecto o seleccionar existente
3. Habilitar Google+ API

#### Configurar OAuth:
1. Ir a "APIs & Services" > "Credentials"
2. Crear "OAuth 2.0 Client IDs"
3. Configurar:
   - **Application type:** Web application
   - **Name:** TureCarga App
   - **Authorized redirect URIs:** 
     ```
     https://[TU-PROYECTO].supabase.co/auth/v1/callback
     ```

#### Obtener Credenciales:
- **Client ID:** `xxxxxxxxxxxxx.apps.googleusercontent.com`
- **Client Secret:** `xxxxxxxxxxxxxxxxxxxxxxxx`

### 2️⃣ **Configurar en Supabase Dashboard**

#### Ir a Authentication:
1. Abrir https://supabase.com/dashboard
2. Seleccionar tu proyecto
3. Ir a "Authentication" > "Providers"

#### Configurar Google Provider:
1. Activar "Google" provider
2. Ingresar:
   - **Client ID:** (del paso anterior)
   - **Client Secret:** (del paso anterior)
3. Guardar configuración

### 3️⃣ **Configurar URLs de Redirección**

#### URLs Permitidas en Google:
```
https://[TU-PROYECTO].supabase.co/auth/v1/callback
```

#### URLs Permitidas en Supabase:
```
https://[TU-PROYECTO].supabase.co/auth/v1/callback
```

### 4️⃣ **Configurar Dominios Autorizados**

#### En Google Cloud Console:
- Agregar dominio de tu app
- Agregar `localhost` para desarrollo

#### En Supabase:
- Configurar "Site URL" en Authentication settings
- Agregar dominios permitidos

### 5️⃣ **Variables de Entorno**

#### En tu app Flutter:
```dart
// Estas se configuran automáticamente por Supabase
// No necesitas configurar nada adicional
```

#### En Supabase:
```bash
# Estas se configuran automáticamente
SUPABASE_URL=https://[TU-PROYECTO].supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 6️⃣ **Configuración de Android**

#### En `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.turecarga.app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### En `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="TureCarga"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        android:theme="@style/LaunchTheme">
        
        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>
</application>
```

### 7️⃣ **Configuración de iOS**

#### En `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.xxxxxxxxxxxxx</string>
        </array>
    </dict>
</array>
```

### 8️⃣ **Probar la Configuración**

#### Comandos de Prueba:
```bash
# Instalar dependencias
flutter pub get

# Limpiar y compilar
flutter clean
flutter pub get

# Ejecutar en dispositivo
flutter run
```

#### Verificar en App:
1. Abrir pantalla de login
2. Presionar "Continuar con Google"
3. Seleccionar cuenta de Google
4. Verificar que navegue a `/welcome`

### 9️⃣ **Solución de Problemas**

#### Error: "Invalid client"
- Verificar Client ID en Supabase
- Verificar que el proyecto esté activo en Google Cloud

#### Error: "Redirect URI mismatch"
- Verificar URLs en Google Cloud Console
- Verificar Site URL en Supabase

#### Error: "Access blocked"
- Verificar que Google+ API esté habilitada
- Verificar configuración de OAuth consent screen

#### Error: "Network error"
- Verificar conexión a internet
- Verificar que Supabase esté activo

### 🔟 **Configuración de Producción**

#### Para Producción:
1. Cambiar URLs de desarrollo por URLs de producción
2. Configurar dominio real en Google Cloud Console
3. Actualizar Site URL en Supabase
4. Probar en dispositivo real

#### URLs de Producción:
```
https://tu-dominio.com/auth/v1/callback
```

---

## ✅ CHECKLIST DE CONFIGURACIÓN

- [ ] Proyecto creado en Google Cloud Console
- [ ] Google+ API habilitada
- [ ] OAuth 2.0 Client ID creado
- [ ] URLs de redirección configuradas
- [ ] Google provider activado en Supabase
- [ ] Client ID y Secret configurados en Supabase
- [ ] Site URL configurada en Supabase
- [ ] Dominios autorizados configurados
- [ ] App compilada y probada
- [ ] Login con Google funcionando

---

**🎉 ¡CONFIGURACIÓN COMPLETA!**

*Una vez completados estos pasos, el login con Google debería funcionar perfectamente.*


## 📋 PASOS PARA CONFIGURAR GOOGLE OAUTH

### 1️⃣ **Configurar en Google Cloud Console**

#### Crear Proyecto:
1. Ir a https://console.cloud.google.com
2. Crear nuevo proyecto o seleccionar existente
3. Habilitar Google+ API

#### Configurar OAuth:
1. Ir a "APIs & Services" > "Credentials"
2. Crear "OAuth 2.0 Client IDs"
3. Configurar:
   - **Application type:** Web application
   - **Name:** TureCarga App
   - **Authorized redirect URIs:** 
     ```
     https://[TU-PROYECTO].supabase.co/auth/v1/callback
     ```

#### Obtener Credenciales:
- **Client ID:** `xxxxxxxxxxxxx.apps.googleusercontent.com`
- **Client Secret:** `xxxxxxxxxxxxxxxxxxxxxxxx`

### 2️⃣ **Configurar en Supabase Dashboard**

#### Ir a Authentication:
1. Abrir https://supabase.com/dashboard
2. Seleccionar tu proyecto
3. Ir a "Authentication" > "Providers"

#### Configurar Google Provider:
1. Activar "Google" provider
2. Ingresar:
   - **Client ID:** (del paso anterior)
   - **Client Secret:** (del paso anterior)
3. Guardar configuración

### 3️⃣ **Configurar URLs de Redirección**

#### URLs Permitidas en Google:
```
https://[TU-PROYECTO].supabase.co/auth/v1/callback
```

#### URLs Permitidas en Supabase:
```
https://[TU-PROYECTO].supabase.co/auth/v1/callback
```

### 4️⃣ **Configurar Dominios Autorizados**

#### En Google Cloud Console:
- Agregar dominio de tu app
- Agregar `localhost` para desarrollo

#### En Supabase:
- Configurar "Site URL" en Authentication settings
- Agregar dominios permitidos

### 5️⃣ **Variables de Entorno**

#### En tu app Flutter:
```dart
// Estas se configuran automáticamente por Supabase
// No necesitas configurar nada adicional
```

#### En Supabase:
```bash
# Estas se configuran automáticamente
SUPABASE_URL=https://[TU-PROYECTO].supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 6️⃣ **Configuración de Android**

#### En `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.turecarga.app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### En `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="TureCarga"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        android:theme="@style/LaunchTheme">
        
        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>
</application>
```

### 7️⃣ **Configuración de iOS**

#### En `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.xxxxxxxxxxxxx</string>
        </array>
    </dict>
</array>
```

### 8️⃣ **Probar la Configuración**

#### Comandos de Prueba:
```bash
# Instalar dependencias
flutter pub get

# Limpiar y compilar
flutter clean
flutter pub get

# Ejecutar en dispositivo
flutter run
```

#### Verificar en App:
1. Abrir pantalla de login
2. Presionar "Continuar con Google"
3. Seleccionar cuenta de Google
4. Verificar que navegue a `/welcome`

### 9️⃣ **Solución de Problemas**

#### Error: "Invalid client"
- Verificar Client ID en Supabase
- Verificar que el proyecto esté activo en Google Cloud

#### Error: "Redirect URI mismatch"
- Verificar URLs en Google Cloud Console
- Verificar Site URL en Supabase

#### Error: "Access blocked"
- Verificar que Google+ API esté habilitada
- Verificar configuración de OAuth consent screen

#### Error: "Network error"
- Verificar conexión a internet
- Verificar que Supabase esté activo

### 🔟 **Configuración de Producción**

#### Para Producción:
1. Cambiar URLs de desarrollo por URLs de producción
2. Configurar dominio real en Google Cloud Console
3. Actualizar Site URL en Supabase
4. Probar en dispositivo real

#### URLs de Producción:
```
https://tu-dominio.com/auth/v1/callback
```

---

## ✅ CHECKLIST DE CONFIGURACIÓN

- [ ] Proyecto creado en Google Cloud Console
- [ ] Google+ API habilitada
- [ ] OAuth 2.0 Client ID creado
- [ ] URLs de redirección configuradas
- [ ] Google provider activado en Supabase
- [ ] Client ID y Secret configurados en Supabase
- [ ] Site URL configurada en Supabase
- [ ] Dominios autorizados configurados
- [ ] App compilada y probada
- [ ] Login con Google funcionando

---

**🎉 ¡CONFIGURACIÓN COMPLETA!**

*Una vez completados estos pasos, el login con Google debería funcionar perfectamente.*

