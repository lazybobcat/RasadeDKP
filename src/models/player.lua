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

---@param player Player
---@return number
function Player:totalCredits(player)
    local total = 0;
    for _, movement in ipairs(player.movements) do
        if movement.type == 'credit' then
            total = total + movement.amount;
        end
    end

    return total;
end

---@param player Player
---@return number
function Player:totalDebits(player)
    local total = 0;
    for _, movement in ipairs(player.movements) do
        if movement.type == 'debit' then
            total = total + movement.amount;
        end
    end

    return total;
end

RDKP.Player = Player;
