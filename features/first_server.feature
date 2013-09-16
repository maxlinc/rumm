Feature: Managing servers

  Scenario: Creating my first server
    Given a file named "first_server.sh" with:
    """
    #! /bin/bash -e

    echo "show servers"
    bundle exec rumm show servers
    echo "show server"
    bundle exec rumm show server rumm-first-server
    echo "create server"
    bundle exec rumm create server --name rumm-first-server --image-id 25a5f2e8-f522-4fe0-b0e0-dbaa62405c25 --flavor-id 2
    echo "show servers"
    bundle exec rumm show servers
    echo "show server"
    bundle exec rumm show server rumm-first-server
    echo "destroy server"
    bundle exec rumm destroy server rumm-first-server
    echo "show servers"
    bundle exec rumm show servers
    echo "show server"
    bundle exec rumm show server rumm-first-server
    """
    When I successfully run `bash first_server.sh`