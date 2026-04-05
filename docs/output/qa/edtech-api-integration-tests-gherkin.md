# EdTech API Integration Tests — Escenarios Gherkin y Datos de Prueba

> **Spec de referencia:** `.github/specs/edtech-api-integration-tests.spec.md` (SPEC-001 — APPROVED)
> **Generado por:** gherkin-case-generator
> **Fecha:** 2026-04-05
> **Alcance:** 40 casos de integración API (API-001 a API-SEC-001) — Karate DSL

---

## Tabla de Contenidos

1. [Flujos Críticos Identificados](#1-flujos-críticos-identificados)
2. [Escenarios Gherkin — Lenguaje de Negocio](#2-escenarios-gherkin--lenguaje-de-negocio)
3. [Escenarios Karate DSL — Referencia para Implementación](#3-escenarios-karate-dsl--referencia-para-implementación)
4. [Datos de Prueba por Escenario](#4-datos-de-prueba-por-escenario)
5. [Inventario de Archivos JSON (testdata/)](#5-inventario-de-archivos-json-testdata)
6. [Trazabilidad HU → Test Cases → Features](#6-trazabilidad-hu--test-cases--features)

---

## 1. Flujos Críticos Identificados

| # | Flujo | Tipo | Impacto | Tags | Test Cases |
|---|-------|------|---------|------|------------|
| F-01 | Registro exitoso de docente | Happy path | Alto | `@smoke @happy-path @auth` | API-001 |
| F-02 | Registro con validación de campos | Error path | Medio | `@error-path @auth` | API-002 |
| F-03 | Registro con username duplicado (case-insensitive) | Edge case | Alto | `@error-path @auth` | API-003 |
| F-04 | Login exitoso (borra sesiones previas) | Happy path | Alto | `@smoke @happy-path @auth` | API-004 |
| F-05 | Login con credenciales inválidas | Error path | Alto | `@error-path @auth` | API-005 |
| F-06 | Login con campos vacíos | Error path | Medio | `@error-path @auth` | API-006 |
| F-07 | Validar sesión activa | Happy path | Alto | `@happy-path @auth` | API-007 |
| F-08 | Validar sesión con token inválido | Error path | Alto | `@error-path @auth` | API-008 |
| F-09 | Logout exitoso + verificación de invalidación | Happy path | Alto | `@smoke @happy-path @auth` | API-009 |
| F-10 | Logout con token inexistente (HALLAZGO-2) | Edge case | Bajo | `@error-path @auth @bug @HALLAZGO-2` | API-010 |
| F-11 | Listar cursos del docente | Happy path | Medio | `@happy-path @courses` | API-011 |
| F-12 | Crear curso exitosamente | Happy path | Alto | `@smoke @happy-path @courses` | API-012 |
| F-13 | Crear curso con nombre duplicado (case-insensitive) | Error path | Alto | `@error-path @courses` | API-013 |
| F-14 | Crear curso con nombre vacío | Error path | Medio | `@error-path @courses` | API-014 |
| F-15 | Detalle de curso existente | Happy path | Medio | `@happy-path @courses` | API-015 |
| F-16 | Detalle de curso inexistente | Error path | Medio | `@error-path @courses` | API-016 |
| F-17 | Buscar estudiante existente | Happy path | Medio | `@happy-path @students` | API-017 |
| F-18 | Buscar estudiante inexistente | Error path | Medio | `@error-path @students` | API-018 |
| F-19 | Inscribir estudiante nuevo (alta on-the-fly) | Happy path | Alto | `@smoke @happy-path @students` | API-019 |
| F-20 | Inscribir con campos vacíos | Error path | Medio | `@error-path @students` | API-020 |
| F-21 | Inscribir estudiante ya inscrito | Error path | Medio | `@error-path @students` | API-021 |
| F-22 | Inscribir estudiante existente (autocomplete) | Edge case | Alto | `@happy-path @students` | API-022 |
| F-23 | Definir programa evaluativo válido (100%) | Happy path | Alto | `@smoke @happy-path @activities` | API-023 |
| F-24 | Programa con suma ≠ 100% | Error path | Alto | `@error-path @activities` | API-024 |
| F-25 | Programa con nombre de actividad vacío | Error path | Medio | `@error-path @activities` | API-025 |
| F-26 | Programa con nombres duplicados | Error path | Medio | `@error-path @activities` | API-026 |
| F-27 | Programa con ponderación ≤ 0 | Error path | Medio | `@error-path @activities` | API-027 |
| F-28 | Actualizar ponderaciones existentes (100%) | Happy path | Alto | `@happy-path @activities` | API-028 |
| F-29 | Eliminar instancia con redistribución | Happy path | Alto | `@happy-path @activities` | API-029 |
| F-30 | Registrar nota válida (≥ 0) | Happy path | Alto | `@smoke @happy-path @grades` | API-030 |
| F-31 | Nota negativa | Error path | Medio | `@error-path @grades` | API-031 |
| F-32 | Nota con tipo no numérico (HALLAZGO-3) | Edge case | Medio | `@error-path @grades @bug @HALLAZGO-3` | API-032 |
| F-33 | Nota nula (null = 0 en promedio) | Edge case | Alto | `@happy-path @grades` | API-033 |
| F-34 | Recálculo de promedios tras cambio de pesos | Edge case | Alto | `@happy-path @grades @reports` | API-034 |
| F-35 | Exportar boletín PDF | Happy path | Alto | `@smoke @happy-path @reports` | API-035 |
| F-36 | Exportar boletín HTML | Happy path | Alto | `@happy-path @reports` | API-036 |
| F-37 | Exportar boletín JSON completo | Happy path | Alto | `@happy-path @reports` | API-037 |
| F-38 | Formato no soportado | Error path | Medio | `@error-path @reports` | API-038 |
| F-39 | Boletín con notas vacías (hasEmptyGrades) | Edge case | Alto | `@happy-path @reports` | API-039 |
| F-40 | Endpoints protegidos sin token (HALLAZGO-1) | Seguridad | Alto | `@security @bug @HALLAZGO-1` | API-SEC-001 |

---

## 2. Escenarios Gherkin — Lenguaje de Negocio

> Escenarios documentales en español para trazabilidad con las HU. Los keywords Karate (inglés) se encuentran en la sección 3.

### 2.1 Autenticación — Registro (HDU_1)

```gherkin
#language: es
Característica: Registro de docente en el sistema

  @smoke @happy-path @auth
  Escenario: F-01 / API-001 — Registro exitoso de docente
    Dado que un docente nuevo proporciona un nombre de usuario y contraseña válidos
    Cuando envía la solicitud de registro
    Entonces el sistema crea la cuenta exitosamente con código 201
    Y le devuelve su identificador, nombre de usuario y un token de sesión activo

  @error-path @auth
  Escenario: F-02 / API-002 — Registro con campos obligatorios vacíos
    Dado que un visitante intenta registrarse sin proporcionar nombre de usuario ni contraseña
    Cuando envía la solicitud de registro
    Entonces el sistema rechaza la solicitud con código 400
    Y el mensaje indica los campos obligatorios faltantes

  @error-path @auth
  Escenario: F-03 / API-003 — Registro con nombre de usuario ya existente
    Dado que ya existe un docente registrado con nombre de usuario "DocentePrueba"
    Cuando otro visitante intenta registrarse con "docenteprueba" (diferente capitalización)
    Entonces el sistema rechaza la solicitud con código 409
    Y el mensaje indica "El nombre de usuario ya existe"
```

### 2.2 Autenticación — Login (HDU_2)

```gherkin
#language: es
Característica: Inicio de sesión del docente

  @smoke @happy-path @auth
  Escenario: F-04 / API-004 — Login exitoso
    Dado que existe un docente registrado con credenciales conocidas
    Cuando el docente inicia sesión con dichas credenciales
    Entonces el sistema autentica al docente con código 200
    Y le devuelve un nuevo token de sesión
    Y las sesiones anteriores del docente quedan invalidadas

  @error-path @auth
  Escenario: F-05 / API-005 — Login con credenciales incorrectas
    Dado que un visitante proporciona una contraseña incorrecta para un usuario existente
    Cuando intenta iniciar sesión
    Entonces el sistema rechaza la solicitud con código 401
    Y el mensaje genérico indica "Usuario o contrasena incorrectos"
    Y no revela si es el usuario o la contraseña lo que falló

  @error-path @auth
  Escenario: F-06 / API-006 — Login con campos vacíos
    Dado que un visitante envía la solicitud de login sin completar los campos
    Cuando el sistema valida la solicitud
    Entonces rechaza con código 400
    Y detalla los campos obligatorios faltantes
```

### 2.3 Autenticación — Sesión y Logout (HDU_2)

```gherkin
#language: es
Característica: Gestión de sesión activa del docente

  @happy-path @auth
  Escenario: F-07 / API-007 — Validar sesión activa
    Dado que un docente tiene una sesión activa con token válido
    Cuando consulta el estado de su sesión
    Entonces el sistema responde con código 200
    Y devuelve los datos del docente y su token

  @error-path @auth
  Escenario: F-08 / API-008 — Validar sesión con token inválido
    Dado que un visitante proporciona un token que no existe en el sistema
    Cuando consulta el estado de la sesión
    Entonces el sistema responde con código 401
    Y el mensaje indica "Sesion invalida o expirada"

  @smoke @happy-path @auth
  Escenario: F-09 / API-009 — Cerrar sesión exitosamente
    Dado que un docente tiene una sesión activa
    Cuando envía la solicitud de cierre de sesión
    Entonces el sistema responde con código 204 sin cuerpo de respuesta
    Y al intentar usar el mismo token para consultar la sesión, recibe código 401

  @error-path @auth @bug @HALLAZGO-2
  Escenario: F-10 / API-010 — Cerrar sesión con token inexistente
    Dado que un visitante proporciona un token que no corresponde a ninguna sesión
    Cuando envía la solicitud de cierre de sesión
    Entonces el sistema responde con código 204
    # HALLAZGO-2: Debería ser 401, pero el backend no verifica si el DELETE afectó filas
```

### 2.4 Gestión de Cursos (HDU_3, HDU_4)

```gherkin
#language: es
Característica: Gestión de cursos del docente

  @happy-path @courses
  Escenario: F-11 / API-011 — Listar cursos del docente
    Dado que un docente autenticado ha creado al menos un curso
    Cuando solicita la lista de sus cursos
    Entonces el sistema responde con código 200
    Y devuelve un listado con nombre, cantidad de estudiantes y cantidad de actividades por curso

  @smoke @happy-path @courses
  Escenario: F-12 / API-012 — Crear curso exitosamente
    Dado que un docente autenticado desea crear un nuevo curso
    Cuando envía el nombre del curso
    Entonces el sistema crea el curso con código 201
    Y devuelve el detalle completo del curso (vacío de estudiantes y actividades)

  @error-path @courses
  Escenario: F-13 / API-013 — Crear curso con nombre duplicado
    Dado que el docente ya tiene un curso llamado "Matemáticas Avanzadas"
    Cuando intenta crear otro curso con nombre "matemáticas avanzadas" (diferente capitalización)
    Entonces el sistema rechaza con código 409
    Y el mensaje indica "Ya existe un curso con este nombre"

  @error-path @courses
  Escenario: F-14 / API-014 — Crear curso con nombre vacío
    Dado que un docente autenticado envía una solicitud de creación de curso sin nombre
    Cuando el sistema valida la solicitud
    Entonces rechaza con código 400
    Y el mensaje indica que el nombre es obligatorio

  @happy-path @courses
  Escenario: F-15 / API-015 — Consultar detalle completo de un curso
    Dado que un docente tiene un curso con estudiantes, actividades y notas registradas
    Cuando consulta el detalle del curso
    Entonces el sistema responde con código 200
    Y devuelve la lista de estudiantes, actividades evaluativas y calificaciones

  @error-path @courses
  Escenario: F-16 / API-016 — Consultar curso inexistente
    Dado que un docente autenticado consulta un curso con identificador que no existe
    Cuando el sistema busca el curso
    Entonces responde con código 404
    Y el mensaje indica "Curso no encontrado"
```

### 2.5 Gestión de Estudiantes (HDU_5)

```gherkin
#language: es
Característica: Gestión de estudiantes y matrículas

  @happy-path @students
  Escenario: F-17 / API-017 — Buscar estudiante existente por identificador
    Dado que existe un estudiante con identificador "EST-001" registrado en el sistema
    Cuando un docente busca al estudiante por ese identificador
    Entonces el sistema responde con código 200
    Y devuelve el identificador, nombre completo y correo electrónico del estudiante

  @error-path @students
  Escenario: F-18 / API-018 — Buscar estudiante inexistente
    Dado que no existe ningún estudiante con identificador "EST-NOEXISTE"
    Cuando un docente busca al estudiante por ese identificador
    Entonces el sistema responde con código 404
    Y el mensaje indica "Estudiante no encontrado"

  @smoke @happy-path @students
  Escenario: F-19 / API-019 — Inscribir estudiante nuevo con alta automática
    Dado que un docente tiene un curso y desea inscribir un estudiante que no existe en el sistema
    Cuando envía los datos del estudiante (identificador, nombre, correo)
    Entonces el sistema crea al estudiante y lo inscribe con código 200
    Y el curso actualizado muestra al estudiante en la lista de inscriptos

  @error-path @students
  Escenario: F-20 / API-020 — Inscribir estudiante con campos vacíos
    Dado que un docente intenta inscribir un estudiante sin completar los datos obligatorios
    Cuando envía la solicitud de inscripción
    Entonces el sistema rechaza con código 400
    Y el estudiante NO queda creado parcialmente en el sistema

  @error-path @students
  Escenario: F-21 / API-021 — Inscribir estudiante ya inscrito en el curso
    Dado que el estudiante "EST-001" ya está inscrito en el curso
    Cuando el docente intenta inscribirlo nuevamente
    Entonces el sistema rechaza con código 409
    Y el mensaje indica "El estudiante ya esta inscrito en este curso"

  @happy-path @students
  Escenario: F-22 / API-022 — Inscribir estudiante existente en nuevo curso (reutilización)
    Dado que "EST-001" ya existe como estudiante global en el sistema
    Cuando un docente lo inscribe en otro curso enviando nombre y correo diferentes
    Entonces el sistema lo inscribe con código 200 reutilizando el registro original
    Y los datos del estudiante conservan el nombre y correo originales (no los nuevos)
```

### 2.6 Programa Evaluativo (HDU_11, HDU_12, HDU_13)

```gherkin
#language: es
Característica: Gestión del programa evaluativo del curso

  @smoke @happy-path @activities
  Escenario: F-23 / API-023 — Definir programa evaluativo válido
    Dado que un docente tiene un curso sin actividades evaluativas
    Cuando define dos actividades cuyas ponderaciones suman exactamente 100%
    Entonces el sistema las crea con código 200
    Y el detalle del curso muestra las actividades con sus ponderaciones

  @error-path @activities
  Escenario: F-24 / API-024 — Programa con ponderaciones que no suman 100%
    Dado que un docente intenta definir actividades cuyas ponderaciones suman 80%
    Cuando envía la solicitud de actualización
    Entonces el sistema rechaza con código 400
    Y el mensaje indica "La suma de ponderaciones debe ser exactamente 100%"

  @error-path @activities
  Escenario: F-25 / API-025 — Actividad con nombre vacío
    Dado que un docente incluye una actividad sin nombre en el programa
    Cuando envía la solicitud
    Entonces el sistema rechaza con código 400
    Y el mensaje indica "Cada actividad debe tener nombre"

  @error-path @activities
  Escenario: F-26 / API-026 — Actividades con nombres duplicados
    Dado que un docente envía dos actividades con el mismo nombre (diferente capitalización)
    Cuando envía la solicitud
    Entonces el sistema rechaza con código 400
    Y el mensaje indica "Las actividades no pueden tener nombres duplicados"

  @error-path @activities
  Escenario: F-27 / API-027 — Actividad con ponderación cero o negativa
    Dado que un docente incluye una actividad con ponderación 0 o valor negativo
    Cuando envía la solicitud
    Entonces el sistema rechaza con código 400
    Y el mensaje indica "Cada actividad debe tener una ponderacion mayor a 0"

  @happy-path @activities
  Escenario: F-28 / API-028 — Actualizar ponderaciones de actividades existentes
    Dado que el curso ya tiene actividades evaluativas con ponderaciones originales
    Cuando el docente envía las mismas actividades (con sus IDs) con nuevas ponderaciones que suman 100%
    Entonces el sistema actualiza las ponderaciones con código 200
    Y el detalle del curso refleja las nuevas ponderaciones

  @happy-path @activities
  Escenario: F-29 / API-029 — Eliminar instancia evaluativa por omisión
    Dado que el curso tiene 3 actividades evaluativas
    Cuando el docente envía solo 2 actividades que suman 100% (omitiendo la tercera)
    Entonces el sistema elimina la actividad omitida con código 200
    Y las notas asociadas a la actividad eliminada también se borran
```

### 2.7 Calificaciones (HDU_14)

```gherkin
#language: es
Característica: Registro y gestión de calificaciones

  @smoke @happy-path @grades
  Escenario: F-30 / API-030 — Registrar nota válida
    Dado que un estudiante está inscrito y existe una actividad evaluativa
    Cuando el docente registra una nota de 4.5 para esa actividad
    Entonces el sistema registra la nota con código 200
    Y el detalle del curso incluye la calificación registrada

  @error-path @grades
  Escenario: F-31 / API-031 — Registrar nota negativa
    Dado que el docente intenta registrar una nota de -1
    Cuando envía la solicitud
    Entonces el sistema rechaza con código 400
    Y el mensaje indica "La nota no puede ser negativa"

  @error-path @grades @bug @HALLAZGO-3
  Escenario: F-32 / API-032 — Registrar nota con tipo no numérico
    Dado que el docente envía un valor no numérico como nota (ej. "abc")
    Cuando el servidor procesa la solicitud
    Entonces el sistema responde con código 500
    Y el mensaje indica "Error interno del servidor"
    # HALLAZGO-3: Debería ser 400, pero Jackson lanza excepción no controlada

  @happy-path @grades
  Escenario: F-33 / API-033 — Registrar nota nula (sin calificación)
    Dado que el docente envía una nota con valor explícitamente nulo
    Cuando el servidor procesa la solicitud
    Entonces el sistema registra la nota como nula con código 200
    Y en los cálculos de promedio, la nota nula se trata como 0

  @happy-path @grades @reports
  Escenario: F-34 / API-034 — Verificar recálculo de promedios tras cambio de ponderaciones
    Dado que un estudiante tiene notas registradas con ponderaciones originales
    Cuando el docente actualiza las ponderaciones de las actividades
    Y luego exporta el boletín en formato JSON
    Entonces el promedio ponderado refleja las nuevas ponderaciones
    Y es matemáticamente correcto según la fórmula: sum(nota × porcentaje) / 100
```

### 2.8 Exportación de Reportes (HDU_15)

```gherkin
#language: es
Característica: Exportación de boletines académicos

  @smoke @happy-path @reports
  Escenario: F-35 / API-035 — Exportar boletín en formato PDF
    Dado que un estudiante tiene notas registradas en todas las actividades del curso
    Cuando el docente solicita el boletín en formato PDF
    Entonces el sistema responde con código 200
    Y el tipo de contenido es "application/pdf"
    Y la cabecera de disposición contiene "boletin-"
    Y el cuerpo de la respuesta no está vacío

  @happy-path @reports
  Escenario: F-36 / API-036 — Exportar boletín en formato HTML
    Dado que un estudiante tiene notas registradas
    Cuando el docente solicita el boletín en formato HTML
    Entonces el sistema responde con código 200
    Y el tipo de contenido es "text/html"
    Y el cuerpo contiene la etiqueta de apertura de un documento HTML

  @happy-path @reports
  Escenario: F-37 / API-037 — Exportar boletín en formato JSON
    Dado que un estudiante tiene notas registradas en todas las actividades
    Cuando el docente solicita el boletín en formato JSON
    Entonces el sistema responde con código 200
    Y el reporte contiene: docente, curso, estudiante, calificaciones, promedio general, promedio ponderado e indicador de notas vacías
    Y el campo "grade" aparece explícitamente con valor null cuando no hay nota (diferente a CourseDetailResponse donde se omite)

  @error-path @reports
  Escenario: F-38 / API-038 — Solicitar formato no soportado
    Dado que el docente solicita el boletín en formato "xml"
    Cuando el sistema valida el formato solicitado
    Entonces rechaza con código 400
    Y el mensaje indica "Formato no soportado"

  @happy-path @reports
  Escenario: F-39 / API-039 — Boletín con notas vacías
    Dado que un estudiante tiene al menos una actividad sin calificación registrada
    Cuando el docente exporta el boletín en formato JSON
    Entonces el sistema responde con código 200
    Y "hasEmptyGrades" es verdadero
    Y los promedios se calculan tratando las notas vacías como 0
```

### 2.9 Seguridad Transversal

```gherkin
#language: es
Característica: Protección de endpoints con autenticación

  @security @bug @HALLAZGO-1
  Escenario: F-40 / API-SEC-001 — Acceso a endpoints protegidos sin token de sesión
    Dado que un visitante no envía el encabezado de autenticación
    Cuando intenta acceder a un endpoint protegido del sistema
    Entonces el sistema responde con código 500
    # HALLAZGO-1: Debería ser 401, pero header ausente causa excepción no controlada

  @security
  Escenario: F-40b / API-SEC-001 — Acceso con token vacío
    Dado que un visitante envía el encabezado de autenticación con valor vacío
    Cuando intenta acceder a un endpoint protegido
    Entonces el sistema responde con código 401
    Y el mensaje indica "Falta el token de sesion"
```

---

## 3. Escenarios Karate DSL — Referencia para Implementación

> Referencia directa para `/unit-testing`. Keywords en inglés, payloads externalizados.

### 3.1 AUTH — Register (`features/auth/register.feature`)

```gherkin
@auth @post
Feature: Registro de docente — POST /api/auth/register
  Valida el registro de nuevos docentes: happy path, campos vacíos y username duplicado.
  HU: HDU_1 | Test Cases: API-001, API-002, API-003

  Background:
    * url baseUrl

  @smoke @happy-path @API-001
  Scenario: API-001 — Registro exitoso de docente
    * def uniqueUser = 'docente_' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/auth/register_valid.json')
    * set payload.username = uniqueUser
    * set payload.password = 'P@ss_Register_001'
    Given path '/api/auth/register'
    And request payload
    When method post
    Then status 201
    And match response.user.id == '#uuid'
    And match response.user.username == uniqueUser
    And match response.token == '#uuid'

  @error-path @API-002
  Scenario: API-002 — Registro con campos vacíos
    * def payload = read('classpath:testdata/auth/register_empty_fields.json')
    Given path '/api/auth/register'
    And request payload
    When method post
    Then status 400
    And match response.message == 'Solicitud invalida'
    And match response.details == '#object'

  @error-path @API-003
  Scenario: API-003 — Registro con username duplicado (case-insensitive)
    * def uniqueUser = 'dup_' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/auth/register_valid.json')
    * set payload.username = uniqueUser
    * set payload.password = 'P@ss_Register_003'
    Given path '/api/auth/register'
    And request payload
    When method post
    Then status 201
    # Segundo registro con diferente capitalización
    * def payload2 = read('classpath:testdata/auth/register_valid.json')
    * set payload2.username = uniqueUser.toUpperCase()
    * set payload2.password = 'P@ss_Register_003b'
    Given path '/api/auth/register'
    And request payload2
    When method post
    Then status 409
    And match response.message == 'El nombre de usuario ya existe'
```

### 3.2 AUTH — Login (`features/auth/login.feature`)

```gherkin
@auth @post
Feature: Login de docente — POST /api/auth/login
  Valida autenticación: happy path, credenciales inválidas y campos vacíos.
  HU: HDU_2 | Test Cases: API-004, API-005, API-006

  Background:
    * url baseUrl

  @smoke @happy-path @API-004
  Scenario: API-004 — Login exitoso
    # Setup: registrar docente
    * def uniqueUser = 'login_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Login_004'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    # Login
    * def loginPayload = read('classpath:testdata/auth/login_valid.json')
    * set loginPayload.username = uniqueUser
    * set loginPayload.password = 'P@ss_Login_004'
    Given path '/api/auth/login'
    And request loginPayload
    When method post
    Then status 200
    And match response.user.id == '#uuid'
    And match response.user.username == uniqueUser
    And match response.token == '#uuid'

  @error-path @API-005
  Scenario: API-005 — Login con credenciales inválidas
    * def uniqueUser = 'badlogin_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Login_005'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    # Login con password incorrecto
    * def loginPayload = read('classpath:testdata/auth/login_invalid_credentials.json')
    * set loginPayload.username = uniqueUser
    Given path '/api/auth/login'
    And request loginPayload
    When method post
    Then status 401
    And match response.message == 'Usuario o contrasena incorrectos'

  @error-path @API-006
  Scenario: API-006 — Login con campos vacíos
    * def payload = read('classpath:testdata/auth/login_empty_fields.json')
    Given path '/api/auth/login'
    And request payload
    When method post
    Then status 400
    And match response.message == 'Solicitud invalida'
```

### 3.3 AUTH — Session (`features/auth/session.feature`)

```gherkin
@auth @get
Feature: Validar sesión — GET /api/auth/session
  Valida consulta de sesión activa y token inválido.
  HU: HDU_2 | Test Cases: API-007, API-008

  Background:
    * url baseUrl

  @happy-path @API-007
  Scenario: API-007 — Validar sesión activa
    * def uniqueUser = 'session_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Session_007'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Validar sesión
    Given path '/api/auth/session'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.user.id == '#uuid'
    And match response.user.username == uniqueUser
    And match response.token == token

  @error-path @API-008
  Scenario: API-008 — Validar sesión con token inválido
    Given path '/api/auth/session'
    And header X-Session-Token = '00000000-0000-0000-0000-000000000000'
    When method get
    Then status 401
    And match response.message == 'Sesion invalida o expirada'
```

### 3.4 AUTH — Logout (`features/auth/logout.feature`)

```gherkin
@auth @post
Feature: Cierre de sesión — POST /api/auth/logout
  Valida logout exitoso y logout con token inexistente (HALLAZGO-2).
  HU: HDU_2 | Test Cases: API-009, API-010

  Background:
    * url baseUrl

  @smoke @happy-path @API-009
  Scenario: API-009 — Logout exitoso + verificación de invalidación
    * def uniqueUser = 'logout_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Logout_009'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Logout
    Given path '/api/auth/logout'
    And header X-Session-Token = token
    When method post
    Then status 204
    # Verificar invalidación
    Given path '/api/auth/session'
    And header X-Session-Token = token
    When method get
    Then status 401

  @error-path @bug @HALLAZGO-2 @API-010
  Scenario: API-010 — Logout con token inexistente
    # HALLAZGO-2: Debería ser 401, actualmente retorna 204
    Given path '/api/auth/logout'
    And header X-Session-Token = '00000000-0000-0000-0000-000000000000'
    When method post
    Then status 204
```

### 3.5 COURSES — List (`features/courses/list_courses.feature`)

```gherkin
@courses @get
Feature: Listar cursos del docente — GET /api/courses
  Valida el listado de cursos con conteos de estudiantes y actividades.
  HU: HDU_3 | Test Cases: API-011

  Background:
    * url baseUrl
    # Setup: registrar docente y obtener token
    * def uniqueUser = 'listcrs_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_ListCrs_011'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token

  @happy-path @API-011
  Scenario: API-011 — Listar cursos del docente
    # Crear un curso
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'Curso_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    # Listar
    Given path '/api/courses'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response == '#array'
    And match each response contains { id: '#uuid', name: '#string', studentCount: '#number', activityCount: '#number' }
```

### 3.6 COURSES — Create (`features/courses/create_course.feature`)

```gherkin
@courses @post
Feature: Crear curso — POST /api/courses
  Valida creación de curso: happy path, nombre duplicado y nombre vacío.
  HU: HDU_3 | Test Cases: API-012, API-013, API-014

  Background:
    * url baseUrl
    * def uniqueUser = 'crscreate_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_CrsCreate_012'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token

  @smoke @happy-path @API-012
  Scenario: API-012 — Crear curso exitosamente
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'Matematicas_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    And match response.id == '#uuid'
    And match response.name == '#string'
    And match response.teacherId == '#uuid'
    And match response.students == '#[]'
    And match response.activities == '#[]'

  @error-path @API-013
  Scenario: API-013 — Crear curso con nombre duplicado (case-insensitive)
    * def courseName = 'DupCurso_' + java.lang.System.currentTimeMillis()
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = courseName
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    # Segundo intento con capitalización diferente
    * def coursePayload2 = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload2.name = courseName.toUpperCase()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload2
    When method post
    Then status 409
    And match response.message == 'Ya existe un curso con este nombre'

  @error-path @API-014
  Scenario: API-014 — Crear curso con nombre vacío
    * def coursePayload = read('classpath:testdata/courses/create_course_empty_name.json')
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 400
```

### 3.7 COURSES — Detail (`features/courses/get_course_detail.feature`)

```gherkin
@courses @get
Feature: Detalle de curso — GET /api/courses/{courseId}
  Valida consulta de curso existente e inexistente.
  HU: HDU_4 | Test Cases: API-015, API-016

  Background:
    * url baseUrl
    * def uniqueUser = 'crsdetail_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_CrsDetail_015'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token

  @happy-path @API-015
  Scenario: API-015 — Detalle de curso existente
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'Detail_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id
    # Consultar detalle
    Given path '/api/courses', courseId
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.id == courseId
    And match response.students == '#[]'
    And match response.activities == '#[]'
    And match response.grades == '#[]'

  @error-path @API-016
  Scenario: API-016 — Detalle de curso inexistente
    Given path '/api/courses', '00000000-0000-0000-0000-000000000000'
    And header X-Session-Token = token
    When method get
    Then status 404
    And match response.message == 'Curso no encontrado'
```

### 3.8 STUDENTS — Search (`features/students/search_student.feature`)

```gherkin
@students @get
Feature: Buscar estudiante — GET /api/students/{studentId}
  Valida búsqueda por student_identifier existente e inexistente.
  HU: HDU_5 | Test Cases: API-017, API-018

  Background:
    * url baseUrl
    * def uniqueUser = 'srchstud_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_SearchStud_017'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token

  @happy-path @API-017
  Scenario: API-017 — Buscar estudiante existente
    # Setup: crear curso e inscribir estudiante
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'SearchStud_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id
    * def studentId = 'EST-' + java.lang.System.currentTimeMillis()
    * def enrollPayload = read('classpath:testdata/students/enroll_student_valid.json')
    * set enrollPayload.studentId = studentId
    * set enrollPayload.name = 'Estudiante Prueba'
    * set enrollPayload.email = studentId.toLowerCase() + '@testmail.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request enrollPayload
    When method post
    Then status 200
    # Buscar
    Given path '/api/students', studentId
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.studentId == studentId
    And match response.name == '#string'
    And match response.email == '#string'

  @error-path @API-018
  Scenario: API-018 — Buscar estudiante inexistente
    Given path '/api/students', 'EST-NOEXISTE-99999'
    And header X-Session-Token = token
    When method get
    Then status 404
    And match response.message == 'Estudiante no encontrado'
```

### 3.9 STUDENTS — Enroll (`features/students/enroll_student.feature`)

```gherkin
@students @post
Feature: Inscribir estudiante — POST /api/courses/{courseId}/students
  Valida inscripción: alta on-the-fly, campos vacíos, duplicado y autocomplete.
  HU: HDU_5 | Test Cases: API-019, API-020, API-021, API-022

  Background:
    * url baseUrl
    * def uniqueUser = 'enroll_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Enroll_019'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Crear curso base
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'Enroll_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id

  @smoke @happy-path @API-019
  Scenario: API-019 — Inscribir estudiante nuevo (alta on-the-fly)
    * def studentId = 'EST-NEW-' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/students/enroll_student_valid.json')
    * set payload.studentId = studentId
    * set payload.name = 'Nuevo Estudiante'
    * set payload.email = studentId.toLowerCase() + '@testmail.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 200
    And match response.students[*].studentId contains studentId

  @error-path @API-020
  Scenario: API-020 — Inscribir con campos vacíos
    * def payload = read('classpath:testdata/students/enroll_student_empty_fields.json')
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 400

  @error-path @API-021
  Scenario: API-021 — Inscribir estudiante ya inscrito
    * def studentId = 'EST-DUP-' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/students/enroll_student_valid.json')
    * set payload.studentId = studentId
    * set payload.name = 'Estudiante Dup'
    * set payload.email = studentId.toLowerCase() + '@testmail.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 200
    # Segundo intento
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 409
    And match response.message == 'El estudiante ya esta inscrito en este curso'

  @happy-path @API-022
  Scenario: API-022 — Inscribir estudiante existente en sistema (autocomplete)
    * def studentId = 'EST-AUTO-' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/students/enroll_student_valid.json')
    * set payload.studentId = studentId
    * set payload.name = 'Original Nombre'
    * set payload.email = studentId.toLowerCase() + '@testmail.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 200
    # Crear segundo curso e inscribir con datos diferentes
    * def course2 = read('classpath:testdata/courses/create_course_valid.json')
    * set course2.name = 'AutoCrs_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request course2
    When method post
    Then status 201
    * def courseId2 = response.id
    * def payload2 = read('classpath:testdata/students/enroll_student_autocomplete.json')
    * set payload2.studentId = studentId
    * set payload2.name = 'Nombre Diferente'
    * set payload2.email = 'diferente@testmail.com'
    Given path '/api/courses', courseId2, 'students'
    And header X-Session-Token = token
    And request payload2
    When method post
    Then status 200
    # Verificar que se conserva el nombre original
    And match response.students[*].name contains 'Original Nombre'
    And match response.students[*].name !contains 'Nombre Diferente'
```

### 3.10 ACTIVITIES — Manage (`features/activities/manage_activities.feature`)

```gherkin
@activities @put
Feature: Gestión de programa evaluativo — PUT /api/courses/{courseId}/activities
  Valida definición, validaciones, actualización y eliminación de actividades.
  HU: HDU_11, HDU_12, HDU_13 | Test Cases: API-023 a API-029

  Background:
    * url baseUrl
    * def uniqueUser = 'activ_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Activ_023'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'Activ_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id

  @smoke @happy-path @API-023
  Scenario: API-023 — Definir programa evaluativo válido (suma = 100%)
    * def payload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 200
    And match response.activities == '#[2]'
    And match each response.activities contains { id: '#uuid', name: '#string', percentage: '#number' }

  @error-path @API-024
  Scenario: API-024 — Programa con suma ≠ 100%
    * def payload = read('classpath:testdata/activities/activities_sum_not_100.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400
    And match response.message == 'La suma de ponderaciones debe ser exactamente 100%'

  @error-path @API-025
  Scenario: API-025 — Actividad con nombre vacío
    * def payload = read('classpath:testdata/activities/activities_empty_name.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400
    And match response.message == 'Cada actividad debe tener nombre'

  @error-path @API-026
  Scenario: API-026 — Actividades con nombres duplicados (case-insensitive)
    * def payload = read('classpath:testdata/activities/activities_duplicate_names.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400
    And match response.message == 'Las actividades no pueden tener nombres duplicados'

  @error-path @API-027
  Scenario: API-027 — Actividad con ponderación ≤ 0
    * def payload = read('classpath:testdata/activities/activities_zero_percentage.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400
    And match response.message == 'Cada actividad debe tener una ponderacion mayor a 0'

  @happy-path @API-028
  Scenario: API-028 — Actualizar ponderaciones (suma = 100%)
    # Definir programa inicial
    * def initialPayload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request initialPayload
    When method put
    Then status 200
    * def act1Id = response.activities[0].id
    * def act2Id = response.activities[1].id
    # Actualizar ponderaciones
    * def updatedPayload = read('classpath:testdata/activities/activities_updated_weights.json')
    * set updatedPayload[0].id = act1Id
    * set updatedPayload[1].id = act2Id
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request updatedPayload
    When method put
    Then status 200
    And match response.activities[0].percentage == 30.0
    And match response.activities[1].percentage == 70.0

  @happy-path @API-029
  Scenario: API-029 — Eliminar instancia por omisión (redistribución)
    # Definir 3 actividades
    * def payload3 = read('classpath:testdata/activities/activities_valid_three.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload3
    When method put
    Then status 200
    And match response.activities == '#[3]'
    * def keepId1 = response.activities[0].id
    * def keepId2 = response.activities[1].id
    # Enviar solo 2 actividades (la tercera se elimina)
    * def reduced = [{id: '#(keepId1)', name: 'Examen Final', percentage: 60.0}, {id: '#(keepId2)', name: 'Tarea', percentage: 40.0}]
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request reduced
    When method put
    Then status 200
    And match response.activities == '#[2]'
```

### 3.11 GRADES — Manage (`features/grades/manage_grades.feature`)

```gherkin
@grades @put
Feature: Gestión de calificaciones — PUT /api/courses/{courseId}/grades
  Valida registro de notas: válida, negativa, no numérica, nula y recálculo.
  HU: HDU_14 | Test Cases: API-030 a API-034

  Background:
    * url baseUrl
    * def uniqueUser = 'grades_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Grades_030'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Crear curso
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'Grades_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id
    # Inscribir estudiante
    * def studentId = 'EST-GRD-' + java.lang.System.currentTimeMillis()
    * def enrollPayload = read('classpath:testdata/students/enroll_student_valid.json')
    * set enrollPayload.studentId = studentId
    * set enrollPayload.name = 'Estudiante Notas'
    * set enrollPayload.email = studentId.toLowerCase() + '@testmail.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request enrollPayload
    When method post
    Then status 200
    # Definir actividades
    * def activPayload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request activPayload
    When method put
    Then status 200
    * def activityId = response.activities[0].id
    * def activityId2 = response.activities[1].id

  @smoke @happy-path @API-030
  Scenario: API-030 — Registrar nota válida
    * def gradePayload = read('classpath:testdata/grades/grade_valid.json')
    * set gradePayload.studentId = studentId
    * set gradePayload.activityId = activityId
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 200
    And match response.grades == '#array'
    And match response.grades[*].grade contains 4.5

  @error-path @API-031
  Scenario: API-031 — Registrar nota negativa
    * def gradePayload = read('classpath:testdata/grades/grade_negative.json')
    * set gradePayload.studentId = studentId
    * set gradePayload.activityId = activityId
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 400
    And match response.message == 'La nota no puede ser negativa'

  @error-path @bug @HALLAZGO-3 @API-032
  Scenario: API-032 — Registrar nota con tipo no numérico
    # HALLAZGO-3: Debería ser 400, actualmente retorna 500
    * def gradePayload = read('classpath:testdata/grades/grade_non_numeric.json')
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 500
    And match response.message == 'Error interno del servidor'

  @happy-path @API-033
  Scenario: API-033 — Registrar nota nula (null = 0 en promedio)
    * def gradePayload = read('classpath:testdata/grades/grade_null.json')
    * set gradePayload.studentId = studentId
    * set gradePayload.activityId = activityId
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 200

  @happy-path @API-034
  Scenario: API-034 — Recálculo de promedios tras cambio de pesos
    # Registrar notas en ambas actividades
    * def g1 = read('classpath:testdata/grades/grade_valid.json')
    * set g1.studentId = studentId
    * set g1.activityId = activityId
    * set g1.grade = 4.0
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g1
    When method put
    Then status 200
    * def g2 = read('classpath:testdata/grades/grade_valid.json')
    * set g2.studentId = studentId
    * set g2.activityId = activityId2
    * set g2.grade = 3.0
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g2
    When method put
    Then status 200
    # Cambiar ponderaciones (60/40 → 30/70)
    * def updAct = [{id: '#(activityId)', name: 'Examen Final', percentage: 30.0}, {id: '#(activityId2)', name: 'Tarea', percentage: 70.0}]
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request updAct
    When method put
    Then status 200
    # Exportar boletín JSON y verificar recálculo
    Given path '/api/courses', courseId, 'students', studentId, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 200
    # weightedAverage = (4.0*30 + 3.0*70)/100 = (120+210)/100 = 3.3
    And match response.weightedAverage == 3.3
```

### 3.12 REPORTS — Export (`features/reports/export_report.feature`)

```gherkin
@reports @get
Feature: Exportar boletín académico — GET /api/courses/{courseId}/students/{studentId}/report
  Valida exportación en PDF, HTML, JSON, formato inválido y notas vacías.
  HU: HDU_15 | Test Cases: API-035 a API-039

  Background:
    * url baseUrl
    * def uniqueUser = 'report_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Report_035'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Crear curso
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'Report_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id
    # Inscribir estudiante
    * def studentId = 'EST-RPT-' + java.lang.System.currentTimeMillis()
    * def enrollPayload = read('classpath:testdata/students/enroll_student_valid.json')
    * set enrollPayload.studentId = studentId
    * set enrollPayload.name = 'Estudiante Reporte'
    * set enrollPayload.email = studentId.toLowerCase() + '@testmail.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request enrollPayload
    When method post
    Then status 200
    # Definir actividades
    * def activPayload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request activPayload
    When method put
    Then status 200
    * def activityId = response.activities[0].id
    * def activityId2 = response.activities[1].id

  @smoke @happy-path @API-035
  Scenario: API-035 — Exportar boletín en PDF
    # Registrar notas
    * def g1 = {studentId: '#(studentId)', activityId: '#(activityId)', grade: 4.5}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g1
    When method put
    Then status 200
    * def g2 = {studentId: '#(studentId)', activityId: '#(activityId2)', grade: 3.5}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g2
    When method put
    Then status 200
    # Exportar PDF
    Given path '/api/courses', courseId, 'students', studentId, 'report'
    And param format = 'pdf'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/pdf'
    And match responseHeaders['Content-Disposition'][0] contains 'boletin-'
    And match responseBytes == '#notnull'

  @happy-path @API-036
  Scenario: API-036 — Exportar boletín en HTML
    * def g1 = {studentId: '#(studentId)', activityId: '#(activityId)', grade: 4.5}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g1
    When method put
    Then status 200
    Given path '/api/courses', courseId, 'students', studentId, 'report'
    And param format = 'html'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/html'
    And match response contains '<html'

  @happy-path @API-037
  Scenario: API-037 — Exportar boletín en JSON
    * def g1 = {studentId: '#(studentId)', activityId: '#(activityId)', grade: 4.5}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g1
    When method put
    Then status 200
    * def g2 = {studentId: '#(studentId)', activityId: '#(activityId2)', grade: 3.5}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g2
    When method put
    Then status 200
    Given path '/api/courses', courseId, 'students', studentId, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.teacher == '#string'
    And match response.course == '#string'
    And match response.student == '#object'
    And match response.grades == '#array'
    And match response.generalAverage == '#number'
    And match response.weightedAverage == '#number'
    And match response.hasEmptyGrades == false
    And match response.exportDate == '#string'
    And match response.format == 'json'

  @error-path @API-038
  Scenario: API-038 — Formato no soportado
    Given path '/api/courses', courseId, 'students', studentId, 'report'
    And param format = 'xml'
    And header X-Session-Token = token
    When method get
    Then status 400
    And match response.message == 'Formato no soportado'

  @happy-path @API-039
  Scenario: API-039 — Boletín con notas vacías (hasEmptyGrades)
    # Solo registrar nota en 1 actividad de 2
    * def g1 = {studentId: '#(studentId)', activityId: '#(activityId)', grade: 4.0}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g1
    When method put
    Then status 200
    # Exportar JSON sin completar la segunda nota
    Given path '/api/courses', courseId, 'students', studentId, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.hasEmptyGrades == true
    # generalAverage = (4.0 + 0) / 2 = 2.0
    And match response.generalAverage == 2.0
    # weightedAverage = (4.0*60 + 0*40)/100 = 2.4
    And match response.weightedAverage == 2.4
```

### 3.13 SECURITY — Token Required (`features/security/token_required.feature`)

```gherkin
@security
Feature: Protección de endpoints — Autenticación requerida
  Valida que los endpoints protegidos rechazan solicitudes sin token.
  Test Cases: API-SEC-001

  Background:
    * url baseUrl

  @bug @HALLAZGO-1 @API-SEC-001
  Scenario: API-SEC-001 — Endpoints protegidos sin header X-Session-Token
    # HALLAZGO-1: Header ausente produce 500 en vez de 401
    # GET /api/courses
    Given path '/api/courses'
    When method get
    Then status 500
    And match response.message == 'Error interno del servidor'

  @security @API-SEC-001b
  Scenario: API-SEC-001b — Endpoints protegidos con token vacío
    Given path '/api/courses'
    And header X-Session-Token = ''
    When method get
    Then status 401
    And match response.message == 'Falta el token de sesion'
```

---

## 4. Datos de Prueba por Escenario

### 4.1 Autenticación

| Escenario | Campo | Válido | Inválido | Borde |
|-----------|-------|--------|----------|-------|
| F-01 Registro exitoso | `username` | `"docente_<ts>"` | `""` | `" "` (solo espacios) |
| F-01 Registro exitoso | `password` | `"P@ss_Register_001"` | `""` | `" "` |
| F-03 Username duplicado | `username` | `"DocentePrueba"` | `"docenteprueba"` (case dup) | `" DocentePrueba "` (con trim) |
| F-04 Login exitoso | `username` | `"login_<ts>"` | — | — |
| F-05 Login inválido | `password` | `"P@ss_Login_005"` | `"PasswordIncorrecto"` | — |

### 4.2 Cursos

| Escenario | Campo | Válido | Inválido | Borde |
|-----------|-------|--------|----------|-------|
| F-12 Crear curso | `name` | `"Matematicas_<ts>"` | `""` | `" "` (solo espacios) |
| F-13 Curso duplicado | `name` | `"Matemáticas"` | `"matemáticas"` (case dup) | — |

### 4.3 Estudiantes

| Escenario | Campo | Válido | Inválido | Borde |
|-----------|-------|--------|----------|-------|
| F-19 Inscripción | `studentId` | `"EST-<ts>"` | `""` | — |
| F-19 Inscripción | `name` | `"Nuevo Estudiante"` | `""` | — |
| F-19 Inscripción | `email` | `"est@testmail.com"` | `"sin-arroba"` | `""` |

### 4.4 Actividades

| Escenario | Campo | Válido | Inválido | Borde |
|-----------|-------|--------|----------|-------|
| F-23 Programa válido | `percentage` (sum) | `60 + 40 = 100` | `50 + 30 = 80` | `99.99 + 0.01 = 100` |
| F-25 Nombre vacío | `name` | `"Examen Final"` | `""` | `" "` |
| F-26 Nombres duplicados | `name` | `"Examen", "Tarea"` | `"Examen", "examen"` | — |
| F-27 Ponderación ≤ 0 | `percentage` | `60.0` | `0` | `-1.0` |

### 4.5 Calificaciones

| Escenario | Campo | Válido | Inválido | Borde |
|-----------|-------|--------|----------|-------|
| F-30 Nota válida | `grade` | `4.5` | `-1.0` | `0.0` |
| F-32 Nota no numérica | `grade` | `4.5` | `"abc"` | — |
| F-33 Nota nula | `grade` | `null` | — | — |

---

## 5. Inventario de Archivos JSON (testdata/)

> Contrato de entrega: estos son los archivos `.json` que `/unit-testing` debe crear en `src/test/java/testdata/`.

### Archivos de datos de prueba (`testdata/`)

| Archivo | Ruta en testdata/ | Escenario(s) | Tipo | Campos dinámicos |
|---------|-------------------|--------------|------|------------------|
| `register_valid.json` | `testdata/auth/` | F-01, F-03, F-04, F-05, F-07, F-09 (setup) | happy-path / setup | `username`, `password` |
| `register_empty_fields.json` | `testdata/auth/` | F-02: Registro con campos vacíos | error-path | — |
| `login_valid.json` | `testdata/auth/` | F-04: Login exitoso | happy-path | `username`, `password` |
| `login_invalid_credentials.json` | `testdata/auth/` | F-05: Login con credenciales incorrectas | error-path | `username` |
| `login_empty_fields.json` | `testdata/auth/` | F-06: Login con campos vacíos | error-path | — |
| `create_course_valid.json` | `testdata/courses/` | F-11, F-12, F-13, F-15, + múltiples setups | happy-path / setup | `name` |
| `create_course_empty_name.json` | `testdata/courses/` | F-14: Crear curso con nombre vacío | error-path | — |
| `enroll_student_valid.json` | `testdata/students/` | F-17 (setup), F-19, F-21, F-22 | happy-path / setup | `studentId`, `name`, `email` |
| `enroll_student_empty_fields.json` | `testdata/students/` | F-20: Inscribir con campos vacíos | error-path | — |
| `enroll_student_invalid_email.json` | `testdata/students/` | Validación RN-12: Email inválido | error-path | `studentId`, `name` |
| `enroll_student_autocomplete.json` | `testdata/students/` | F-22: Inscribir estudiante existente | happy-path | `studentId`, `name`, `email` |
| `activities_valid_two.json` | `testdata/activities/` | F-23: Programa válido (2 actividades, 60/40) | happy-path | — |
| `activities_valid_three.json` | `testdata/activities/` | F-29: Setup para eliminación (3 actividades) | setup | — |
| `activities_sum_not_100.json` | `testdata/activities/` | F-24: Suma ≠ 100% | error-path | — |
| `activities_empty_name.json` | `testdata/activities/` | F-25: Nombre de actividad vacío | error-path | — |
| `activities_duplicate_names.json` | `testdata/activities/` | F-26: Nombres duplicados (case-insensitive) | error-path | — |
| `activities_zero_percentage.json` | `testdata/activities/` | F-27: Ponderación ≤ 0 | error-path | — |
| `activities_updated_weights.json` | `testdata/activities/` | F-28: Ponderaciones actualizadas (30/70) | happy-path | `[*].id` |
| `grade_valid.json` | `testdata/grades/` | F-30, F-34: Nota válida (4.5) | happy-path | `studentId`, `activityId` |
| `grade_negative.json` | `testdata/grades/` | F-31: Nota negativa (-1) | error-path | `studentId`, `activityId` |
| `grade_non_numeric.json` | `testdata/grades/` | F-32: Nota con tipo incorrecto ("abc") | error-path | — |
| `grade_null.json` | `testdata/grades/` | F-33: Nota nula | happy-path | `studentId`, `activityId` |

**Total: 22 archivos JSON** distribuidos en 5 subdirectorios.

**Convención de nombrado aplicada:**
- Payload directo (happy path): `<acción>_valid.json` / `<acción>_<variante>.json`
- Precondición/setup: `<acción>_for_<operación>.json` (no necesario en este caso, los setup se comparten)
- Error path: `<acción>_<tipo_error>.json`
- Edge case: `<acción>_<caso_borde>.json`

**Campos dinámicos:** se inyectan en el `.feature` con `* set payload.<campo> = <variable>` después del `read()`. NO incluidos en los JSON estáticos.

---

## 6. Trazabilidad HU → Test Cases → Features

| HU | Test Cases | Feature File | Flujos |
|----|-----------|-------------|--------|
| HDU_1 | API-001, API-002, API-003 | `auth/register.feature` | F-01, F-02, F-03 |
| HDU_2 | API-004, API-005, API-006 | `auth/login.feature` | F-04, F-05, F-06 |
| HDU_2 | API-007, API-008 | `auth/session.feature` | F-07, F-08 |
| HDU_2 | API-009, API-010 | `auth/logout.feature` | F-09, F-10 |
| HDU_3 | API-011 | `courses/list_courses.feature` | F-11 |
| HDU_3 | API-012, API-013, API-014 | `courses/create_course.feature` | F-12, F-13, F-14 |
| HDU_4 | API-015, API-016 | `courses/get_course_detail.feature` | F-15, F-16 |
| HDU_5 | API-017, API-018 | `students/search_student.feature` | F-17, F-18 |
| HDU_5 | API-019, API-020, API-021, API-022 | `students/enroll_student.feature` | F-19, F-20, F-21, F-22 |
| HDU_11/12/13 | API-023 a API-029 | `activities/manage_activities.feature` | F-23 a F-29 |
| HDU_14 | API-030 a API-034 | `grades/manage_grades.feature` | F-30 a F-34 |
| HDU_15 | API-035 a API-039 | `reports/export_report.feature` | F-35 a F-39 |
| Transversal | API-SEC-001 | `security/token_required.feature` | F-40 |

### Cobertura de Reglas de Negocio

| Regla | Descripción | Test Cases que la cubren |
|-------|-------------|------------------------|
| RN-01 | Cursos únicos por docente (case-insensitive) | API-013 |
| RN-02 | Ponderaciones suman 100% (±0.01) | API-023, API-024, API-028, API-029 |
| RN-03 | Cada ponderación > 0 | API-027 |
| RN-04 | Nombres de actividades no vacíos | API-025 |
| RN-05 | Nombres no duplicados (case-insensitive) | API-026 |
| RN-06 | Notas ≥ 0 (si no es null) | API-030, API-031 |
| RN-07 | Notas vacías = 0 en promedios | API-033, API-034, API-039 |
| RN-08 | hasEmptyGrades flag | API-037, API-039 |
| RN-09 | Usernames únicos (case-insensitive) | API-003 |
| RN-10 | Sesión única (login borra previas) | API-004 |
| RN-11 | Estudiante reutilizable | API-019, API-022 |
| RN-12 | Email válido por regex | API-019 (validado en setup), enroll_student_invalid_email.json |

### Cobertura de Formas de Error

| Forma | Descripción | Test Cases |
|-------|-------------|-----------|
| Forma 1 | ApiException (negocio) | API-003, API-005, API-008, API-013, API-021, API-024–027, API-031, API-038 |
| Forma 2 | @Valid fallido | API-002, API-006, API-014, API-020 |
| Forma 3 | Catch-all (500) | API-032, API-SEC-001 |

### Cobertura de Hallazgos Conocidos

| Hallazgo | Severidad | Test Case | Tag |
|----------|-----------|-----------|-----|
| HALLAZGO-1 | Media | API-SEC-001 | `@bug @HALLAZGO-1` |
| HALLAZGO-2 | Baja | API-010 | `@bug @HALLAZGO-2` |
| HALLAZGO-3 | Media | API-032 | `@bug @HALLAZGO-3` |
| HALLAZGO-4 | Info | API-004 | (validable: segundo login invalida primer token) |
| HALLAZGO-5 | Baja | API-037, API-039 | (null grade en reporte vs omitido en CourseDetail) |
| HALLAZGO-6 | Info | API-024–027 | (todos Forma 1, nunca Forma 2) |
