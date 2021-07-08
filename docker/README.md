# Galaxy-GSA Docker building

1. Download this repository.

   ```shell
   git clone git@github.com:gsa-central/galaxy-gsa.git
   ##Or use wget to download the files
   # wget https://github.com/gsa-central/galaxy-gsa/archive/refs/heads/main.zip
   # unzip main.zip
   # mv galaxy-gsa-main galaxy-gsa
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

