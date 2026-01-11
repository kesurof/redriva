services:
  ${APP_NAME}:
    image: traefik/whoami
    container_name: ${APP_NAME}
    restart: unless-stopped

    networks:
      - proxy

    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"

      # Router (lié DIRECTEMENT à APP_NAME)
      - "traefik.http.routers.${APP_NAME}.rule=Host(`${APP_DOMAIN}`)"
      - "traefik.http.routers.${APP_NAME}.entrypoints=websecure"
      - "traefik.http.routers.${APP_NAME}.tls=true"
      - "traefik.http.routers.${APP_NAME}.service=${APP_NAME}"

      # Middleware (remplacé dynamiquement)
      - "traefik.http.routers.${APP_NAME}.middlewares=auth-basic@file"

      # Service
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=80"

networks:
  proxy:
    external: true
