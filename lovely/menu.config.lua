return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -5
    },
    patches = {
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "local main_menu = nil",
                position = "after",
                match_indent = true
            },
            payload = "local mods = nil"
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "main_menu = UIBox_button{ label = {localize('b_main_menu')}, button = \"go_to_menu\", minw = 5}",
                position = "after",
                match_indent = true
            },
            payload = "mods = UIBox_button{ id = \"mods_button\", label = {localize('b_mods')}, button = \"mods_button\", minw = 5}"
        },
        {
            pattern = {
                target = "functions/common_events.lua",
                pattern = "G.ARGS.set_alerts_alertables%[11%].should_alert = alert_booster",
                position = "after",
                match_indent = true
            },
            payload = "table.insert(G.ARGS.set_alerts_alertables, {id = 'mods_button', alert_uibox_name = 'mods_button_alert', should_alert = SMODS.mod_button_alert})"
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "main_menu,",
                position = "after",
                match_indent = true
            },
            payload = "mods,"
        },
        --[[ {
            pattern = {
                target = "game.lua",
                pattern = "self.ASSET_ATLAS%[self.asset_atli%[i%].name%].image = love.graphics.newImage%(.+%)",
                position = "after",
                match_indent = true
            },
            payload = "local foundAny = false\nfor i, v in pairs(SMODS.config) do\nfoundAny = true\nend\nif not foundAny then\nSMODS.config = love.filesystem.load(\"smods/config.lua\")()\nend\nlocal mipmap_level = SMODS.config.graphics_mipmap_level_options[SMODS.config.graphics_mipmap_level]\nif mipmap_level and mipmap_level > 0 then\n    self.ASSET_ATLAS[self.asset_atli[i].name].image:setMipmapFilter('linear', mipmap_level)\nend"
        }, ]]
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "create_option_cycle%(%{w = 4,scale = 0%.8, label = localize%(%\"b_set_CRT_bloom\"%),options = localize%(%(\"ml_bloom_opt\"%)%), opt_callback = 'change_crt_bloom', current_option = G%.SETTINGS%.GRAPHICS%.bloom%}%),",
                position = "after",
                match_indent = true
            },            
            payload = "create_option_cycle({label = localize('b_graphics_mipmap_level'),scale = 0.8, options = SMODS.config.graphics_mipmap_level_options, opt_callback = 'SMODS_change_mipmap', current_option = SMODS.config.graphics_mipmap_level}),"
        }
    }
}
