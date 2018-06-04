local discordia = require('discordia')
local fs = require('fs')
local client = discordia.Client()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

-- wrap a message as Discord code block
local function wrap(msg)
    return '```\n' .. msg .. '\n```'
end
    
do
    -- which global names are available in sandboxed script
    local whitelist = {
        'coroutine', 'assert', 'tostring', 'tonumber',
        'pairs', 'ipairs', 'pcall', 'bit', 'error',
        'string', 'unpack', 'table', 'next', 'math',
        'select', 'type', 'setmetatable', 'getmetatable'
    }
    
    -- Attempt to run a string script
    -- Return: success (bool), message (string)
    function sandbox(script)
        -- set up script sandbox
        local sandboxEnv = {}
        for _,name in pairs(whitelist) do
            sandboxEnv[name] = _G[name]
        end
    
        -- set up print function to capture output
        local output = {}
        sandboxEnv.print = function(...)
            local o = {...}
            if not next(o) then
                o[1] = 'nil'
            end
            for k in pairs(o) do o[k] = tostring(o[k]) end
            output[#output+1] = table.concat(o, '\t')
        end
        
        -- load the script
        local fcn, err = loadstring(script)
        if not fcn then
            return false, 'Load error:\n' .. wrap(err)
        end
        
        -- set the env and execute the script
        setfenv(fcn, sandboxEnv)
        local res, err = pcall(fcn)
        if not res then
            return false, 'Runtime error:\n' .. wrap(err)
        end
        
        local strOutput = table.concat(output, '\n')
        return true, strOutput:len() > 0 and ('Output:\n' .. wrap(strOutput)) or ('No output')
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
        p, err = io.popen('git log master..origin/master --pretty=format:"%h: %s, commited by %cn (%ce)"')
        if not p then
            message.channel:send('Error performing log: ``' .. err .. '``')
            return
        else
            local log = p:read('*all')
            if log:len() > 0 then
                message.channel:send( wrap(log) )
            end
            p:close()
        end
        
        -- pull and report results
        p, err = io.popen('git pull --ff-only')
        if not p then
            message.channel:send('Error executing pull: ``' .. err .. '``')
            return
        else
            message.channel:send( wrap(p:read('*all')) )
            message.channel:send('Restarting....')
            os.exit()
            p:close()
        end
    end
    
    if message.content == '!woo' then
        message.channel:send('Weeaaough')
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

