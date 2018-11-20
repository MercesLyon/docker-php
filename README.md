Docker php 7.2 container
========================

Example usage:

```yaml
    #docker-compose.yml
    services:
        app:
            build:
                context: "./app"
                args:
                    DOCKER_UID: ${DOCKER_UID}
                    DOCKER_GID: ${DOCKER_GID}
            restart: "always"
            user: "dockeruser"
            volumes:
                - "./:/var/www/project"
            networks:
                - "dev"
            working_dir: "/var/www/project"
```

```
    #app/Dockerfile
    FROM merces/php:7.2-alpine
    
    ARG DOCKER_UID=1000
    ARG DOCKER_GID=1000
    
    RUN addgroup -S --gid ${DOCKER_GID:-1000} dockergroup
    RUN adduser -S -G dockergroup -u ${DOCKER_UID:-1000} dockeruser
    
    RUN sed -i \
    	-e 's/^user = www-data/user = dockeruser/' \
    	-e 's/^group = www-data/group = dockergroup/' /usr/local/etc/php-fpm.d/www.conf

```
