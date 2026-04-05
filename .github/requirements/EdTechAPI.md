# EdTechAPI.md — Documento de Visión y Requerimientos

## Reto de Implementación: API de Reportes y Boletines Académicos

| Campo | Detalle |
|---|---|
| **Proyecto** | EdTech — Reportes y Boletines Académicos |
| **Versión** | 1.0 |
| **Fecha** | 5 de abril de 2026 |
| **Tipo** | Requerimiento Oficial / PRD Técnico |
| **Autor** | TPO — Consolidado desde API_CONTRACTS.md v1.0 y TEST_CASES.md v2.0 |
| **Estado** | PENDIENTE DE SPEC |
| **Público objetivo** | IA (Copilot/LLM) para generación de SPEC, Gherkin y automatización Karate DSL |

---

## Tabla de contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Visión del Sistema](#2-visión-del-sistema)
3. [Alcance Funcional (Scope)](#3-alcance-funcional-scope)
4. [Superficie de API — Contratos Obligatorios](#4-superficie-de-api--contratos-obligatorios)
5. [Modelo de Datos — Esquema de Persistencia](#5-modelo-de-datos--esquema-de-persistencia)
6. [Reglas de Negocio Invariantes](#6-reglas-de-negocio-invariantes)
7. [Modelo de Autenticación y Seguridad](#7-modelo-de-autenticación-y-seguridad)
8. [Sistema de Errores Estandarizado](#8-sistema-de-errores-estandarizado)
9. [Catálogo Completo de Mensajes de Error](#9-catálogo-completo-de-mensajes-de-error)
10. [Funcionalidades Críticas — Checklist de Implementación](#10-funcionalidades-críticas--checklist-de-implementación)
11. [Hallazgos Conocidos y Comportamientos Divergentes](#11-hallazgos-conocidos-y-comportamientos-divergentes)
12. [Matriz de Cobertura de Pruebas](#12-matriz-de-cobertura-de-pruebas)
13. [Flujos E2E Críticos](#13-flujos-e2e-críticos)
14. [Definición de Hecho (DoD)](#14-definición-de-hecho-dod)
15. [Restricciones y Decisiones de Arquitectura](#15-restricciones-y-decisiones-de-arquitectura)
16. [Glosario de Dominio](#16-glosario-de-dominio)

---

## 1. Resumen Ejecutivo

**EdTechAPI** es una API REST local construida con **Java 21 + Spring Boot + SQLite** que permite a docentes gestionar el ciclo académico completo: registro e inicio de sesión, creación de cursos, inscripción de estudiantes, definición de programas evaluativos con ponderaciones, registro de calificaciones y exportación de boletines individuales en **PDF**, **HTML** y **JSON**.

El sistema opera exclusivamente en `localhost:8080`, utiliza autenticación por sesión del lado del servidor (header `X-Session-Token`) y persiste todos los datos en una base SQLite local (`./data/edtech.db`).

Este documento consolida la especificación técnica completa (contratos de API, esquema de BD, mensajes de error, hallazgos) y la superficie funcional (44 casos de prueba: 40 de integración API + 4 E2E) en un único artefacto de entrada para el flujo ASDD.

**La meta**: que un equipo de QA automatice la validación completa de esta API utilizando **Karate DSL**, cubriendo 12 endpoints, 40 escenarios de integración y 4 flujos E2E, con datos de prueba externalizados y trazabilidad total hacia las Historias de Usuario (HDU_1 a HDU_15).

---

## 2. Visión del Sistema

> **EdTech existe para resolver un problema concreto**: los docentes necesitan una herramienta local, sin dependencias de infraestructura externa, que les permita gestionar cursos, estudiantes, programas evaluativos y calificaciones, y generar boletines académicos individuales exportables.

### Principios rectores

1. **Local-first**: todo corre en `localhost`. Sin cloud, sin servicios externos, sin complejidad de despliegue.
2. **Sesión simple**: un docente, una sesión activa a la vez. Sin JWT, sin roles, sin recuperación de contraseña.
3. **Integridad evaluativa**: las ponderaciones SIEMPRE suman 100%. Las notas vacías cuentan como 0 en cálculos. El sistema advierte antes de exportar si hay notas pendientes.
4. **Exportación consistente**: HTML y PDF comparten la misma plantilla. JSON se genera desde el mismo modelo de reporte.
5. **Contratos estrictos**: cada endpoint tiene un contrato definido con status codes, mensajes de error exactos y formatos de respuesta documentados.

---

## 3. Alcance Funcional (Scope)

### 3.1 Historias de Usuario cubiertas

| ID | Historia | Dominio | Criticidad |
|---|---|---|---|
| HDU_1 | Registrar usuarios (docentes) | Autenticación | Crítica |
| HDU_2 | Iniciar sesión / validar sesión / cerrar sesión | Autenticación | Crítica |
| HDU_3 | Crear un nuevo curso | Gestión de Cursos | Crítica |
| HDU_4 | Consultar detalle de un curso | Gestión de Cursos | Alta |
| HDU_5 | Agregar estudiantes a un curso (alta on-the-fly) | Gestión de Estudiantes | Crítica |
| HDU_11 | Definir programa evaluativo del curso | Programa Evaluativo | Crítica |
| HDU_12 | Eliminar instancia de evaluación con redistribución | Programa Evaluativo | Crítica |
| HDU_13 | Actualizar ponderación de instancias existentes | Programa Evaluativo | Crítica |
| HDU_14 | Registrar nota de una instancia de evaluación | Calificaciones | Crítica |
| HDU_15 | Generar boletín del estudiante (PDF/HTML/JSON) | Reportes | Crítica |

### 3.2 Dominios funcionales

```
┌─────────────────────────────────────────────────────────────────────┐
│                        EdTech API (localhost:8080)                   │
├─────────────┬────────────┬──────────────┬────────────┬──────────────┤
│    AUTH      │  COURSES   │  STUDENTS    │  PROGRAM   │   REPORTS    │
│             │            │              │ & GRADES   │              │
│ · register  │ · create   │ · search     │ · define   │ · export PDF │
│ · login     │ · list     │ · enroll     │ · update   │ · export HTML│
│ · session   │ · detail   │ · auto-      │ · delete   │ · export JSON│
│ · logout    │            │   complete   │ · grade    │ · warnings   │
└─────────────┴────────────┴──────────────┴────────────┴──────────────┘
```

### 3.3 Fuera de alcance (Non-Goals)

- Portal estudiantil o acceso público.
- Roles diferenciados (admin, estudiante, etc.).
- Recuperación de contraseña.
- Carga masiva de estudiantes o notas.
- Notificaciones push o por email.
- Despliegue en cloud o contenedores.
- Exportación en formato XML u otros no especificados.

---

## 4. Superficie de API — Contratos Obligatorios

### 4.1 Configuración general

| Propiedad | Valor |
|---|---|
| Base URL | `http://localhost:8080` |
| Puerto | `8080` |
| Base de datos | SQLite (`./data/edtech.db`) |
| Serialización JSON | Jackson · `default-property-inclusion: non_null` — campos `null` se **omiten** del JSON |
| CORS | Habilitado para `localhost:5173` y `localhost:4173` · Header expuesto: `Content-Disposition` |
| Password hashing | BCrypt |
| Identificadores | UUID v4 generados por el backend |

### 4.2 Tabla de endpoints

| # | Método | Endpoint | Auth | Controller | HU |
|---|---|---|---|---|---|
| 1 | `POST` | `/api/auth/register` | No | AuthController | HDU_1 |
| 2 | `POST` | `/api/auth/login` | No | AuthController | HDU_2 |
| 3 | `GET` | `/api/auth/session` | Sí | AuthController | HDU_2 |
| 4 | `POST` | `/api/auth/logout` | Sí | AuthController | HDU_2 |
| 5 | `GET` | `/api/courses` | Sí | CourseController | HDU_3 |
| 6 | `POST` | `/api/courses` | Sí | CourseController | HDU_3 |
| 7 | `GET` | `/api/courses/{courseId}` | Sí | CourseController | HDU_4 |
| 8 | `GET` | `/api/students/{studentId}` | Sí | CourseController | HDU_5 |
| 9 | `POST` | `/api/courses/{courseId}/students` | Sí | CourseController | HDU_5 |
| 10 | `PUT` | `/api/courses/{courseId}/activities` | Sí | CourseController | HDU_11/12/13 |
| 11 | `PUT` | `/api/courses/{courseId}/grades` | Sí | CourseController | HDU_14 |
| 12 | `GET` | `/api/courses/{courseId}/students/{studentId}/report?format=` | Sí | ReportController | HDU_15 |

### 4.3 Contratos detallados por endpoint

---

#### AUTH-01: POST /api/auth/register

**Propósito**: Registrar un nuevo docente y crear sesión automáticamente.

**Request**:
```json
{
  "username": "string (@NotBlank)",
  "password": "string (@NotBlank)"
}
```

**Lógica de negocio**:
1. `username` se normaliza con `.trim()`. Unicidad validada con `lower(username) = lower(?)` → **case-insensitive**.
2. `password`: no null, no blank. Se hashea con BCrypt.
3. Se genera UUID v4 para `teacherId` y para `token`.
4. Se inserta en `teachers` y en `sessions`.

**Respuestas**:

| Status | Condición | Tipo | Mensaje / Body |
|---|---|---|---|
| `201 Created` | Registro exitoso | — | `SessionResponse` |
| `400 Bad Request` | Body con campos vacíos + `@Valid` | Forma 2 | `"Solicitud invalida"` + details por campo |
| `400 Bad Request` | Username o password blank (nivel service) | Forma 1 | `"El nombre de usuario es obligatorio"` / `"La contrasena es obligatoria"` |
| `409 Conflict` | Username duplicado (case-insensitive) | Forma 1 | `"El nombre de usuario ya existe"` |
| `500 Internal Server Error` | Body null, malformado o tipo incorrecto | Forma 3 | `"Error interno del servidor"` |

**SessionResponse** (compartido con login y session):
```json
{
  "user": {
    "id": "uuid-v4-string",
    "username": "string"
  },
  "token": "uuid-v4-string"
}
```

> **IMPORTANTE**: `username` está dentro del objeto `user`, NO en el nivel raíz.

---

#### AUTH-02: POST /api/auth/login

**Propósito**: Autenticar docente. **Elimina TODAS las sesiones previas** antes de crear una nueva.

**Request**:
```json
{
  "username": "string (@NotBlank)",
  "password": "string (@NotBlank)"
}
```

**Lógica de negocio**:
1. Busca teacher por `lower(username) = lower(?)` → **case-insensitive**.
2. Compara password con hash usando `passwordEncoder.matches()`.
3. Si coincide: `DELETE FROM sessions WHERE teacher_id = ?` (borra TODAS las sesiones previas).
4. Crea nueva sesión con UUID v4.

**Respuestas**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `200 OK` | Login exitoso | — | `SessionResponse` |
| `400 Bad Request` | Campos vacíos con `@Valid` | Forma 2 | `"Solicitud invalida"` |
| `400 Bad Request` | Username/password blank (nivel service) | Forma 1 | `"El nombre de usuario es obligatorio"` / `"La contrasena es obligatoria"` |
| `401 Unauthorized` | Credenciales incorrectas | Forma 1 | `"Usuario o contrasena incorrectos"` |
| `500 Internal Server Error` | Body malformado | Forma 3 | `"Error interno del servidor"` |

> El mensaje `401` es intencionalmente genérico: no distingue entre "usuario no existe" y "contraseña incorrecta".

---

#### AUTH-03: GET /api/auth/session

**Propósito**: Validar token y obtener datos de la sesión actual.

| Propiedad | Valor |
|---|---|
| Header requerido | `X-Session-Token: <uuid>` |

**Respuestas**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `200 OK` | Token válido | — | `SessionResponse` |
| `401 Unauthorized` | Token vacío (blank) | Forma 1 | `"Falta el token de sesion"` |
| `401 Unauthorized` | Token no existe en DB | Forma 1 | `"Sesion invalida o expirada"` |
| `500 Internal Server Error` | Header `X-Session-Token` **ausente** | Forma 3 | `"Error interno del servidor"` (HALLAZGO-1) |

---

#### AUTH-04: POST /api/auth/logout

**Propósito**: Cerrar sesión eliminando el token de la base de datos.

| Propiedad | Valor |
|---|---|
| Header requerido | `X-Session-Token: <uuid>` |

**Lógica**: Ejecuta `DELETE FROM sessions WHERE token = ?` **sin verificar** si el DELETE afectó filas.

**Respuestas**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `204 No Content` | Token existía → sesión eliminada | — | Sin body |
| `204 No Content` | Token NO existía → DELETE no afectó filas | — | Sin body (HALLAZGO-2) |
| `401 Unauthorized` | Token vacío (blank) | Forma 1 | `"Falta el token de sesion"` |
| `500 Internal Server Error` | Header ausente | Forma 3 | `"Error interno del servidor"` (HALLAZGO-1) |

---

#### COURSE-01: GET /api/courses

**Propósito**: Listar todos los cursos del docente autenticado con conteos.

| Propiedad | Valor |
|---|---|
| Header requerido | `X-Session-Token: <uuid>` |

**Respuesta exitosa** (`200 OK`):
```json
[
  {
    "id": "uuid",
    "name": "Matemáticas",
    "teacherId": "uuid",
    "studentCount": 5,
    "activityCount": 3,
    "createdAt": "2026-04-05T10:00:00.000Z"
  }
]
```

> Devuelve `[]` (array vacío) si el docente no tiene cursos. Ordenado por `created_at DESC`.

**Errores**:

| Status | Condición | Mensaje |
|---|---|---|
| `401 Unauthorized` | Token inválido/expirado | `"Sesion invalida o expirada"` |
| `500 Internal Server Error` | Header ausente | `"Error interno del servidor"` |

---

#### COURSE-02: POST /api/courses

**Propósito**: Crear un nuevo curso para el docente autenticado.

**Request**:
```json
{
  "name": "string (@NotBlank)"
}
```

**Lógica**: `name` se normaliza con `.trim()`. Unicidad: `lower(name) = lower(?)` + mismo `teacher_id` → **case-insensitive por docente**.

**Respuestas**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `201 Created` | Curso creado | — | `CourseDetailResponse` |
| `400 Bad Request` | Campo `name` vacío + `@Valid` | Forma 2 | `"Solicitud invalida"` |
| `400 Bad Request` | Name blank (nivel service) | Forma 1 | `"El nombre del curso es obligatorio"` |
| `401 Unauthorized` | Token inválido | Forma 1 | `"Sesion invalida o expirada"` |
| `409 Conflict` | Nombre duplicado (mismo docente) | Forma 1 | `"Ya existe un curso con este nombre"` |

**CourseDetailResponse** (compartido con getCourse, addStudent, updateActivities, updateGrade):
```json
{
  "id": "uuid",
  "name": "Matemáticas",
  "teacherId": "uuid",
  "students": [
    {
      "id": "uuid-interno",
      "studentId": "EST-001",
      "name": "Juan Pérez",
      "email": "juan@email.com"
    }
  ],
  "activities": [
    {
      "id": "uuid",
      "name": "Examen Final",
      "percentage": 40.0
    }
  ],
  "grades": [
    {
      "studentId": "EST-001",
      "activityId": "uuid-actividad",
      "grade": 4.5
    }
  ],
  "createdAt": "2025-04-05T10:00:00.000Z"
}
```

> **Ordenamiento**: `students` por `full_name ASC` · `activities` por `position ASC` · `grades` por student `full_name ASC`.
>
> **Nota sobre null grades**: Debido a Jackson `non_null`, si `grade` es `null`, el campo `grade` se **omite completamente** del JSON en `CourseDetailResponse` (HALLAZGO-5).

---

#### COURSE-03: GET /api/courses/{courseId}

**Propósito**: Obtener detalle completo de un curso (estudiantes, actividades, notas).

| Propiedad | Valor |
|---|---|
| Header requerido | `X-Session-Token: <uuid>` |
| Path param | `courseId` — UUID del curso |

**Lógica**: `loadOwnedCourse()` busca curso donde `id = ?` AND `teacher_id = ?`. Si no encuentra (no existe O pertenece a otro docente): 404.

**Respuestas**:

| Status | Condición | Mensaje |
|---|---|---|
| `200 OK` | Éxito | `CourseDetailResponse` |
| `401 Unauthorized` | Token inválido | `"Sesion invalida o expirada"` |
| `404 Not Found` | Curso no existe o pertenece a otro docente | `"Curso no encontrado"` |

---

#### COURSE-04: GET /api/students/{studentId}

**Propósito**: Buscar un estudiante globalmente por su `student_identifier`.

| Propiedad | Valor |
|---|---|
| Header requerido | `X-Session-Token: <uuid>` |
| Path param | `studentId` — el `student_identifier` (ej. `"EST-001"`) |

**Lógica**: Búsqueda **exacta** y **case-sensitive** por `student_identifier`. Se normaliza con `.trim()`. Solo requiere autenticación (no ownership de ningún curso).

**Respuesta exitosa** (`200 OK`):
```json
{
  "id": "uuid-interno",
  "studentId": "EST-001",
  "name": "Juan Pérez",
  "email": "juan@email.com"
}
```

**Errores**:

| Status | Condición | Mensaje |
|---|---|---|
| `400 Bad Request` | studentId vacío/blank | `"El ID del estudiante es obligatorio"` |
| `401 Unauthorized` | Token inválido | `"Sesion invalida o expirada"` |
| `404 Not Found` | Estudiante no existe | `"Estudiante no encontrado"` |

---

#### COURSE-05: POST /api/courses/{courseId}/students

**Propósito**: Inscribir un estudiante en un curso. Si no existe en el sistema, lo crea (alta on-the-fly).

**Request**:
```json
{
  "studentId": "string (@NotBlank)",
  "name": "string (@NotBlank)",
  "email": "string (@NotBlank)"
}
```

**Lógica de negocio**:
1. Verifica ownership del curso (`loadOwnedCourse`).
2. Normaliza cada campo con `.trim()`.
3. Valida email con regex: `^[^\s@]+@[^\s@]+\.[^\s@]+$`.
4. Busca estudiante por `student_identifier`:
   - Si no existe → crea nuevo registro en `students`.
   - Si existe → **reutiliza el registro existente** (ignora name y email recibidos).
5. Verifica que no esté ya inscrito en el curso.
6. Inserta en `course_students`.
7. Retorna `CourseDetailResponse`.

**Respuestas**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `200 OK` | Estudiante inscrito | — | `CourseDetailResponse` |
| `400 Bad Request` | Campos vacíos + `@Valid` | Forma 2 | `"Solicitud invalida"` |
| `400 Bad Request` | Campo vacío (nivel service) | Forma 1 | `"El ID del estudiante es obligatorio"` / `"El nombre completo es obligatorio"` / `"El correo electronico es obligatorio"` |
| `400 Bad Request` | Email inválido | Forma 1 | `"El correo electronico no es valido"` |
| `401 Unauthorized` | Token inválido | Forma 1 | `"Sesion invalida o expirada"` |
| `404 Not Found` | Curso no encontrado | Forma 1 | `"Curso no encontrado"` |
| `409 Conflict` | Estudiante ya inscrito | Forma 1 | `"El estudiante ya esta inscrito en este curso"` |

---

#### COURSE-06: PUT /api/courses/{courseId}/activities

**Propósito**: Reemplazar TODAS las actividades evaluativas de un curso. Las que ya no estén en la lista se eliminan junto con sus notas.

> **ATENCIÓN**: Este endpoint **NO tiene `@Valid`** en `@RequestBody`. Toda la validación es manual (HALLAZGO-6). Todos los errores son Forma 1 (nunca Forma 2).

**Request** (array directo, NO objeto envolvente):
```json
[
  {
    "id": "uuid-existente-o-null",
    "name": "string (obligatorio)",
    "percentage": 40.0
  },
  {
    "id": null,
    "name": "string (obligatorio)",
    "percentage": 60.0
  }
]
```

**Lógica de negocio**:
1. Verifica ownership.
2. Validaciones manuales (`validateActivities()`):
   - Array no puede ser null ni vacío.
   - Cada nombre no puede ser blank.
   - Nombres únicos (case-insensitive con `toLowerCase()`).
   - Cada `percentage` debe ser > 0.
   - Suma de `percentage` debe ser exactamente 100 (tolerancia ±0.01).
3. Para cada actividad: si `id` null/blank → nuevo UUID; si existe en DB → UPDATE; si no → INSERT.
4. Actividades existentes que **no están** en la lista nueva → eliminadas junto con sus `student_grades`.

**Respuestas**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `200 OK` | Actividades actualizadas | — | `CourseDetailResponse` |
| `400 Bad Request` | Lista vacía/null | Forma 1 | `"Debe existir al menos una actividad evaluativa"` |
| `400 Bad Request` | Nombre vacío | Forma 1 | `"Cada actividad debe tener nombre"` |
| `400 Bad Request` | Nombres duplicados | Forma 1 | `"Las actividades no pueden tener nombres duplicados"` |
| `400 Bad Request` | Ponderación ≤ 0 o null | Forma 1 | `"Cada actividad debe tener una ponderacion mayor a 0"` |
| `400 Bad Request` | Suma ≠ 100% | Forma 1 | `"La suma de ponderaciones debe ser exactamente 100%"` |
| `401 Unauthorized` | Token inválido | Forma 1 | `"Sesion invalida o expirada"` |
| `404 Not Found` | Curso no encontrado | Forma 1 | `"Curso no encontrado"` |
| `500 Internal Server Error` | Body malformado o tipos incorrectos | Forma 3 | `"Error interno del servidor"` (HALLAZGO-3) |

---

#### COURSE-07: PUT /api/courses/{courseId}/grades

**Propósito**: Registrar o actualizar la nota de un estudiante en una actividad evaluativa.

**Request**:
```json
{
  "studentId": "string — student_identifier, NO UUID interno (@NotBlank)",
  "activityId": "string — UUID de la actividad (@NotBlank)",
  "grade": 4.5
}
```

> `grade` es `Double` (nullable). Si es `null`, se guarda como null en DB. Si se omite del JSON, Jackson lo interpreta como `null`. No existe validación de máximo.

**Lógica de negocio**:
1. Verifica ownership.
2. `validateGrade()`: si `grade` null → permite; si `grade < 0` → error.
3. `resolveStudentInternalId()` → verifica que el estudiante está inscrito en ESE curso.
4. `ensureActivityBelongsToCourse()` → verifica que la actividad existe en ESE curso.
5. Si ya existe grade → UPDATE; si no → INSERT.

**Respuestas**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `200 OK` | Nota registrada/actualizada | — | `CourseDetailResponse` |
| `400 Bad Request` | studentId o activityId blank + `@Valid` | Forma 2 | `"Solicitud invalida"` |
| `400 Bad Request` | Grade negativa | Forma 1 | `"La nota no puede ser negativa"` |
| `401 Unauthorized` | Token inválido | Forma 1 | `"Sesion invalida o expirada"` |
| `404 Not Found` | Curso no encontrado | Forma 1 | `"Curso no encontrado"` |
| `404 Not Found` | Estudiante no inscrito en el curso | Forma 1 | `"El estudiante no pertenece al curso"` |
| `404 Not Found` | Actividad no existe en el curso | Forma 1 | `"La actividad evaluativa no existe en el curso"` |
| `500 Internal Server Error` | `grade` con tipo incorrecto (ej. string) | Forma 3 | `"Error interno del servidor"` (HALLAZGO-3) |

---

#### REPORT-01: GET /api/courses/{courseId}/students/{studentId}/report

**Propósito**: Exportar boletín académico de un estudiante en formato JSON, HTML o PDF.

| Propiedad | Valor |
|---|---|
| Header requerido | `X-Session-Token: <uuid>` |
| Path params | `courseId` (UUID), `studentId` (student_identifier, NO UUID interno) |
| Query param | `format` (obligatorio): `json`, `html`, `pdf` |

**Lógica de negocio**:
1. Valida `format` no null/blank, convierte a lowercase.
2. Obtiene curso, busca estudiante dentro del curso por `studentId`.
3. Por cada actividad, busca la nota. Si no existe: `grade = null`.
4. Cálculos (null grades = 0):
   - `generalAverage = sum(grades) / count(activities)` donde null = 0
   - `weightedAverage = sum(grade × percentage) / 100` donde null = 0
   - `hasEmptyGrades = true` si alguna nota es null

**Respuesta JSON** (`200 OK`):
```json
{
  "teacher": "nombre_del_docente",
  "course": "nombre_del_curso",
  "student": {
    "id": "EST-001",
    "name": "Juan Pérez",
    "email": "juan@email.com"
  },
  "grades": [
    {
      "activity": "Examen Final",
      "percentage": 40.0,
      "grade": 4.5
    },
    {
      "activity": "Tarea",
      "percentage": 60.0,
      "grade": null
    }
  ],
  "generalAverage": 2.25,
  "weightedAverage": 1.8,
  "hasEmptyGrades": true,
  "exportDate": "2025-04-05T10:00:00.000Z",
  "format": "json"
}
```

> **CRÍTICO (HALLAZGO-5)**: El JSON del reporte se construye manualmente (StringBuilder), NO con Jackson. Por lo tanto, `"grade": null` **SÍ aparece** explícitamente, a diferencia de `CourseDetailResponse` donde Jackson omite null grades.

**Respuesta HTML** (`200 OK`):
- Content-Type: `text/html;charset=UTF-8`
- Content-Disposition: `attachment; filename="boletin-{sanitized}-{studentId}.html"`
- Null grades se muestran como `"Sin nota"`

**Respuesta PDF** (`200 OK`):
- Content-Type: `application/pdf`
- Content-Disposition: `attachment; filename="boletin-{sanitized}-{studentId}.pdf"`
- Generado desde HTML con OpenHTMLToPDF

**Patrón de filename**: `boletin-{sanitizedCourseName}-{studentId}.{extension}`
- Sanitización: `courseName.replaceAll("[^a-zA-Z0-9_-]", "-")`

**Errores**:

| Status | Condición | Tipo | Mensaje |
|---|---|---|---|
| `400 Bad Request` | Formato vacío/blank | Forma 1 | `"El formato es obligatorio"` |
| `400 Bad Request` | Formato no soportado (ej. "xml") | Forma 1 | `"Formato no soportado"` |
| `401 Unauthorized` | Token inválido | Forma 1 | `"Sesion invalida o expirada"` |
| `404 Not Found` | Curso no encontrado | Forma 1 | `"Curso no encontrado"` |
| `404 Not Found` | Estudiante no inscrito en el curso | Forma 1 | `"Estudiante no encontrado en el curso"` |
| `500 Internal Server Error` | Error generando PDF | Forma 1 | `"No fue posible generar el PDF"` |
| `500 Internal Server Error` | Query param `format` ausente | Forma 3 | `"Error interno del servidor"` |

---

## 5. Modelo de Datos — Esquema de Persistencia

### 5.1 Diagrama de tablas

```sql
-- 1. teachers (docentes)
CREATE TABLE IF NOT EXISTS teachers (
    id TEXT PRIMARY KEY,              -- UUID v4
    username TEXT NOT NULL UNIQUE,     -- case-insensitive en queries
    password_hash TEXT NOT NULL,       -- BCrypt
    created_at TEXT NOT NULL           -- ISO 8601 UTC
);

-- 2. sessions (sesiones activas)
CREATE TABLE IF NOT EXISTS sessions (
    token TEXT PRIMARY KEY,            -- UUID v4
    teacher_id TEXT NOT NULL,          -- FK → teachers.id (lógica)
    created_at TEXT NOT NULL
);

-- 3. students (globales, NO por curso)
CREATE TABLE IF NOT EXISTS students (
    id TEXT PRIMARY KEY,               -- UUID v4 interno
    student_identifier TEXT NOT NULL UNIQUE,  -- ID público (ej. "EST-001")
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- 4. courses
CREATE TABLE IF NOT EXISTS courses (
    id TEXT PRIMARY KEY,               -- UUID v4
    teacher_id TEXT NOT NULL,          -- FK → teachers.id (lógica)
    name TEXT NOT NULL,
    created_at TEXT NOT NULL,
    UNIQUE(teacher_id, name)           -- Unicidad por docente
);

-- 5. course_students (N:M entre cursos y estudiantes)
CREATE TABLE IF NOT EXISTS course_students (
    id TEXT PRIMARY KEY,
    course_id TEXT NOT NULL,           -- FK → courses.id (lógica)
    student_id TEXT NOT NULL,          -- FK → students.id (lógica)
    created_at TEXT NOT NULL,
    UNIQUE(course_id, student_id)
);

-- 6. evaluation_activities (programa evaluativo)
CREATE TABLE IF NOT EXISTS evaluation_activities (
    id TEXT PRIMARY KEY,               -- UUID v4
    course_id TEXT NOT NULL,           -- FK → courses.id (lógica)
    name TEXT NOT NULL,
    weight REAL NOT NULL,              -- Ponderación (suma = 100%)
    position INTEGER NOT NULL,         -- Orden de presentación
    UNIQUE(course_id, name)
);

-- 7. student_grades (notas)
CREATE TABLE IF NOT EXISTS student_grades (
    id TEXT PRIMARY KEY,
    course_id TEXT NOT NULL,
    student_id TEXT NOT NULL,          -- FK → students.id (UUID interno, NO student_identifier)
    activity_id TEXT NOT NULL,         -- FK → evaluation_activities.id
    grade REAL,                        -- Nullable (null = sin nota)
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE(course_id, student_id, activity_id)
);
```

### 5.2 Notas críticas sobre el esquema

| Aspecto | Detalle |
|---|---|
| **Foreign Keys** | NO hay FOREIGN KEYS definidas. Las relaciones son manejadas por lógica de aplicación |
| **`student_grades.student_id`** | Referencia `students.id` (UUID interno), **NO** `student_identifier` |
| **`grade`** | Es `REAL` nullable. `null` = sin calificación (tratado como 0 en cálculos) |
| **`weight` vs `percentage`** | En BD se llama `weight`; en la API se expone como `percentage` |
| **Timestamps** | Almacenados como `TEXT` en formato ISO 8601 |

---

## 6. Reglas de Negocio Invariantes

Estas reglas son **inquebrantables** desde la primera iteración del MVP:

| # | Regla | Validación | Mensaje de error |
|---|---|---|---|
| RN-01 | Cursos únicos por docente (case-insensitive) | `lower(name) = lower(?) AND teacher_id = ?` | `"Ya existe un curso con este nombre"` |
| RN-02 | Ponderaciones suman exactamente 100% | `abs(sum - 100) <= 0.01` | `"La suma de ponderaciones debe ser exactamente 100%"` |
| RN-03 | Cada ponderación > 0 | `percentage > 0` | `"Cada actividad debe tener una ponderacion mayor a 0"` |
| RN-04 | Nombres de instancias no vacíos | `name.isBlank() == false` | `"Cada actividad debe tener nombre"` |
| RN-05 | Nombres de instancias no duplicados (case-insensitive) | `toLowerCase()` comparison | `"Las actividades no pueden tener nombres duplicados"` |
| RN-06 | Notas numéricas ≥ 0 | `grade >= 0` (si no es null) | `"La nota no puede ser negativa"` |
| RN-07 | Notas vacías = 0 en cálculo | null → 0 para `generalAverage` y `weightedAverage` | — |
| RN-08 | Advertencia si existen notas vacías | `hasEmptyGrades = true` en reporte | — |
| RN-09 | Usernames únicos (case-insensitive) | `lower(username) = lower(?)` | `"El nombre de usuario ya existe"` |
| RN-10 | Sesión única por docente | Login borra todas las sesiones previas | — |
| RN-11 | Estudiante se reutiliza si ya existe | Búsqueda por `student_identifier` antes de crear | — |
| RN-12 | Email válido por regex | `^[^\s@]+@[^\s@]+\.[^\s@]+$` | `"El correo electronico no es valido"` |

---

## 7. Modelo de Autenticación y Seguridad

### 7.1 Flujo de autenticación

```
             ┌──────────────────┐
             │  POST /register  │ ← Sin auth
             │  crea teacher +  │
             │  session         │
             └───────┬──────────┘
                     │ token
                     ▼
             ┌──────────────────┐
             │  POST /login     │ ← Sin auth
             │  valida creds    │
             │  BORRA sesiones  │
             │  previas         │
             │  crea nueva      │
             └───────┬──────────┘
                     │ token
                     ▼
    ┌────────────────────────────────────┐
    │  Endpoints protegidos              │
    │  Header: X-Session-Token: <uuid>   │
    │                                    │
    │  GET /session  → valida token      │
    │  GET/POST/PUT courses, students,   │
    │  activities, grades, report        │
    └────────────────┬───────────────────┘
                     │
                     ▼
             ┌──────────────────┐
             │  POST /logout    │
             │  DELETE token    │
             │  → 204 siempre  │
             └──────────────────┘
```

### 7.2 Reglas de seguridad

| Regla | Detalle |
|---|---|
| **Mecanismo** | Sesión del lado del servidor en tabla `sessions` |
| **Header** | `X-Session-Token` (UUID v4 generado por backend) |
| **Sesión única** | Login elimina TODAS las sesiones previas del docente |
| **Sin expiración** | No existe TTL ni limpieza automática |
| **Password** | Hasheado con BCrypt. Nunca en texto plano |
| **Header ausente** | Produce 500 (HALLAZGO-1), NO 401 |
| **Header vacío** | Produce 401 correctamente: `"Falta el token de sesion"` |
| **Ownership** | Los cursos solo son visibles/modificables por su docente creador |

---

## 8. Sistema de Errores Estandarizado

El `ApiExceptionHandler` produce **3 formas** de respuesta de error:

### Forma 1 — ApiException (errores de negocio)

```json
{
  "timestamp": "2025-04-05T10:00:00.000Z",
  "status": 400,
  "error": "Bad Request",
  "message": "<mensaje_en_español>",
  "details": {}
}
```
> `details` es siempre `{}` vacío. Status varía: 400, 401, 404, 409, 500.

### Forma 2 — Validación Spring @Valid

```json
{
  "timestamp": "2025-04-05T10:00:00.000Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Solicitud invalida",
  "details": {
    "username": "must not be blank",
    "password": "must not be blank"
  }
}
```
> Solo se activa en endpoints con `@Valid`: register, login, courses (create), students (enroll), grades.

### Forma 3 — Catch-all (excepciones no controladas)

```json
{
  "timestamp": "2025-04-05T10:00:00.000Z",
  "status": 500,
  "error": "Internal Server Error",
  "message": "Error interno del servidor",
  "details": {}
}
```
> Se dispara ante: header ausente, body malformado, tipos incorrectos en campos numéricos.

### Tabla de dispatch por situación

| Situación | Handler | Status | Forma |
|---|---|---|---|
| Negocio (credenciales, duplicados, not found, etc.) | ApiException | Variable | Forma 1 |
| Body con `@Valid` + campos faltantes/inválidos | MethodArgumentNotValidException | 400 | Forma 2 |
| Header `X-Session-Token` **ausente** | Catch-all (Exception) | **500** | Forma 3 |
| Body con tipos incorrectos (ej. `"grade": "abc"`) | Catch-all (Exception) | **500** | Forma 3 |
| Body vacío o malformado en endpoint con `@Valid` | Catch-all (Exception) | **500** | Forma 3 |

---

## 9. Catálogo Completo de Mensajes de Error

### 9.1 Autenticación (AuthService)

| Mensaje exacto | Status | Contexto |
|---|---|---|
| `"El nombre de usuario es obligatorio"` | 400 | register/login · username null/blank |
| `"La contrasena es obligatoria"` | 400 | register/login · password null/blank |
| `"El nombre de usuario ya existe"` | 409 | register · username duplicado (case-insensitive) |
| `"Usuario o contrasena incorrectos"` | 401 | login · credenciales inválidas (genérico) |
| `"Falta el token de sesion"` | 401 | token header vacío/blank |
| `"Sesion invalida o expirada"` | 401 | token no encontrado en DB |

### 9.2 Cursos y Estudiantes (CourseService)

| Mensaje exacto | Status | Contexto |
|---|---|---|
| `"El nombre del curso es obligatorio"` | 400 | createCourse · name blank |
| `"Ya existe un curso con este nombre"` | 409 | createCourse · nombre duplicado (case-insensitive) |
| `"Curso no encontrado"` | 404 | curso no existe o pertenece a otro docente |
| `"El ID del estudiante es obligatorio"` | 400 | studentId blank |
| `"El nombre completo es obligatorio"` | 400 | name blank en addStudent |
| `"El correo electronico es obligatorio"` | 400 | email blank en addStudent |
| `"El correo electronico no es valido"` | 400 | email no cumple regex |
| `"El estudiante ya esta inscrito en este curso"` | 409 | addStudent duplicado |
| `"Estudiante no encontrado"` | 404 | findStudentByIdentifier sin resultado |
| `"El estudiante no pertenece al curso"` | 404 | updateGrade · estudiante no inscrito |
| `"La actividad evaluativa no existe en el curso"` | 404 | updateGrade · activityId inválido |
| `"La nota no puede ser negativa"` | 400 | grade < 0 |

### 9.3 Actividades (CourseService — validación manual)

| Mensaje exacto | Status | Contexto |
|---|---|---|
| `"Debe existir al menos una actividad evaluativa"` | 400 | lista vacía o null |
| `"Cada actividad debe tener nombre"` | 400 | actividad con nombre blank |
| `"Las actividades no pueden tener nombres duplicados"` | 400 | nombres repetidos (case-insensitive) |
| `"Cada actividad debe tener una ponderacion mayor a 0"` | 400 | percentage null o ≤ 0 |
| `"La suma de ponderaciones debe ser exactamente 100%"` | 400 | sum ≠ 100 (tolerancia ±0.01) |

### 9.4 Reportes (ReportService)

| Mensaje exacto | Status | Contexto |
|---|---|---|
| `"El formato es obligatorio"` | 400 | format null/blank |
| `"Formato no soportado"` | 400 | formato ≠ json/html/pdf |
| `"Estudiante no encontrado en el curso"` | 404 | studentId no inscrito en el curso |
| `"No fue posible generar el PDF"` | 500 | error en OpenHTMLToPDF |

### 9.5 Framework (Spring / Catch-all)

| Mensaje exacto | Status | Contexto |
|---|---|---|
| `"Solicitud invalida"` | 400 | Forma 2 · `@Valid` fallido |
| `"must not be blank"` | — | En `details` por cada campo `@NotBlank` fallido |
| `"Error interno del servidor"` | 500 | Forma 3 · cualquier excepción no manejada |

---

## 10. Funcionalidades Críticas — Checklist de Implementación

### 10.1 Autenticación y Sesión

- [ ] **API-001** · Registro exitoso → 201 + `SessionResponse` con `user.username` y `token`
- [ ] **API-002** · Registro con campos vacíos → 400 + mensaje indicando campo faltante
- [ ] **API-003** · Registro con username duplicado → 409 + `"El nombre de usuario ya existe"`
- [ ] **API-004** · Login exitoso → 200 + `SessionResponse`
- [ ] **API-005** · Login con credenciales inválidas → 401 + mensaje genérico (no revela qué falló)
- [ ] **API-006** · Login con campos vacíos → 400
- [ ] **API-007** · Validar sesión activa → 200 + `SessionResponse`
- [ ] **API-008** · Validar sesión con token inválido → 401
- [ ] **API-009** · Logout exitoso → 204 + token invalidado (verificar con GET /session posterior)
- [ ] **API-010** · Logout con token inválido → **401** (@bug HALLAZGO-2, actualmente retorna 204)

### 10.2 Gestión de Cursos

- [ ] **API-011** · Listar cursos del docente → 200 + array con `id`, `name`, `studentCount`, `activityCount`
- [ ] **API-012** · Crear curso → 201 + `CourseDetailResponse`
- [ ] **API-013** · Crear curso con nombre duplicado → 409
- [ ] **API-014** · Crear curso con nombre vacío → 400

### 10.3 Gestión de Estudiantes

- [ ] **API-015** · Detalle de curso existente → 200 + `students[]`, `activities[]`, `grades[]`
- [ ] **API-016** · Detalle de curso inexistente → 404
- [ ] **API-017** · Buscar estudiante existente → 200 + `studentId`, `name`, `email`
- [ ] **API-018** · Buscar estudiante inexistente → 404
- [ ] **API-019** · Inscribir estudiante nuevo (alta on-the-fly) → 200 + curso actualizado
- [ ] **API-020** · Inscribir con campos vacíos → 400 + estudiante NO creado parcialmente
- [ ] **API-021** · Inscribir estudiante ya inscrito → 409
- [ ] **API-022** · Inscribir estudiante existente en sistema (autocomplete) → 200 + reutiliza registro

### 10.4 Programa Evaluativo

- [ ] **API-023** · Definir programa válido (suma = 100%) → 200 + actividades creadas
- [ ] **API-024** · Definir programa con suma ≠ 100% → 400 + mensaje con "100"
- [ ] **API-025** · Programa con nombre vacío → 400
- [ ] **API-026** · Programa con nombres duplicados → 400
- [ ] **API-027** · Programa con ponderación ≤ 0 → 400
- [ ] **API-028** · Actualizar ponderaciones (suma = 100%) → 200 + ponderaciones actualizadas
- [ ] **API-029** · Eliminar instancia con redistribución → 200 + instancia eliminada

### 10.5 Calificaciones

- [ ] **API-030** · Nota válida (≥ 0) → 200 + promedios recalculados
- [ ] **API-031** · Nota negativa → 400
- [ ] **API-032** · Nota con caracteres no numéricos → **400** (@bug HALLAZGO-3, actualmente retorna 500)
- [ ] **API-033** · Nota nula (null = 0 en promedio) → 200 + promedios con null = 0
- [ ] **API-034** · Recálculo de promedios tras cambio de pesos → verificar consistencia matemática

### 10.6 Exportación de Reportes

- [ ] **API-035** · Exportar PDF → 200 + Content-Type `application/pdf` + Content-Disposition + body binario no vacío
- [ ] **API-036** · Exportar HTML → 200 + Content-Type `text/html` + contiene `<html`
- [ ] **API-037** · Exportar JSON → 200 + JSON con `teacher`, `course`, `student`, `grades`, `generalAverage`, `weightedAverage`, `hasEmptyGrades`
- [ ] **API-038** · Formato no soportado (xml) → 400 + `"Formato no soportado"`
- [ ] **API-039** · Boletín con notas vacías → 200 + `hasEmptyGrades: true` + promedios con null = 0

### 10.7 Seguridad Transversal

- [ ] **API-SEC-001** · Todos los endpoints protegidos sin token → **401** (@bug HALLAZGO-1, si header ausente actualmente retorna 500)

---

## 11. Hallazgos Conocidos y Comportamientos Divergentes

Los tests deben validar el comportamiento esperado/correcto. Los escenarios afectados por hallazgos conocidos deben etiquetarse con @bug @HALLAZGO-X — fallarán hasta que el DEV corrija el bug, y pasarán automáticamente tras la corrección.

| ID | Severidad | Tipo | Endpoint | Descripción | Impacto en Tests |
|---|---|---|---|---|---|
| **HALLAZGO-1** | Media | Bug | Todos los protegidos | Header `X-Session-Token` **ausente** → 500 (debería ser 401). Header **vacío** (`""`) → 401 correcto | API-SEC-001: header ausente = 500; header vacío = 401 |
| **HALLAZGO-2** | Baja | Bug | POST /logout | Token inexistente → 204 (debería ser 401). No verifica `rowsAffected` | API-010: esperar 204 en vez de 401 |
| **HALLAZGO-3** | Media | Bug | PUT /activities, PUT /grades | Tipos incorrectos en `Double` (`"abc"`) → 500 (debería ser 400) | API-032: esperar 500 en vez de 400 |
| **HALLAZGO-4** | Info | Diseño | POST /login | Sesión única: login borra TODAS las sesiones previas | Verificable: login 2 veces, primer token → 401 |
| **HALLAZGO-5** | Baja | Inconsistencia | GET /courses/{id} vs GET /report?format=json | Jackson omite `grade: null` en CourseDetailResponse; StringBuilder escribe `"grade": null` en reporte | Validar diferente: CourseDetail = campo ausente; Report = campo presente con null |
| **HALLAZGO-6** | Info | Diseño | PUT /activities | No tiene `@Valid` en `@RequestBody`. Toda validación es manual | Todos los errores son Forma 1, nunca Forma 2 |

---

## 12. Matriz de Cobertura de Pruebas

### 12.1 Distribución por nivel

| Nivel | Herramienta | Casos | % | Responsable |
|---|---|---|---|---|
| Unitarias | JUnit | No documentados | ~85% | DEV (cobertura ≥ 80%) |
| **Integración API** | **Karate DSL** | **40** | ~15% | **QA** |
| **E2E** | **SerenityBDD** | **4** | ~5% | **QA** |
| | | **44 documentados** | | |

### 12.2 Cobertura por Historia de Usuario

| HU | Descripción | Casos API | Casos E2E | Total |
|---|---|---|---|---|
| HDU_1 | Registrar usuarios | API-001, API-002, API-003 | E2E-001, E2E-002 | **5** |
| HDU_2 | Iniciar sesión | API-004 a API-010 | E2E-001, E2E-002 | **9** |
| HDU_3 | Crear curso | API-011 a API-014 | E2E-001 | **5** |
| HDU_4 | Consultar curso | API-015, API-016 | E2E-001 | **3** |
| HDU_5 | Agregar estudiantes | API-017 a API-022 | E2E-001, E2E-004 | **8** |
| HDU_11 | Definir programa | API-023 a API-027 | E2E-001, E2E-003 | **7** |
| HDU_12 | Eliminar instancia | API-029 | E2E-003 | **2** |
| HDU_13 | Actualizar instancia | API-028, API-034 | E2E-003 | **3** |
| HDU_14 | Registrar nota | API-030 a API-033 | E2E-001, E2E-003, E2E-004 | **7** |
| HDU_15 | Generar boletín | API-035 a API-039 | E2E-001, E2E-004 | **7** |
| Transversal | Seguridad | API-SEC-001 | E2E-002 | **2** |

### 12.3 Cobertura por endpoint

| Endpoint | Casos | Escenarios cubiertos |
|---|---|---|
| `POST /api/auth/register` | API-001, API-002, API-003 | Happy path + validación + duplicado |
| `POST /api/auth/login` | API-004, API-005, API-006 | Happy path + credenciales inválidas + vacío |
| `GET /api/auth/session` | API-007, API-008 | Sesión válida + token inválido |
| `POST /api/auth/logout` | API-009, API-010 | Logout exitoso + token inválido |
| `GET /api/courses` | API-011 | Listar cursos |
| `POST /api/courses` | API-012, API-013, API-014 | Creación + duplicado + vacío |
| `GET /api/courses/{courseId}` | API-015, API-016 | Existente + inexistente |
| `GET /api/students/{studentId}` | API-017, API-018 | Existente + inexistente |
| `POST /api/courses/{id}/students` | API-019, API-020, API-021, API-022 | Nuevo + vacío + ya inscrito + autocomplete |
| `PUT /api/courses/{id}/activities` | API-023 a API-029 | Definir + 5 validaciones + actualizar + eliminar |
| `PUT /api/courses/{id}/grades` | API-030 a API-034 | Nota válida + negativa + no numérica + nula + recálculo |
| `GET /.../report?format=` | API-035 a API-039 | PDF + HTML + JSON + formato inválido + notas vacías |
| Todos los protegidos | API-SEC-001 | Seguridad transversal sin token |

**12/12 endpoints cubiertos al 100%.**

---

## 13. Flujos E2E Críticos

### E2E-001 — Flujo completo del MVP

**Cadena**: HDU_1 → HDU_2 → HDU_3 → HDU_5 → HDU_11 → HDU_14 → HDU_15

Registro → Login → Crear curso → Inscribir estudiante → Definir programa (100%) → Registrar notas → Exportar boletín PDF. Verificar que el promedio ponderado en el boletín es matemáticamente correcto.

### E2E-002 — Autenticación y protección de rutas

**Cadena**: HDU_1 → HDU_2

Registro → Login → Acceso a Dashboard → Logout → Verificar que sin sesión activa no se accede a rutas protegidas.

### E2E-003 — Gestión de programa evaluativo con recálculo

**Cadena**: HDU_11 → HDU_14 → HDU_13 → HDU_12

Definir programa (3 instancias) → Registrar notas → Editar ponderaciones → Verificar recálculo → Eliminar una instancia con redistribución → Verificar nuevo recálculo.

### E2E-004 — Calificación parcial y reporte con advertencia

**Cadena**: HDU_5 → HDU_14 → HDU_15

Registrar notas parciales (al menos una vacía) → Verificar que null = 0 en promedios → Generar boletín → Verificar `hasEmptyGrades: true` → Promedios coherentes con la regla null = 0.

---

## 14. Definición de Hecho (DoD)

Este requerimiento se considera **CUMPLIDO** cuando se satisfacen TODAS las siguientes condiciones:

### 14.1 Cobertura de pruebas

- [ ] Los 40 casos de integración API (API-001 a API-SEC-001) están implementados como `.feature` files de Karate DSL
- [ ] Los 4 flujos E2E (E2E-001 a E2E-004) están documentados como escenarios ejecutables
- [ ] Cada caso de prueba valida el **status code exacto** esperado
- [ ] Cada caso de prueba valida el **mensaje de error exacto** del catálogo (sección 9)
- [ ] Los datos de prueba están **externalizados** en archivos `testdata/*.json`

### 14.2 Cumplimiento de contratos

- [ ] Los 12 endpoints responden según los contratos de la sección 4
- [ ] Las 3 formas de error (Forma 1, 2, 3) están correctamente validadas
- [ ] Los 6 hallazgos (HALLAZGO-1 a HALLAZGO-6) están contemplados en las validaciones
- [ ] La estructura de `SessionResponse` y `CourseDetailResponse` se valida con schemas

### 14.3 Reglas de negocio

- [ ] Las 12 reglas de negocio invariantes (RN-01 a RN-12) están cubiertas por al menos un caso de prueba
- [ ] El recálculo de promedios tras cambio de ponderaciones es matemáticamente correcto
- [ ] La inconsistencia de serialización null (HALLAZGO-5) está validada en ambos contextos

### 14.4 Infraestructura de pruebas

- [ ] Proyecto Karate funcional con `pom.xml`, Maven Wrapper, `karate-config.js` y `TestRunner.java`
- [ ] Ejecución completa con `mvn test` sin errores de compilación
- [ ] Features organizados por dominio: `auth/`, `courses/`, `students/`, `activities/`, `grades/`, `reports/`, `security/`

### 14.5 Trazabilidad

- [ ] Cada `.feature` file referencia los IDs de test case (API-XXX) y la HU asociada
- [ ] Existe mapeo completo entre HU → Test Cases → Feature Files

---

## 15. Restricciones y Decisiones de Arquitectura

| Decisión | Detalle |
|---|---|
| **Stack backend** | Java 21 + Spring Boot + JdbcTemplate + SQLite |
| **BD local** | SQLite en `./data/edtech.db`. Sin servidor de BD externo |
| **Autenticación** | Sesión server-side. Header `X-Session-Token`. Sin JWT |
| **Sesión única** | Login invalida todas las sesiones previas del docente |
| **Sin expiración** | No hay TTL ni cleanup de sesiones |
| **Exportación** | PDF y HTML desde misma plantilla. PDF con OpenHTMLToPDF |
| **Serialización** | Jackson `non_null`: campos null omitidos (excepto en reporte JSON manual) |
| **Herramienta de test API** | Karate DSL |
| **Herramienta de test E2E** | SerenityBDD + Cucumber |
| **Datos de prueba** | Externalizados en `testdata/*.json` |

---

## 16. Glosario de Dominio

| Término | Definición | En código |
|---|---|---|
| **Docente** (Teacher) | Persona autenticada que crea cursos y registra notas | `teachers` table |
| **Sesión** (Session) | Token UUID v4 server-side que autentica al docente | `sessions` table |
| **Curso** (Course) | Materia creada por un docente, única por nombre para ese docente | `courses` table |
| **Estudiante** (Student) | Persona inscrita en uno o más cursos. Registro global reutilizable | `students` table |
| **Student Identifier** | ID público del estudiante (ej. "EST-001"). Diferente del UUID interno | `student_identifier` column |
| **Instancia evaluativa** (Activity) | Componente del programa académico con nombre y ponderación | `evaluation_activities` table |
| **Ponderación** (Percentage/Weight) | Peso porcentual de una instancia (suma = 100%). `weight` en BD, `percentage` en API | `weight` / `percentage` |
| **Calificación** (Grade) | Nota numérica ≥ 0 o null (vacía). Null = 0 en cálculos | `student_grades` table |
| **Promedio general** | `sum(grades) / count(activities)` donde null = 0 | `generalAverage` |
| **Promedio ponderado** | `sum(grade × percentage) / 100` donde null = 0 | `weightedAverage` |
| **Boletín** (Report) | Documento exportable (PDF/HTML/JSON) con notas y promedios de un estudiante | endpoint `/report` |
| **HasEmptyGrades** | Flag booleano que indica si hay notas vacías en el boletín | `hasEmptyGrades` |

---

> **Siguiente paso en el flujo ASDD**: Este documento debe procesarse con `/generate-spec` para producir la especificación técnica en `.github/specs/EdTechAPI.spec.md`, seguido de `/gherkin-case-generator` y `/risk-identifier`.
