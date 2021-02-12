### Databases

* on remote server
    * `bash .docksal/commands/backup-db` – backup database to archive
    * `bash .docksal/commands/share-db` – share database archive to $DOCROOT with secret hash URL
* on local machine (via Docksal)
    * `fin db cli` – connect to database from terminal or [read the docs](https://docs.docksal.io/service/db/access/), if You want to connect to database with desktop application
    * `fin backup-db` – backup the database from remote environment and save it in `.docksal/services/db/dump/` directory (this command need direct access to RDS database)
    * `fin download-db` – download the dump archive from remote URL and save it in `.docksal/services/db/dump/` directory (please define `REMOTE_HOST_URL` in `.docksal/docksal-local.env` file)
    * `fin restore-db` – restore the latest file from `.docksal/services/db/dump/` directory to database 

> If You want to automatically import database during `fin init` command put SQL files in `.docksal/services/db/init/` directory » [read more in docs](https://docs.docksal.io/service/db/import/).
