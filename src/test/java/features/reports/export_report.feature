@reports @get
Feature: Reporte de notas — GET /api/courses/{courseId}/students/{studentId}/report
  Valida exportación de reporte: happy path, sin calificaciones, estudiante no inscrito,
  curso inexistente y estudiante inexistente.
  HU: HDU_15 | Test Cases: API-035, API-036, API-037, API-038, API-039

  Background:
    * url baseUrl
    # Setup completo: docente, curso, estudiante, actividades
    * def ts = java.lang.System.currentTimeMillis()
    * def uniqueUser = 'report_' + ts
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
    * set coursePayload.name = 'ReportCurso_' + ts
    Given path '/api/courses'
    And header X-Session-Token = token
    And request coursePayload
    When method post
    Then status 201
    * def courseId = response.id
    # Inscribir estudiante
    * def studentIdentifier = 'STU_REPORT_' + ts
    * def enrollPayload = read('classpath:testdata/students/enroll_student_valid.json')
    * set enrollPayload.studentId = studentIdentifier
    * set enrollPayload.name = 'ReportStudent_' + ts
    * set enrollPayload.email = 'report_' + ts + '@test.com'
    Given path '/api/courses', courseId, 'students'
    And header X-Session-Token = token
    And request enrollPayload
    When method post
    Then status 200
    # Configurar 2 actividades
    * def actPayload = read('classpath:testdata/activities/activities_valid_two.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request actPayload
    When method put
    Then status 200
    * def activityId1 = response.activities[0].id
    * def activityId2 = response.activities[1].id

  @smoke @happy-path @API-035
  Scenario: API-035 — Reporte con calificaciones completas
    # Calificar actividad 1
    * def grade1 = read('classpath:testdata/grades/grade_valid.json')
    * set grade1.studentId = studentIdentifier
    * set grade1.activityId = activityId1
    * set grade1.grade = 4.5
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request grade1
    When method put
    Then status 200
    # Calificar actividad 2
    * def grade2 = read('classpath:testdata/grades/grade_valid.json')
    * set grade2.studentId = studentIdentifier
    * set grade2.activityId = activityId2
    * set grade2.grade = 3.8
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request grade2
    When method put
    Then status 200
    # Obtener reporte
    Given path '/api/courses', courseId, 'students', studentIdentifier, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.student.id == studentIdentifier
    And match response.course == '#string'
    And match response.grades == '#[2]'
    And match response.weightedAverage == '#number'
    And match response.generalAverage == '#number'

  @happy-path @API-036
  Scenario: API-036 — Reporte sin calificaciones (notas null o ausentes)
    Given path '/api/courses', courseId, 'students', studentIdentifier, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.student.id == studentIdentifier
    And match response.course == '#string'

  @error-path @API-037
  Scenario: API-037 — Reporte para estudiante no inscrito en el curso
    # Crear otro curso sin inscribir al estudiante
    * def course2Payload = read('classpath:testdata/courses/create_course_valid.json')
    * set course2Payload.name = 'NoInscrito_' + java.lang.System.currentTimeMillis()
    Given path '/api/courses'
    And header X-Session-Token = token
    And request course2Payload
    When method post
    Then status 201
    * def courseIdOther = response.id
    # Intentar reporte de estudiante no inscrito en ese curso
    Given path '/api/courses', courseIdOther, 'students', studentIdentifier, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 404

  @error-path @API-038
  Scenario: API-038 — Reporte con curso inexistente
    Given path '/api/courses', '00000000-0000-0000-0000-000000000000', 'students', studentIdentifier, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 404

  @error-path @API-039
  Scenario: API-039 — Reporte con estudiante inexistente
    Given path '/api/courses', courseId, 'students', 'NONEXISTENT_999', 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 404
