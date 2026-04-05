@auth @post
Feature: Cierre de sesión — POST /api/auth/logout
  Valida logout exitoso y logout con token inexistente (HALLAZGO-2).
  HU: HDU_2 | Test Cases: API-009, API-010

  Background:
    * url baseUrl

  @smoke @happy-path @API-009
  Scenario: API-009 — Logout exitoso + verificación de invalidación
    # Setup: registrar docente
    * def uniqueUser = 'logout_' + java.lang.System.currentTimeMillis()
    * def regPayload = read('classpath:testdata/auth/register_valid.json')
    * set regPayload.username = uniqueUser
    * set regPayload.password = 'P@ss_Logout_009'
    Given path '/api/auth/register'
    And request regPayload
    When method post
    Then status 201
    * def token = response.token
    # Logout
    Given path '/api/auth/logout'
    And header X-Session-Token = token
    When method post
    Then status 204
    # Verificar invalidación: el token ya no sirve
    Given path '/api/auth/session'
    And header X-Session-Token = token
    When method get
    Then status 401

  @error-path @bug @HALLAZGO-2 @API-010
  Scenario: API-010 — Logout con token inexistente
    # HALLAZGO-2: Debería ser 401, actualmente retorna 204
    Given path '/api/auth/logout'
    And header X-Session-Token = '00000000-0000-0000-0000-000000000000'
    When method post
    Then status 401
