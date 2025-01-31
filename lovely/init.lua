local lovely = {}
local path = ... .. "."
local pathSlashes = path:gsub("%.", "/")

lovely.mod_dir = love.filesystem.getSaveDirectory() .. "/Mods"
love.filesystem.createDirectory("Patched")

local configFiles = {}
for i, file in ipairs(love.filesystem.getDirectoryItems("smods/lovely/")) do
    -- if file ends with .config.lua
    if file:match(".config.lua$") then
        table.insert(configFiles, love.filesystem.load("smods/lovely/" .. file)())
    end
end

local oldRead = love.filesystem.read
function love.filesystem.read(path)
    if love.filesystem.getInfo("Patched/" .. path) then
        return oldRead("Patched/" .. path)
    else
        return oldRead(path)
    end
end

table.sort(configFiles, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
end)

local function parseConfigFile(file, forceDir)
    forceDir = forceDir or "smods/lovely/"

    print("Parsing with priority " .. (file.priority or 0), "and version " .. (file.version or "unknown"), " with " .. #file.patches .. " patches")
    for _, patch in ipairs(file.patches) do
        local target = (patch.regex or patch.pattern).target or ""
        local pattern = (patch.regex or patch.pattern).pattern or ""
        local position = (patch.regex or patch.pattern).position or "at"
        local line_prepend = (patch.regex or patch.pattern).line_prepend or ""
        local findSpecificFunction = (patch.regex or patch.pattern).findSpecificFunction or false
        local payload = patch.payload

        local file = love.filesystem.read(target)
        local indent = file:match("^([ \t]*)")

        print(pattern)
        --[[ local newFile = file:gsub(pattern, function(match)
            if position == "before" then
                return payload .. "\n" .. indent .. match
            elseif position == "after" then
                return match .. "\n" .. indent .. payload
            elseif position == "at" then
                -- Do not include the match
                return payload
            end
        end) ]]

        -- if theres findSpecificFunction, then it can ONLY replace exacts inside the lua function
        if findSpecificFunction then
            local function findFunction(file, functionName)
                local functionStart = file:find("function " .. functionName .. "%(")
                if not functionStart then
                    return nil
                end
                local functionEnd = file:find("end", functionStart)
                if not functionEnd then
                    return nil
                end
                return file:sub(functionStart, functionEnd)
            end

            local function replaceFunction(file, functionName, payload)
                local functionStart = file:find("function " .. functionName .. "%(")
                if not functionStart then
                    return file
                end
                local functionEnd = file:find("end", functionStart)
                if not functionEnd then
                    return file
                end
                return file:sub(1, functionStart - 1) .. payload .. file:sub(functionEnd + 1)
            end

            local functionName = findSpecificFunction
            local functionContents = findFunction(file, functionName)
            if functionContents then
                local newFunctionContents = functionContents:gsub(pattern, function(match)
                    if position == "before" then
                        return payload .. "\n" .. indent .. match
                    elseif position == "after" then
                        return match .. "\n" .. indent .. payload
                    elseif position == "at" then
                        -- Do not include the match
                        return payload
                    end
                end)
                newFile = replaceFunction(file, functionName, newFunctionContents)
            else
                print("Could not find function " .. functionName)
                newFile = file
            end
        else
            print(pattern)
            newFile = file:gsub(pattern, function(match)
                if position == "before" then
                    return payload .. "\n" .. indent .. match
                elseif position == "after" then
                    return match .. "\n" .. indent .. payload
                elseif position == "at" then
                    -- Do not include the match
                    return payload
                end
            end)
        end

        -- create all the subdirectories

        local dirs = {}
        for dir in target:gmatch("([^/]+)") do
            table.insert(dirs, dir)
        end
        table.remove(dirs, #dirs)
        local dir = ""
        for i, d in ipairs(dirs) do
            dir = dir .. d .. "/"
            love.filesystem.createDirectory("Patched/" .. dir)
        end
        
        love.filesystem.write("Patched/" .. target, newFile)

        -- lastly, load the file as normal
    end
end
for i, file in ipairs(configFiles) do
    parseConfigFile(file)
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
end

lovely.version = "1.0.0"

return lovely