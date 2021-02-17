#!/bin/bash

install_la() {
    printf "Welcome to install programm loadavg telegram watcher! \nNumber processors of this computer: $(nproc) \n Recommended max load average value: $(nproc)\n\n"
    echo -n 'Enter setting value for the maximum load average for 1 minute: '
    read AVG_MAX
    if (($(($AVG_MAX * 1)) > 0)); then
        SET_AVG_MAX="Max load average for 1 minute set: $AVG_MAX"
        printf "$SET_AVG_MAX\n\n"
    else
        printf "\033[0;31mOnly integer values > 0...\033[0m\n"
        install_la
    fi
}

install_telegram() {
    echo -n 'Enter your telegram bot token: '
    read BOT_ID
    SET_BOT_ID="Telegram bot token set: $BOT_ID"
    printf "$SET_BOT_ID\n\n"
    echo -n 'Enter your telegram chat id: '
    read CHAT_ID
    SET_CHAT_ID="Telegram chat id set: $CHAT_ID"
    TG_URL="https://api.telegram.org/bot$BOT_ID/sendMessage"
    printf "$SET_CHAT_ID\n\n"
    if [ $(command -v ip) ]; then
        IP=$(ip route get 8.8.8.8 | grep src | awk '{print $NF}')
    fi
    N=$'\n'
    TG_RES=$(curl -s -X POST \
        --data "chat_id=$CHAT_ID&parse_mode=html&text=$IP $N Settings are almost ready $N $SET_AVG_MAX $N $SET_BOT_ID $N $SET_CHAT_ID" $TG_URL |
        sed -r 's/.*"ok"[[:space:]]*:[[:space:]]*(true)[[:space:]]*,[[:space:]]*"result".*/\1/')
    if [ "$TG_RES" != "true" ]; then
        printf "\033[0;31mTelegram bot token or chat id is wrong...\033[0m\n"
        install_telegram
    fi
}

install_la
install_telegram
echo -n 'Enter your pastebin.com api developer key(optional): '
read PASTE_KEY
printf "Pastebin developer token set: $PASTE_KEY\n\n"

IFS=""

SCRIPT=$(curl -s https://raw.githubusercontent.com/avtobys/loadavg-telegram-watcher/main/loadavg_watcher |
    sed -r "s/AVG_MAX=([0-9]+)/AVG_MAX=$AVG_MAX/" |
    sed -r "s/BOT_ID=\"[^\"]+\"/BOT_ID=\"$BOT_ID\"/" |
    sed -r "s/CHAT_ID=\"[^\"]+\"/CHAT_ID=\"$CHAT_ID\"/" |
    sed -r "s/PASTE_KEY=\"[^\"]+\"/PASTE_KEY=\"$PASTE_KEY\"/")

if [ "$(echo $SCRIPT | sed -n 's/.*\(successful installation marker\).*/\1/ip;T;q')" != "successful installation marker" ]; then
    printf "\033[0;31mCan't load script https://raw.githubusercontent.com/avtobys/loadavg-telegram-watcher/main/loadavg_watcher\033[0m\n"
    exit 1
fi

if [ ! -d "/usr/local/bin" ]; then
    printf "\033[0;31mNo such directory /usr/local/bin\033[0m\n"
    exit 1
fi

if [ ! -d "/etc/cron.d" ]; then
    printf "\033[0;31mNo such directory /etc/cron.d\033[0m\n"
    exit 1
fi

echo $SCRIPT > /usr/local/bin/loadavg_watcher
chmod +x /usr/local/bin/loadavg_watcher
echo '* * * * * root /usr/local/bin/loadavg_watcher > /dev/null 2>&1' > /etc/cron.d/loadavg_watcher
echo 'Installation completed successfully!'
exit 0
