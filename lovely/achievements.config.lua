return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -10
    },
    patches = {
        {
            regex = {
                target = "functions/common_events.lua",
                pattern = "if G%.F_NO_ACHIEVEMENTS then return end[%s]*%-%-|FROM LOCAL SETTINGS FILE",
                position = "before",
                line_prepend = "$indent"
            },
            payload = [[
G.SETTINGS.ACHIEVEMENTS_EARNED = G.SETTINGS.ACHIEVEMENTS_EARNED or {}
for k, v in pairs(G.ACHIEVEMENTS) do
    if not v.key then v.key = k end
    for kk, vv in pairs(G.SETTINGS.ACHIEVEMENTS_EARNED) do 
        if G.ACHIEVEMENTS[kk] and G.ACHIEVEMENTS[kk].mod then
            G.ACHIEVEMENTS[kk].earned = true
        end
    end
end
            ]]
        },
        {
            pattern = {
                target = "functions/common_events.lua",
                pattern = "if G.GAME.challenge then return end",
                position = "after",
                match_indent = true
            },
            payload = [[
fetch_achievements() -- Refreshes achievements
for k, v in pairs(G.ACHIEVEMENTS) do
    if (not v.earned) and (v.unlock_condition and type(v.unlock_condition) == 'function') and v:unlock_condition(args) then
        unlock_achievement(k)
    end
end
            ]]
        },
        {
            pattern = {
                target = "functions/common_events.lua",
                pattern = "if G.PROFILES[G.SETTINGS.profile].all_unlocked then return end",
                position = "at",
                match_indent = true
            },
            payload = [[
if G.PROFILES[G.SETTINGS.profile].all_unlocked and (G.ACHIEVEMENTS and G.ACHIEVEMENTS[achievement_name] and not G.ACHIEVEMENTS[achievement_name].bypass_all_unlocked and SMODS.config.achievements < 3) or (SMODS.config.achievements < 3 and (G.GAME.seeded or G.GAME.challenge)) then return true end
            ]]
        },
        {
            pattern = {
                target = "functions/common_events.lua",
                pattern = "local achievement_set = false\nif G.F_NO_ACHIEVEMENTS then return end",
                position = "at",
                match_indent = true
            },
            payload = [[
local achievement_set = false
if not G.ACHIEVEMENTS then fetch_achievements() end
G.SETTINGS.ACHIEVEMENTS_EARNED[achievement_name] = true
G:save_progress()

if G.ACHIEVEMENTS[achievement_name] and G.ACHIEVEMENTS[achievement_name].mod then 
    if not G.ACHIEVEMENTS[achievement_name].earned then
        --|THIS IS THE FIRST TIME THIS ACHIEVEMENT HAS BEEN EARNED
        achievement_set = true
        G.FILE_HANDLER.force = true
    end
    G.ACHIEVEMENTS[achievement_name].earned = true
end

if achievement_set then 
    notify_alert(achievement_name)
    return true
end
if G.F_NO_ACHIEVEMENTS and not (G.ACHIEVEMENTS[achievement_name] or {}).mod then return true end
            ]]
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "local t_s = Sprite%(%d+,%d+,1%.5%*%(_atlas%.px/_atlas%.py%),1%.5,_atlas, _c and _c%.pos or {x=3, y=0}%)",
                position = "before",
                match_indent = true
            },
            payload = "if SMODS.Achievements[_achievement] then _c = SMODS.Achievements[_achievement]; _atlas = G.ASSET_ATLAS[_c.atlas] end"
        },
        {
            regex = {
                target = "functions/common_events.lua",
                pattern = "if G%.GAME%.seeded or G%.GAME%.challenge then return end",
                position = "at"
            },
            payload = "if not SMODS.config.seeded_unlocks and (G.GAME.seeded or G.GAME.challenge) then return end"
        },
        {
            pattern = {
                target = "functions/state_events.lua",
                pattern = "if not G.GAME.seeded and not G.GAME.challenge then",
                position = "at",
                match_indent = true
            },
            payload = "if (not G.GAME.seeded and not G.GAME.challenge) or SMODS.config.seeded_unlocks then"
        },
        {
            regex = {
                target = "functions/common_events.lua",
                pattern = "if G%.GAME%.seeded then",
                position = "at"
            },
            payload = "if false then"
        },
        {
            regex = {
                target = "functions/common_events.lua",
                pattern = "if G%.GAME%.challenge then",
                position = "at"
            },
            payload = "if false then"
        }
    }
}
