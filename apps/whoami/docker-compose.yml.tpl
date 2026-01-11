services:
  whoami:
    image: traefik/whoami
    container_name: ${APP_NAME}
    restart: unless-stopped

    volumes:
      - "${APP_DATA_DIR}/config:/config"

    networks:
      - proxy

    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"

      # Router
      - "traefik.http.routers.${APP_NAME}.name=${APP_NAME}"
      - "traefik.http.routers.${APP_NAME}.rule=Host(`${APP_DOMAIN}`)"
      - "traefik.http.routers.${APP_NAME}.entrypoints=websecure"
      - "traefik.http.routers.${APP_NAME}.tls=true"

      # Middleware (modifiable par REDRIVA)
      - "traefik.http.routers.${APP_NAME}.middlewares=auth-basic@file"

      # Service
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=80"

networks:
  proxy:
    external: true
