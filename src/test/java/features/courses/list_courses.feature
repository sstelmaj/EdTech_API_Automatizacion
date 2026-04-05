@courses @get
Feature: Listar cursos — GET /api/courses
  Valida la obtención del listado de cursos del docente autenticado.
  HU: HDU_3 | Test Cases: API-011

  Background:
    * url baseUrl
    # Setup: registrar docente y obtener token
    * def uniqueUser = 'listcourses_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_List_011'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token

  @smoke @happy-path @API-011
  Scenario: API-011 — Listar cursos del docente (vacío al inicio)
    Given path '/api/courses'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response == '#[]'
