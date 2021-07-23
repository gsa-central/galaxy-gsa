<img src="https://github.com/mora-lab/mora-lab.github.io/blob/master/picture/MORALAB_Banner.png">

# Galaxy-GSA Docker
This Docker version is based on [bgruening/galaxy-stable](https://hub.docker.com/r/bgruening/galaxy-stable/)

With this version of Galaxy-GSA, you need to install the tools dependencies to run the GSA tools (see the list of dependencies at each tool's help).

# Usage

1. First you need to install docker. Please follow the instructions from the [Docker project](https://docs.docker.com/get-docker/) or from [our own website](https://github.com/mora-lab/installing/tree/main/docker).

2. After a successful installation, all you need to do is:

```
sudo systemctl start docker
sudo docker run -d -p 8080:80 -p 8021:21 -p 8022:22 moralab/galaxy-gsa
```

3. Open http://localhost:8080/ with a browser.

The galaxy administrator user is `galaxy` with `galaxy` as password.

# Galaxy-GSA Docker building

1. Download this repository.

   ```shell
   # use wget to download the files
   wget https://github.com/gsa-central/galaxy-gsa/archive/refs/heads/main.zip
   # unzip main.zip
   mv galaxy-gsa-main galaxy-gsa 
   ```

2. build the Galaxy-GSA image with `Dockerfile`

   ```shell
   cd galaxy-gsa
   cp -r tools docker/GalaxyGSA
   cd docker
   docker build --tag moralab/galaxy-gsa:latest .
   ```

3. test the image

   ```shell
   docker run -d --privileged -p 8080:80 moralab/galaxy-gsa:latest
   ```

4. Open http://localhost:8080/ with a browser.

The galaxy administrator user is `galaxy` with `galaxy` as password.

*Last updated: July 23rd, 2021*
