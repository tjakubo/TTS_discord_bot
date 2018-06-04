local discordia = require('discordia')
local client = discordia.Client()

-- Globals
fs = require('fs')
require('src/util')

-- Commands
local cmd = require('src/command')
cmd.loadCommand('example')
cmd.loadCommand('exec')

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
    cmd.handleMessage(message)
        
    if message.content == '!ping' then
        message.channel:send('Pong!')
    end

    if message.content == '!quit' then
        message.channel:send('Exiting....')
        os.exit()
    end

    if message.content == '!update' then
        message.channel:send('Updating...')
        
        -- fetch remote
        local p, err = io.popen('git fetch origin')
        if not p then
            message.channel:send('Error fetching origin: ``' .. err .. '``')
            return
        else
            p:read('*all')
            p:close()
        end
        
        -- check for commits ahead, report if there are any
        p, err = io.popen('git log master..origin/master --pretty=format:"%h: %s, committed by %cn (%ce)"')
        if not p then
            message.channel:send('Error performing log: ``' .. err .. '``')
            return
        else
            local log = p:read('*all')
            if log:len() > 0 then
                message.channel:send( log:blockWrap() )
            end
            p:close()
        end
        
        -- pull and report results
        p, err = io.popen('git pull --ff-only')
        if not p then
            message.channel:send('Error executing pull: ``' .. err .. '``')
            return
        else
            message.channel:send( p:read('*all'):blockWrap() )
            message.channel:send('Restarting....')
            os.exit()
            p:close()
        end
    end
    
    if message.content == '!woo' then
        message.channel:send('Weeaough')
    end

end)

client:run(fs.readFileSync('token.dat'))

