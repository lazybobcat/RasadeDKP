local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local AceGUI = LibStub("AceGUI-3.0");
local opened = false;
local tree = {};
local treeSelectedItem = nil;

-- Create a tree for the TreeGroup widget with every player in the database
local function updateTree()
    local playersTree = {};
    local players = RDKP.Database:GetPlayers();
    if nil ~= players then
        for _, player in ipairs(players) do
            table.insert(playersTree, {
                value = player.id,
                text = player.name,
            });
        end
    end

    local countWL = #RDKP.db.global.waitingList;
    local wlTitle = "En attente";
    local wlDisabled = true;
    if countWL > 0 then
        wlTitle = wlTitle .. " (" .. countWL .. ")";
        wlDisabled = false;
    end

    tree = { {
        value = "waitingList",
        text = wlTitle,
        icon = "Interface\\Icons\\Inv_misc_scrollunrolled04b",
        disabled = wlDisabled,
    }, {
        value = "raid",
        text = "Raid",
        icon = "Interface\\Icons\\SPELL_SHADOW_SKULL",
        disabled = not IsInRaid(),
    }, {
        value = "roster",
        text = "Joueurs",
        icon = "Interface\\Icons\\INV_Drink_05",
        children = playersTree
    } };
end
RDKP.Database:RegisterPlayersUpdated("mainwindow_updateTree", function(event, players)
    updateTree();
end);

-- Extract TreeGroup creation from OpenMainWindow
local function createTreeGroup(parent)
    local treeGroup = AceGUI:Create("TreeGroup");
    treeGroup:SetTree(tree);
    treeGroup:SetFullHeight(true);
    treeGroup:SetFullWidth(true);
    treeGroup:SetCallback("OnGroupSelected", function(container, event, group)
        local groupTitle = { strsplit("\001", group) };
        treeSelectedItem = group;
        container:ReleaseChildren();
        if "waitingList" == group then
            RDKP:Debug("Waiting list selected");
            RDKP:CreatePlayerList(RDKP.db.global.waitingList, container);
        elseif "raid" == group then
            RDKP:Debug("Raid selected");
            RDKP:CreateRaidView(container);
        elseif "roster" == group then
            RDKP:Debug("Roster selected");
            RDKP:CreateRosterList(RDKP.db.global.players, container, function(playerId)
                treeGroup:SelectByPath("roster", playerId);
            end);
        elseif group:find("roster", 1, true) and #groupTitle > 1 then
            local groupTitle = { strsplit("\001", group) };
            local id = tonumber(groupTitle[2]);
            local player = RDKP.Database:FindPlayer(id);
            if nil ~= player then
                RDKP:Debug("Player selected: " .. player.name);
                RDKP:CreatePlayerDetails(player, container);
            end
        else
            local icon = AceGUI:Create("Label");
            icon:SetText("Selected: " .. group);
            icon:SetImage("Interface\\AddOns\\RasadeDKP\\media\\images\\logo_medium.tga");
            icon:SetImageSize(128, 128);
            container:AddChild(icon);
        end
    end);
    if nil ~= treeSelectedItem then
        treeGroup:SelectByValue(treeSelectedItem);
    end

    parent:AddChild(treeGroup);
end

local frame = AceGUI:Create("Window");
frame:Hide();

function InitMainWindow()
    frame:SetTitle(L["UI_MAINWINDOW_TITLE"]);
    frame:SetStatusText(L["UI_MAINWINDOW_STATUS"]);
    frame:SetWidth(960);
    frame:SetHeight(675);
    frame.frame:SetResizeBounds(600, 350);
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, -10);
    frame:SetCallback("OnClose", function(widget)
        frame:Hide();
    end)
    frame:SetLayout("Flow");

    local iconFrame = CreateFrame("Frame", nil, frame.frame);
    iconFrame:SetFrameStrata("TOOLTIP")
    iconFrame:SetFrameLevel(100)
    iconFrame:SetWidth(100);
    iconFrame:SetHeight(100);
    local icon = iconFrame:CreateTexture(nil, "OVERLAY", nil);
    icon:SetTexture("Interface\\AddOns\\RasadeDKP\\media\\images\\logo_medium.tga");
    icon:SetAllPoints(iconFrame);
    iconFrame.texture = icon;
    iconFrame:SetPoint("TOPLEFT", -20, 20);
    iconFrame:Show();

    local topGroup = AceGUI:Create("SimpleGroup");
    topGroup:SetHeight(28);
    topGroup:SetLayout("Fill");

    -- local share = AceGUI:Create("Button");
    -- share:SetText("Share data (todo)");
    -- share:SetDisabled(true);
    -- topGroup:AddChild(share);

    -- Auctions button
    local auctions = CreateFrame("Button", "RDKPOpenAuctions", frame.frame, "UIPanelButtonTemplate");
    auctions:SetText(L["UI_MAINWINDOW_AUCTIONS"]);
    auctions:SetPoint("TOPLEFT", 75, -30);
    auctions:SetHeight(24);
    local text = auctions:GetFontString();
    if nil ~= text then
        text:ClearAllPoints();
        text:SetPoint("TOPLEFT", 15, -1);
        text:SetPoint("BOTTOMRIGHT", -15, 1);
        text:SetJustifyV("MIDDLE");
        auctions:SetWidth(text:GetStringWidth() + 30);
    end
    auctions:SetScript("OnClick", function()
        RDKP:OpenAuctionsWindow();
    end);

    -- Export button
    local export = CreateFrame("Button", "RDKPOpenExport", frame.frame, "UIPanelButtonTemplate");
    export:SetText(L["UI_MAINWINDOW_EXPORT_CSV"]);
    export:SetPoint("TOPRIGHT", -15, -30);
    export:SetHeight(24);
    text = export:GetFontString();
    if nil ~= text then
        text:ClearAllPoints();
        text:SetPoint("TOPLEFT", 15, -1);
        text:SetPoint("BOTTOMRIGHT", -15, 1);
        text:SetJustifyV("MIDDLE");
        export:SetWidth(text:GetStringWidth() + 30);
    end
    export:SetScript("OnClick", function()
        local csv = RDKP:ExportDataAsCSV();
        RDKP:OpenExportWindow(csv);
    end);

    local mainGroup = AceGUI:Create("SimpleGroup");
    mainGroup:SetFullHeight(true);
    mainGroup:SetFullWidth(true);
    mainGroup:SetLayout("Flow");

    updateTree();
    createTreeGroup(mainGroup);
    RDKP.Database:RegisterPlayersUpdated("mainwindow_OpenMainWindow", function(event, players)
        updateTree();
        mainGroup:ReleaseChildren();
        createTreeGroup(mainGroup);
    end);
    RDKP.Database:RegisterWaitingListUpdated("mainwindow_OpenMainWindow", function(event, players)
        updateTree();
        mainGroup:ReleaseChildren();
        createTreeGroup(mainGroup);
    end);

    frame:AddChild(topGroup);
    frame:AddChild(mainGroup);

    _G["RDKP_Mainwindow"] = frame.frame;
end

function RDKP:OpenMainWindow()
    if not opened then
        InitMainWindow();
        opened = true;
    end
    frame:Show();
end
