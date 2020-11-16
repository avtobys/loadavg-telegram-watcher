# loadavg-telegram-watcher
monitors loadavg and sends problem messages to Telegram

place this script in the directory /etc/cron.d and get messages about the load

\* \* \* \* \* root (AVG_MAX=0.5;BOT_ID="your_telegram_bot_id";CHAT_ID="your_chat_id";AVG=$(awk -v avg_max=${AVG_MAX} '$1>avg_max{print $1}' /proc/loadavg);if [ -n "$AVG" ]; then curl -L "https://api.telegram.org/bot$BOT_ID/sendMessage?chat_id=$CHAT_ID&parse_mode=html&text=HIGH AVG: $AVG";sleep 61s;AVG=$(awk -v avg_max=${AVG_MAX} '$1<=avg_max{print $1}' /proc/loadavg);if [ -n "$AVG" ]; then curl -L "https://api.telegram.org/bot$BOT_ID/sendMessage?chat_id=$CHAT_ID&parse_mode=html&text=NORMAL AVG: $AVG";fi;fi;) > /dev/null 2>&1
