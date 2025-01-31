return {
    manifest = {
        version = "1.0.0",
        dump_lua = true,
        priority = -5
    },
    patches = {
        {
            pattern = {
                target = "game.lua",
                pattern = "self%.SPEEDFACTOR = 1",
                position = "after",
                match_indent = true
            },
            payload = "initSteamodded()"
        }
    }
}
