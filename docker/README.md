# Galaxy-GSA Docker building

1. Download this repository.

   ```shell
   git clone git@github.com:mora-lab/Galaxy-GSA-docker-building.git
   ```

   

2. build the Galaxy-GSA image with `Dockerfile`

   ```shell
   cd Galaxy-GSA-docker-building
   docker build --tag moralabgalaxy/galaxy-gsa:latest .
   ```

3. test the image

   ```shell
   docker run -d --privileged -p 8080:80 moralabgalaxy/galaxy-gsa:latest
   ```



The galaxy administrator  user is `admin` with `password` as password.

