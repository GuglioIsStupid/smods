return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -10
    },
    patches = {
        {
            pattern = {
                target = "back.lua",
                pattern = "if not selected_back then selected_back = G%.P_CENTERS%.b_red end",
                position = "after",
                match_indent = true
            },
            payload = "self.atlas = selected_back.unlocked and selected_back.atlas or nil"
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "if not new_back then new_back = G%.P_CENTERS%.b_red end",
                position = "after",
                match_indent = true
            },
            payload = "self.atlas = new_back.unlocked and new_back.atlas or nil"
        },
        {
            pattern = {
                target = "functions/button_callbacks.lua",
                pattern = "G%.PROFILES%[G%.SETTINGS%.profile%]%.MEMORY%.deck = args%.to_val",
                position = "after",
                match_indent = true
            },
            payload = [[
for key, val in pairs(G.sticker_card.area.cards) do
    val.children.back = false
    val:set_ability(val.config.center, true)
end]]
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "function Back:apply_to_run%(%)",
                position = "after",
                match_indent = true
            },
            payload = [[
    local obj = self.effect.center
    if obj.apply and type(obj.apply) == 'function' then
        obj:apply(self)
    end]]
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "if not args then return end",
                position = "after",
                match_indent = true
            },
            payload = [[
    local obj = self.effect.center
    if type(obj.calculate) == 'function' then
        local o = {obj:calculate(self, args)}
        if next(o) ~= nil then return unpack(o) end
    elseif type(obj.trigger_effect) == 'function' then
        -- kept for compatibility
        local o = {obj:trigger_effect(args)}
        if next(o) ~= nil then
            sendWarnMessage(('Found `trigger_effect` function on SMODS.Back object "%s". This field is deprecated; please use `calculate` instead.'):format(obj.key), 'Back')
            return unpack(o)
        end
    end]]
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "if not back_config%.unlock_condition then",
                position = "at",
                match_indent = true
            },
            payload = [[
local localized_by_smods
local key_override
if back_config.locked_loc_vars and type(back_config.locked_loc_vars) == 'function' then
    local res = back_config:locked_loc_vars() or {}
    loc_args = res.vars or {}
    key_override = res.key
end
if G.localization.descriptions.Back[key_override or back_config.key].unlock_parsed then
    localize{type = 'unlocks', key = key_override or back_config.key, set = 'Back', nodes = loc_nodes, vars = loc_args}
    localized_by_smods = true
end
if not back_config.unlock_condition then]]
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "localize%{type = 'descriptions', key = 'demo_locked', set = \"Other\", nodes = loc_nodes, vars = loc_args%}",
                position = "at",
                match_indent = true
            },
            payload = [[
if not localized_by_smods then
    localize{type = 'descriptions', key = 'demo_locked', set = "Other", nodes = loc_nodes, vars = loc_args}
end]]
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "loc_args = %[{other_name}%]",
                position = "at",
                match_indent = true
            },
            payload = "loc_args = loc_args or {other_name}"
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "loc_args = %[{tostring%(back_config%.unlock_condition%.amount%)%}]",
                position = "at",
                match_indent = true
            },
            payload = "loc_args = loc_args or {tostring(back_config.unlock_condition.amount)}"
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "loc_args = %[{other_name, colours = {get_stake_col%(back_config%.unlock_condition%.stake%)}}%]",
                position = "at",
                match_indent = true
            },
            payload = "loc_args = loc_args or {other_name, colours = {get_stake_col(back_config.unlock_condition.stake)}}"
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "if name_to_check == 'Blue Deck' then",
                position = "at",
                match_indent = true
            },
            payload = [[
local key_override
if back_config.loc_vars and type(back_config.loc_vars) == 'function' then
	local res = back_config:loc_vars() or {}
	loc_args = res.vars or {}
	key_override = res.key
elseif name_to_check == 'Blue Deck' then loc_args = {effect_config.hands}]]
        },
        {
            pattern = {
                target = "back.lua",
                pattern = "key = back_config%.key",
                position = "at"
            },
            payload = "key = key_override or back_config.key"
        }
    }
}
