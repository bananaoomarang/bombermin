# Giant Bomber #

## Development ##

You will need to provide an API key:

1. Copy `src/main/constants.yaml.example` => `src/main/constants.yaml`
2. Fill in GB API key from https://www.giantbomb.com/api/

Next you will need to setup your Roku device [like so](https://blog.roku.com/developer/developer-setup-guide).

Just install ukor by running `npm i` in the project (you will need node/NPM installed on machine), then to build/install:

```
$ npm run install -- <device-ip> --auth=<username>:<password>
```

You can connect to the device logs/debug interface with `telnet` (or presumably whatever):

```
$ telnet <device-ip> 8085
```

Have fun!
