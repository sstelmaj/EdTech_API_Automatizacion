---
id: SPEC-001
status: APPROVED
feature: edtech-api-integration-tests
created: 2026-04-05
updated: 2026-04-05
author: spec-generator
version: "1.0"
related-specs: []
---

# EdTech API — Pruebas de Integración (Karate DSL)

## 1. REQUERIMIENTOS

### Alcance

Este SPEC cubre **exclusivamente las 40 pruebas de integración API** (API-001 a API-SEC-001) ejecutadas con **Karate DSL** contra la API REST local de EdTech (`localhost:8080`). Los 4 flujos E2E (E2E-001 a E2E-004) se implementarán en un repositorio separado con SerenityBDD y quedan **fuera de alcance** de este SPEC.

### Historias de Usuario

| ID | Como... | Quiero... | Para... |
|-------|---------|-----------|---------|
| HDU_1 | Docente | registrarme con username y password | acceder al sistema y obtener un token de sesión |
| HDU_2 | Docente | iniciar sesión, validar mi sesión y cerrarla | autenticarme de forma segura con sesión server-side |
| HDU_3 | Docente autenticado | crear un nuevo curso con nombre único | organizar mi actividad académica |
| HDU_4 | Docente autenticado | consultar el detalle completo de un curso | ver estudiantes, actividades y notas asociadas |
| HDU_5 | Docente autenticado | inscribir estudiantes en un curso (con alta on-the-fly) | gestionar la nómina de estudiantes por curso |
| HDU_11 | Docente autenticado | definir el programa evaluativo de un curso | establecer actividades y ponderaciones que sumen 100% |
| HDU_12 | Docente autenticado | eliminar una instancia evaluativa con redistribución | ajustar el programa evaluativo eliminando componentes |
| HDU_13 | Docente autenticado | actualizar ponderaciones de instancias existentes | reorganizar los pesos del programa evaluativo |
| HDU_14 | Docente autenticado | registrar la nota de un estudiante en una actividad | alimentar el boletín académico con calificaciones |
| HDU_15 | Docente autenticado | exportar el boletín de un estudiante en PDF, HTML o JSON | generar reportes académicos con promedios calculados |

### Criterios de Aceptación (Gherkin)

#### Autenticación (AUTH)

```gherkin
Escenario: API-001 — Registro exitoso
  Dado que envío un POST a /api/auth/register con username y password válidos
  Cuando el servidor procesa la solicitud
  Entonces recibo status 201
  Y el body contiene "user.id", "user.username" y "token"

Escenario: API-002 — Registro con campos vacíos
  Dado que envío un POST a /api/auth/register con campos vacíos
  Cuando el servidor valida la solicitud
  Entonces recibo status 400
  Y el message indica el campo faltante

Escenario: API-003 — Registro con username duplicado
  Dado que ya existe un docente con username "TestDocente"
  Cuando envío un POST a /api/auth/register con el mismo username (case-insensitive)
  Entonces recibo status 409
  Y el message es "El nombre de usuario ya existe"

Escenario: API-004 — Login exitoso
  Dado que existe un docente registrado
  Cuando envío un POST a /api/auth/login con credenciales válidas
  Entonces recibo status 200
  Y el body contiene SessionResponse

Escenario: API-005 — Login con credenciales inválidas
  Dado que envío un POST a /api/auth/login con password incorrecto
  Cuando el servidor valida las credenciales
  Entonces recibo status 401
  Y el message es "Usuario o contrasena incorrectos"

Escenario: API-006 — Login con campos vacíos
  Dado que envío un POST a /api/auth/login con campos vacíos
  Cuando el servidor valida la solicitud
  Entonces recibo status 400

Escenario: API-007 — Validar sesión activa
  Dado que tengo un token de sesión válido
  Cuando envío un GET a /api/auth/session con header X-Session-Token
  Entonces recibo status 200
  Y el body contiene SessionResponse

Escenario: API-008 — Validar sesión con token inválido
  Dado que envío un GET a /api/auth/session con un token inexistente
  Cuando el servidor busca la sesión
  Entonces recibo status 401
  Y el message es "Sesion invalida o expirada"

Escenario: API-009 — Logout exitoso
  Dado que tengo una sesión activa
  Cuando envío un POST a /api/auth/logout con el token válido
  Entonces recibo status 204
  Y el token queda invalidado (GET /session posterior retorna 401)

Escenario: API-010 — Logout con token inválido
  Dado que envío un POST a /api/auth/logout con un token inexistente
  Cuando el servidor intenta eliminar la sesión
  Entonces recibo status 204
  # HALLAZGO-2: debería ser 401, pero actualmente retorna 204
```

