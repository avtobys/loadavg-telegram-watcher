# loadavg-telegram-watcher
monitors the load average server and in case of problems sends problem messages to Telegram, sends paste to pastebin.com with info of user processes sorted by cpu usage and current processlist mysql. Pastebin link is included in the telegram message.

easy install with customization:

\# bash <(curl -s https://raw.githubusercontent.com/avtobys/loadavg-telegram-watcher/main/install.sh)

places this script to /usr/local/bin/loadavg_watcher  
places the cron task to /etc/cron.d

![alt text](https://i.imgur.com/ZciVBcm.jpg)

complete!

* Tested on Debian Linux
