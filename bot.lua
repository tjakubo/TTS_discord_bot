local discordia = require('discordia')
local client = discordia.Client()

-- Globals
fs = require('fs')
log = require('log')
log.outfile = 'bot_runtime.log'
require('src/util')


-- Commands
local cmd = require('src/command')
cmd.loadCommand('example')
cmd.loadCommand('run')
cmd.loadCommand('update')

-- When the bot comes online
client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

-- On any message seen by bot
client:on('messageCreate', function(message)
    
    -- So I can easily see if it's alive
    if message.content == '!ping' then
        message.channel:send('Pong!')
    end

    -- Handle any explicit commands
    local cmdRan, result = cmd.handleMessage(message)
    if cmdRan and result then
        log.info(result)
    end
end)

-- Run the bot
assert(fs.existsSync('token.dat'), 'No bot token file found. Create a \'token.dat\' file containing it and try again.')
client:run(fs.readFileSync('token.dat'))

