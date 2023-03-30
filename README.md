# php-for-ee-docker
A Dockerfile for creating a PHP 8.2 container with the extensions required to run ExpressionEngine.

This is an Alpine-based image that comes purposely bare. It does not include ExpressionEngine itself, nor a webserver. You will need to bring your own EE installation and proxy.

This was created for my personal use (see second-to-last section) and passes all checks on the [Server Compatibility Wizard](https://docs.expressionengine.com/v6/installation/requirements.html#server-compatibility-wizard). Feel free to try it and let me know if it works for you! I cannot offer much support for using this image, especially if you use a different reverse proxy.

## get this image

### build

1. Clone this repo
```sh
git clone https://github.com/telophase/php-for-ee-docker.git
cd php-for-ee-docker
```
2. Make any changes to the Dockerfile, if necessary
3. Build using `docker buildx`. ([How to install `buildx`](https://docs.docker.com/build/install-buildx/))
```docker
sudo docker buildx build ./ --tag php-for-ee-docker:latest
```

### pull from a registry 
Latest builds are pushed to both [Docker Hub](https://hub.docker.com/) and the [Github Container Registry](https://ghcr.io).

Build tags correspond to which PHP version is shipped. Current tags are:
- `latest`, `8.2` - Tested with EE7.2+


## deploy via `docker-compose`
Using volume mounts, you can mount your ExpressionEngine files into the container however you like. Here, we are assuming that all of your EE files (including your `themes` `system` directories, and your `index.php` and `admin.php` files) are in one folder that is mounted once.

Network names are not required, rename them as you see fit.

```docker
services:
  app:
    image: telophase/php-for-ee-docker
    restart: unless-stopped
    container_name: expressionengine
    volumes:
      - /path/to/your/ee/files:/var/www/html
    networks:
      - caddy # attaches container to an external reverse proxy network
      - eengine # atteches container to db, make sure your db is also on this network
    depends_on:
      - db
    links:
      - db:db
   
# Be sure to add a database of your choice, and import your EE database into it.

networks:
  caddy:
    external: true
  eengine:
    driver: bridge
```


## my usecase: proxying with caddy-docker-proxy
I created this in order to use with caddy-docker-proxy. Please see that project's README for more information about hwo it works if you need to tweak it.

Be sure your proxy network, in this case, `caddy`, was created as an external network via `docker network create`.

```docker
# ...
    labels:
      caddy_0: YOUR_FQDN
      # ------- themes directory
      # uncomment this section if you need handling for your themes directory
      # especially if it is not in the root of your base path (/var/www/html)
      # sometimes ee will not rely on the filepath
      #caddy_0.1_handle_path: /themes/* 
      #caddy_0.1_handle_path.0_root: "* /var/www/html/themes"
      #caddy_0.1_handle_path.1_encode: gzip
      #caddy_0.1_handle_path.2_file_server:

      # ------- site root
      caddy_0.2_handle: 
      # you may need to tweak the root path if your index.php/admin.ee is in a subfolder 
      caddy_0.2_handle.0_root: "* /var/www/html/" 
      caddy_0.2_handle.1_encode: gzip
      caddy_0.2_handle.2_file_server:
      caddy_0.2_handle.3_php_fastcgi: app:9000 
      # make sure "app" is whatever you called the ee service, if you changed it
# ...
```
Edit your `config.php` to point to your new database.

Grant your files permissions 755 (or whatever your Control Panel asks you to do), and change their owner to your Caddy user. In my case, this user was called `82`. You can see this user by creating a file with your new EE installation.


## license
(c) 2023 [Alex H](https://gimon.zone) <[@telophase](https://github.com/telophase)>
<br>
MIT license

This project was derived from the archived repo [guidang/docker-caddy-php](https://github.com/guidang/docker-caddy-php) and its Dockerfile.<br>
(c) 2022 Jetsung Chan <[@jetsung](https://github.com/jetsung)><br>
MIT license