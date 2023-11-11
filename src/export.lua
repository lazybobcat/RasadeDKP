local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

--[[
Rows of transactions are formatted as follows:
    - date
    - player
    - character
    - type
    - amount
    - reason
    - item link
]]
local columns = {"formattedDate", "player", "character", "type", "amount", "reason", "itemLink"};

---@return table
function RDKP:PrepareDataForExport()
    local data = {};
    local players = self.Database:GetPlayers();
    for _, player in ipairs(players) do
        for _, movement in ipairs(player.movements) do
            local movementData = {};
            movementData.date = movement.date;
            movementData.formattedDate = date("%d/%m/%Y %H:%M:%S", movement.date);
            movementData.player = player.name;
            movementData.character = movement.character;
            movementData.type = movement.type;
            movementData.amount = movement.amount;
            if nil ~= movement.item and '' ~= movement.item then
                local itemId = string.match(movement.item, "item:(%d+):") or 0;
                movementData.reason = movement.item;
                movementData.itemLink = "https://www.wowhead.com/item="..itemId;
            else
                movementData.reason = movement.reason;
                movementData.itemLink = '';
            end
            table.insert(data, movementData);
        end
    end

    -- sort by date
    table.sort(data, function(a, b) return a.date < b.date end);

    return data;
end

---@return string
function RDKP:ExportDataAsCSV()
    local data = self:PrepareDataForExport();
    local separator = ',';
    local enclosure = '"';
    local output = "";

    -- header
    for _, column in ipairs(columns) do
        output = string.format("%1$s%2$s%4$s%2$s%3$s", output, enclosure, separator, L["CSV_H_"..column]);
    end
    output = string.format("%1$s\n", output:sub(1, -2));

    -- rows
    for _, row in ipairs(data) do
        for _, column in ipairs(columns) do
            output = string.format("%1$s%2$s%4$s%2$s%3$s", output, enclosure, separator, row[column]);
        end
        output = string.format("%1$s\n", output:sub(1, -2));
    end

    return output:sub(1, -2);
end
