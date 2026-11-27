# SensorTrack — Flutter, Sensores Físicos y Supabase

Aplicación móvil desarrollada en **Flutter y Dart** para la asignatura **Desarrollo de Plataformas Móviles**. Permite capturar en tiempo real los datos de los sensores físicos de un dispositivo Android (**acelerómetro**, **giroscopio** y **GPS**), almacenarlos en la nube con **Supabase (PostgreSQL)** y consumirlos desde la base de datos para mostrar historial, detalles y estadísticas con gráficos.

---

## Funcionalidades principales

1. **Pantalla Splash e Inicio (`splash.dart` / `home_page.dart`)**
   - Pantalla de presentación **SensorTrack**.
   - Verificación en vivo del estado de conexión con Supabase (`sensor_readings`).
   - Detección de sensores disponibles en el dispositivo (Acelerómetro, Giroscopio y GPS).
   - Menú de navegación inferior de 5 pestañas y accesos rápidos.
2. **Monitoreo de Sensores (`sensores_page.dart`)**
   - Lectura en tiempo real de los ejes **X, Y, Z** del **Acelerómetro** (`m/s²`) y del **Giroscopio** (`rad/s`) mediante `sensors_plus`.
   - Control para **Iniciar / Detener monitoreo** y liberación automática de suscripciones en `dispose()`.
   - Botón **Guardar medición** en Supabase con manejo de errores (`try/catch` + `SnackBar`).
3. **Ubicación GPS (`ubicacion_page.dart`)**
   - Validación de servicio GPS y solicitud de permisos en tiempo de ejecución mediante `geolocator`.
   - Visualización de **latitud, longitud, precisión (m) y fecha/hora de captura**.
   - Vista previa de mapa con mosaicos de OpenStreetMap y botón **Guardar ubicación en Supabase**.
4. **Historial de Mediciones (`historial_page.dart`)**
   - Consumo de los registros almacenados en Supabase usando `FutureBuilder`.
   - Listado ordenado del más reciente al más antiguo con tipo de sensor, valores y fecha/hora.
   - Al seleccionar cualquier registro se abre un `AlertDialog` con su detalle completo.
5. **Estadísticas y Visualización (`estadisticas_page.dart`)**
   - Cantidad total de registros y conteo por tipo de sensor.
   - Valores máximo y mínimo registrados del acelerómetro.
   - Última ubicación GPS registrada.
   - Gráfico lineal de evolución de los ejes X, Y, Z del acelerómetro con `fl_chart`.

---

## Tecnologías y paquetes utilizados

| Paquete / Tecnología | Uso en el proyecto |
| :--- | :--- |
| **Flutter & Dart** | Desarrollo de la aplicación móvil |
| **Supabase (PostgreSQL)** | Backend y almacenamiento en la nube (`sensor_readings`) |
| `supabase_flutter` | Conexión, inserción y consulta de mediciones |
| `sensors_plus` | Lectura en tiempo real del acelerómetro y giroscopio |
| `geolocator` | Gestión de permisos y captura de coordenadas GPS |
| `fl_chart` | Gráfico lineal de evolución de mediciones |

---

## Estructura del proyecto

```text
taller_sensortrack/
├── android/app/src/main/AndroidManifest.xml   # Permisos INTERNET y ubicación GPS
├── sensor_readings.sql                        # Script SQL (tabla, RLS y permisos GRANT)
├── docs/capturas/                             # Capturas de código para documentación/Wiki
└── lib/
    ├── main.dart                              # Inicialización de Supabase y MaterialApp
    ├── splash.dart                            # Pantalla Splash SensorTrack
    ├── services/
    │   └── supabase_service.dart              # Conexión, INSERT, SELECT y formateo
    └── pages/
        ├── mainpage.dart                      # IndexedStack + BottomNavigationBar
        ├── home_page.dart                     # Inicio, conexión y sensores disponibles
        ├── sensores_page.dart                 # Acelerómetro y Giroscopio en tiempo real
        ├── ubicacion_page.dart                # GPS, permisos y vista previa de mapa
        ├── historial_page.dart                # Listado de registros y detalle
        └── estadisticas_page.dart             # Métricas y gráfico fl_chart
```

---

## Instalación y ejecución

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```
2. **Configurar base de datos en Supabase:**
   - Ejecutar el script [`sensor_readings.sql`](sensor_readings.sql) en el **SQL Editor** de Supabase (crea la tabla, habilita RLS, crea políticas `SELECT`/`INSERT` y otorga permisos `GRANT` al rol `anon`).
   - Verificar `url` y `publishableKey` en `lib/main.dart`.
3. **Ejecutar en dispositivo físico Android (ej. Xiaomi Redmi Note 11s):**
   ```bash
   flutter devices
   flutter run
   ```

---

## Documentación completa

Consulta la pestaña **Wiki** del repositorio para ver el **Informe Técnico completo** con la explicación de permisos en el código, conexión a Supabase, recolección de datos, consumo desde la base de datos y capturas de código.
