return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -10
    },
    patches = {
        {
            pattern = {
                target = "tag.lua",
                pattern = "function Tag:apply_to_run%(_context%)",
                position = "after",
                match_indent = true
            },
            payload = [[
    if self.triggered then return end
    local obj = SMODS.Tags[self.key]
    local res
    if obj and obj.apply and type(obj.apply) == 'function' then
        res = obj:apply(self, _context)
    end
    if res then return res end
            ]]
        },
        {
            pattern = {
                target = "tag.lua",
                pattern = "function Tag:set_ability%(%s*%)",
                position = "after",
                match_indent = true
            },
            payload = [[
    local obj = SMODS.Tags[self.key]
    local res
    if obj and obj.set_ability and type(obj.set_ability) == 'function' then
        obj:set_ability(self)
    end
            ]]
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "local tag_matrix = %{%}",
                position = "at",
                match_indent = true
            },
            payload = [[
local tag_matrix = {}
local counter = 0
local tag_tab = {}
local tag_pool = {}
if G.ACTIVE_MOD_UI then
    for k, v in pairs(G.P_TAGS) do
        if v.mod and G.ACTIVE_MOD_UI.id == v.mod.id then tag_pool[k] = v end
    end
else
    tag_pool = G.P_TAGS
end
for k, v in pairs(tag_pool) do
    counter = counter + 1
    tag_tab[#tag_tab+1] = v
end
for i = 1, math.ceil(counter / 6) do
    table.insert(tag_matrix, {})
end
            ]]
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "v%.children%.alert%.states%.collide%.can = false",
                position = "after",
                match_indent = true
            },
            payload = [[
local table_nodes = {}
for i = 1, math.ceil(counter / 6) do
    table.insert(table_nodes, {n=G.UIT.R, config={align = "cm"}, nodes=tag_matrix[i]})
end
            ]]
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "%{n=G%.UIT%.R, config=%{align = \"cm\"%}, nodes=tag_matrix%[1%]},",
                position = "at",
                match_indent = true
            },
            payload = "table_nodes"
        },
        {
            pattern = {
                target = "tag.lua",
                pattern = "G%.ASSET_ATLAS%[\"tags\"]",
                position = "at"
            },
            payload = "G.ASSET_ATLAS[(not self.hide_ability) and G.P_TAGS[self.key].atlas or \"tags\"]"
        },
        {
            pattern = {
                target = "tag.lua",
                pattern = "function Tag:get_uibox_table%(tag_sprite%)",
                position = "at",
                match_indent = true
            },
            payload = "function Tag:get_uibox_table(tag_sprite, vars_only)"
        },
        {
            pattern = {
                target = "tag.lua",
                pattern = "tag_sprite%.ability_UIBox_table = generate_card_ui%(G%.P_TAGS%[self%.key%], nil, loc_vars, %(self%.hide_ability%) and 'Undiscovered' or 'Tag', nil, %(self%.hide_ability%)%)",
                position = "at",
                match_indent = true
            },
            payload = [[
if vars_only then return loc_vars end
tag_sprite.ability_UIBox_table = generate_card_ui(G.P_TAGS[self.key], nil, loc_vars, (self.hide_ability) and 'Undiscovered' or 'Tag', nil, (self.hide_ability), nil, nil, self)
            ]]
        },
        {
            pattern = {
                target = "functions/common_events.lua",
                pattern = "elseif _c%.set == 'Tag' then",
                position = "after",
                match_indent = true
            },
            payload = [[
specific_vars = specific_vars or Tag.get_uibox_table({ name = _c.name, config = _c.config, ability = { orbital_hand = '['..localize('k_poker_hand')..']' }}, nil, true)
            ]]
        },
        {
            pattern = {
                target = "functions/button_callbacks.lua",
                pattern = "G%.FUNCS%.reroll_boss = function%(e%)",
                position = "after",
                match_indent = true
            },
            payload = [[
if not G.blind_select_opts then
    G.GAME.round_resets.boss_rerolled = true
    if not G.from_boss_tag then ease_dollars(-10) end
    G.from_boss_tag = nil
    G.GAME.round_resets.blind_choices.Boss = get_new_boss()
    for i = 1, #G.GAME.tags do
        if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
    end
    return true
end
            ]]
        }
    }
}
