@activities @put
Feature: Gestionar actividades — PUT /api/courses/{courseId}/activities
  Valida configuración de actividades: happy path, suma != 100, nombre vacío,
  duplicados, porcentaje 0, actualización y verificación en detalle.
  HU: HDU_7 | Test Cases: API-023, API-024, API-025, API-026, API-027, API-028, API-029

  Background:
    * url baseUrl
    # Setup: registrar docente, crear curso
    * def uniqueUser = 'act_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Act_023'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'ActCurso_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id

  @smoke @happy-path @API-023
  Scenario: API-023 — Configurar 2 actividades (suma 100%)
    * def payload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 200
    And match response.activities == '#[2]'
    And match each response.activities == { id: '#uuid', name: '#string', percentage: '#number' }

  @happy-path @API-024
  Scenario: API-024 — Configurar 3 actividades (suma 100%)
    * def payload = read('classpath:testdata/activities/activities_valid_three.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 200
    And match response.activities == '#[3]'

  @error-path @API-025
  Scenario: API-025 — Actividades con suma != 100%
    * def payload = read('classpath:testdata/activities/activities_sum_not_100.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400
    And match response.message == 'La suma de ponderaciones debe ser exactamente 100%'

  @error-path @HALLAZGO-6 @API-026
  Scenario: API-026 — Actividad con nombre vacío
    # HALLAZGO-6: PUT /activities no tiene @Valid, podría aceptar nombre vacío
    * def payload = read('classpath:testdata/activities/activities_empty_name.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400

  @error-path @API-027
  Scenario: API-027 — Actividades con nombres duplicados
    * def payload = read('classpath:testdata/activities/activities_duplicate_names.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400
    And match response.message == 'Las actividades no pueden tener nombres duplicados'

  @error-path @API-028
  Scenario: API-028 — Actividad con porcentaje 0
    * def payload = read('classpath:testdata/activities/activities_zero_percentage.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 400
    And match response.message == 'Cada actividad debe tener una ponderacion mayor a 0'

  @happy-path @API-029
  Scenario: API-029 — Actualizar actividades y verificar reflejo en detalle
    # Primera configuración
    * def payload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request payload
    When method put
    Then status 200
    * def act1Id = response.activities[0].id
    * def act2Id = response.activities[1].id
    # Actualizar con nuevos pesos usando IDs reales
    * def updated = [{id: '#(act1Id)', name: 'Examen Final', percentage: 30.0}, {id: '#(act2Id)', name: 'Tarea', percentage: 70.0}]
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request updated
    When method put
    Then status 200
    And match response.activities == '#[2]'
    # Verificar en detalle del curso
    Given path '/api/courses', courseId
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.activities == '#[2]'
    And match response.activities[0].percentage == 30
    And match response.activities[1].percentage == 70
