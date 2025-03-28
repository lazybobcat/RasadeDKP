local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local AceGUI = LibStub("AceGUI-3.0");
local frame = AceGUI:Create("RDKPTransparentWindow");
frame:SetTitle("Trade");
frame:SetWidth(375);
frame:SetHeight(400);
frame:EnableResize(false);
frame:SetPoint("CENTER", UIParent, "CENTER", -400, 150);
frame:SetCallback("OnClose", function(widget)
    frame:Hide();
end)
frame:SetLayout("Flow");
frame:Hide();

---@type {bid: Bid, character: string, item: string, check: boolean, uiCheckbox: any} | nil
local currentTrade = nil;
---@type {bid: Bid, character: string, item: string, check: boolean, uiCheckbox: any}[]
local allTrades = {};

-- frame layout
local container = AceGUI:Create("SimpleGroup");
container:SetFullWidth(true);
container:SetFullHeight(true);
container:SetLayout("Flow");
frame:AddChild(container);

local scrollFrame = AceGUI:Create("ScrollFrame");
scrollFrame:SetLayout("Flow");
scrollFrame:SetFullWidth(true);
scrollFrame:SetFullHeight(true);
container:AddChild(scrollFrame);

local validateButton = CreateFrame("Button", "RDKPValidateTrades", frame.frame, "UIPanelButtonTemplate");
validateButton:SetText(L["UI_TRADESWINDOW_ACTION_VALIDATE"]);
validateButton:SetPoint("BOTTOMLEFT", frame.frame, "BOTTOM", 5, 20);
validateButton:SetPoint("BOTTOMRIGHT", frame.frame, "BOTTOMRIGHT", -15, 20);

local function RefreshTradesList()
    scrollFrame:ReleaseChildren();
    for _, trade in ipairs(allTrades) do
        ---@type {bid: Bid, character: string, item: string, check: any}
        local check = AceGUI:Create("CheckBox");
        check:SetRelativeWidth(0.1);
        check:SetValue(false);
        scrollFrame:AddChild(check);
        trade.uiCheckbox = check;

        local playerName = AceGUI:Create("Label");
        playerName:SetRelativeWidth(0.3);
        playerName:SetText(trade.character);
        scrollFrame:AddChild(playerName);

        local item = AceGUI:Create("Label");
        item:SetRelativeWidth(0.4);
        item:SetText(trade.item);
        scrollFrame:AddChild(item);

        local tradeButton = AceGUI:Create("Button");
        tradeButton:SetText("Trade");
        tradeButton:SetRelativeWidth(0.2);
        tradeButton:SetCallback("OnClick", function()
            currentTrade = trade;
            InitiateTrade(trade.character);
        end);
        scrollFrame:AddChild(tradeButton);
    end
end

function RDKP:OnTradeAcceptUpdate(event, player1, player2)
    -- player2 is true only if target accepted the trade before player. that's not reliable.
    if player1 == 1 and nil ~= currentTrade then
        currentTrade.check:SetValue(true);
    end
end

function RDKP:OnTradeClosed(event)
    currentTrade = nil;
end

function RDKP:OpenTradesWindow()
    RefreshTradesList();
    frame:Show();
end

---@param bid Bid
---@param item string
RDKP.Database:RegisterBidWon("tradeswindow_bidwon", function(event, bid, item)
    ---@type {bid: Bid, character: string, item: string, check: boolean}
    local trade = {
        bid = bid,
        character = string.match(bid.character, "(.*)-.*"),
        item = item,
        check = false,
    }
    table.insert(allTrades, trade);
    RefreshTradesList();
end);

-- on click, remove all checked trades from the list
validateButton:SetScript("OnClick", function()
    local trades = {};
    for _, trade in ipairs(allTrades) do
        if not trade.check then
            table.insert(trades, trade);
        end
    end
    allTrades = trades;
    RefreshTradesList();
end);
