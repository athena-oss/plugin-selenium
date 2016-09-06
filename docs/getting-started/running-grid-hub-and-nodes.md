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

If you started a Selenium Hub locally, and you want your node to be able to register in it, you'll have to link both containers.

`athena info` command will list all the runnig containers.

```bash
$ athena info
       ___   __  __
      /   | / /_/ /_  ___  ____  ____ _
     / /| |/ __/ __ \/ _ \/ __ \/ __  /
    / ___ / /_/ / / /  __/ / / / /_/ /
   /_/  |_\__/_/ /_/\___/_/ /_/\__,_/
                              v0.4.0
  ==================================

[INFO] Running containers [image|container|status]:

 * selenium/hub  athena-selenium-hub-default-0  [UP]
```

Now we use the container name:

```bash
$ athena selenium start firefox 2.53.0 --link=athena-selenium-hub-default-0:hub
```

# Expose Grid Hub or Nodes Port

You can optionally expose component port number by setting `--port=<port>` to publish externally under `<port>` number.

```bash
$ athena selenium start hub 2.53.0 --port=5001
```

```bash
$ athena selenium start firefox 2.53.0 --port=5001
```

**NOTE:** This setting is available for all nodes and the hub.

# Versions

A list of available versions for both hub and nodes, can be found in official Selenium Docker Hub page.

* https://hub.docker.com/r/selenium/hub/tags/
* https://hub.docker.com/r/selenium/node-firefox/tags/
* https://hub.docker.com/r/selenium/node-chrome/tags/

