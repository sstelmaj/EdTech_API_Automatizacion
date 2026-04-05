@auth @post
Feature: Registro de docente — POST /api/auth/register
  Valida el registro de nuevos docentes: happy path, campos vacíos y username duplicado.
  HU: HDU_1 | Test Cases: API-001, API-002, API-003

  Background:
    * url baseUrl

  @smoke @happy-path @API-001
  Scenario: API-001 — Registro exitoso de docente
    * def uniqueUser = 'docente_' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/auth/register_valid.json')
    * set payload.username = uniqueUser
    * set payload.password = 'P@ss_Register_001'
    Given path '/api/auth/register'
    And request payload
    When method post
    Then status 201
    And match response.user.id == '#uuid'
    And match response.user.username == uniqueUser
    And match response.token == '#uuid'

  @error-path @API-002
  Scenario: API-002 — Registro con campos vacíos
    * def payload = read('classpath:testdata/auth/register_empty_fields.json')
    Given path '/api/auth/register'
    And request payload
    When method post
    Then status 400
    And match response.message == 'Solicitud invalida'
    And match response.details == '#object'

  @error-path @API-003
  Scenario: API-003 — Registro con username duplicado (case-insensitive)
    # Primer registro
    * def uniqueUser = 'dup_' + java.lang.System.currentTimeMillis()
    * def payload = read('classpath:testdata/auth/register_valid.json')
    * set payload.username = uniqueUser
    * set payload.password = 'P@ss_Register_003'
    Given path '/api/auth/register'
    And request payload
    When method post
    Then status 201
    # Segundo registro con diferente capitalización
    * def payload2 = read('classpath:testdata/auth/register_valid.json')
    * set payload2.username = uniqueUser.toUpperCase()
    * set payload2.password = 'P@ss_Register_003b'
    Given path '/api/auth/register'
    And request payload2
    When method post
    Then status 409
    And match response.message == 'El nombre de usuario ya existe'
