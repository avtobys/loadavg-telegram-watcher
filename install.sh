#!/bin/bash

if [ ! -d "/usr/local/bin" ]; then
    printf "\033[0;31mNo such directory /usr/local/bin\033[0m\n"
    exit 1
fi

if [ ! -d "/etc/cron.d" ]; then
    printf "\033[0;31mNo such directory /etc/cron.d\033[0m\n"
    exit 1
fi


[ -z "${IP:=$(curl -s -m1 checkip.amazonaws.com)}" ] && [ -z "${IP:=$(curl -s -m1 ident.me)}" ] && [ -z "${IP:=$(curl -s -m1 ipinfo.io/ip)}" ]

RECOMM=$(awk 'function ceil(x){return int(x)+(x>int(x))} {print ceil($0*1.3)}' <<< $(nproc))

printf "Welcome to install programm loadavg telegram watcher! \n\nNumber processors of this computer[$IP]: $(nproc) \nRecommended max load average value: $RECOMM\n\n"

if [ -z "$AVG_MAX" ]; then
    echo -n 'Enter setting value for the maximum load average for 1 minute(0 = recommended): '
    read AVG_MAX
fi

if [ "$AVG_MAX" = "0" -o -z "$AVG_MAX" ]; then
    AVG_MAX=$RECOMM
fi

if [[ ! "$AVG_MAX" =~ ^[0-9]+$ ]]; then
    AVG_MAX=$RECOMM
fi

echo ${SET_AVG_MAX:="Max load average set: $AVG_MAX"}

install_telegram() {
    if [ -z "$BOT_ID" ]; then
        echo -n 'Enter your telegram bot token: '
        read BOT_ID
    fi
    echo ${SET_BOT_ID:="Telegram bot token set: $BOT_ID"}
    if [ -z "$CHAT_ID" ]; then
        echo -n 'Enter your telegram chat id: '
        read CHAT_ID
    fi
    echo ${SET_CHAT_ID:="Telegram chat id set: $CHAT_ID"}
    TG_URL="https://api.telegram.org/bot$BOT_ID/sendMessage"
    N=$'\n'
    TG_RES=$(curl -s -X POST \
        --data "chat_id=$CHAT_ID&parse_mode=html&text=$IP $N Settings are almost ready $N $SET_AVG_MAX $N $SET_BOT_ID $N $SET_CHAT_ID" $TG_URL |
        sed -r 's/.*"ok"[[:space:]]*:[[:space:]]*(true)[[:space:]]*,[[:space:]]*"result".*/\1/')
    if [ "$TG_RES" != "true" ]; then
        BOT_ID=
        CHAT_ID=
        SET_BOT_ID=
        SET_CHAT_ID=
        printf "\033[0;31mTelegram bot token or chat id is wrong...\033[0m\n"
        return 1
    else
        return 0
    fi
}


while ! install_telegram; do
    true
done

if [ -z "$PASTE_KEY" ]; then
    echo -n 'Enter your pastebin.com api developer key(optional): '
    read PASTE_KEY
fi

echo "Pastebin developer token set: $PASTE_KEY"

if [ $(command -v ps) ]; then
    echo "ps: ok"
else
    printf "\033[0;31mCommand ps not found\033[0m\n"
    exit 1
fi

echo -n "mysqladmin: "
if [ $(command -v mysqladmin) ]; then
    echo "ok"
else
    echo "fail"
fi

echo -n "iotop: "
if [ $(command -v iotop) ]; then
    echo "ok"
else
    echo "fail"
fi

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

echo $SCRIPT >/usr/local/bin/loadavg_watcher
chmod +x /usr/local/bin/loadavg_watcher
echo '* * * * * root /usr/local/bin/loadavg_watcher > /dev/null 2>&1' >/etc/cron.d/loadavg_watcher
echo "Installation completed successfully!"
exit 0
