@grades @put
Feature: Registrar calificaciones — PUT /api/courses/{courseId}/grades
  Valida registro de notas: happy path, nota negativa, valor no numérico, nota null y sin actividades.
  HU: HDU_9 | Test Cases: API-030, API-031, API-032, API-033, API-034

  Background:
    * url baseUrl
    # Setup: registrar docente, crear curso, inscribir estudiante, configurar actividades
    * def ts = java.lang.System.currentTimeMillis()
    * def uniqueUser = 'grade_' + ts
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Grade_030'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Crear curso
    * def coursePayload = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload.name = 'GradeCurso_' + ts
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id
    # Inscribir estudiante
    * def studentIdentifier = 'STU_GRADE_' + ts
    * def enrollPayload = read('classpath:testdata/students/enroll_student_valid.json')
    * set enrollPayload.studentId = studentIdentifier
    * set enrollPayload.name = 'StudentGrade_' + ts
    * set enrollPayload.email = 'grade_' + ts + '@test.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request enrollPayload
    When method post
    Then status 200
    # Configurar actividades
    * def actPayload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request actPayload
    When method put
    Then status 200
    * def activityId1 = response.activities[0].id
    * def activityId2 = response.activities[1].id

  @smoke @happy-path @API-030
  Scenario: API-030 — Registrar calificación válida (0–5)
    * def gradePayload = read('classpath:testdata/grades/grade_valid.json')
    * set gradePayload.studentId = studentIdentifier
    * set gradePayload.activityId = activityId1
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 200
    And match response.grades == '#[1]'
    And match response.grades[0].studentId == studentIdentifier
    And match response.grades[0].activityId == activityId1
    And match response.grades[0].grade == 4.5

  @error-path @API-031
  Scenario: API-031 — Registrar calificación negativa
    * def gradePayload = read('classpath:testdata/grades/grade_negative.json')
    * set gradePayload.studentId = studentIdentifier
    * set gradePayload.activityId = activityId1
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 400
    And match response.message == 'La nota no puede ser negativa'

  @error-path @HALLAZGO-3 @API-032
  Scenario: API-032 — Registrar calificación con valor no numérico
    # HALLAZGO-3: Enviar String en campo Double causa 500 en vez de 400
    * def gradePayload = read('classpath:testdata/grades/grade_non_numeric.json')
    * set gradePayload.studentId = studentIdentifier
    * set gradePayload.activityId = activityId1
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 400

  @error-path @HALLAZGO-5 @API-033
  Scenario: API-033 — Registrar calificación con valor null
    # HALLAZGO-5: null es permitido por la API; inconsistencia en serialización de response
    * def gradePayload = read('classpath:testdata/grades/grade_null.json')
    * set gradePayload.studentId = studentIdentifier
    * set gradePayload.activityId = activityId1
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 200

  @error-path @API-034
  Scenario: API-034 — Registrar calificación sin actividades configuradas
    # Crear curso SIN actividades
    * def coursePayload2 = read('classpath:testdata/courses/create_course_valid.json')
    * set coursePayload2.name = 'NoActCurso_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload2
    When method post
    Then status 201
    * def courseIdNoAct = response.id
    # Inscribir estudiante en ese curso
    * def enrollPayload2 = read('classpath:testdata/students/enroll_student_valid.json')
    * set enrollPayload2.studentId = 'STU_NOACT_' + java.lang.System.currentTimeMillis()
    * set enrollPayload2.name = 'NoActStudent'
    * set enrollPayload2.email = 'noact_' + java.lang.System.currentTimeMillis() + '@test.com'
    Given path '/api/courses', courseIdNoAct, 'students'
    And header X-Session-Token = token
    And request enrollPayload2
    When method post
    Then status 200
    # Intentar calificar sin actividades
    * def gradePayload = read('classpath:testdata/grades/grade_valid.json')
    * set gradePayload.studentId = enrollPayload2.studentId
    * set gradePayload.activityId = '00000000-0000-0000-0000-000000000000'
    Given path '/api/courses', courseIdNoAct, 'grades'
    And header X-Session-Token = token
    And request gradePayload
    When method put
    Then status 404
