---
name: gitflow
description: 'GitFlow completo para AUTO_API_KARATE: issue → rama → push → PR en GitHub'
---

# GitFlow Workflow — AUTO_API_KARATE

Eres el agente **coder**. Cuando el usuario te dé una tarea a implementar, ejecuta los siguientes pasos en orden usando la GitHub CLI (`gh`). No saltes pasos.

## Contexto del repositorio

- **Usuario:** `sstelmaj`
- **Repositorio:** `AUTO_API_KARATE`
- **Repo completo:** `sstelmaj/AUTO_API_KARATE`
- **URL:** `https://github.com/sstelmaj/AUTO_API_KARATE`
- **Rama base para PRs:** `main`

---

## Paso 1 — Crear el Issue en el Project

```bash
gh issue create \
  --repo sstelmaj/AUTO_API_KARATE \
  --title "<TÍTULO_DE_LA_TAREA>" \
  --body "<DESCRIPCIÓN_DETALLADA>"
```

> Guarda el número de issue que devuelve el comando (ej: `#42`). Lo usarás en los pasos siguientes.

---

## Paso 2 — Determinar el tipo de rama

Usa el prefijo según el tipo de tarea:

| Tipo | Prefijo | Cuándo usarlo |
|---|---|---|
| Nueva funcionalidad | `feature/` | Implementación nueva |
| Corrección de bug | `fix/` | Bug reportado |
| Deuda técnica | `chore/` | Refactor, DT-xx |
| Documentación | `docs/` | Solo docs |

Formato del nombre de rama: `<tipo>/ISSUE-<n>-<descripcion-en-kebab-case>`

Ejemplo: `feature/ISSUE-42-get-products-list-karate`

---

## Paso 3 — Crear y pushear la rama

```bash
# Asegurarse de estar en main actualizado
git checkout main
git pull origin main

# Crear la rama
git checkout -b <nombre-de-rama>

# Pushear la rama vacía al remoto
git push -u origin <nombre-de-rama>
```

---

## Paso 4 — Crear el Pull Request hacia develop

```bash
gh pr create \
  --repo sstelmaj/AUTO_API_KARATE \
  --base main \
  --head <nombre-de-rama> \
  --title "[ISSUE-<n>] <TÍTULO_DE_LA_TAREA>" \
  --body "## Descripción
<DESCRIPCIÓN_DE_LOS_CAMBIOS>

## Issue relacionado
Closes #<n>

## Checklist
- [ ] .feature file creado en `src/test/java/features/`
- [ ] Happy path (@smoke) y error path cubiertos
- [ ] Datos de prueba sintéticos (sin PII ni datos reales)
- [ ] baseUrl referenciada desde karate-config.js (no hardcodeada)
- [ ] Suite ejecuta correctamente con `./gradlew test`\"
```

---

## Reglas de naming para commits

Mientras trabajas en la rama, los commits deben seguir:

```
<type>(ISSUE-<n>): <descripción en imperativo>
```

Types válidos: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`

Ejemplos:
- `feat(ISSUE-42): add get products list karate feature`
- `test(ISSUE-43): add happy path and error path for POST createAccount`
- `chore(ISSUE-44): configure karate-config.js baseUrl`

---

## Reglas Karate a respetar al generar código

Antes de escribir código, verifica:

- ❌ NUNCA hardcodear `baseUrl` en un `.feature` — siempre via `karate-config.js`
- ❌ NUNCA usar datos reales de producción ni PII en los escenarios
- ✅ Un `.feature` por endpoint/operación HTTP (GET, POST, PUT, DELETE)
- ✅ Cada `.feature` debe tener al menos `@smoke` (happy path) + `@error-path`
- ✅ Datos de prueba sintéticos — usar `karate.random()` para emails únicos
- ✅ Tags obligatorios: `@get`, `@post`, `@put` o `@delete` según el método
- ✅ Leer `.github/instructions/tests.instructions.md` antes de crear cualquier archivo

---

## Flujo resumido

```
Tarea recibida
     ↓
gh issue create → obtener #n
     ↓
git checkout main && git pull
     ↓
git checkout -b <tipo>/ISSUE-<n>-<descripcion>
     ↓
git push -u origin <rama>
     ↓
gh pr create --base main
     ↓
Implementar código Karate respetando tests.instructions.md
```