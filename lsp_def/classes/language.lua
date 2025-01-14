---@meta

---@type SMODS.Language
---@class SMODS.Language: SMODS.GameObject
---@field label? string Label displayed in the language selection screen. 
---@field font? number|table Font the in-game text uses. Using the number 1-9 uses vanilla fonts, and specifying a table uses custom font. See [SMODS.Language](https://github.com/Steamodded/smods/wiki/SMODS.Language) docs for details.
---@field loc_key? string Key to another language. Treats it as a base, keeping any unchanged localization strings intact and adding changes to the language and fonts. 
---@field __call? fun(self: table|SMODS.Language, o: SMODS.Language): SMODS.Language
---@field extend? fun(self: table|SMODS.Language, o: SMODS.Language): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: table|SMODS.Language): table
---@field check_duplicate_key? fun(self: table|SMODS.Language): boolean Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: table|SMODS.Language) Registers the object. 
---@field check_dependencies? fun(self: table|SMODS.Language): boolean Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: table|SMODS.Language) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: table|SMODS.Language, ...: any): string Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: table|SMODS.Language) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: table|SMODS.Language) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: table|SMODS.Language) Inject all direct instances of `o` of the class by calling `o:inject`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: table|SMODS.Language) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: table|SMODS.Language, key: string, obj: table, silent?: boolean): SMODS.Language Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: table|SMODS.Language, key: string): table|nil Returns an object if one matches the `key`. 
---@overload fun(self: SMODS.Language): SMODS.Language
SMODS.Language = setmetatable({}, {
    __call = function(self)
        return self
    end
})