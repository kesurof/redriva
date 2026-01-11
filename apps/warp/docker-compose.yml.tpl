services:
  warp:
    image: caomingjun/warp:latest
    container_name: warp
    restart: unless-stopped

    capabilities:
      - NET_ADMIN
      - MKNOD
      - AUDIT_WRITE

    security_opt:
      - apparmor:unconfined

    device_cgroup_rules:
      - 'c 10:200 rwm'

    sysctls:
      net.ipv6.conf.all.disable_ipv6: "0"
      net.ipv4.conf.all.src_valid_mark: "1"
      net.ipv4.ip_forward: "1"
      net.ipv6.conf.all.forwarding: "1"

    environment:
      WARP_SLEEP: "2"
      WARP_ENABLE_NAT: "1"

    volumes:
      - /opt/docker/warp/config:/var/lib/cloudflare-warp

    networks:
      warp_net:
        ipv4_address: 172.19.0.250

networks:
  warp_net:
    external: true
