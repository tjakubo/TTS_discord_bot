function string.trim(str)
    return str:match('%s*(.-)%s*')
end

function string.wrap(str)
    return '``' .. str .. '``'
end

function string.blockWrap(str)
    return '```\n' .. str .. '\n```'
end

function string.bold(str)
    return '**' .. str .. '**'
end

function string.italic(str)
    return '*' .. str .. '*'
end