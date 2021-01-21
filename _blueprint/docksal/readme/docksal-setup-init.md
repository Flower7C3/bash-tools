### Beware of init command

> Command `fin init` is creating all Docker stuff for project. First it deletes all Docker containers, networks and volumes (including project database). Then it creates them again. And finally it runs `fin prepare-site` command, which contains site specific initial definitions. So once You run this command please do not run it again, unless You want to recreate all project components again.
>
> If You want to start previously initialized project, please use `fin start` command.
