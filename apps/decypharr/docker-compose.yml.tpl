services:
  decypharr:
    image: cy01/blackhole:latest
    container_name: decypharr
    restart: always

    environment:
      PUID: 1000
      PGID: 1000

    volumes:
      - /opt/docker/decypharr/config:/app
      - /mnt:/mnt:rshared

    devices:
      - /dev/fuse:/dev/fuse:rwm

    cap_add:
      - SYS_ADMIN
      - NET_ADMIN

    security_opt:
      - apparmor:unconfined

    ports:
      - "8282:8282"

    healthcheck:
      test: >
        /bin/sh -c "
        ip route | grep -q 'default via 172.19.0.250' || ip route replace default via 172.19.0.250;
        wget -qO- --timeout=2 http://localhost:8282/health || exit 0
        "
      interval: 30s
      timeout: 10s
      retries: 3

    networks:
      proxy:
      warp_net:

networks:
  proxy:
    external: true
  warp_net:
    external: true
