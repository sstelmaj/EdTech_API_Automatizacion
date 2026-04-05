@students @get
Feature: Buscar estudiante — GET /api/students/{studentId}
  Valida búsqueda de estudiante por ID: existente e inexistente.
  HU: HDU_5 | Test Cases: API-017, API-018

  Background:
    * url baseUrl
    # Setup: registrar docente, crear curso e inscribir estudiante
    * def uniqueUser = 'search_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Search_017'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Crear curso
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'SearchCurso_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id
    # Inscribir estudiante
    * def studentIdentifier = 'STU_SEARCH_' + java.lang.System.currentTimeMillis()
    * def enrollPayload = read('classpath:testdata/students/enroll_student_valid.json')
    * set enrollPayload.studentId = studentIdentifier
    * set enrollPayload.name = 'StudentSearch_' + java.lang.System.currentTimeMillis()
    * set enrollPayload.email = 'search_' + java.lang.System.currentTimeMillis() + '@test.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request enrollPayload
    When method post
    Then status 200

  @happy-path @API-017
  Scenario: API-017 — Buscar estudiante existente
    Given path '/api/students', studentIdentifier
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.studentId == studentIdentifier
    And match response.name == '#string'
    And match response.email == '#string'

  @error-path @API-018
  Scenario: API-018 — Buscar estudiante inexistente
    Given path '/api/students', 'NONEXISTENT_999'
    And header X-Session-Token = token
    When method get
    Then status 404
    And match response.message == 'Estudiante no encontrado'
