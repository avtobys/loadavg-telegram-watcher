# loadavg-telegram-watcher
monitors the load average server and in case of problems sends problem messages to Telegram, sends paste to pastebin.com with info of user processes sorted by cpu usage and current processlist mysql. Pastebin link is included in the telegram message.

easy install with customization:

\# bash <(curl -s https://raw.githubusercontent.com/avtobys/loadavg-telegram-watcher/main/install.sh)

automatic places this script to /usr/local/bin/loadavg_watcher  
automatic places places the cron task to /etc/cron.d/loadavg_watcher

![plot](img/1.png)

complete!

* Tested on Debian Linux

\# yes > /dev/null
