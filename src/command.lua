local cmd = {}
cmd.prefix = '!'

function cmd.hasCommand(msgString)
    return msgString:find('^' .. cmd.prefix)
end

function cmd.getCommand(msgString)
    if not cmd.hasCommand(msgString) then
        return
    end
    local command, body = msgString:match('^' .. cmd.prefix .. '(%S+)(.-)$')
    body = body:match('^%s*(.-)%s*$')
    return command, body
end

cmd.commands = {
    regular = {},
    admin = {}
}
local cmds = cmd.commands

function cmd.addCommand(name, callback, adminOnly)
    local target = adminOnly and cmds.admin or cmds.regular
    assert(not target[name], 'Trying to add \'' .. name .. '\' command twice')
    target[name] = callback
end

local commandsPath = 'src/commands/'
function cmd.loadCommand(filename)
    cmd.addCommand( unpack(require(commandsPath .. filename)) )
end

function cmd.isElevatedUser(userObject)
    if not fs.existsSync('elevated_users.txt') then
        return false
    end
    local elevatedUsers = fs.readFileSync('elevated_users.txt')
    return elevatedUsers:find(userObject.fullname, 1, true) ~= nil
end

function cmd.handleMessage(msgObject)
    
    if cmd.hasCommand(msgObject.content) then
        local command, body = cmd.getCommand(msgObject.content)
        
        if cmds.admin[command] and cmd.isElevatedUser(msgObject.author) then
            return true, cmds.admin[command](body, msgObject)
        elseif cmds[command] then
            return true, cmds.regular[command](body, msgObject)
        end
    end
    return false
end

return cmd

