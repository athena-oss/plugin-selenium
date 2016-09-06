# Introduction

You can optionally override default configuration settings using environment variables.

# Java and Selenium Options

You can optionally provide additional options for both Java and Selenium.

This is done by setting a environment variable, `JAVA_OPTS` for Java options. Or `SE_OPTS` for Selenium.

```bash
$ athena selenium start hub 2.53.0 -e JAVA_OPTS="-xms128m" -e SE_OPTS="-log /home/ubuntu/project/selenium.log"
```

These variables can be set for `hub`, `firefox`, `firefox-debug`, `chrome` and `chrome-debug`.

# Hub

```bash
GRID_NEW_SESSION_WAIT_TIMEOUT=-1
GRID_JETTY_MAX_THREADS=-1
GRID_NODE_POLLING=5000
GRID_CLEAN_UP_CYCLE=5000
GRID_TIMEOUT=30000
GRID_BROWSER_TIMEOUT=0
GRID_MAX_SESSION=5
GRID_UNREGISTER_IF_STILL_DOWN_AFTER=30000
```

Environment variables are set using docker options.

```bash
$ athena selenium start hub 2.53.0 -e GRID_NEW_SESSION_WAIT_TIMEOUT=30 -e GRID_TIMEOUT=-1
```

# Nodes (Firefox, Chrome, PhantomJS)

```bash
SCREEN_WIDTH=1360
SCREEN_HEIGHT=1020
SCREEN_DEPTH=24
DISPLAY=:99.0
```

Environment variables are set using docker options.

```bash
$ athena selenium start firefox 2.53.0 -e SCREEN_WIDTH=800 -e SCREEN_HEIGHT=600
```

## Connect Node to Remote Host

You can optionally connect your node to an external Selenium Hub instance, using `REMOTE_HOST`, `HUB_PORT_4444_TCP_ADDR` and `HUB_PORT_4444_TCP_PORT` environment variables.

```bash
$ athena selenium start firefox 2.53.0 -e REMOTE_HOST="http://1.2.3.4:5555" -e HUB_PORT_4444_TCP_ADDR="1.2.3.4" -e HUB_PORT_4444_TCP_PORT="4444"
```
