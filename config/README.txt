In order to run the docker instance on helium (I assume UITS enterprise docker is similar), you must pass a directory on
the host machine to the docker instance. This directory contains the files with database credentials and any other app
specific protected data that the Rails runtime accesses. For example:

docker run -ditP --network=host --name rmd_stage --mount type=bind,ro=true,src=/run/secrets,dst=/rmd/config/ rmd

the 'src' value is the directory path that contains the configuration files. These files will be made available in the
'dst' value of the Docker image. In this case, the rails config folder. On helium, the protected data files are located
in /srv/docker/rmd_stage/secrets/ so the 'src' value in the docker run command would be that location.
