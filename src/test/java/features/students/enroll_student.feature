@students @post
Feature: Inscribir estudiante — POST /api/courses/{courseId}/students
  Valida inscripción: happy path, campos vacíos, estudiante ya inscrito y autocompletado.
  HU: HDU_5 | Test Cases: API-019, API-020, API-021, API-022

  Background:
    * url baseUrl
    # Setup: registrar docente y crear curso
    * def uniqueUser = 'enroll_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Enroll_019'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Crear curso
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'EnrollCurso_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id

  @smoke @happy-path @API-019
  Scenario: API-019 — Inscribir estudiante nuevo exitosamente
    * def ts = java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/students/enroll_student_valid.json')
    * set payload.studentId = 'STU_' + ts
    * set payload.name = 'Estudiante_' + ts
    * set payload.email = 'enroll_' + ts + '@test.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 200
    And match response.id == courseId
    And match response.students == '#[1]'
    And match response.students[0].studentId == payload.studentId
    And match response.students[0].name == payload.name
    And match response.students[0].email == payload.email

  @error-path @API-020
  Scenario: API-020 — Inscribir estudiante con campos vacíos
    * def payload = read('classpath:testdata/students/enroll_student_empty_fields.json')
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 400
    And match response.message == 'Solicitud invalida'

  @error-path @API-021
  Scenario: API-021 — Inscribir estudiante ya inscrito en el curso
    # Inscribir estudiante por primera vez
    * def ts = java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/students/enroll_student_valid.json')
    * set payload.studentId = 'STU_DUP_' + ts
    * set payload.name = 'Estudiante_Dup_' + ts
    * set payload.email = 'dup_' + ts + '@test.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 200
    # Intentar inscripción duplicada en el mismo curso
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 409

  @happy-path @API-022
  Scenario: API-022 — Autocompletado: mismo studentId en otro curso reutiliza datos
    # Inscribir estudiante en primer curso
    * def ts = java.lang.System.currentTimeMillis()
    * def studentIdentifier = 'AUTO_' + ts
    * def payload = read('classpath:testdata/students/enroll_student_autocomplete.json')
    * set payload.studentId = studentIdentifier
    * set payload.name = 'AutoComp_' + ts
    * set payload.email = 'autocomp_' + ts + '@test.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request payload
    When method post
    Then status 200
    * def enrolledStudent = response.students[0]
    # Crear segundo curso
    * def course2Payload = read('classpath:testdata/courses/create_course_valid.json')
    * set course2Payload.name = 'AutoCompCurso2_' + ts
    Given path '/api/courses'
    And header X-Session-Token = token
    And request course2Payload
    When method post
    Then status 201
    * def courseId2 = response.id
    # Inscribir con mismo studentId en segundo curso
    * def payload2 = read('classpath:testdata/students/enroll_student_autocomplete.json')
    * set payload2.studentId = studentIdentifier
    * set payload2.name = 'NombreDiferente'
    * set payload2.email = 'different@test.com'
    Given path '/api/courses', courseId2, 'students'
    And header X-Session-Token = token
    And request payload2
    When method post
    Then status 200
    # RN-06: Mismo student record porque el studentId ya existía
    And match response.students[0].studentId == studentIdentifier
    And match response.students[0].name == enrolledStudent.name
