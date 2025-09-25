# CMaNGOS for Docker

Docker image that builds and runs the CMaNGOS Classic Core. It contains the `mangosd` and `realmd` executables and is designed to be used in a Docker Compose stack. It also includes every module available for the classic core.

## Usage

### Pre-requisites

* Docker installed on the machine.
* The data folder from the client (not provided).
* Ports 3724 and 8085 open on the host firewall (not sure if they are TCP or UDP sorry).

### Using the Docker Compose stack

#### Using pre-built images

1. Clone the repository to your PC. Do not add `--recurse-submodules` as they are not required for pre-built images.
```
$ git clone https://github.com/BradF-99/cmangos-docker
```

2. Add the extracted data from your game client to the `data/` folder.

3. Edit the configuration files in the `etc/` folder to your liking.

4. In `sql/03-insert-realm.sql` change the values to suit your needs. More information on the realm flags, timezone and allowed security level [can be found here](https://github.com/cmangos/issues/wiki/realmlist).

5. Start the stack:

```
$ docker compose -f docker-compose.yml up
```

The initial server boot will take some time - on my testing virtual machine the first boot took just under 11 minutes. This is due to the amount of data that CMaNGOS puts in to the database. It will probably be faster if your database is on an SSD. I would test this myself but couldn't be bothered. Sorry.

#### Using self-built images

1. Clone the repository to your PC. Note the `--recurse-submodules`, as omitting it will not clone CMaNGOS or the modules. Feel free to make a cup of tea / coffee at this point as it will likely take some time.
```
$ git clone --recurse-submodules https://github.com/BradF-99/cmangos-docker
```

2. Add the extracted data from your game client to the `data/` folder.

3. Edit the configuration files in the `etc/` folder to your liking.

4. In `sql/03-insert-realm.sql` change the values to suit your needs. More information on the realm flags, timezone and allowed security level [can be found here](https://github.com/cmangos/issues/wiki/realmlist).

5. Start the stack (and tell Docker to build the images). Feel free to drink the cup of tea / coffee you made earlier as this will also take some time.

```
$ docker compose -f docker-compose-local.yml up --build
```

As above, the initial boot will take a while (even more so because Docker has to build the image) so enjoy your cup of tea / coffee and don't rush.

### Running the image stand-alone
Alternatively if you don't wish to use Docker Compose the image can be run on it's own. Bear in mind you will need to run at least two instances (one for `realmd` and one for `mangosd`), and will have to mount the `etc/` and `data/` folders. Depending on how you set up your database (container or running on host / other machine) you'll need to modify the  `mangosd.conf` and `realmd.conf` files in `etc/`.

TODO: add cli

### Notes
* By default all modules are enabled with the exception of Hardcore mode. All other settings have been left as their defaults.
* If you have already have a server, you can use your current database with it. 
    * The easiest way is to dump the contents of the database and then add the dumped file to the `sql/` folder using something like `mysqldump -u root -p --all-databases --opt --skip-lock-tables -v --result-file=cmangos.sql`
    * Alternatively, you can change the connection string in the `etc/` folder to connect to your current database.
* If using self-built images:
    * The build process will take some time as it must install the required packages and then run make. On my testing virtual machine (8 vCPUs, 16GB RAM) it took 17 minutes to build the image.
    * You will need approx 12GB of free system memory to complete the build process.
* This set-up theoretically supports multiple realms but I haven't tried it myself. All you should need to do is duplicate the `mangosd` service in your docker compose file of choice, add the realm definition to the table and then open the port on the host.
* No security hardening has been done on the database so do not expose it to the internet (you shouldn't need to anyway). If you do need to, your use cases are likely more advanced and you know the steps to take in order to safely expose the database (but really think if you need to do this or not).
    * If you wish to run realms on separate machines, try using a WireGuard link between the machines that need to connect to the database so it is never exposed directly to the internet. 

## Things to do
* Fix the stupid health check for the database
* Automatically generate the container images and put them in GHCR
* Could make a separate image that builds the database using classic-db at runtime instead of having to dump the entirety from a pre-configured database?

## Licence

This project follows the licence terms of the mangos-classic repository. 

World of Warcraft content and materials are trademarks and copyrights of Blizzard or its licensors. All rights reserved.