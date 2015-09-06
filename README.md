# zk-balance

### What?

This is a NodeJS app that polls github for ZK commits, and calculates balance changes introduced by each commit (using black magic and lua shell-outs). This information is presented in an AngularJS frontend for easy viewing

### Hacking

##### Requirements

You will need:

  - [NodeJS](https://nodejs.org/download/)
  - [Lua](http://www.lua.org/download.html)
  - [Git](https://git-scm.com/downloads)
  - [A modern web browser](https://www.google.com/chrome/browser/desktop/)

##### Getting Started

With your tools in hand, we head to the terminal:

```
$ git clone https://github.com/kaen/zk-balance.git
$ cd zk-balance
$ npm install .
$ sudo npm install -g sails
```

If everything runs smoothly, we just need to bootstrap the Github data.

##### Bootstrapping Git Data

1. Make sure you have `git` and `grunt` somewhere in your path
2. Run `grunt ingest`
3. Hold `Ctrl+C` to kill grunt when you get bored (`pkill -9 -f node` may be necessary on slow rigs)
4. All set! Now type `sails lift` and go to http://localhost:1337/ to start hacking :)

### Docker

To test locally in an environment identical to the production server, install [Docker](https://docs.docker.com/installation/) and simply run:

`$ ./ops/run-in-docker.sh`

Then use `docker ps` to see which port Docker was bound to. Data is automatically refreshed in the production environment.

### Static Build

This project can be built statically. You will need to have `grunt` and `lua` somewhere in your `$PATH`. You may also need to configure `config/github.coffee` as shown in `config/github.coffee.example` if you are fetching unit data frequently. 

```
grunt fetch --prod
grunt static --prod
```

The results can be found in `www/`. Due to the use of XHR, the build currently only runs behind some sort of webserver (i.e. testing via `file://` will fail).

##### Further Reading

You may want to read up on the stack:

- NodeJS
- SailsJS
- AngularJS
- Twitter Bootstrap
- Waterline
- Bluebird
