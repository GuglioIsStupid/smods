local lovely = {}
local path = ... .. "."
local pathSlashes = path:gsub("%.", "/")
local TOML = require(path .. "toml")

lovely.mod_dir = love.filesystem.getSaveDirectory() .. "/Mods"
love.filesystem.createDirectory("Patched")

local tomlFiles = {}
for i, file in ipairs(love.filesystem.getDirectoryItems(pathSlashes)) do
    if file:sub(-5) == ".toml" then
        table.insert(tomlFiles, file)
    end
end

local function parseToml(file, forcedDir)
    forcedDir = forcedDir or pathSlashes
    local txt = love.filesystem.read(forcedDir .. "/" .. file)
    local mod = TOML(txt)

    local manifest = mod.manifest
    local patches = mod.patches
    for i, v in ipairs(patches) do
        for k, regex in ipairs(v.regex) do
            local target = regex.target
            local pattern = regex.pattern
            -- replace <indent> with \t
            local position = regex.position:gsub("<indent>", '\t')
            local match_indent = regex.match_indent
            local line_prepend = regex.line_prepend
            local payload = regex.payload
            local targetFile = love.filesystem.read(target)

            local newFile = targetFile:gsub(pattern, function(match)
                if position == "before" then
                    return line_prepend .. payload .. match
                elseif position == "after" then
                    return match .. line_prepend .. payload
                end
            end)

            love.filesystem.write("Patches/" .. target, newFile)
        end
    end
end

for i, file in ipairs(tomlFiles) do
    parseToml(file, "smods/lovely/")
end

local function recursiveLoadLua(directory)
    for _, file in ipairs(love.filesystem.getDirectoryItems(directory)) do
        if love.filesystem.getInfo(directory .. "/" .. file).type == "directory" then
            recursiveLoadLua(directory .. "/" .. file)
        else
            if file:sub(-4) == ".lua" then
                love.filesystem.load(directory .. "/" .. file)()
            end
        end
    end
end

tomlFiles = {}

function lovely.getAllMods()
    for _, mod in ipairs(love.filesystem.getDirectoryItems(lovely.mod_dir)) do
        if love.filesystem.getInfo(lovely.mod_dir .. "/" .. mod).type == "directory" then
            print("Mod: " .. mod)
            local tomlFiles = {}
            for i, file in ipairs(love.filesystem.getDirectoryItems(lovely.mod_dir .. "/" .. mod)) do
                if file:sub(-5) == ".toml" then
                    table.insert(tomlFiles, mod .. "/" .. file)
                end

                -- load all lua files
                recursiveLoadLua(lovely.mod_dir .. "/" .. mod)
            end
        else
            love.filesystem.load(lovely.mod_dir .. "/" .. mod)()
        end
    end

    for i, file in ipairs(tomlFiles) do
        parseToml(file)
    end
end

return lovely