# Selenium Plugin

This plugin provides a straightforward API (cli and programatically) to handle browser automation using [Selenium](http://www.seleniumhq.org/).

It supports management of Selenium components such as the Grid Hub as well as the Browser Nodes (Firefox, Chrome) and PhantomJs.

You can easily use this plugin in your local development machine or in a CI/CD pipeline.

## How to Install ?

To install it simply run the following command :

```bash
$ athena plugins install selenium https://github.com/athena-oss/plugin-selenium.git
```

or

* On MAC OSX using [Homebrew](http://brew.sh/) :
```bash
$ brew tap athena-oss/plugin-selenium
$ brew install plugin-selenium
```

Read the [Documentation](http://athena-oss.github.io/plugin-selenium) on using Athena.

## How to Use ?

This plugin provides the following commands :

### start - starts the components

```bash
$ athena selenium start <type> <version> [--port=<port>|--instances=<nr_of_instances>] [<docker_options>...]
```
  * type : hub, firefox, firefox-debug, chrome, chrome-debug, phantomjs
  * version : 2.49.1, etc...
  * --port : specifies which port to be exposed on the host machine
  * --instances : specifies how many instances should be started

### stop - stops the components

```bash
$ athena selenium stop <all|type> [--port=<port>|--instance=<instance_nr>]

$ # e.g. stop hub
$ athena selenium stop hub
```

### logs - shows the logs of the components

```bash
$ athena selenium logs <type|component_name> [--port=<port>|--instance=<instance_nr>]

$ # e.g. 'athena info' shows running 'athena-selenium-hub-default'
$ athena selenium logs hub

$ # e.g. 'athena info' shows running 'athena-node-firefox-4441'
$ athena selenium logs firefox 4441
$ # or also possible
$ athena selenium logs athena-node-firefox-4441
```

### terminal - connects to the terminal of the component

```bash
$ athena selenium terminal <type|component_name> [--port=<port>|--instance=<instance_nr>]

$ # e.g. 'athena info' shows running 'athena-selenium-hub-default'
$ athena selenium terminal hub

$ # e.g. 'athena info' shows running 'athena-node-firefox-4441'
$ athena selenium terminal firefox 4441
$ # or also possible
$ athena selenium terminal athena-node-firefox-4441
```

### cleanup - removes the component(s) from the host machine

```bash
$ athena selenium cleanup <all|type>
```

## Contributing

Checkout our guidelines on how to contribute in [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

Releases are managed using github's release feature. We use [Semantic Versioning](http://semver.org) for all
the releases. Every change made to the code base will be referred to in the release notes (except for
cleanups and refactorings).

## License

Licensed under the [Apache License Version 2.0 (APLv2)](LICENSE).
