local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local currentPage = 1;
local AceGUI = LibStub("AceGUI-3.0");
local frame = AceGUI:Create("Window");
frame:SetTitle(L["UI_AUCTIONSWINDOW_TITLE"]);
frame:SetWidth(400);
frame:SetHeight(675);
frame.frame:SetResizeBounds(400, 200);
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 590, -10);
frame:SetCallback("OnClose", function(widget)
    frame:Hide();
end)
frame:SetLayout("Flow");

local previousButton = AceGUI:Create("Icon");
local nextButton = AceGUI:Create("Icon");
local auctionName = AceGUI:Create("Heading");
local cancelButton = CreateFrame("Button", "RDKPCancelAuction", frame.frame, "UIPanelButtonTemplate");
local tradeButton = CreateFrame("Button", "RDKPTrade", frame.frame, "UIPanelButtonTemplate");
local auctionGroup = AceGUI:Create("SimpleGroup");

---@param goToLastPage boolean | nil
local function RefreshAuctions(goToLastPage)
    goToLastPage = goToLastPage or false;
    auctionGroup:ReleaseChildren();
    local auctions = RDKP.Database:GetAuctions();
    -- Generate WoW UI that displays the auctions with one per page and button to navigate between pages
    if #auctions > 0 then
        if goToLastPage then
            currentPage = #auctions;
        end
        local maxPage = #auctions;
        nextButton:SetDisabled(false);
        previousButton:SetDisabled(false);
        if currentPage == maxPage then
            nextButton:SetDisabled(true);
        end
        if currentPage == 1 then
            previousButton:SetDisabled(true);
        end
        ---@type Auction
        local auction = auctions[currentPage];

        auctionGroup:SetFullWidth(true);
        auctionGroup:SetFullHeight(true);
        auctionGroup:SetLayout("Flow");

        -- auction title
        if not auction.cancelled then
            auctionName:SetText(L["UI_AUCTIONSWINDOW_HEADER_TITLE"](auction.item));
        else
            auctionName:SetText(L["UI_AUCTIONSWINDOW_HEADER_TITLE_CANCELLED"](auction.item));
        end

        -- quantity
        local quantity = AceGUI:Create("Label");
        quantity:SetRelativeWidth(1);
        quantity:SetText(L["UI_AUCTIONSWINDOW_HEADER_QUANTITY"](auction.quantity or 1, auction.lootRemaining or 0));
        auctionGroup:AddChild(quantity);

        -- headers
        local bidPlayer = AceGUI:Create("Label");
        bidPlayer:SetRelativeWidth(0.4);
        bidPlayer:SetText(L["UI_AUCTIONSWINDOW_HEADER_PLAYER"]);
        auctionGroup:AddChild(bidPlayer);

        local bidAmount = AceGUI:Create("Label");
        bidAmount:SetRelativeWidth(0.15);
        bidAmount:SetText(L["UI_AUCTIONSWINDOW_HEADER_BID"]);
        auctionGroup:AddChild(bidAmount);

        local dkpPlayer = AceGUI:Create("Label");
        dkpPlayer:SetRelativeWidth(0.15);
        dkpPlayer:SetText(L["UI_AUCTIONSWINDOW_HEADER_DKP"]);
        auctionGroup:AddChild(dkpPlayer);

        -- list of auction.bids
        RDKP:Debug(auction);
        for _, bid in ipairs(auction.bids) do
            local bidRow = AceGUI:Create("SimpleGroup");
            bidRow:SetLayout("Flow");
            bidRow:SetFullWidth(true);
            bidRow:SetHeight(20);

            local bidPlayer = AceGUI:Create("Label");
            bidPlayer:SetRelativeWidth(0.4);
            bidPlayer:SetText(bid.character);
            bidRow:AddChild(bidPlayer);

            local color = "|cff2BC85A";
            if tonumber(bid.player.dkp) < tonumber(bid.dkp) then
                color = "|cffC9221C";
            end
            local bidAmount = AceGUI:Create("Label");
            bidAmount:SetRelativeWidth(0.15);
            bidAmount:SetText(color..bid.dkp.."|r");
            bidRow:AddChild(bidAmount);

            local dkpPlayer = AceGUI:Create("Label");
            dkpPlayer:SetRelativeWidth(0.15);
            dkpPlayer:SetText(bid.player.dkp);
            bidRow:AddChild(dkpPlayer);

            -- ok button
            if auction.closed == false and bid.won == false then
                local okButton = AceGUI:Create("Button");
                okButton:SetText(L["UI_AUCTIONSWINDOW_ACTION_OK"]);
                okButton:SetRelativeWidth(0.3);
                okButton:SetCallback("OnClick", function()
                    RDKP:AttributeAuctionedItem(auction, bid);
                end);
                bidRow:AddChild(okButton);
            else
                if bid.won then
                    local bidWOn = AceGUI:Create("Label");
                    bidWOn:SetRelativeWidth(0.3);
                    bidWOn:SetText(L["UI_AUCTIONSWINDOW_WON"]);
                    bidRow:AddChild(bidWOn);
                end
            end

            auctionGroup:AddChild(bidRow);
        end

        -- cancel button
        cancelButton:Disable();
        if auction.closed == false then
            cancelButton:Enable();
            cancelButton:SetScript("OnClick", function()
                RDKP:CancelAuctionedItem(auction);
            end)
        end

        -- open trade window button
        tradeButton:Disable();
        if auction.closed == true then
            tradeButton:Enable();
            tradeButton:SetScript("OnClick", function()
                RDKP:OpenTradesWindow(auction);
            end)
        end

        frame:AddChild(auctionGroup);
    end
