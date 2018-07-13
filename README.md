# Enumivo Auto Claim bash script
* I recommend to use this script outside your BP node. If so I fully recommend to
do it over a secured connection since you have to send your wallet's pass to your
BP (or any other BP) node to be processed.

The sript will help you claim your ENU coins once a day. It gets executed once a
day by cron and it stays in a loop checking if the claim is possible. After it's
done all tokens from your wallet get staked automatically 50% to CPU and 50% to
network.
# How to use it
* Script configuration. You have some variables that needs to be changed inside
the script and I will describe them below:
- wallet: Your wallet name. If you have not specified any you should use: default
- enucli: is your wallet binary followed by your node or a public node. You should
use absolute path to your enucli binary that it is compiled with the the rest of
the software. Follow my example.
- keep: should be substracted from the claimed tokens. The rest will be
automatically staken 50% / 50% for CPU / NET. If you want to keep them all in
your wallet just configure it with a value higher than your regular claim. 1000
for instance
- bot_token: represents your bot ID. IF you want to use my bot just ping me and
I will share the details with you. If not you can simply create your own bot. To
do so you simply start a chat with  
- chat_id: You will need a chat ID in order to allow the bot to send messages to
you. To do that you talk to your bot /start it's a good thing to start with. Then
you check the following url:
https://api.telegram.org/bot<your Bot ID 12345678:LettersNumbers>/getUpdates
There you will find the chat id you had with your username.
telechat: IF you want to disable the chat just change it to 0.
* Crontab configuration. You should use the cron_entry file found in the repo
There's a small description inside it. IF you have any problems ping me.
To enter something in crontab: crontab -e
