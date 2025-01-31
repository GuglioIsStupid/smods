return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -10
    },
    patches = {
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "if blind_state == 'Select' then blind_state = 'Current' end",
                position = 'after'
            },
            payload = [[
local blind_desc_nodes = {}
for k, v in ipairs(text_table) do
  blind_desc_nodes[#blind_desc_nodes+1] = {n=G.UIT.R, config={align = "cm", maxw = 2.8}, nodes={
    {n=G.UIT.T, config={text = v or '-', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled}}
  }}
end]]
        },
        {
            regex = {
                target = "functions/UI_definitions.lua",
                pattern = [[
text_table%[1%] and {n=G%.UIT%.R, config={align = "cm", minh = 0%.7, padding = 0%.05, minw = 2%.9}, nodes={
[\t ]*  text_table%[1%] and {n=G%.UIT%.R, config={align = "cm", maxw = 2%.8}, nodes={
[\t ]*    {n=G%.UIT%.T, config={id = blind_choice%.config%.key, ref_table = {val = ''}, ref_value = 'val', scale = 0%.32, colour = disabled and G%.C%.UI%.TEXT_INACTIVE or G%.C%.WHITE, shadow = not disabled, func = 'HUD_blind_debuff_prefix'}},
[\t ]*    {n=G%.UIT%.T, config={text = text_table%[1%] or '\-', scale = 0%.32, colour = disabled and G%.C%.UI%.TEXT_INACTIVE or G%.C%.WHITE, shadow = not disabled}}
[\t ]*  }} or nil,
[\t ]*  text_table%[2%] and {n=G%.UIT%.R, config={align = "cm", maxw = 2%.8}, nodes={
[\t ]*    {n=G%.UIT%.T, config={text = text_table%[2%] or '\-', scale = 0%.32, colour = disabled and G%.C%.UI%.TEXT_INACTIVE or G%.C%.WHITE, shadow = not disabled}}
[\t ]*  }} or nil,
[\t ]*}} or nil,]],
                position = "at"
            },
            payload = "text_table[1] and {n=G.UIT.R, config={align = \"cm\", minh = 0.7, padding = 0.05, minw = 2.9}, nodes = blind_desc_nodes} or nil,"
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "create_UIBox_blind_choice%(%)",
                position = 'at'
            },
            payload = "create_UIBox_HUD_blind()"
        },
        {
            regex = {
                target = "functions/UI_definitions.lua",
                pattern = [[
%{n=G%.UIT%.R, config=%{align = "cm", padding = 0%.05%}, nodes=%{
[\t ]*  %{n=G%.UIT%.R, config=%{align = "cm", minh = 0%.3, maxw = 4%.2%}, nodes=%{
[\t ]*    %{n=G%.UIT%.T, config=%{ref_table = %{val = ''%}, ref_value = 'val', scale = scale*0%.9, colour = G%.C%.UI%.TEXT_LIGHT, func = 'HUD_blind_debuff_prefix'%}%},
[\t ]*    %{n=G%.UIT%.T, config=%{ref_table = G%.GAME%.blind%.loc_debuff_lines, ref_value = 1, scale = scale*0%.9, colour = G%.C%.UI%.TEXT_LIGHT, id = 'HUD_blind_debuff_1', func = 'HUD_blind_debuff'%}%}
[\t ]*  %}%},
[\t ]*  %{n=G%.UIT%.R, config=%{align = "cm", minh = 0%.3, maxw = 4%.2%}, nodes=%{
[\t ]*    %{n=G%.UIT%.T, config=%{ref_table = G%.GAME%.blind%.loc_debuff_lines, ref_value = 2, scale = scale*0%.9, colour = G%.C%.UI%.TEXT_LIGHT, id = 'HUD_blind_debuff_2', func = 'HUD_blind_debuff'%}%}
[\t ]*  %}%},
[\t ]*%}%},]],
                position = "at"
            },
            payload = [[
{n=G.UIT.R, config={align = "cm", id = 'HUD_blind_debuff', func = 'HUD_blind_debuff'}, nodes={}}]]
        },
        {
            pattern = {
                target = "blind.lua",
                pattern = "self.loc_debuff_lines%[1%] = ''",
                position = 'at'
            },
            payload = 'EMPTY(self.loc_debuff_lines)'
        },
        {
            pattern = {
                target = "blind.lua",
                pattern = "for k, v in ipairs(loc_target) do",
                position = 'before'
            },
            payload = 'EMPTY(self.loc_debuff_lines)',
            match_indent = true
        },
        {
            pattern = {
                target = "blind.lua",
                pattern = "self.loc_debuff_text = self.loc_debuff_text..v..(k <= #loc_target and ' ' or '')",
                position = 'after'
            },
            payload = "self.loc_debuff_lines[k] = v",
            match_indent = true
        },
        {
            regex = {
                target = "blind.lua",
                pattern = [[
self%.loc_debuff_lines%[1%] = loc_target%[1%] or ''
self%.loc_debuff_lines%[2%] = loc_target%[2%] or ''
]],
                position = 'at'
            },
            payload = ''
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "{n=G.UIT.R, config={align = \"cm\", id = 'row_blind', minw = 1, minh = 3.75}, nodes={}}",
                position = 'at'
            },
            payload = [[
{n=G.UIT.R, config={align = "cm", id = 'row_blind', minw = 1, minh = 3.75}, nodes={
    {n=G.UIT.B, config={w=0, h=3.64, id = 'row_blind_bottom'}, nodes={}}
}}]]
        },
        {
            pattern = {
                target = "game.lua",
                pattern = "config = {major = G.HUD:get_UIE_by_ID('row_blind'), align = 'cm', offset = {x=0,y=-10}, bond = 'Weak'}",
                position = 'at'
            },
            payload = "config = {major = G.HUD:get_UIE_by_ID('row_blind_bottom'), align = 'bmi', offset = {x=0,y=-10}, bond = 'Weak'}",
            match_indent = true
        },
        {
            regex = {
                target = "functions/common_events.lua",
                pattern = [[
G%.HUD_blind:get_UIE_by_ID%('HUD_blind_debuff_1'%):juice_up%(0%.3, 0%)
G%.HUD_blind:get_UIE_by_ID%('HUD_blind_debuff_2'%):juice_up%(0%.3, 0%)
G%.GAME%.blind:juice_up()%]],
                position = 'at'
            },
            payload = 'SMODS.juice_up_blind()',
            line_prepend = '$indent'
        },
        {
            regex = {
                target = "functions/state_events.lua",
                pattern = [[
G%.HUD_blind:get_UIE_by_ID%('HUD_blind_debuff_1'%):juice_up%(0%.3, 0%)
G%.HUD_blind:get_UIE_by_ID%('HUD_blind_debuff_2'%):juice_up%(0%.3, 0%)
G%.GAME%.blind:juice_up()%]],
                position = 'at'
            },
            payload = 'SMODS.juice_up_blind()',
            line_prepend = '$indent'
        },
        {
            regex = {
                target = 'functions/UI_definitions.lua',
                pattern = [[\(k ==1 and blind%.name == 'The Wheel' and '1' or ''\)\.\.]],
                position = 'at'
            },
            payload = ''
        }
    }
}
