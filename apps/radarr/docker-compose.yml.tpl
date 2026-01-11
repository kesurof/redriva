services:
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    restart: unless-stopped

    environment:
      PUID: 1000
      PGID: 1000
      TZ: Europe/Paris

    volumes:
      - /opt/docker/radarr/config:/config
      - /data/radarr/import:/data/import
      - /data/media/movies:/data/media/movies
      - /mnt/decypharrradarr:/mnt/decypharrradarr:ro,rshared

    ports:
      - "7878:7878"

    networks:
      proxy:
      warp_net:

networks:
  proxy:
    external: true
  warp_net:
    external: true
