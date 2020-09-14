## Local development setup

1. Install [Docksal](https://docksal.io).
2. Clone repository.
3. Place SQL init file in `.docksal/services/db/init/` directory.
4. Run `fin init` command in project root directory.
5. Open [novavax.docksal](https://novavax.docksal) page.

Enjoy :)

## How to?

* connect to database from cli » `fin db cli`
* connect to database with desktop application » [read the docs](https://docs.docksal.io/service/db/access/) 
* enable Xdebug » [read the docs](https://docs.docksal.io/tools/xdebug/) 
* read server logs » `fin logs --follow`
* start previously inited Docker containers » `fin start`
* stop Docker containers » `fin stop`
* completely remove Docker stuff related to this project » `fin project remove`
