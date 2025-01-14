---@meta

---@class SMODS.Keybind: SMODS.GameObject
---@field key_pressed? string Required key to press for this keybind to activate. Keycodes are documented [here](https://love2d.org/wiki/KeyConstant)
---@field event? string Defines when the keybind should trigger. "pressed": on key press, "released": on key release, "held": on key hold for specified amount of time. 
---@field held_duration? number How long the keybind needs to be pressed before activation. Only active if `event = held`. 
---@field held_keys? table Array of keycodes additionally required to be pressed for keybind to activate. 
---@field __call? fun(self: SMODS.Keybind, o: SMODS.Keybind): SMODS.Keybind
---@field extend? fun(self: SMODS.Keybind, o: SMODS.Keybind): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Keybind, o: SMODS.Keybind): table
---@field check_duplicate_key? fun(self: SMODS.Keybind): boolean Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Keybind) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Keybind): boolean Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Keybind) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Keybind, ...: any): string Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Keybind) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Keybind) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Keybind) Inject all direct instances of `o` of the class by calling `o:inject`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Keybind) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Keybind, key: string, obj: table, silent?: boolean): SMODS.Keybind Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Keybind, key: string): table|nil Returns an object if one matches the `key`. 
---@field action? fun(self: SMODS.Keybind) Called when the keybind is triggered. 
---@overload fun(self: SMODS.Keybind): SMODS.Keybind
SMODS.Keybind = setmetatable({}, {
    __call = function(self)
        return self
    end
})