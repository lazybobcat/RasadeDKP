local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local setmetatable = _G.setmetatable;

---@class Movement
---@field date number | nil
---@field type string
---@field amount number
---@field item string | number | nil
---@field reason string
---@field character string
local Movement = {
    date = 0,
    type = "debit", -- "debit" or "credit"
    amount = 0,
    item = 0,
    reason = '',
    character = '',
}
Movement.__index = Movement;

---@param o Movement | nil
---@return Movement
function Movement:new(o)
    local movement = o or {};
    setmetatable(movement, self);

    movement.date = GetServerTime();

    return movement;
end

RDKP.Movement = Movement;
