local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local acceptBets = false;
local auctionsRefused = {};

function RDKP:OnWhisperMessage(event, message, from)
    if false == acceptBets then
        return;
    end

    ---@type Auction
    local auction = RDKP.db.global.auctions[#RDKP.db.global.auctions];
    local player = self.Database:FindPlayerByCharacterName(from);
    local dkp = string.match(message, "(%d+)");
    if nil == auction then
        return;
    end
    if nil == player then
        RDKP:SendPrivateMessage(L["DEFAULT_PLAYER_UNKNOWN_MESSAGE"], from);
        return;
    end
    if nil == dkp then
        if nil == auctionsRefused[from] then
            auctionsRefused[from] = true;
            RDKP:SendPrivateMessage(L["DEFAULT_DKP_UNKNOWN_MESSAGE"], from);
        end
        return;
    end
    RDKP.Database:PlaceBid(player, from, dkp);
    RDKP:SendPrivateMessage(L["DEFAULT_BID_PLACED_MESSAGE"](dkp, auction.item), from);
end

function RDKP:StartAuction(item)
    local auction = RDKP.Auction:new{
        item = item,
        bids = {},
        closed = false,
        cancelled = false,
    };
    table.insert(RDKP.db.global.auctions, auction);
    acceptBets = true;
    RDKP:OpenAuctionsWindow();
    RDKP:SendChatMessage("============================");
    RDKP:SendChatMessage(L["RL_MESSAGE_SEND_DKP"]);
    RDKP:SendChatMessage(item);
    RDKP:SendChatMessage("============================");
end

---@param auction Auction
---@param bid Bid
function RDKP:AttributeAuctionedItem(auction, bid)
    local player = RDKP.Database:FindPlayer(bid.player.id);
    if nil == player then
        return;
    end
    acceptBets = false;
    RDKP.Database:CloseAuction(auction, bid);
    -- remove dkp from player
    RDKP.Database:DebitPlayer(player, bid.character, bid.dkp, auction.item, auction.item);
    -- send message to player
    RDKP:SendPrivateMessage(L["DEFAULT_AUCTION_WON_MESSAGE"](bid.dkp, auction.item), bid.character);
    RDKP:SendChatMessage(L["RL_MESSAGE_AUCTION_ENDED"](auction.item, bid.character));
    RDKP:SendChatMessage("============================");
end

---@param auction Auction
function RDKP:CancelAuctionedItem(auction)
    acceptBets = false;
    RDKP.Database:CancelAuction(auction);
    RDKP:SendChatMessage(L["RL_MESSAGE_AUCTION_CANCELLED"](auction.item));
    RDKP:SendChatMessage("============================");
end
