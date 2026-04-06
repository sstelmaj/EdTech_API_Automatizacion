@grades @put
Feature: Registrar calificaciones — PUT /api/courses/{courseId}/grades
  Valida registro de notas: happy path, nota negativa, valor no numérico, nota nula
  y recálculo de promedios tras cambio de ponderaciones.
  HU: HDU_14 | Test Cases: API-030, API-031, API-032, API-033, API-034

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
    * def actPayload = read('classpath:testdata/activities/activities_valid_three.json')
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request actPayload
    When method put
    Then status 200
    * def activityId1 = response.activities[0].id
    * def activityId2 = response.activities[1].id
    * def activityId3 = response.activities[2].id

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

  @error-path @bug @HALLAZGO-3 @API-032
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

  @happy-path @API-034
  Scenario: API-034 — Recálculo de promedios tras cambio de ponderaciones
    # Background ya configuró: Parcial 1 (30%), Parcial 2 (30%), Examen Final (40%)
    * def p1Id = activityId1
    * def p2Id = activityId2
    * def finalId = activityId3
    # Paso 1: Asignar notas — P1=4.0, P2=3.0, Final=5.0
    * def g1 = {studentId: '#(studentIdentifier)', activityId: '#(p1Id)', grade: 4.0}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g1
    When method put
    Then status 200
    * def g2 = {studentId: '#(studentIdentifier)', activityId: '#(p2Id)', grade: 3.0}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g2
    When method put
    Then status 200
    * def g3 = {studentId: '#(studentIdentifier)', activityId: '#(finalId)', grade: 5.0}
    Given path '/api/courses', courseId, 'grades'
    And header X-Session-Token = token
    And request g3
    When method put
    Then status 200
    # Promedio ponderado previo = 4.0×0.30 + 3.0×0.30 + 5.0×0.40 = 4.10
    # Paso 2: Actualizar ponderaciones (P1: 20%, P2: 20%, Final: 60%)
    * def updatedAct = [{id: '#(p1Id)', name: 'Parcial 1', percentage: 20.0}, {id: '#(p2Id)', name: 'Parcial 2', percentage: 20.0}, {id: '#(finalId)', name: 'Examen Final', percentage: 60.0}]
    Given path '/api/courses', courseId, 'activities'
    And header X-Session-Token = token
    And request updatedAct
    When method put
    Then status 200
    # Paso 3: Verificar que el promedio se recalculó
    # Nuevo promedio ponderado = 4.0×0.20 + 3.0×0.20 + 5.0×0.60 = 4.40
    Given path '/api/courses', courseId, 'students', studentIdentifier, 'report'
    And param format = 'json'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.weightedAverage == 4.4
