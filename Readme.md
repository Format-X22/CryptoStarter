Opal for frontend JS compile:

    opal -I ./opal -g opal-jquery -c opal/Main.rb > public/js/all.js

For html use Pug compiler (like RubyMine pug/jade watcher) with --pretty flag.

ENV vars:
- SENDGRID_API_KEY - key for mailer
- TEAM_EMAIL - mail-target for pre-registration data