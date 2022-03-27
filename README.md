# Bombermin #

Unofficial Roku app for browsing Giant Bomb.

Advantages over the official app:

+ Search function
+ Saves/loads video position crossplatform
+ Pagination for shows

## Installing ##

Unfortunately Roku no longer allows users to easily sideload channels with a code, which was previously how people were installing this channel.

Unless I can get it approved/on the store, I think the only way to install is the following:

1. Download the latest release zip from [here](https://github.com/bananaoomarang/bombermin/releases/tag/v2.2.0), the file should be called something like 'bombermin-<version-number>.zip'.
1. Follow these instructions to sideload the application: [instructions here](https://blog.roku.com/developer/developer-setup-guide).

This should allow you to install the channel on your device. It may seem weird but this is how Roku enables developers to load/test their own applications so it should be perfectly safe.

Note that using this new workaround method to install the channel you will not automatically receive updates, if there is a new release you will have to download the new zip file manually and reload it.

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
