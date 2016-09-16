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

**NOTE:** When using `chrome-debug` or `firefox-debug`, in order to access the vnc server you must specify the following options after the command :

`-p <the_port_you_want_to_bind>:5900` 

e.g.: 

`athena selenium start firefox-debug 2.53.0 -p 6002:5900`

# Versions

A list of available versions for both hub and nodes, can be found in official Selenium Docker Hub page.

* https://hub.docker.com/r/selenium/hub/tags/
* https://hub.docker.com/r/selenium/node-firefox/tags/
* https://hub.docker.com/r/selenium/node-chrome/tags/