#### Cursos (COURSES)

```gherkin
Escenario: API-011 — Listar cursos del docente
  Dado que estoy autenticado y he creado al menos un curso
  Cuando envío un GET a /api/courses
  Entonces recibo status 200
  Y el body es un array con objetos que contienen "id", "name", "studentCount", "activityCount"

Escenario: API-012 — Crear curso exitosamente
  Dado que estoy autenticado
  Cuando envío un POST a /api/courses con un nombre válido
  Entonces recibo status 201
  Y el body contiene CourseDetailResponse

Escenario: API-013 — Crear curso con nombre duplicado
  Dado que ya tengo un curso con nombre "Matemáticas"
  Cuando envío un POST a /api/courses con el mismo nombre (case-insensitive)
  Entonces recibo status 409
  Y el message es "Ya existe un curso con este nombre"

Escenario: API-014 — Crear curso con nombre vacío
  Dado que estoy autenticado
  Cuando envío un POST a /api/courses con name vacío
  Entonces recibo status 400
```

#### Estudiantes (STUDENTS)

```gherkin
Escenario: API-015 — Detalle de curso existente
  Dado que tengo un curso con estudiantes, actividades y notas
  Cuando envío un GET a /api/courses/{courseId}
  Entonces recibo status 200
  Y el body contiene "students[]", "activities[]", "grades[]"

Escenario: API-016 — Detalle de curso inexistente
  Dado que envío un GET a /api/courses/{courseId} con un UUID inexistente
  Cuando el servidor busca el curso
  Entonces recibo status 404
  Y el message es "Curso no encontrado"

Escenario: API-017 — Buscar estudiante existente
  Dado que existe un estudiante con student_identifier "EST-001"
  Cuando envío un GET a /api/students/EST-001
  Entonces recibo status 200
  Y el body contiene "studentId", "name", "email"

Escenario: API-018 — Buscar estudiante inexistente
  Dado que envío un GET a /api/students/EST-NOEXISTE
  Cuando el servidor busca por student_identifier
  Entonces recibo status 404
  Y el message es "Estudiante no encontrado"

Escenario: API-019 — Inscribir estudiante nuevo (alta on-the-fly)
  Dado que estoy autenticado y tengo un curso
  Cuando envío un POST a /api/courses/{courseId}/students con datos de estudiante nuevo
  Entonces recibo status 200
  Y el body contiene CourseDetailResponse con el estudiante en "students[]"

Escenario: API-020 — Inscribir con campos vacíos
  Dado que envío un POST a /api/courses/{courseId}/students con campos vacíos
  Cuando el servidor valida la solicitud
  Entonces recibo status 400
  Y el estudiante NO se crea parcialmente en el sistema

Escenario: API-021 — Inscribir estudiante ya inscrito
  Dado que el estudiante "EST-001" ya está inscrito en el curso
  Cuando envío un POST para inscribirlo de nuevo
  Entonces recibo status 409
  Y el message es "El estudiante ya esta inscrito en este curso"

Escenario: API-022 — Inscribir estudiante existente en sistema (autocomplete)
  Dado que "EST-001" ya existe como estudiante global
  Cuando lo inscribo en un curso nuevo con name y email diferentes
  Entonces recibo status 200
  Y el sistema reutiliza el registro existente (name y email originales)
```

#### Programa Evaluativo (ACTIVITIES)

