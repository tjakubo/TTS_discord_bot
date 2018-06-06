-- Command for running arbitrary Lua code in a sandbox
-- Dumps any print calls from the code
-- If executed with no command body (just "!run"), tries to run the body of a previous message


-- which global names are available in sandboxed script
local whitelist = {
    'coroutine', 'assert', 'tostring', 'tonumber',
    'pairs', 'ipairs', 'pcall', 'bit', 'error',
    'string', 'unpack', 'table', 'next', 'math',
    'select', 'type', 'setmetatable', 'getmetatable'
}
-- error for when the script is taking too long
local function timeoutError()
    error('Script timed out (infinite loop?)')
end

-- Attempt to run a string script
-- Return: success (bool), message (string)
local function sandbox(script)
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
        return false, 'Load error:\n' .. err:wrap()
    end
    
    -- set the env and execute the script
    jit.off()
    setfenv(fcn, sandboxEnv)
    debug.sethook(timeoutError, '', 1e8)
    local res, err = pcall(fcn)
    debug.sethook()
    jit.on()
    
    if not res then
        return false, 'Runtime error:\n' .. err:wrap()
    end
    
    local strOutput = table.concat(output, '\n')
    return true, strOutput:len() > 0 and ('Output:\n' .. strOutput:wrap()) or ('No output')
end

-- Find a code block in a message string, at worst just run the body
local function findCode(str)
    return str:match('```lua(.-)```') or str:match('```(.-)```') or str:match('``(.-)``') or str
end


local function commandFunction(body, messageObj)
    local script = nil
    -- Get the script body from the same message, previus if empty
    if body:len() > 0 then
        script = findCode(body)
    else
        local prevMsg = messageObj.channel:getMessagesBefore(messageObj.id, 1):iter()()
        if prevMsg then
            script = findCode(prevMsg.content)
        end
    end
    if not script then 
        return false
    end
    
    -- Run the script and print results
    local res, out = sandbox(script)
    messageObj.channel:send(out)
    -- Tag the command with an emoji cause why not
    if res then
        messageObj:addReaction('\u{2705}') -- check mark
    else
        messageObj:addReaction('\u{274C}') -- cross mark
    end
    return res
end

return {'run', commandFunction, false}