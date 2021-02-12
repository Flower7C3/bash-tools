### Wordpress

* on remote server
    * `bash .docksal/commands/backup-wp-uploads` – backup uploaded files to archive
    * `bash .docksal/commands/share-wp-uploads` – share uploaded files archive to $DOCROOT with secret hash URL
* on local machine (via Docksal)
    * `fin download-wp-uploads` – download the uploaded files archive from remote URL and save archive in `.docksal/services/cli/uploads/` directory (please define `REMOTE_HOST_URL` in `.docksal/docksal-local.env` file)
    * `fin restore-wp-uploads` – restore the latest archive from `.docksal/services/cli/uploads/` directory to uploaded files 
