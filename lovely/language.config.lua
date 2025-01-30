return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -10
    },
    patches = {
        {
            pattern = {
                target = "game.lua",
                pattern = "if not %(love%.filesystem%.read%('localization/'%.%.G%.SETTINGS%.language%.'.lua'%)%) or G%.F_ENGLISH_ONLY then",
                position = "at",
                match_indent = true
            },
            payload = "if false then"
        },
        {
            pattern = {
                target = "game.lua",
                pattern = "local localization = love%.filesystem%.getInfo%('localization/'%.%.G%.SETTINGS%.language%.'.lua'%)",
                position = "at",
                match_indent = true
            },
            payload = "local localization = love.filesystem.getInfo('localization/'..G.SETTINGS.language..'.lua') or love.filesystem.getInfo('localization/en-us.lua')"
        },
        {
            pattern = {
                target = "game.lua",
                pattern = "self%.localization = assert%(loadstring%(love%.filesystem%.read%('localization/'%.%.G%.SETTINGS%.language%.'.lua'%)%)%)%(%))",
                position = "at",
                match_indent = true
            },
            payload = "self.localization = assert(loadstring(love.filesystem.read('localization/'..G.SETTINGS.language..'.lua') or love.filesystem.read('localization/en-us.lua')))()"
        },
        {
            pattern = {
                target = "game.lua",
                pattern = "self%.LANG = self%.LANGUAGES%[self%.SETTINGS%.language%] or self%.LANGUAGES%['en%-us']",
                position = "at",
                match_indent = true
            },
            payload = "self.LANG = self.LANGUAGES[self.SETTINGS.real_language or self.SETTINGS.language] or self.LANGUAGES['en-us']"
        },
        {
            pattern = {
                target = "functions/button_callbacks.lua",
                pattern = "G%.SETTINGS%.language = lang%.key",
                position = "at",
                match_indent = true
            },
            payload = "G.SETTINGS.language = lang.loc_key or lang.key\nG.SETTINGS.real_language = lang.key"
        },
        {
            pattern = {
                target = "functions/button_callbacks.lua",
                pattern = "if %(_infotip_object%.config%.set ~= e%.config%.ref_table%.label%) and %(not G%.F_NO_ACHIEVEMENTS%) then",
                position = "at",
                match_indent = true
            },
            payload = "if (_infotip_object.config.set ~= e.config.ref_table.label) then"
        }
    }
}
