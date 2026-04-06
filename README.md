# EdTech API — Suite de Automatización Karate DSL

Suite de pruebas de integración para la **EdTech API** (Java 21 + Spring Boot), desarrollada con [Karate DSL](https://github.com/karatelabs/karate) siguiendo el flujo **ASDD** (Agent Spec Software Development).

---

## Requisitos

| Herramienta | Versión mínima | Notas |
|-------------|---------------|-------|
| **Java** | 11+ | Única dependencia requerida en la máquina |
| **Maven** | — | No necesario: el proyecto incluye Maven Wrapper |
| **EdTech API** | — | Debe estar corriendo en `http://localhost:8080` |

> El Maven Wrapper (`mvnw` / `mvnw.cmd`) descarga Maven automáticamente en la primera ejecución. No hay que instalar nada más.

---

## Estructura del proyecto

```
EdTech_API_Automatizacion/
├── src/test/java/
│   ├── karate-config.js          # Configuración global: baseUrl, timeouts
│   ├── runners/
│   │   ├── TestRunner.java       # Runner principal — ejecuta toda la suite
│   │   ├── AuthRunner.java        # Runner módulo auth
│   │   ├── CoursesRunner.java     # Runner módulo courses
│   │   ├── StudentsRunner.java    # Runner módulo students
│   │   ├── ActivitiesRunner.java  # Runner módulo activities
│   │   ├── GradesRunner.java      # Runner módulo grades
│   │   ├── ReportsRunner.java     # Runner módulo reports
│   │   └── SecurityRunner.java   # Runner módulo security
│   ├── features/                 # Escenarios Karate (.feature)
│   │   ├── auth/                 # register, login, logout, session
│   │   ├── courses/              # list, create, get-detail
│   │   ├── students/             # search, enroll
│   │   ├── activities/           # configurar ponderaciones
│   │   ├── grades/               # registrar calificaciones
│   │   ├── reports/              # exportar reporte de notas
│   │   └── security/             # token required
│   └── testdata/                 # Payloads JSON externalizados
│       ├── auth/
│       ├── courses/
│       ├── students/
│       ├── activities/
│       └── grades/
├── .github/
│   ├── requirements/             # Requerimientos de negocio
│   ├── specs/                    # Especificaciones técnicas (ASDD)
│   └── docs/                     # Lineamientos QA
├── docs/output/qa/               # Gherkin cases + matriz de riesgos
├── pom.xml
└── mvnw / mvnw.cmd
```

---

## Cómo ejecutar los tests

### 1. Levanta la API primero

La suite apunta a `http://localhost:8080`. Asegurate de que la EdTech API esté corriendo antes de ejecutar cualquier test.

### 2. Ejecutar la suite completa

**Linux / macOS:**
```bash
./mvnw test
```

**Windows:**
```cmd
mvnw.cmd test
```

### 3. Ejecutar por módulo

Cada módulo tiene su propio Runner independiente:

```cmd
mvnw.cmd test "-Dtest=runners.AuthRunner"
mvnw.cmd test "-Dtest=runners.CoursesRunner"
mvnw.cmd test "-Dtest=runners.StudentsRunner"
mvnw.cmd test "-Dtest=runners.ActivitiesRunner"
mvnw.cmd test "-Dtest=runners.GradesRunner"
mvnw.cmd test "-Dtest=runners.ReportsRunner"
mvnw.cmd test "-Dtest=runners.SecurityRunner"
```

### 4. Filtrar por tags

```cmd
mvnw.cmd test "-Dkarate.options=--tags @smoke"
mvnw.cmd test "-Dkarate.options=--tags @happy-path"
mvnw.cmd test "-Dkarate.options=--tags @error-path"
```

### 5. Ver el reporte HTML

Después de cada ejecución, el reporte se genera en:

```
target/karate-reports/karate-summary.html
```

Abrilo en cualquier navegador para ver el detalle de cada escenario.

---

## Cobertura de la API

| Módulo | Endpoint | Tests | Escenarios |
|--------|----------|-------|-----------|
| **Auth** | POST /api/auth/register | API-001–003 | Registro exitoso, campos vacíos, duplicado |
| **Auth** | POST /api/auth/login | API-004–006 | Login exitoso, credenciales inválidas, campos vacíos |
| **Auth** | GET /api/auth/session | API-007–008 | Sesión activa, token inválido |
| **Auth** | POST /api/auth/logout | API-009–010 | Logout exitoso, token inexistente |
| **Courses** | GET /api/courses | API-011 | Listado vacío inicial |
| **Courses** | POST /api/courses | API-012–014 | Crear curso, nombre vacío, duplicado |
| **Courses** | GET /api/courses/{id} | API-015–016 | Detalle existente, inexistente |
| **Students** | GET /api/students/{id} | API-017–018 | Buscar existente, inexistente |
| **Students** | POST /api/courses/{id}/students | API-019–022 | Inscribir, campos vacíos, estudiante ya inscrito, autocompletado |
| **Activities** | PUT /api/courses/{id}/activities | API-023–029 | Configurar ponderaciones, errores de validación, actualización |
| **Grades** | PUT /api/courses/{id}/grades | API-030–034 | Registrar nota, negativa, no numérica, null, recálculo de promedios |
| **Reports** | GET /api/courses/{id}/students/{id}/report | API-035–039 | PDF, HTML, JSON, formato no soportado, notas vacías |
| **Security** | Todos los endpoints | API-SEC-001 | Header ausente → 401/500 |

**Total: 85 tests — 72 passed ✓ | 13 fallan intencionalmente (HALLAZGOs documentados)**

---

## Tags disponibles

| Tag | Descripción |
|-----|-------------|
| `@smoke` | Happy paths críticos — ejecutar en cada build |
| `@happy-path` | Todos los flujos exitosos |
| `@error-path` | Validaciones y casos de error |
| `@auth` | Tests de autenticación |
| `@courses` | Tests de cursos |
| `@students` | Tests de estudiantes |
| `@activities` | Tests de actividades |
| `@grades` | Tests de calificaciones |
| `@reports` | Tests de reportes |
| `@security` | Tests de seguridad |
| `@HALLAZGO-N` | Bugs conocidos documentados |

---

## Flujo ASDD

Este proyecto fue desarrollado siguiendo el flujo **Agent Spec Software Development**:

```
Requerimientos (.github/requirements/)
        ↓
Spec técnica (.github/specs/)          ← /generate-spec
        ↓
Gherkin + Riesgos (docs/output/qa/)    ← /gherkin-case-generator + /risk-identifier
        ↓
Implementación Karate (src/test/)      ← /unit-testing
```

Los artefactos de cada fase están versionados en el repositorio para trazabilidad completa.

---

## Configuración

El archivo `src/test/java/karate-config.js` centraliza la configuración:

```javascript
var config = {
  baseUrl: 'http://localhost:8080',  // ← cambiar si la API corre en otro puerto
  connectTimeout: 10000,
  readTimeout: 10000
};
```

Para apuntar a otro entorno, modificá solo el `baseUrl`.

---

## Stack técnico

| Componente | Versión |
|------------|---------|
| Karate DSL | 1.4.1 |
| JUnit 5 | 5.9 |
| Java | 11+ |
| Maven | 3.9+ (via wrapper) |