```gherkin
Escenario: API-023 — Definir programa válido (suma = 100%)
  Dado que tengo un curso sin actividades
  Cuando envío un PUT a /api/courses/{courseId}/activities con actividades que suman 100%
  Entonces recibo status 200
  Y el body contiene CourseDetailResponse con las actividades creadas

Escenario: API-024 — Definir programa con suma ≠ 100%
  Dado que envío actividades cuyas ponderaciones suman 80%
  Cuando el servidor valida las ponderaciones
  Entonces recibo status 400
  Y el message es "La suma de ponderaciones debe ser exactamente 100%"

Escenario: API-025 — Programa con nombre de actividad vacío
  Dado que envío actividades con un nombre blank
  Cuando el servidor valida los nombres
  Entonces recibo status 400
  Y el message es "Cada actividad debe tener nombre"

Escenario: API-026 — Programa con nombres duplicados
  Dado que envío dos actividades con el mismo nombre (case-insensitive)
  Cuando el servidor valida unicidad
  Entonces recibo status 400
  Y el message es "Las actividades no pueden tener nombres duplicados"

Escenario: API-027 — Programa con ponderación ≤ 0
  Dado que envío una actividad con percentage 0 o negativo
  Cuando el servidor valida las ponderaciones
  Entonces recibo status 400
  Y el message es "Cada actividad debe tener una ponderacion mayor a 0"

Escenario: API-028 — Actualizar ponderaciones (suma = 100%)
  Dado que el curso tiene actividades existentes
  Cuando envío un PUT con las mismas actividades (con id) pero ponderaciones nuevas que suman 100%
  Entonces recibo status 200
  Y las ponderaciones están actualizadas

Escenario: API-029 — Eliminar instancia con redistribución
  Dado que el curso tiene 3 actividades
  Cuando envío un PUT con solo 2 actividades que suman 100%
  Entonces recibo status 200
  Y la actividad eliminada ya no aparece en "activities[]"
  Y las notas asociadas a la actividad eliminada se borran
```

#### Calificaciones (GRADES)

```gherkin
Escenario: API-030 — Nota válida (≥ 0)
  Dado que el estudiante está inscrito y la actividad existe
  Cuando envío un PUT a /api/courses/{courseId}/grades con grade 4.5
  Entonces recibo status 200
  Y el body contiene CourseDetailResponse con la nota registrada

Escenario: API-031 — Nota negativa
  Dado que envío un PUT con grade -1
  Cuando el servidor valida la nota
  Entonces recibo status 400
  Y el message es "La nota no puede ser negativa"

Escenario: API-032 — Nota con caracteres no numéricos
  Dado que envío un PUT con grade "abc"
  Cuando el servidor procesa el tipo incorrecto
  Entonces recibo status 500
  Y el message es "Error interno del servidor"
  # HALLAZGO-3: debería ser 400, actualmente retorna 500

Escenario: API-033 — Nota nula (null en promedio = 0)
  Dado que envío un PUT con grade null
  Cuando el servidor registra la nota
  Entonces recibo status 200
  Y la nota se guarda como null (tratada como 0 en promedios)

Escenario: API-034 — Recálculo de promedios tras cambio de pesos
  Dado que el estudiante tiene notas registradas
  Cuando actualizo las ponderaciones de las actividades
  Y exporto el boletín JSON
  Entonces el weightedAverage refleja las nuevas ponderaciones
```

#### Reportes (REPORTS)

```gherkin
Escenario: API-035 — Exportar PDF
  Dado que el estudiante tiene notas registradas
  Cuando envío un GET a /api/courses/{courseId}/students/{studentId}/report?format=pdf
  Entonces recibo status 200
  Y Content-Type es "application/pdf"
  Y Content-Disposition contiene "boletin-"
  Y el body tiene longitud > 0

Escenario: API-036 — Exportar HTML
  Dado que el estudiante tiene notas registradas
  Cuando envío un GET con format=html
  Entonces recibo status 200
  Y Content-Type contiene "text/html"
  Y el body contiene "<html"

Escenario: API-037 — Exportar JSON
  Dado que el estudiante tiene notas registradas
  Cuando envío un GET con format=json
  Entonces recibo status 200
  Y el body contiene "teacher", "course", "student", "grades", "generalAverage", "weightedAverage", "hasEmptyGrades"

Escenario: API-038 — Formato no soportado
  Dado que envío un GET con format=xml
  Cuando el servidor valida el formato
  Entonces recibo status 400
  Y el message es "Formato no soportado"

Escenario: API-039 — Boletín con notas vacías
  Dado que el estudiante tiene al menos una nota sin registrar
  Cuando exporto el boletín en JSON
  Entonces recibo status 200
  Y "hasEmptyGrades" es true
  Y los promedios tratan null como 0
```

#### Seguridad Transversal

