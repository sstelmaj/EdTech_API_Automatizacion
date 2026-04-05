@courses @get
Feature: Detalle del curso — GET /api/courses/{courseId}
  Valida obtención de detalle de un curso existente y uno inexistente.
  HU: HDU_3 | Test Cases: API-015, API-016

  Background:
    * url baseUrl
    # Setup: registrar docente y crear curso
    * def uniqueUser = 'detail_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Detail_015'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Crear curso
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'DetalleCurso_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id

  @happy-path @API-015
  Scenario: API-015 — Obtener detalle de curso existente
    Given path '/api/courses', courseId
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.id == courseId
    And match response.name == '#string'
    And match response.students == '#[]'
    And match response.activities == '#[]'

  @error-path @API-016
  Scenario: API-016 — Obtener detalle de curso inexistente
    Given path '/api/courses', '00000000-0000-0000-0000-000000000000'
    And header X-Session-Token = token
    When method get
    Then status 404
    And match response.message == 'Curso no encontrado'
