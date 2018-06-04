local discordia = require('discordia')
local fs = require('fs')
local client = discordia.Client()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

do
    local sandboxEnv = {}
    
    function sandbox(script)
        local output = {}
        sandboxEnv.print = function(...)
            local o = {...}
            for k in pairs(o) do o[k] = tostring(o[k]) end
            output[#output+1] = table.concat(o, '\t')
        end
        
        local fcn, err = loadstring(script)
        if not fcn then
            return false, 'Load error:\n' .. err
        end
        
        setfenv(fcn, sandboxEnv)
        local res, err = pcall(fcn)
        if not res then
            return false, 'Runtime error:\n' .. err
        end
        return true, table.concat(output, '\n')
    end
end

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
    
    if message.content:find('^!exec') then
        local script = message.content:match('```lua(.-)```') or message.content:match('```(.-)```')
        if not script then
            message.channel:send('Code not found in the !exec message. Make sure to wrap it in three backtics (`).')
            return
        end
        local res, out = sandbox(script)
        message.channel:send(out)
    end

end)

client:run(fs.readFileSync('token.dat'))