```gherkin
Escenario: API-SEC-001 — Endpoints protegidos sin token
  Dado que NO envío el header X-Session-Token
  Cuando intento acceder a cualquier endpoint protegido
  Entonces recibo status 500
  # HALLAZGO-1: debería ser 401 con header ausente; con header vacío ("") sí retorna 401
```

### Reglas de Negocio

| ID | Regla | Endpoints afectados |
|------|-------|-------------------|
| RN-01 | Cursos únicos por docente (case-insensitive: `lower(name)` + `teacher_id`) | POST /api/courses |
| RN-02 | Ponderaciones suman exactamente 100% (tolerancia ±0.01) | PUT /api/courses/{id}/activities |
| RN-03 | Cada ponderación > 0 | PUT /api/courses/{id}/activities |
| RN-04 | Nombres de actividades no vacíos | PUT /api/courses/{id}/activities |
| RN-05 | Nombres de actividades no duplicados (case-insensitive) | PUT /api/courses/{id}/activities |
| RN-06 | Notas numéricas ≥ 0 (si no es null) | PUT /api/courses/{id}/grades |
| RN-07 | Notas vacías = 0 en cálculos de promedio | GET /report?format=json |
| RN-08 | `hasEmptyGrades = true` si hay notas sin registrar | GET /report |
| RN-09 | Usernames únicos (case-insensitive) | POST /api/auth/register |
| RN-10 | Sesión única por docente: login borra sesiones previas | POST /api/auth/login |
| RN-11 | Estudiante se reutiliza si ya existe (búsqueda por `student_identifier`) | POST /api/courses/{id}/students |
| RN-12 | Email válido por regex `^[^\s@]+@[^\s@]+\.[^\s@]+$` | POST /api/courses/{id}/students |

### Hallazgos Conocidos

Los escenarios afectados por bugs conocidos deben etiquetarse con `@bug` + `@HALLAZGO-X` en los `.feature` files. Estos tests validan el comportamiento **actual** (no el esperado) y pasarán automáticamente cuando el DEV corrija el bug.

| ID | Severidad | Endpoint | Comportamiento actual vs esperado |
|------|-----------|----------|----------------------------------|
| HALLAZGO-1 | Media | Todos los protegidos | Header `X-Session-Token` ausente → 500 (esperado: 401) |
| HALLAZGO-2 | Baja | POST /logout | Token inexistente → 204 (esperado: 401) |
| HALLAZGO-3 | Media | PUT /activities, PUT /grades | Tipo incorrecto en Double → 500 (esperado: 400) |
| HALLAZGO-4 | Info | POST /login | Login borra TODAS las sesiones previas (por diseño) |
| HALLAZGO-5 | Baja | GET /courses/{id} vs GET /report?format=json | Jackson omite `grade: null` en CourseDetailResponse; StringBuilder escribe `"grade": null` en reporte |
| HALLAZGO-6 | Info | PUT /activities | No tiene `@Valid` → todos los errores son Forma 1, nunca Forma 2 |

---

## 2. DISEÑO

### Endpoints involucrados

| # | Método | Endpoint | Descripción | Auth | HU |
|---|--------|----------|-------------|------|----|
| 1 | POST | `/api/auth/register` | Registrar docente + crear sesión | No | HDU_1 |
| 2 | POST | `/api/auth/login` | Autenticar docente (borra sesiones previas) | No | HDU_2 |
| 3 | GET | `/api/auth/session` | Validar token activo | Sí | HDU_2 |
| 4 | POST | `/api/auth/logout` | Cerrar sesión (borrar token) | Sí | HDU_2 |
| 5 | GET | `/api/courses` | Listar cursos del docente con conteos | Sí | HDU_3 |
| 6 | POST | `/api/courses` | Crear curso nuevo | Sí | HDU_3 |
| 7 | GET | `/api/courses/{courseId}` | Detalle completo del curso | Sí | HDU_4 |
| 8 | GET | `/api/students/{studentId}` | Buscar estudiante por identifier | Sí | HDU_5 |
| 9 | POST | `/api/courses/{courseId}/students` | Inscribir estudiante (alta on-the-fly) | Sí | HDU_5 |
| 10 | PUT | `/api/courses/{courseId}/activities` | Reemplazar programa evaluativo | Sí | HDU_11/12/13 |
| 11 | PUT | `/api/courses/{courseId}/grades` | Registrar/actualizar nota | Sí | HDU_14 |
| 12 | GET | `/api/courses/{courseId}/students/{studentId}/report?format=` | Exportar boletín (PDF/HTML/JSON) | Sí | HDU_15 |

