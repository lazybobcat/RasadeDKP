local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

-- MESSAGES CONSTANTS
RDKP.Messages = {};

-- send comm message to all addon owners in the raid
function RDKP:SendAddonMessage(message)
    RDKP:SendCommMessage(RDKP.COMM_PREFIX, message, RDKP.COMM_CHANNEL);
    RDKP:Debug("Comm Sent // ".. message);
end

-- send message in configured chat
function RDKP:SendChatMessage(message)
    SendChatMessage(message, RDKP.COMM_CHANNEL);
end

-- send private message
function RDKP:SendPrivateMessage(message, player)
    if player:find(RDKP.CURRENT_PLAYER, 1, true) ~= 1 then
        SendChatMessage(message, "WHISPER", nil, player);
    end
end

-- process the incoming message
function RDKP:OnCommReceived(prefix, message, distribution, sender)
    -- ignore messages we have sent
    if RDKP.CURRENT_PLAYER == sender then return end

    RDKP:Debug("Comm Received // ".. message .. " // from ".. sender);

    local command, nextposition = RDKP:GetArgs(message, 1);
    -- if RDKP.Messages.Ping == command then
    --     local version = string.sub(message, nextposition);
    --     RDKP:OnPingReceived(sender, version);
    -- end
end
