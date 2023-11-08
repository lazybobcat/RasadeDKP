local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local setmetatable = _G.setmetatable;

---@class Player
---@field id number | nil
---@field name string
---@field characters table
---@field dkp number
---@field movements table
local Player = {
    id = nil,
    name = '',
    characters = {},
    dkp = 0,
    movements = {},
}
Player.__index = Player;

---@param o Player | nil
---@return Player
function Player:new(o)
    local player = o or {};
    setmetatable(player, self);

    return player;
end

RDKP.Player = Player;
