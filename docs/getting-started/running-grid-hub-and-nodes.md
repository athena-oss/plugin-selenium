# Selenium Grid Hub

```bash
$ athena selenium start hub 2.53.0
```

# Grid Nodes

```bash
$ athena selenium start firefox 2.53.0
```

Nodes available:
 * `firefox`
 * `firefox-debug`
 * `chrome`
 * `chrome-debug`
 * `phantomjs`

# Link Grid Nodes to Local Hub

When a Selenium Grid Node is started, it will try to automatically link with a running Grid Hub or/and Proxy Server.

In case `--skip-hub` or/and `--skip-proxy` exists, the link will not be performed.

For performing a link with another running container, you can optionally specify `--link-hub=<container_name>` and/or `--link-proxy=<container_name>`.

# Expose Grid Hub or Nodes Port

You can optionally expose component port number by setting `--port=<port>` to publish externally under `<port>` number. This will expose the default port 4444 (Selenium management port). This setting is available for all nodes and the hub.

```bash
$ athena selenium start hub 2.53.0 --port=5001
```

```bash
$ athena selenium start firefox 2.53.0 --port=5001
```

# Debug with a VNC

When you use `chrome-debug` or `firefox-debug` you can connect to a VNC by exporting the container port 5900 to the outside, e.g.:

`athena selenium start firefox-debug 2.41.1 -p 5900:5900`

If you want to start multiple instances of the `firefox-debug` browser, and you want docker to handle automatically the ports, you can do:
- `athena selenium start firefox-debug 2.41.1 --instances=3 -P`

This will start 3 instances of `firefox-debug` and will export all the ports automatically. 

Run `docker ps` and check the containers port that point to `5900` for e.g.:

```
CONTAINER ID  ...   PORTS                     NAMES
18f70efe1f71  ...   0.0.0.0:32770->5900/tcp   athena-selenium-0-firefox-debug-2
cc029088974b  ...   0.0.0.0:32769->5900/tcp   athena-selenium-0-firefox-debug-1
456eb5673da9  ...   0.0.0.0:32768->5900/tcp   athena-selenium-0-firefox-debug
7a755dd68a3f  ...   4444/tcp                  athena-selenium-0-hub
```

This information tells us that if I want to connect to `athena-selenium-0-firefox-debug-2` VNC I have to to it to `vnc://localhost:32770`.

# Versions

A list of available versions for both hub and nodes, can be found in official Selenium Docker Hub page.

* https://hub.docker.com/r/selenium/hub/tags/
* https://hub.docker.com/r/selenium/node-firefox/tags/
* https://hub.docker.com/r/selenium/node-chrome/tags/

