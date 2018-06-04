-- which global names are available in sandboxed script
local whitelist = {
    'coroutine', 'assert', 'tostring', 'tonumber',
    'pairs', 'ipairs', 'pcall', 'bit', 'error',
    'string', 'unpack', 'table', 'next', 'math',
    'select', 'type', 'setmetatable', 'getmetatable'
}

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

local function commandFunction(body, message)
    local script = body:match('```lua(.-)```') or body:match('```(.-)```') or body:match('``(.-)``') or body
    if body:len() == 0 then
        message.channel:send('Code not found in the !exec message. Make sure to wrap it in three backtics (`).')
        return false
    end
    local res, out = sandbox(script)
    message.channel:send(out)
    return res
end

return {'exec', commandFunction, false}