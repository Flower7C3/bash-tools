### Drupal

* on remote server
    * `bash .docksal/commands/backup-dru-files` – backup Drupal files to archive
    * `bash .docksal/commands/share-dru-files` – share Drupal files archive to $DOCROOT with secret hash URL
* on local machine (via Docksal)
    * `fin download-dru-files` – download the Drupal files archive from remote URL and save it in `.docksal/services/cli/files/` directory (please define `REMOTE_HOST_URL` in `.docksal/docksal-local.env` file)
    * `fin restore-dru-files` – restore the latest archive from `.docksal/services/cli/files/` directory to Drupal files 
    * `fin dru-admin` – display Drupal admin URL
    * `fin drush [command]` – run any Drush command
