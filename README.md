# LXDE noVNC

This project provides a lightweight a Linux desktop through the browser running inside a container using Docker.

![alt text](flujo-xvfb-x11vnc.png "Flow xvfb redirect to x11vnc")

# Getting started

To launch the LXDE desktop in your browser create a `docker-compose.yml` file like the following:

```yaml
version: '3.8'

services:
  desktop:
    image: jmeiracorbal/lxde-novnc:latest
    container_name: lxde-novnc
    ports:
      - "6080:6080"
      - "5900:5900"
    environment:
      - VNC_USER=docker
      - VNC_PASS=letmein
    restart: unless-stopped
```

Required and optional ports:

* 6080: creates the access via browser.
* 5900: it's optional. Add if you need VNC access with a traditional client (Guacamole).

Access:

```yaml
docker compose up --build -d
```

After running, go to http://localhost:6080 and you'll see the LXDE desktop running on the browser.

# Configuration

You can customize the container using environment variables in your compose file or when running with docker run:

* `VNC_USER`: username created inside the container. Default value is docker.
* `VNC_PASS`: VNC password used if authentication is enabled. Default value is letmein.
* `RESOLUTION`: screen resolution of the virtual desktop (WxH). The default value is 1280x720.
* `DISPLAY`: it's the virtual display number (should not be changed). The default value is :0.

> By default, the container doesn't enforce the password auth. See the Authentication and security section for how to enable it.

Example usage with custom resolution and credentials:

```yaml
environment:
  - VNC_USER=alice
  - VNC_PASS=s3cr3t
  - RESOLUTION=1440x900
```

# Components

* Xvfb (virtual framebuffer): it's the output inside container, but is not real because simulates a memory screen where is drawed the desktop environment. Has the `DISPLAY=:0` value as a another Linux desktop app.
* x11vnc server: this project uses VNC protocol, like RDP (Remote Desktop), x11... In remote. `x11vnc` is the VNC server where
  the desktop is drawed; draw the background, panel, windows, menus, etc. over the framebuffer (:0) que provee Xvfb.
* websockify: bridge to connect VNC protocol through web sockets. The bridge is listen on port 6080 (HTTP/WebSocket) to translate WebSocket signal to TCP, and redirect the traffic inside port 5900, where is the real VNC server listen.
* noVNC: it's a VNC client. It's loaded from web browser (`/usr/share/novnc`).

# Authentication and security

This container doesn't use VNC password authentication as default (x11vnc is started with the flag -nopw). This is intentional to make the environment accessible. If password protection is required, remove the -nopw argument in entrypoint.sh and ensure VNC_PASS is correctly configured.

> If you want to add HTTP authentication bellow this container, it will be performed externally. Examples: through reverse proxy such as Nginx, Traefik...

# Graphical interface VNC redirect

It leverages a virtual X server (Xvfb), a VNC server (x11vnc) and a web socket proxy (websockify) to expose a graphical interface through the client noVNC.

```text
[Browser]
     ↓ (HTML)
   http://localhost:6080/vnc.html
     ↓
  [noVNC Client]
     ↓ (WebSocket)
  ws://localhost:6080/websockify
     ↓
  [websockify]
     ↓ (VNC server)
  localhost:5900
     ↓ 
  [x11vnc]
     ↓
  [Xvfb :0] ← LXDE desktop
```

# Support

One of the most important ideas is to create a minimal yet full desktop experience that will run reliably platform with Docker from Linux and macOS (Silicon, Intel) and Windows without require an external VNC client or a full desktop environment.

# Disclaimers 

Improvements are welcome, but this is a personal project designed to assist my own server manager. It's not intended for commercial use, nor is there any business interest associated with it.

Issues might exist and will be handled as time permits, but one should not expect any fixes or changes as certain. 

If you found a bug or have any suggestion, please create an [issue](https://github.com/jmeiracorbal/lxde-novnc/issues) in line with the [code of conduct](./CODE_OF_CONDUCT.md) and [Contributing guide](./CONTRIBUTING.md) of the project.

# License

The project is covered under the MIT License.

