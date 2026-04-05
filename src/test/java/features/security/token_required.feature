@security @cross-cutting
Feature: Token requerido — Endpoints protegidos
  Valida que todos los endpoints protegidos requieren X-Session-Token.
  HALLAZGO-1: Sin header debería retornar 401, actualmente retorna 500.
  Test Case: API-SEC-001

  Background:
    * url baseUrl

  @bug @HALLAZGO-1 @API-SEC-001
  Scenario Outline: API-SEC-001 — Endpoint <endpoint> sin token retorna error
    # HALLAZGO-1: Se espera 401 pero el servidor retorna 500 cuando falta el header
    Given path '<endpoint>'
    When method <method>
    Then assert responseStatus == 401 

    Examples:
      | endpoint                                                                      | method |
      | /api/auth/session                                                              | get    |
      | /api/auth/logout                                                               | post   |
      | /api/courses                                                                   | get    |
      | /api/courses                                                                   | post   |
      | /api/courses/00000000-0000-0000-0000-000000000000                               | get    |
      | /api/students/00000000-0000-0000-0000-000000000000                              | get    |
      | /api/courses/00000000-0000-0000-0000-000000000000/students                      | post   |
      | /api/courses/00000000-0000-0000-0000-000000000000/activities                    | put    |
      | /api/courses/00000000-0000-0000-0000-000000000000/grades                        | put    |
      | /api/courses/00000000-0000-0000-0000-000000000000/students/00000000-0000-0000-0000-000000000000/report | get |