end

-- previous button
previousButton:SetImage("Interface\\Icons\\Misc_arrowleft");
previousButton:SetImageSize(24, 24);
previousButton:SetRelativeWidth(0.1);
previousButton:SetDisabled(true);
previousButton:SetCallback("OnClick", function()
    PlaySound(852); -- SOUNDKIT.IG_MAINMENU_OPTION
    currentPage = currentPage - 1;
    RefreshAuctions();
end);
frame:AddChild(previousButton);

-- auction name
auctionName:SetRelativeWidth(0.8);
frame:AddChild(auctionName);

-- next button
nextButton:SetImage("Interface\\Icons\\Misc_arrowright");
nextButton:SetImageSize(24, 24);
nextButton:SetRelativeWidth(0.1);
nextButton:SetDisabled(true);
nextButton:SetCallback("OnClick", function()
    PlaySound(852); -- SOUNDKIT.IG_MAINMENU_OPTION
    currentPage = currentPage + 1;
    RefreshAuctions();
end);
frame:AddChild(nextButton);

-- cancel auction button
cancelButton:SetText(L["UI_AUCTIONSWINDOW_ACTION_CANCEL"]);
cancelButton:Disable();
cancelButton:SetPoint("BOTTOMLEFT", frame.frame, "BOTTOMLEFT", 15, 20);
cancelButton:SetPoint("BOTTOMRIGHT", frame.frame, "BOTTOM", -5, 20);

-- trades button
tradeButton:SetText(L["UI_AUCTIONSWINDOW_ACTION_TRADES"]);
tradeButton:Disable();
tradeButton:SetPoint("BOTTOMLEFT", frame.frame, "BOTTOM", 5, 20);
tradeButton:SetPoint("BOTTOMRIGHT", frame.frame, "BOTTOMRIGHT", -15, 20);


frame:Hide();

function RDKP:OpenAuctionsWindow()
    RefreshAuctions(true);
    frame:Show();
end

RDKP.Database:RegisterAuctionsUpdated("auctionswindow_refreshAuctions", function(event, players)
    RefreshAuctions(true);
end);
