# Bombermin #

Unofficial Roku app for browsing Giantbomb. Still very much work in progress!

Advantages over the official app:

+ Search function
+ Saves/loads video position crossplatform
+ Pagination for shows

Still needs:

+ Pagination for search
+ A lot of UI work (right now it is pretty much stock Roku components + some parts are pretty janky)
+ A logo! (currently it is just the Roku placeholder art)

Mainly want to figure out a logo and a better flow for logging in/out, then will try to 'release' in some fashion that doesn't require compiling/sideloading.

## Development ##

First setup your Roku device [like so](https://blog.roku.com/developer/developer-setup-guide).

Just install ukor by running `npm i` in the project (you will need node/NPM installed on machine), then to build/install:

```
$ npm run install -- <device-ip> --auth=<username>:<password>
```

You can connect to the device logs/debug interface with `telnet` (or presumably whatever):

```
$ telnet <device-ip> 8085
```

Have fun!