**Configuración de conexión:**

| Propiedad | Valor |
|-----------|-------|
| Base URL | `http://localhost:8080` |
| Autenticación | Header `X-Session-Token: <uuid>` |
| Serialización | Jackson `non_null` (campos null omitidos) |

### Modelo de datos de prueba

**SessionResponse** (compartido por register, login, session):
```json
{
  "user": {
    "id": "uuid-v4",
    "username": "string"
  },
  "token": "uuid-v4"
}
```

**CourseDetailResponse** (compartido por create course, get course, add student, update activities, update grade):
```json
{
  "id": "uuid",
  "name": "string",
  "teacherId": "uuid",
  "students": [
    { "id": "uuid-interno", "studentId": "EST-001", "name": "string", "email": "string" }
  ],
  "activities": [
    { "id": "uuid", "name": "string", "percentage": 40.0 }
  ],
  "grades": [
    { "studentId": "EST-001", "activityId": "uuid", "grade": 4.5 }
  ],
  "createdAt": "ISO-8601"
}
```

**ReportResponse** (JSON):
```json
{
  "teacher": "string",
  "course": "string",
  "student": { "id": "EST-001", "name": "string", "email": "string" },
  "grades": [
    { "activity": "string", "percentage": 40.0, "grade": 4.5 }
  ],
  "generalAverage": 2.25,
  "weightedAverage": 1.8,
  "hasEmptyGrades": true,
  "exportDate": "ISO-8601",
  "format": "json"
}
```

**Sistema de errores** — 3 formas de respuesta:

| Forma | Disparador | Estructura |
|-------|-----------|-----------|
| Forma 1 | ApiException (negocio) | `{ timestamp, status, error, message, details: {} }` |
| Forma 2 | `@Valid` fallido | `{ timestamp, status: 400, error, message: "Solicitud invalida", details: { campo: "must not be blank" } }` |
| Forma 3 | Catch-all | `{ timestamp, status: 500, error, message: "Error interno del servidor", details: {} }` |

### Notas de diseño

- **Base URL** configurable en `karate-config.js` como variable global `baseUrl`.
- **Autenticación**: los features protegidos requieren un `Background` que registre/logee un docente y almacene el token en una variable Karate.
- **Aislamiento de datos**: cada `.feature` crea sus propios datos de prueba (registro de docente con username único por ejecución) para evitar colisiones entre ejecuciones consecutivas.
- **Unicidad de username**: se recomienda generar usernames con timestamp o UUID parcial desde Karate (`function(){ return 'doc_' + java.lang.System.currentTimeMillis() }`).
- **HALLAZGO-5 (null grades)**: en CourseDetailResponse el campo `grade` se omite cuando es null (Jackson `non_null`); en ReportResponse el campo `"grade": null` aparece explícitamente (StringBuilder manual). Los asserts deben reflejar esta diferencia.
- **PUT /activities sin @Valid (HALLAZGO-6)**: todos los errores de validación de actividades son Forma 1 (nunca Forma 2).

### Estrategia de datos de prueba

- **Externalización obligatoria:** los payloads de prueba deben vivir en archivos `.json` separados, nunca inline en los `.feature` files.
- **Ubicación:** `src/test/java/testdata/<dominio>/` — separados por dominio funcional (`auth/`, `courses/`, `students/`, `activities/`, `grades/`, `reports/`).
- **Campos dinámicos:** credenciales (`username`, `password`) y student identifiers se inyectan en runtime desde el `.feature` con `* set`. No incluir en JSON estáticos.
- **Datos sintéticos:** dominio `@testmail.com`, contraseñas con patrón `P@ss_<Contexto>_<ID>`. NUNCA PII real.
- **Lectura con classpath:** `* def payload = read('classpath:testdata/auth/register_valid.json')`

### Estructura de archivos objetivo

