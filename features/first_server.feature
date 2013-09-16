@vcr
Feature: Managing servers

  Scenario: Creating my first server
    When I successfully run `rumm show servers`
    Then the output should contain "you don't have any servers"
    And I run `rumm show server rumm-first-server`
    And I successfully run `rumm create server --name rumm-first-server --image-id 25a5f2e8-f522-4fe0-b0e0-dbaa62405c25 --flavor-id 2`
    And I successfully run `rumm show servers`
    Then the output should match /.*rumm-first-server -> id: [\w-]+, status: ACTIVE, ipv4: [\d\.]+.*/
    And I run `rumm show server rumm-first-server`
    Then the output should match /.*rumm-first-server: [\w-]+ \(ACTIVE\).*/
    And I successfully run `rumm destroy server rumm-first-server`
    Then the output should contain "requested destruction of server"
    # And I successfully run `rumm show servers`
    # And I successfully run `rumm show server rumm-first-server`