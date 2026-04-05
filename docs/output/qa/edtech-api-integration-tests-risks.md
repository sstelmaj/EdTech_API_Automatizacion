# Matriz de Riesgos — EdTech API Integration Tests

> **Spec de referencia:** `.github/specs/edtech-api-integration-tests.spec.md` (SPEC-001 — APPROVED)
> **Generado por:** risk-identifier
> **Fecha:** 2026-04-05
> **Método:** Regla ASD del CoE (Alto=Obligatorio, Medio=Recomendado, Bajo=Opcional)

---

## Resumen

| Nivel | Cantidad | Testing |
|-------|----------|---------|
| **Alto (A)** | 8 | Obligatorio — bloquea release |
| **Medio (S)** | 6 | Recomendado — documentar si se omite |
| **Bajo (D)** | 3 | Opcional — priorizar en backlog |
| **Total** | **17** | |

---

## Detalle

| ID | HU | Descripción del Riesgo | Factores | Nivel | Testing |
|------|------|----------------------|----------|-------|---------|
| R-001 | HDU_1, HDU_2 | **Bypass de autenticación por header ausente** — El header `X-Session-Token` ausente produce 500 en vez de 401 (HALLAZGO-1), exponiendo stack trace y permitiendo ambigüedad en la capa de seguridad | Autenticación/autorización, Bug conocido en todos los endpoints protegidos | **A** | Obligatorio |
| R-002 | HDU_2 | **Sesiones huérfanas por logout sin validación** — POST /logout retorna 204 incluso con token inexistente (HALLAZGO-2), impidiendo detección de intentos de cierre con tokens robados o manipulados | Autenticación/autorización, Operaciones destructivas (sesión) | **A** | Obligatorio |
| R-003 | HDU_1 | **Passwords almacenados con BCrypt sin expiración** — No existe TTL ni limpieza de sesiones; tokens viven indefinidamente. Riesgo de sesiones perpetuas si el docente no cierra sesión explícitamente | Autenticación/autorización, Sin mecanismo de expiración | **A** | Obligatorio |
| R-004 | HDU_11, HDU_12, HDU_13 | **Corrupción del programa evaluativo por validación manual** — PUT /activities no usa `@Valid` (HALLAZGO-6); toda validación es manual con riesgo de bypass si se envían tipos inesperados (HALLAZGO-3: `Double` como string → 500) | Lógica de negocio compleja, Código nuevo sin historial de estabilidad | **A** | Obligatorio |
| R-005 | HDU_11, HDU_14 | **Integridad evaluativa: ponderaciones ≠ 100%** — Si la validación de suma (RN-02, tolerancia ±0.01) falla silenciosamente, los promedios ponderados serán matemáticamente incorrectos, afectando boletines oficiales | Lógica de negocio compleja, Impacto en datos académicos | **A** | Obligatorio |
| R-006 | HDU_14, HDU_15 | **Cálculo incorrecto de promedios con notas nulas** — Notas vacías se tratan como 0 (RN-07). Si la lógica falla, generalAverage y weightedAverage serán incorrectos. Agravado por HALLAZGO-5 (inconsistencia null entre CourseDetail y Report) | Lógica de negocio compleja, Inconsistencia de serialización documentada | **A** | Obligatorio |
| R-007 | HDU_12 | **Eliminación de actividad borra calificaciones en cascada** — PUT /activities elimina actividades omitidas junto con sus `student_grades`. Operación destructiva sin confirmación; si se envía payload incorrecto, se pierden notas irrecuperablemente | Operaciones destructivas irrecuperables | **A** | Obligatorio |
| R-008 | HDU_15 | **Generación de boletín PDF/HTML fallida** — Endpoint de reporte depende de OpenHTMLToPDF (librería externa). Fallo en generación produce 500 genérico. La exportación es la entrega final de valor al docente | Integración con librería externa, Funcionalidad crítica para el usuario | **A** | Obligatorio |
| R-009 | HDU_5 | **Creación parcial de estudiante en inscripción fallida** — POST /students crea el estudiante globalmente antes de inscribirlo en el curso. Si la inscripción falla (409 duplicado), ¿queda un estudiante "huérfano"? Hay riesgo de datos inconsistentes | Lógica de negocio compleja, Componente con dependencias (students ↔ course_students) | **S** | Recomendado |
| R-010 | HDU_1 | **Username duplicado con case-insensitive y trim** — La unicidad depende de `lower(username)` + `.trim()`. Combinaciones de espacios y capitalización podrían no estar cubiertas completamente | Lógica de negocio compleja | **S** | Recomendado |
| R-011 | HDU_3 | **Nombre de curso duplicado por docente (case-insensitive)** — Unicidad con `lower(name)` + `teacher_id`. Edge case: nombres con caracteres especiales, acentos o espacios múltiples podrían evadir la validación | Lógica de negocio compleja | **S** | Recomendado |
| R-012 | HDU_14 | **Deserialización de tipos incorrectos en grade** — HALLAZGO-3: enviar `"grade": "abc"` produce 500 en vez de 400. Afecta tanto PUT /grades como PUT /activities con `percentage` incorrecta | Bug conocido, Validación de tipos en Jackson | **S** | Recomendado |
| R-013 | HDU_5 | **Validación de email por regex permisiva** — RN-12 usa `^[^\s@]+@[^\s@]+\.[^\s@]+$` que acepta emails técnicamente válidos pero inusuales. Riesgo bajo pero podría permitir datos basura | Lógica de negocio (validación) | **S** | Recomendado |
| R-014 | HDU_2 | **Sesión única por diseño: login invalida tokens previos** — HALLAZGO-4: cada login borra TODAS las sesiones. Si un docente tiene múltiples pestañas, todas excepto la última quedan sin sesión | Funcionalidad de alta frecuencia de uso, Diseño intencional pero con impacto UX | **S** | Recomendado |
| R-015 | HDU_4 | **Ordenamiento de respuestas no determinístico** — CourseDetailResponse ordena students por `full_name ASC`, activities por `position ASC`. Si el orden cambia, tests de igualdad exacta fallarán | Código nuevo sin historial | **D** | Opcional |
| R-016 | HDU_15 | **Inconsistencia de serialización null (HALLAZGO-5)** — Jackson omite `grade: null` en CourseDetailResponse; StringBuilder escribe `"grade": null` en reporte JSON. No es un bug funcional pero puede confundir consumidores de la API | Inconsistencia documentada, Sin impacto funcional directo | **D** | Opcional |
| R-017 | HDU_3 | **Listado de cursos vacío** — GET /courses retorna `[]` cuando no hay cursos. Bajo riesgo, pero los consumidores deben manejar este caso | Feature básica de lectura | **D** | Opcional |