```
src/test/java/
├── karate-config.js
├── features/
│   ├── auth/
│   │   ├── register.feature            # API-001, API-002, API-003
│   │   ├── login.feature               # API-004, API-005, API-006
│   │   ├── session.feature             # API-007, API-008
│   │   └── logout.feature              # API-009, API-010
│   ├── courses/
│   │   ├── list_courses.feature        # API-011
│   │   ├── create_course.feature       # API-012, API-013, API-014
│   │   └── get_course_detail.feature   # API-015, API-016
│   ├── students/
│   │   ├── search_student.feature      # API-017, API-018
│   │   └── enroll_student.feature      # API-019, API-020, API-021, API-022
│   ├── activities/
│   │   └── manage_activities.feature   # API-023 a API-029
│   ├── grades/
│   │   └── manage_grades.feature       # API-030 a API-034
│   ├── reports/
│   │   └── export_report.feature       # API-035 a API-039
│   └── security/
│       └── token_required.feature      # API-SEC-001
├── testdata/
│   ├── auth/
│   │   ├── register_valid.json
│   │   ├── register_empty_fields.json
│   │   ├── login_valid.json
│   │   └── login_invalid_credentials.json
│   ├── courses/
│   │   ├── create_course_valid.json
│   │   └── create_course_empty_name.json
│   ├── students/
│   │   ├── enroll_student_valid.json
│   │   ├── enroll_student_empty_fields.json
│   │   ├── enroll_student_invalid_email.json
│   │   └── enroll_student_autocomplete.json
│   ├── activities/
│   │   ├── activities_valid_two.json
│   │   ├── activities_valid_three.json
│   │   ├── activities_sum_not_100.json
│   │   ├── activities_empty_name.json
│   │   ├── activities_duplicate_names.json
│   │   ├── activities_zero_percentage.json
│   │   └── activities_updated_weights.json
│   ├── grades/
│   │   ├── grade_valid.json
│   │   ├── grade_negative.json
│   │   ├── grade_non_numeric.json
│   │   └── grade_null.json
│   └── reports/
│       (sin archivos JSON — reportes se consumen via GET con query params)
└── runners/
    └── TestRunner.java
```

### Mapeo Test Cases → Feature Files → Reglas de Negocio

| Test Case | Feature File | Reglas de Negocio | Tags |
|-----------|-------------|-------------------|------|
| API-001 | `auth/register.feature` | — | `@smoke @post @happy-path @auth` |
| API-002 | `auth/register.feature` | — | `@post @error-path @auth` |
| API-003 | `auth/register.feature` | RN-09 | `@post @error-path @auth` |
| API-004 | `auth/login.feature` | RN-10 | `@smoke @post @happy-path @auth` |
| API-005 | `auth/login.feature` | — | `@post @error-path @auth` |
| API-006 | `auth/login.feature` | — | `@post @error-path @auth` |
| API-007 | `auth/session.feature` | — | `@get @happy-path @auth` |
| API-008 | `auth/session.feature` | — | `@get @error-path @auth` |
| API-009 | `auth/logout.feature` | — | `@smoke @post @happy-path @auth` |
| API-010 | `auth/logout.feature` | — | `@post @error-path @auth @bug @HALLAZGO-2` |
| API-011 | `courses/list_courses.feature` | — | `@get @happy-path @courses` |
| API-012 | `courses/create_course.feature` | — | `@smoke @post @happy-path @courses` |
| API-013 | `courses/create_course.feature` | RN-01 | `@post @error-path @courses` |
| API-014 | `courses/create_course.feature` | — | `@post @error-path @courses` |
| API-015 | `courses/get_course_detail.feature` | — | `@get @happy-path @courses` |
| API-016 | `courses/get_course_detail.feature` | — | `@get @error-path @courses` |
| API-017 | `students/search_student.feature` | — | `@get @happy-path @students` |
| API-018 | `students/search_student.feature` | — | `@get @error-path @students` |
| API-019 | `students/enroll_student.feature` | RN-11 | `@smoke @post @happy-path @students` |
| API-020 | `students/enroll_student.feature` | — | `@post @error-path @students` |
| API-021 | `students/enroll_student.feature` | — | `@post @error-path @students` |
| API-022 | `students/enroll_student.feature` | RN-11, RN-12 | `@post @happy-path @students` |
| API-023 | `activities/manage_activities.feature` | RN-02, RN-03, RN-04, RN-05 | `@smoke @put @happy-path @activities` |
| API-024 | `activities/manage_activities.feature` | RN-02 | `@put @error-path @activities` |
| API-025 | `activities/manage_activities.feature` | RN-04 | `@put @error-path @activities` |
| API-026 | `activities/manage_activities.feature` | RN-05 | `@put @error-path @activities` |
| API-027 | `activities/manage_activities.feature` | RN-03 | `@put @error-path @activities` |
| API-028 | `activities/manage_activities.feature` | RN-02 | `@put @happy-path @activities` |
| API-029 | `activities/manage_activities.feature` | RN-02 | `@put @happy-path @activities` |
| API-030 | `grades/manage_grades.feature` | RN-06 | `@smoke @put @happy-path @grades` |
| API-031 | `grades/manage_grades.feature` | RN-06 | `@put @error-path @grades` |
| API-032 | `grades/manage_grades.feature` | — | `@put @error-path @grades @bug @HALLAZGO-3` |
| API-033 | `grades/manage_grades.feature` | RN-07 | `@put @happy-path @grades` |
| API-034 | `grades/manage_grades.feature` | RN-07 | `@put @happy-path @grades @reports` |
| API-035 | `reports/export_report.feature` | — | `@smoke @get @happy-path @reports` |
| API-036 | `reports/export_report.feature` | — | `@get @happy-path @reports` |
| API-037 | `reports/export_report.feature` | RN-07, RN-08 | `@get @happy-path @reports` |
| API-038 | `reports/export_report.feature` | — | `@get @error-path @reports` |
| API-039 | `reports/export_report.feature` | RN-07, RN-08 | `@get @happy-path @reports` |
| API-SEC-001 | `security/token_required.feature` | — | `@security @bug @HALLAZGO-1` |

