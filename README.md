# CMaNGOS for Docker

Docker image that builds and runs the CMaNGOS Classic Core. It contains the `mangosd` and `realmd` executables and is designed to be used in a Docker Compose stack. It also includes every module available for the classic core.

# Usage

### Pre-requisites

* Docker installed on the machine.
* The data folder from the client (not provided).

### Using the Docker Compose stack

1. Clone the repository to your PC. Note the `--recurse-submodules`, as omitting it will not clone CMaNGOS or the modules.
```
$ git clone --recurse-submodules https://github.com/BradF-99/cmangos-docker
```

2. Edit the configuration files in the `etc/` folder to your liking. Do not change the database connection strings if you are running the Docker Compose stack.

3. Depending on your needs, you can either run the Docker Compose stack that uses pre-built images or a self-built image:

```
$ docker compose -f docker-compose.yml up # Pre-built images
$ docker compose -f docker-compose-local.yml up --build # Self-built images
```

### Running the image stand-alone
Alternatively the image can be run on it's own. Bear in mind you will need to run at least two instances, and will have to mount the `etc/` and `data/` folders. Depending on how you set up your database (container or running on host / other machine) you'll need to modify the  `mangosd.conf` and `realmd.conf`.

TODO: add cli

### Notes
* By default all modules are enabled with the exception of Hardcore mode. All other settings have been left as their defaults.
* If you have already have a server, you can use your current database with it. 
    * The easiest way is to dump the contents of the database and then add the dumped file to the `sql/` folder using something like `mysqldump -u root -p --all-databases --opt --skip-lock-tables -v --result-file=cmangos.sql`
    * Alternatively, you can change the connection string in the `etc/` folder.
* If using self-built images:
    * The build process will take some time as it must install the required packages and then run make.
    * You will need approx 12GB of free system memory to complete the build process.

# Licence

This project follows the licence terms of the mangos-classic repository. 

World of Warcraft content and materials are trademarks and copyrights of Blizzard or its licensors. All rights reserved.