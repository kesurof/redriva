services:
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    restart: unless-stopped

    environment:
      PUID: 1000
      PGID: 1000
      TZ: Europe/Paris

    volumes:
      - /opt/docker/prowlarr/config:/config

    ports:
      - "9696:9696"

    networks:
      proxy:

networks:
  proxy:
    external: true
