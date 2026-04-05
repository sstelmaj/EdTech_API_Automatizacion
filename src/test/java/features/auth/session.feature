@auth @get
Feature: Validar sesión — GET /api/auth/session
  Valida consulta de sesión activa y token inválido.
  HU: HDU_2 | Test Cases: API-007, API-008

  Background:
    * url baseUrl

  @happy-path @API-007
  Scenario: API-007 — Validar sesión activa
    # Setup: registrar docente
    * def uniqueUser = 'session_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Session_007'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Validar sesión
    Given path '/api/auth/session'
    And header X-Session-Token = token
    When method get
    Then status 200
    And match response.user.id == '#uuid'
    And match response.user.username == uniqueUser
    And match response.token == token

  @error-path @API-008
  Scenario: API-008 — Validar sesión con token inválido
    Given path '/api/auth/session'
    And header X-Session-Token = '00000000-0000-0000-0000-000000000000'
    When method get
    Then status 401
    And match response.message == 'Sesion invalida o expirada'
