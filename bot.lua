local discordia = require('discordia')
local fs = require('fs')
local client = discordia.Client()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)


client:on('messageCreate', function(message)
    if message.content == '!ping' then
        message.channel:send('Pong!')
    end

    if message.content == '!quit' then
        message.channel:send('Exiting....')
        os.exit()
    end

    if message.content == '!update' then
        message.channel:send('Updating...')
        local p, err = io.popen('git pull --ff-only')
        if not p then
            message.channel:send('Error executing pull: ``' .. err .. '``')
            return
        end
        message.channel:send('```\n' .. p:read('*all') .. '\n```')
        message.channel:send('Restarting....')
        os.exit()
    end
    
    if message.content == '!woo' then
        message.channel:send('Wee')
    end

end)

client:run(fs.readFileSync('token.dat'))

