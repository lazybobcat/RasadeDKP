local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local setmetatable = _G.setmetatable;

---@class Bid
---@field character string | nil
---@field dkp number
---@field player Player | nil
---@field won boolean
local Bid = {
    character = nil,
    dkp = 0,
    player = nil,
    won = false,
}
Bid.__index = Bid;

---@param o Bid | nil
---@return Bid
function Bid:new(o)
    local bid = o or {};
    setmetatable(bid, self);

    return bid;
end

RDKP.Bid = Bid;


---@class Auction
---@field item string | nil
---@field quantity number
---@field lootRemaining number
---@field bids Bid[]
---@field closed boolean
---@field cancelled boolean
local Auction = {
    item = nil,
    quantity = 1,
    lootRemaining = 1,
    bids = {},
    closed = false,
    cancelled = false,
}
Auction.__index = Auction;

---@param o Auction | nil
---@return Auction
function Auction:new(o)
    local auction = o or {};
    setmetatable(auction, self);

    return auction;
end

RDKP.Auction = Auction;