---

## Plan de Mitigación — Riesgos ALTO

### R-001: Bypass de autenticación por header ausente (HALLAZGO-1)

- **Mitigación técnica**: El backend debe capturar `MissingRequestHeaderException` y retornar 401 en vez de 500. Hasta que se corrija, los tests deben validar el comportamiento actual (500) con tag `@bug @HALLAZGO-1`.
- **Tests obligatorios**:
  - `API-SEC-001` — Todos los endpoints protegidos sin header → valida 500 actual
  - `API-SEC-001b` — Todos los endpoints con header vacío → valida 401 correcto
- **Bloqueante para release**: ✅ Sí — cualquier endpoint protegido es accesible sin autenticación clara

---

### R-002: Sesiones huérfanas por logout sin validación (HALLAZGO-2)

- **Mitigación técnica**: El backend debe verificar `rowsAffected > 0` en el DELETE de sesión y retornar 401 si el token no existía. Hasta corrección, test valida 204 con tag `@bug @HALLAZGO-2`.
- **Tests obligatorios**:
  - `API-009` — Logout exitoso + verificación posterior con GET /session
  - `API-010` — Logout con token inexistente → valida 204 actual (esperado: 401)
- **Bloqueante para release**: ✅ Sí — no se detectan intentos de logout con tokens inválidos

---

### R-003: Sesiones sin expiración (TTL indefinido)

- **Mitigación técnica**: No hay corrección posible sin cambio de diseño. Mitigación parcial: los tests deben validar que logout efectivamente invalida el token (API-009 verifica con GET /session posterior).
- **Tests obligatorios**:
  - `API-007` — Validar sesión activa (confirma que funciona)
  - `API-009` — Logout + verificación de invalidación
  - `API-004` — Login borra sesiones previas (RN-10 mitiga parcialmente)
- **Bloqueante para release**: ✅ Sí — riesgo aceptado por diseño, pero testing obligatorio para confirmar que logout funciona

---

### R-004: Validación manual en PUT /activities (HALLAZGO-3, HALLAZGO-6)

- **Mitigación técnica**: El backend debería agregar `@Valid` o capturar las `HttpMessageNotReadableException` para retornar 400. Los tests cubren todas las validaciones manuales (API-023 a API-029).
- **Tests obligatorios**:
  - `API-023` — Programa válido (happy path: confirma que la validación manual funciona)
  - `API-024` — Suma ≠ 100%
  - `API-025` — Nombre vacío
  - `API-026` — Nombres duplicados (case-insensitive)
  - `API-027` — Ponderación ≤ 0
  - `API-032` — Tipo incorrecto → 500 actual (`@bug @HALLAZGO-3`)
- **Bloqueante para release**: ✅ Sí — validación manual es el único control; si falla, datos corruptos

---

### R-005: Integridad evaluativa — ponderaciones ≠ 100%

- **Mitigación técnica**: Tolerancia de ±0.01 (RN-02) está implementada. Los tests deben verificar tanto el rechazo (suma incorrecta) como la aceptación (suma correcta) y el recálculo de promedios post-actualización.
- **Tests obligatorios**:
  - `API-023` — Definir programa con suma = 100% (happy path)
  - `API-024` — Rechazar suma ≠ 100%
  - `API-028` — Actualizar ponderaciones (new sum = 100%)
  - `API-034` — Recálculo de promedio ponderado tras cambio de pesos