---

## 3. LISTA DE TAREAS

### QA / Automatización

- [ ] Generar escenarios Gherkin detallados + inventario de archivos JSON (`/gherkin-case-generator`)
- [ ] Identificar y clasificar riesgos ASD (`/risk-identifier`)
- [ ] Implementar `.feature` files Karate organizados por dominio (`/unit-testing`):
  - [ ] `features/auth/register.feature` — API-001, API-002, API-003
  - [ ] `features/auth/login.feature` — API-004, API-005, API-006
  - [ ] `features/auth/session.feature` — API-007, API-008
  - [ ] `features/auth/logout.feature` — API-009, API-010
  - [ ] `features/courses/list_courses.feature` — API-011
  - [ ] `features/courses/create_course.feature` — API-012, API-013, API-014
  - [ ] `features/courses/get_course_detail.feature` — API-015, API-016
  - [ ] `features/students/search_student.feature` — API-017, API-018
  - [ ] `features/students/enroll_student.feature` — API-019, API-020, API-021, API-022
  - [ ] `features/activities/manage_activities.feature` — API-023 a API-029
  - [ ] `features/grades/manage_grades.feature` — API-030 a API-034
  - [ ] `features/reports/export_report.feature` — API-035 a API-039
  - [ ] `features/security/token_required.feature` — API-SEC-001
- [ ] Generar archivos `.json` en `testdata/` por dominio (`/unit-testing`):
  - [ ] `testdata/auth/` — 4 archivos JSON
  - [ ] `testdata/courses/` — 2 archivos JSON
  - [ ] `testdata/students/` — 4 archivos JSON
  - [ ] `testdata/activities/` — 7 archivos JSON
  - [ ] `testdata/grades/` — 4 archivos JSON
- [ ] Configurar `karate-config.js` con `baseUrl = 'http://localhost:8080'` (`/unit-testing`)
- [ ] Configurar `TestRunner.java` con scan de `classpath:features` (`/unit-testing`)
- [ ] Verificar `pom.xml` y Maven Wrapper existentes (`/unit-testing`)
- [ ] Etiquetar escenarios con hallazgos conocidos: `@bug @HALLAZGO-X` donde corresponda
- [ ] Ejecutar suite completa y validar resultados (`mvnw.cmd test`)
- [ ] Validar que los 12 endpoints están cubiertos al 100%
- [ ] Validar que las 12 reglas de negocio (RN-01 a RN-12) tienen al menos 1 caso de prueba
- [ ] Validar que las 3 formas de error están cubiertas por al menos 1 escenario cada una
