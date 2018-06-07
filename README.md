# TTS_discord_bot
WIP

# Installation
1. Fork and clone the repo
2. Run ``sh install.sh`` to install dependencies  
(or install Luvit and Discordia on your own)
3. Create a new app (a bot) on https://discordapp.com/developers/applications/me/
4. Copy its token and save it as a text in a ``token.dat`` file in the project dir
5. (optional) Create a ``elevated_users.txt`` file with your Discord name#tag for admin commands to work
6. Add/invite your bot to your testing server (you need permissions on it, create your own if you need to)
7. Run ``./luvit bot.lua``
8. Type ``!ping`` to see if it's alive

# Convenience for remote work
* You can install ``immortal`` (https://immortal.run/) and run ``immortal -c immortal-bot`` to automatically restart the bot  
* You can then push to your repo and tell the bot ``!update`` to make it pull the changes (safe, FF only), exit and be restarted by immortal  
* ``bot_runtime.log`` (while still rough) can give you some insight on what's going on in an immortal-started bot
