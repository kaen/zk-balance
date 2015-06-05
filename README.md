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

##### Bootstrapping Github Data

1. Copy `config/github.coffee.example` to `config/github.coffee`
2. Edit `config/github.coffee` to contain your github login
3. run `sails c`, which will print a picture of a sailboat and bring you to the SailsJS prompt.
4. At the prompt enter: `github.refreshGithubData()`
5. You should see units being loaded, followed by commit data and balance change crunching.
6. Allow this to run for a bit (10-20 minutes is ideal, it may take an hour or more to complete by itself)
7. Hold `Ctrl+C` to kill sails when you get bored (`pkill -9 -f node` may be necessary on slow rigs)
8. All set! Now type `sails lift` and go to http://localhost:1337/ to start hacking :)

##### Docker

To test locally in an environment identical to the production server, install [Docker](https://docs.docker.com/installation/) and simply run:

`$ ./ops/run-in-docker.sh`

Then use `docker ps` to see which port Docker was bound to. Data is automatically refreshed in the production environment.

##### Further Reading

You may want to read up on the stack:

- NodeJS
- SailsJS
- AngularJS
- Twitter Bootstrap
- Waterline
- Bluebird
