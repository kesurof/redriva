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

      # ==================================================
      # Router Traefik
      # ==================================================
      - "traefik.http.routers.${APP_NAME}.rule=Host(`${APP_DOMAIN}`)"
      - "traefik.http.routers.${APP_NAME}.entrypoints=web,websecure"
      - "traefik.http.routers.${APP_NAME}.tls=true"

      # ==================================================
      # Middlewares Traefik
      #
      # ⚠️ Cette ligne DOIT exister, même vide.
      # Elle est volontairement vide par défaut.
      #
      # REDRIVA se contente de REMPLACER cette valeur
      # (ex: auth-basic@file) sans jamais la créer.
      # ==================================================
      - "traefik.http.routers.${APP_NAME}.middlewares="

      # ==================================================
      # Service Traefik
      # ==================================================
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=80"

networks:
  proxy:
    external: true
