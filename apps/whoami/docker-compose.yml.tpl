services:
  whoami:
    image: traefik/whoami
    container_name: ${APP_NAME}
    restart: unless-stopped

    networks:
      - proxy

    labels:
      - "traefik.enable=true"

      # IMPORTANT — réseau Docker utilisé par Traefik
      - "traefik.docker.network=proxy"

      # Router
      - "traefik.http.routers.${APP_NAME}.rule=Host(`${APP_DOMAIN}`)"
      - "traefik.http.routers.${APP_NAME}.entrypoints=web,websecure"
      - "traefik.http.routers.${APP_NAME}.tls=true"

      # Service
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=80"

networks:
  proxy:
    external: true
