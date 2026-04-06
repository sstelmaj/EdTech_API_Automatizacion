@courses @post
Feature: Crear curso — POST /api/courses
  Valida creación de cursos: happy path, título duplicado y título vacío.
  HU: HDU_3 | Test Cases: API-012, API-013, API-014

  Background:
    * url baseUrl
    # Setup: registrar docente y obtener token
    * def uniqueUser = 'createcourse_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Course_012'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token

  @smoke @happy-path @API-012
  Scenario: API-012 — Crear curso exitosamente
    * def payload = read('classpath:testdata/courses/create_course_valid.json')
    * def courseName = 'Curso_' + java.lang.System.currentTimeMillis()
    * set payload.name = courseName
    Given path '/api/courses'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 201
    And match response.id == '#uuid'
    And match response.name == courseName
    And match response.teacherId == '#uuid'
    # Verificar: aparece en listado
    Given path '/api/courses'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response[*].name contains courseName

  @error-path @API-013
  Scenario: API-013 — Crear curso con título duplicado (mismo docente)
    * def courseName = 'DupCurso_' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/courses/create_course_valid.json')
    * set payload.name = courseName
    # Primer curso
    Given path '/api/courses'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 201
    # Segundo curso con mismo nombre
    * def payload2 = read('classpath:testdata/courses/create_course_valid.json')
    * set payload2.name = courseName
    Given path '/api/courses'
    And header X-Session-Token = token
    And request payload2
    When method post
    Then status 409
    And match response.message == 'Ya existe un curso con este nombre'

  @error-path @API-014
  Scenario: API-014 — Crear curso con título vacío
    * def payload = read('classpath:testdata/courses/create_course_empty_name.json')
    Given path '/api/courses'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 400
    And match response.message == 'Solicitud invalida'
