FROM ubuntu:25.10

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV RESOLUTION=1280x720

# Required packages to build the environment and the lxde core through the x11vnc
# tigervnc-standalone-server for use vncpasswd command
RUN apt-get update && apt-get install -y \
    lxde-core lxterminal \
    x11vnc xvfb \
    tigervnc-standalone-server \
    novnc websockify \
    net-tools curl wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar el lxpanel
COPY ./config/lxpanel /etc/skel/.config/lxpanel

# Create the redirection to noVNC index
COPY ./static/index.html /usr/share/novnc/index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5900 6080

CMD ["/entrypoint.sh"]