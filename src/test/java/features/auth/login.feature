@auth @post
Feature: Login de docente — POST /api/auth/login
  Valida autenticación: happy path, credenciales inválidas y campos vacíos.
  HU: HDU_2 | Test Cases: API-004, API-005, API-006

  Background:
    * url baseUrl

  @smoke @happy-path @API-004
  Scenario: API-004 — Login exitoso
    # Setup: registrar docente
    * def uniqueUser = 'login_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Login_004'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def firstToken = response.token
    # Login
    * def loginPayload = read('classpath:testdata/auth/login_valid.json')
    * set loginPayload.username = uniqueUser
    * set loginPayload.password = 'P@ss_Login_004'
    Given path '/api/auth/login'
    And request loginPayload
    When method post
    Then status 200
    And match response.user.id == '#uuid'
    And match response.user.username == uniqueUser
    And match response.token == '#uuid'
    # RN-10: Sesión anterior invalidada
    * def newToken = response.token
    Given path '/api/auth/session'
    And header X-Session-Token = firstToken
    When method get
    Then status 401

  @error-path @API-005
  Scenario: API-005 — Login con credenciales inválidas
    # Setup: registrar docente
    * def uniqueUser = 'badlogin_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Login_005'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    # Login con password incorrecto
    * def loginPayload = read('classpath:testdata/auth/login_invalid_credentials.json')
    * set loginPayload.username = uniqueUser
    Given path '/api/auth/login'
    And request loginPayload
    When method post
    Then status 401
    And match response.message == 'Usuario o contrasena incorrectos'

  @error-path @API-006
  Scenario: API-006 — Login con campos vacíos
    * def payload = read('classpath:testdata/auth/login_empty_fields.json')
    Given path '/api/auth/login'
    And request payload
    When method post
    Then status 400
    And match response.message == 'Solicitud invalida'
