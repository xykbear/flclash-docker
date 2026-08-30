# FlClash Docker

Auto-updating Docker image for [FlClash](https://github.com/chen08209/FlClash), a multi-platform proxy client based on Clash Meta.

Based on the (unmaintained) [libzonda/flclash-docker](https://github.com/libzonda/flclash-docker) approach, rebuilt around a GitHub Actions auto-update pipeline so the image stays current with upstream releases.

## How auto-update works

The GitHub Actions workflow runs on a schedule (every 14 days) and:

1. Fetches the latest stable release tag of upstream FlClash via the GitHub API.
2. Compares it with the committed `FLCLASH_VERSION`.
3. If a new release exists, updates `FLCLASH_VERSION`, rebuilds the image for `linux/amd64` and `linux/arm64`, and pushes it to GHCR as `latest` plus a version tag.

You can also trigger a manual rebuild anytime via **Actions → Build and Publish Docker Image → Run workflow**.

## Pull

```sh
docker pull ghcr.io/xykbear/flclash-docker:latest
```

## Run with compose

```yaml
services:
  flclash:
    image: ghcr.io/xykbear/flclash-docker:latest
    container_name: flclash
    network_mode: bridge
    volumes:
      - ./flclash-data:/config/xdg/data/com.follow.clash
    ports:
      - "5800:5800"       # noVNC GUI (import subscription / pick node)
      - "7890:7890"       # HTTP / mixed proxy
      - "7891:7891"       # SOCKS proxy
      - "9091:9091"       # Clash controller (dashboard)
      - "1053:1053/udp"   # DNS
    environment:
      - TZ=Asia/Shanghai
    restart: unless-stopped
```

> Adjust port bindings to your setup. For a LAN bypass proxy, point client devices at your host IP plus the proxy ports (e.g. `192.168.1.10:7890`). See `compose.example.yaml`.

## Usage

1. Open the GUI at `http://<host>:5800` (noVNC in your browser).
2. Import your subscription URL (see your provider's docs, e.g. [caomei.wiki FlClash on Linux](https://www.caomei.wiki/knowledge-base/linux-clash/)).
3. Enable **LAN proxy** (局域网代理) so other devices can use the proxy ports.
4. Manage nodes and rules in the GUI; the Clash dashboard is available via port `9091` (host/controller `9090` forwarded by `socat`).

## Security

This image is intended for **private LAN use only**. Do not publish its ports (GUI, proxies, controller) to the public internet. The Clash controller in particular grants full config control.

## Build locally

```sh
docker build --build-arg FLCLASH_VERSION=v0.8.96 -t flclash:dev .
```

The `.deb` package is downloaded from the upstream GitHub release at build time and verified against the published `SHA256SUMS`.

## Ports

| Port | Purpose |
|------|---------|
| 5800 | noVNC web GUI |
| 5900 | VNC |
| 7890 | HTTP / mixed proxy |
| 7891 | SOCKS proxy |
| 1053 | DNS (UDP) |
| 9091 | Clash controller (forwarded from 127.0.0.1:9090) |

## Acknowledgements

- [chen08209/FlClash](https://github.com/chen08209/FlClash) — the core application
- [jlesage/docker-baseimage](https://github.com/jlesage/docker-baseimage) — base GUI image
- [libzonda/flclash-docker](https://github.com/libzonda/flclash-docker) — original Docker packaging
