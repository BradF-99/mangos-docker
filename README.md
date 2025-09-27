# CMaNGOS for Docker

This repository contains a Docker image that builds and runs the CMaNGOS Classic Core as well as Compose definitions to easily spin up a CMaNGOS instance. The image contains the `mangosd` and `realmd` executables and is designed to be used in a Docker Compose stack. It also includes every module available for the classic core.

## Getting Started

### Pre-requisites

* Docker installed on the machine.
* The data folder from the client (not provided).
* Ports 3724 and 8085 open on the host firewall (not sure if they are TCP or UDP sorry).

### Using the Docker Compose stack

#### Using pre-built images

1. Clone the repository to the machine. Do not add `--recurse-submodules` as they are not required for pre-built images.  Alternatively you can download the `docker-compose.yml` file as well as the `sql/` and create the `etc/` and `data/` folders yourself. Don't forget all of the `.conf` files!
```sh
$ git clone https://github.com/BradF-99/cmangos-docker
```

2. Add the extracted data from your game client to the `data/` folder.

3. Edit the configuration files in the `etc/` folder to your liking.

4. In `sql/03-insert-realm.sql` change the values to suit your needs. More information on the realm flags, timezone and allowed security level [can be found here](https://github.com/cmangos/issues/wiki/realmlist).

5. Start the stack:

```sh
$ docker compose -f docker-compose.yml up
```

The initial server boot will take some time - on my testing virtual machine the first boot took just under 11 minutes. This is due to the amount of data that CMaNGOS puts in to the database. It will probably be faster if your database is on an SSD. I would test this myself but couldn't be bothered. Sorry.

#### Using self-built images

1. Clone the repository to the machine. Note the `--recurse-submodules`, as omitting it will not clone CMaNGOS or the modles. Feel free to make a cup of tea / coffee at this point as it will likely take some time.
```
$ git clone --recurse-submodules https://github.com/BradF-99/cmangos-docker
```

2. Add the extracted data from your game client to the `data/` folder.

3. Edit the configuration files in the `etc/` folder to your liking.

4. In `sql/03-insert-realm.sql` change the values to suit your needs. More information on the realm flags, timezone and allowed security level [can be found here](https://github.com/cmangos/issues/wiki/realmlist).

5. Start the stack (and tell Docker to build the images). Feel free to drink the cup of tea / coffee you made earlier as this will also take some time.

```sh
$ docker compose -f docker-compose-local.yml up --build
```

As above, the initial boot will take a while (even more so because Docker has to build the image) so enjoy your cup of tea / coffee and don't rush.

### Running the image stand-alone
Alternatively if you don't wish to use Docker Compose the image can be run on it's own. Bear in mind you will need to run at least two instances (one for `realmd` and one for `mangosd`), and will have to mount the `etc/` and `data/` folders. Depending on how you set up your database (container or running on host / other machine) you'll need to modify the  `mangosd.conf` and `realmd.conf` files in `etc/`. You may want to do this if you wish to run a stand-alone realm on another machine, for example.

```sh
$ docker run -v ./etc:/mangos/etc -v ./data:/mangos/bin/data -p 8085:8085 ghcr.io/bradf-99/mangos-docker:latest

$ docker run -v ./etc:/mangos/etc -p 3724:3724 --entrypoint /mangos/bin/realmd ghcr.io/bradf-99/mangos-docker:latest
```

### Notes
* By default all modules are enabled with the exception of Hardcore mode. All other settings have been left as their defaults.
* If you have already have a server, you can use your current database with it. 
    * The easiest way is to dump the contents of the database and then add the dumped file to the `sql/` folder using something like `mysqldump -u root -p --databases classiccharacters classiclogs classicmangos classicrealmd --opt --skip-lock-tables -v --result-file=cmangos.sql`. Don't forget to remove the existing SQL script `01-alldb-modules.sql.xz` and remember that MariaDB executes SQL init scripts in alphabetical order.
    * Alternatively, you can change the connection string in the `etc/` folder to connect to your current database.
* If using self-built images:
    * The build process will take some time as it must install the required packages and then run make. On my testing virtual machine (8 vCPUs, 16GB RAM) it took 17 minutes to build the image. The GitHub Action to build the image takes around 22 minutes.
    * You will need approx 12GB of free system memory to complete the build process.
* This set-up theoretically supports multiple realms but I haven't tried it myself. All you should need to do is duplicate the `mangosd` service in your docker compose file of choice, open the respective ports on the host and then add the realm definition to the table like so:
```sql
USE classicrealmd;
DELETE FROM realmlist WHERE id=1;
INSERT INTO realmlist (id, name, address, port, icon, realmflags, timezone, allowedSecurityLevel)
VALUES 
    ('1', 'Vanilla Realm', '73.21.37.73', '8085', '0', '0', '3', '0'),
    ('2', 'PvP Realm', '73.21.37.73', '8086', '1', '0', '3', '0'),
    ('3', 'RP Realm', '73.21.37.73', '8087', '6', '0', '3', '0'),
    ('4', 'RP PvP Realm', '73.21.37.73', '8088', '8', '0', '3', '0');
```

* Do not expose the database to the internet. (you shouldn't need to anyway). If you do need to, your use cases are likely more advanced and you know the steps to take in order to safely do so (but really think if you need to do this or not).
    * If you wish to run realms on separate machines, try using a WireGuard link between the machines that need to connect to the database so it is never exposed directly to the internet. (This is not security advice.)

## Metrics

CMaNGOS exposes metrics in the form of the InfluxDB line protocol. The Compose stack includes the necessary containers to export these metrics to a Grafana Cloud instance. Additionally, Docker metrics and logs are also exported to Prometheus and Loki respectively.

To use metrics with Grafana Cloud, do the following:

1. If you do not have a Grafana Cloud instance, [create one here](https://grafana.com/products/cloud/) (the free plan should be more than enough).
2. Go to the [My Account section on Grafana.com](https://grafana.com/auth/sign-in/). Once here, select your Grafana Cloud instance on the sidebar on the left. It should bring you to the "Manage your stack" page.
3. In the Prometheus section, click the blue "Send Metrics" button. Scroll down until you see the "Grafana Data Source settings" section.
4. Click the "Generate now" text next to the Password entry. Give your token a name and click "Create token". Make a note of this token as we will need to add it to our Alloy configuration.
5. Add the details from the Grafana Data Source section to the `prometheus.remote_write "grafanacloud"` section of the `metrics/config.alloy` file, changing the `url`, `username` and `password` fields. Once complete it should look something like this:
```
prometheus.remote_write "grafanacloud" {
  endpoint {
    url = "https://prometheus-prod-73-prod-au-southeast-1.grafana.net/api/prom/push"

    basic_auth {
      username = "1234567"
      password = "glc_somelonggrafana.comapitokenhere"
    }
  }
}
```
6. Return to the "Manage your stack" page and in click the blue "Send Logs" button in the Loki section.
7. Add the details from the Grafana Data Source settings section to the `loki.write "grafanacloud"` section of the `metrics/config.alloy` file, changing the `url`, `username` and `password` fields. Note that the username for Prometheus and Loki will be different, but the password will be the same. Once complete it should look something like this:
```
loki.write "grafanacloud" {
  endpoint {
    url = "https://logs-prod-073.grafana.net/loki/api/v1/push"

    basic_auth {
      username = "7654321"
      password = "glc_somelonggrafana.comapitokenhere"
    }
  }
}

```
8. In `etc/mangosd.conf` change `Metric.Enable = 0` to `Metric.Enable = 1`. No other settings need to be changed.
9. In your Compose stack YAML definition, un-comment out the `alloy` and `influxdb-exporter` sections.
10. Start the stack back up.
11. Visit the Drilldown or Explore pages in Grafana Cloud to ensure logs and metrics are propagating to Grafana Cloud.

Please note that you do not have to use Grafana Cloud - you can modify the configuration in `metrics/config.alloy` to export to your own Prometheus and Loki servers.

## Contributions
Contributions are most welcome. To make a change, please fork the repository, make your changes and then create a PR targeting the master branch of this repository, adding myself as a reviewer.

## Things to do
* Fix the stupid health check for the database
* Could make a separate image that builds the database using classic-db at runtime instead of having to dump the entirety from a pre-configured database?
* Trigger the GitHub Action when an upstream commit from the mangos-classic module is pushed

## Licence

This project follows the licence terms of the mangos-classic repository. 

World of Warcraft content and materials are trademarks and copyrights of Blizzard or its licensors. All rights reserved.