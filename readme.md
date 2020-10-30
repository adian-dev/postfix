# Postfix docker container


## Build

```
docker build . -t postfix
```

Or you can use directly our image `adiandev/postfix`

## Usage


```
docker run --name postfix -v -e ADMIN_EMAIL=your_email --hostname your_domain adiandev/postfix
```

## Usage (docker compose) + opendkim

```
version: '2'
services:
  postfix.localhost:
    image: adiandev/postfix
    container_name: postfix
    networks:
      postfix-net:
      dkim-net:
    environment:
      ADMIN_EMAIL: your_email
      DKIM_HOST: dkim
    volumes:
      - ./postfix-data:/var/spool/postfix
      - ./postfix-logs:/var/log/postfix
    hostname: "postfix.localhost"
  dkim:
    image: adiandev/opendkim
    container_name: dkim
    networks:
      dkim-net:
    environment:
      HOST: "postfix.localhost"
    volumes:
      - ./dkim-keys:/etc/opendkim/keys
      - ./dkim-logs:/var/log/dkim

networks:
  postfix-net:
  dkim-net:
```

## Environment variables

+ ADMIN_EMAIL (Required): Mail for root
+ DKIM_HOST (Optional): Host of dkim milter

