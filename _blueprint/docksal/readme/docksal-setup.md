# {PROJECT_NAME}

## Local development setup

1. Install [Docksal](https://docksal.io) *(required only once, but please update it sometimes)*.
2. Clone repository.
3. Place SQL init file in `.docksal/services/db/init/` directory for the database auto import *(optional, You can do it later)*.
4. Run `fin init` command in project root directory *(required only once, see note below)*.
5. Open [{VIRTUAL_HOST}](https://{VIRTUAL_HOST}) page.

Enjoy :)

### Beware of init command

> Command `fin init` is creating all Docker stuff for project. First it deletes all Docker containers, networks and volumes (including project database). Then it creates them again. And finally it runs `fin init-site` command, which contains site specific initial definitions. So once You run this command please do not run it again, unless You want to recreate all project components again.
> 
> If You want to start previously initialized project, please use `fin start` command.

### Docksal customization

> Docksal uses Docker Compose syntax, so You can extend default configuration by editing `.docksal/docksal.yml` file. Please [read the docs](https://docs.docksal.io/). 

