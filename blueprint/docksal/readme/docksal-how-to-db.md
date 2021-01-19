* backup the database from remote environment and save dump file in `.docksal/services/db/dump/` directory » `fin backup-db`
* restore the latest file from `.docksal/services/db/dump/` directory to database » `fin restore-db` 
* backup and restore database in one command » `fin reload-db`
* if You want to automatically import database during `fin init` command put SQL files in `.docksal/services/db/init/` directory » [read more in docs](https://docs.docksal.io/service/db/import/)
