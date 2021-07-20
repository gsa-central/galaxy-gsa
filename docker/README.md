# Galaxy-GSA Docker
This Docker version is based on [bgruening/galaxy-stable](https://hub.docker.com/r/bgruening/galaxy-stable/)

With our Galaxy-GSA, you need to install tools dependencies when you run the GSA tools.

# Usage
At first you need to install docker. Please follow the [very good instructions](https://docs.docker.com/get-docker/) from the Docker project.

After the successful installation, all you need to do is:

```
docker run -d -p 8080:80 -p 8021:21 -p 8022:22 moralab/galaxy-gsa
```

and then visit http://localhost:8080 to check Galaxy-GSA docker.



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

4. Open http://localhost:8080/ with browser.

The galaxy administrator user is `galaxy` with `galaxy` as password.

