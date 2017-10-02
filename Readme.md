### CryptoStarter platform
Main site demo: [demo.cryptostarter.io](https://demo.cryptostarter.io) 
ICO site: [cryptostarter.io](https://cryptostarter.io)

***

Branches:

- **master** - ICO site before release, main site after release
- **develop** - main site before release, unstable main site after release
- **token** *(and token branches)* - token code before release

Frontend JS compile:

    opal -I ./opal -g opal-jquery -c opal/Main.rb > public/js/all.js

Frontend HTML compile - pug compiler/watcher with `--pretty` flag.

ENV vars:
- **SENDGRID_API_KEY** - key for mailer (ICO only for now)
- **TEAM_EMAIL** - mail-target for pre-registration data (ICO only for now)