- **Bloqueante para release**: ✅ Sí — ponderaciones incorrectas invalidan todos los boletines

---

### R-006: Cálculo incorrecto de promedios con notas nulas

- **Mitigación técnica**: La regla RN-07 (null = 0) debe validarse matemáticamente. Los tests deben calcular el promedio esperado y comparar con la respuesta del API.
- **Tests obligatorios**:
  - `API-033` — Nota nula registrada exitosamente
  - `API-034` — Recálculo matemáticamente correcto: `weightedAverage = sum(grade × percentage) / 100`
  - `API-037` — Reporte JSON con todos los campos calculados
  - `API-039` — Reporte con `hasEmptyGrades: true` y promedios con null = 0
- **Bloqueante para release**: ✅ Sí — promedios incorrectos en boletines académicos oficiales

---

### R-007: Eliminación de actividad borra calificaciones en cascada

- **Mitigación técnica**: Operación por diseño (PUT reemplaza todas las actividades). Los tests deben verificar que la actividad eliminada desaparece y que las notas asociadas se borran.
- **Tests obligatorios**:
  - `API-029` — Eliminar instancia por omisión: 3 actividades → enviar 2 → verificar que la tercera y sus notas desaparecen
  - `API-015` — Consultar detalle del curso post-eliminación para confirmar consistencia
- **Bloqueante para release**: ✅ Sí — pérdida de datos sin posibilidad de rollback

---

### R-008: Generación de boletín PDF/HTML fallida

- **Mitigación técnica**: OpenHTMLToPDF es dependencia externa. Los tests validan Content-Type, Content-Disposition y que el body no esté vacío. El error 500 "No fue posible generar el PDF" solo se dispara ante fallos internos de la librería.
- **Tests obligatorios**:
  - `API-035` — Exportar PDF: Content-Type `application/pdf`, Content-Disposition con "boletin-", body no vacío
  - `API-036` — Exportar HTML: Content-Type `text/html`, contiene `<html`
  - `API-037` — Exportar JSON: estructura completa validada
  - `API-038` — Formato no soportado → 400
  - `API-039` — Boletín con notas vacías → hasEmptyGrades:true
- **Bloqueante para release**: ✅ Sí — exportación de boletín es la entrega final de valor del sistema

---

## Mapa de Riesgos → Test Cases

| Riesgo | Test Cases Obligatorios | Feature File |
|--------|------------------------|-------------|
| R-001 | API-SEC-001, API-SEC-001b | `security/token_required.feature` |
| R-002 | API-009, API-010 | `auth/logout.feature` |
| R-003 | API-004, API-007, API-009 | `auth/login.feature`, `auth/session.feature`, `auth/logout.feature` |
| R-004 | API-023 a API-027, API-032 | `activities/manage_activities.feature`, `grades/manage_grades.feature` |
| R-005 | API-023, API-024, API-028, API-034 | `activities/manage_activities.feature`, `grades/manage_grades.feature` |
| R-006 | API-033, API-034, API-037, API-039 | `grades/manage_grades.feature`, `reports/export_report.feature` |
| R-007 | API-015, API-029 | `activities/manage_activities.feature`, `courses/get_course_detail.feature` |
| R-008 | API-035 a API-039 | `reports/export_report.feature` |
| R-009 | API-019, API-020, API-022 | `students/enroll_student.feature` |
| R-010 | API-003 | `auth/register.feature` |
| R-011 | API-013 | `courses/create_course.feature` |
| R-012 | API-032 | `grades/manage_grades.feature` |
| R-013 | API-019 (setup), enroll_invalid_email | `students/enroll_student.feature` |
| R-014 | API-004 | `auth/login.feature` |

---

## Recomendaciones de Priorización

### Orden de ejecución sugerido (por riesgo)

1. **Seguridad primero**: `security/token_required.feature` → R-001
2. **Auth completo**: `auth/*.feature` → R-002, R-003, R-014
3. **Programa evaluativo**: `activities/manage_activities.feature` → R-004, R-005, R-007
4. **Calificaciones + cálculos**: `grades/manage_grades.feature` → R-005, R-006, R-012
5. **Reportes**: `reports/export_report.feature` → R-006, R-008
6. **Estudiantes**: `students/enroll_student.feature` → R-009, R-013
7. **Cursos**: `courses/*.feature` → R-011, R-015, R-017

### Tags de ejecución por nivel de riesgo

```bash
# Solo riesgos ALTO → criterio mínimo de aceptación
mvnw.cmd test -Dkarate.options="--tags @smoke"

# Riesgos ALTO + MEDIO → cobertura recomendada
mvnw.cmd test -Dkarate.options="--tags ~@HALLAZGO-1"

# Suite completa → todos los niveles
mvnw.cmd test
```
