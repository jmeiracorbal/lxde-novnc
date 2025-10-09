FROM ubuntu:25.10

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV RESOLUTION=1280x720

RUN apt-get update && apt-get install -y \
    lxde-core lxterminal \
    x11vnc xvfb \
    tigervnc-standalone-server \
    novnc websockify \
    net-tools curl wget \
    x11-utils procps \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar el lxpanel
COPY ./config/lxpanel /etc/skel/.config/lxpanel

# Create the redirection to noVNC index
COPY ./static/index.html /usr/share/novnc/index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Health check: verify that websockify is responding on port 6080
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:6080/ || exit 1

EXPOSE 5900 6080

CMD ["/entrypoint.sh"]