return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -10
    },
    patches = {
        {
            pattern = {
                target = "card.lua",
                pattern = "G%.ASSET_ATLAS%[\"centers\"%]",
                position = "at"
            },
            payload = "G.ASSET_ATLAS[(G.GAME.viewed_back or G.GAME.selected_back) and ((G.GAME.viewed_back or G.GAME.selected_back)[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or (G.GAME.viewed_back or G.GAME.selected_back).atlas) or 'centers']"
        },
        {
            pattern = {
                target = "card.lua",
                pattern = "G%.ASSET_ATLAS%[_center%.atlas or _center%.set%]",
                position = "at"
            },
            payload = "G.ASSET_ATLAS[(_center.undiscovered and (_center.undiscovered[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or _center.undiscovered.atlas)) or (SMODS.UndiscoveredSprites[_center.set] and (SMODS.UndiscoveredSprites[_center.set][G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or SMODS.UndiscoveredSprites[_center.set].atlas)) or _center.set] or G.ASSET_ATLAS[\"Joker\"]"
        },
        {
            pattern = {
                target = "card.lua",
                pattern = "G%.ASSET_ATLAS%['Joker'%]",
                position = "at"
            },
            payload = "G.ASSET_ATLAS[_center[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or _center.atlas or _center.set]"
        },
        {
            pattern = {
                target = "card.lua",
                pattern = "G%.ASSET_ATLAS%[_center%.set%]",
                position = "at"
            },
            payload = "G.ASSET_ATLAS[_center[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or _center.atlas or _center.set]"
        },
        {
            pattern = {
                target = "card.lua",
                pattern = "%(_center%.set == 'Joker' and G%.j_undiscovered%.pos%) or",
                position = "before",
                match_indent = true
            },
            payload = "(_center.undiscovered and _center.undiscovered.pos) or (SMODS.UndiscoveredSprites[_center.set] and SMODS.UndiscoveredSprites[_center.set].pos) or"
        },
        {
            pattern = {
                target = "card.lua",
                pattern = "%(_center%.set == 'Booster' and G%.booster_undiscovered%.pos%)%)",
                position = "at",
                match_indent = true
            },
            payload = "(_center.set == 'Booster' and G.booster_undiscovered.pos) or G.j_undiscovered.pos)"
        },
        {
            pattern = {
                target = "functions/misc_functions.lua",
                pattern = "return G%.ASSET_ATLAS%[_front.atlas%] or G.ASSET_ATLAS%[\"cards_\"%.%.%(G%.SETTINGS%.colourblind_option and 2 or 1%)%], _front%.pos",
                position = "at",
                match_indent = true
            },
            payload = "return G.ASSET_ATLAS[G.SETTINGS.colourblind_option and _front.hc_atlas or _front.lc_atlas or {}] or G.ASSET_ATLAS[_front.atlas] or G.ASSET_ATLAS[\"cards_\"..(G.SETTINGS.colourblind_option and 2 or 1)], _front.pos"
        },
        {
            pattern = {
                target = "functions/button_callbacks.lua",
                pattern = "G:set_render_settings%(%)",
                position = "at",
                match_indent = true
            },
            payload = "SMODS.injectObjects(SMODS.Atlas)"
        },
        {
            pattern = {
                target = "functions/UI_definitions.lua",
                pattern = "G.ASSET_ATLAS%[\"icons\"%]",
                position = "after",
                match_indent = false,
                findSpecificFunction = "create_UIBox_notify_alert"
            },
            payload = [[
    local _smods_atlas = _c and ((G.SETTINGS.colourblind_option and _c.hc_atlas or _c.lc_atlas) or _c.atlas)
    if _smods_atlas then
        _atlas = G.ASSET_ATLAS[_smods_atlas] or _atlas
    end
]]
        },
        {
            pattern = {
                target = "card.lua",
                pattern = "shared_sprite:draw_shader%('dissolve', nil, nil, nil, self%.children%.center, scale_mod, rotate_mod%)",
                position = "at",
                match_indent = true
            },
            payload = "\nif (self.config.center.undiscovered and not self.config.center.undiscovered.no_overlay) or not( SMODS.UndiscoveredSprites[self.ability.set] and SMODS.UndiscoveredSprites[self.ability.set].no_overlay) then \n    shared_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)\nelse\nend"
        }
    }
}
