### Databases

* connect to database from cli » `fin db cli`
* connect to database with desktop application » [read the docs](https://docs.docksal.io/service/db/access/)
* backup the database from remote environment and save dump file in `.docksal/services/db/dump/` directory » `fin backup-db`
* restore the latest file from `.docksal/services/db/dump/` directory to database » `fin restore-db` 
* backup and restore database in one command » `fin migrate-db`
* if You want to automatically import database during `fin init` command put SQL files in `.docksal/services/db/init/` directory » [read more in docs](https://docs.docksal.io/service/db/import/)
