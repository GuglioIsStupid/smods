---@meta

---@class SMODS.Rarity: SMODS.GameObject
---@field pools? table Table with a list of ObjectTypes keys this rarity should be added to.
---@field badge_colour? table HEX color the rarity badge uses. 
---@field default_weight? number Default weight of the rarity. When referenced in ObjectTypes with just the key, this value is used as the default. 
---@overload fun(self: SMODS.Rarity): SMODS.Rarity
SMODS.Rarity = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@param self SMODS.Rarity Class to extend
---@param o SMODS.Rarity Class to create
---@return table o
---Primary method of creating a class. 
function SMODS.Rarity:extend(o) return o end

---@param self SMODS.Rarity
---Registers the object. 
function SMODS.Rarity:register() end

---@param self SMODS.Rarity
---Called during `inject_class`. Handles injecting loc_text. 
function SMODS.Rarity:process_loc_text() end

---@param self SMODS.Rarity
---Called before `inject_class`. Injects and manages class information before object injection. 
function SMODS.Rarity:pre_inject_class() end

---@param self SMODS.Rarity
---Called after `inject_class`. Injects and manages class information after object injection. 
function SMODS.Rarity:post_inject_class() end

---@param self SMODS.Rarity
---Inject all direct instances of `o` of the class by calling `o:inject`. 
---Also injects anything necessary for the class itself. 
---Only called if class has defined both `obj_table` and `obj_buffer`. 
function SMODS.Rarity:inject_class() end

---@param self SMODS.Rarity
---Called during `inject_class`. Injects the object into the game. 
function SMODS.Rarity:inject() end

---@param self SMODS.Rarity
---@param key string
---@param obj table
---@param silent? boolean
---@return SMODS.Rarity obj
---Takes control of vanilla objects. Child class must have get_obj for this to function
function SMODS.Rarity:take_ownership(key, obj, silent) return obj end

---@param self SMODS.Rarity
---@param weight number Default weight this ObjectType sets for this rarity. 
---@param object_type SMODS.ObjectType
---@return number weight
---Used for finer control over this rarity's weight
function SMODS.Rarity:get_weight(weight, object_type) end

---@param self SMODS.Rarity
---@param dt number delta-time
---Used to make a gradient for this rarity's `badge_colour`. 
function SMODS.Rarity:gradient(dt) end

---@param self SMODS.Rarity
---@param rarity string
---@return string 
---Returns loclaized rarity key. 
function SMODS.Rarity:get_rarity_badge(rarity) end

---@param _pool_key string Key to ObjectType
---@param _rand_key? string Used as polling seed
---@return string rarity_key
---Polls all rarities tied to provided ObjectType. 
function SMODS.poll_rarity(_pool_key, _rand_key) end

---@param object_type SMODS.ObjectType
---@param rarity SMODS.Rarity
---Injects `rarity` into `object_type`. 
function SMODS.inject_rarity(object_type, rarity) end
