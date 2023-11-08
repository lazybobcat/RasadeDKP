local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local AceGUI = LibStub("AceGUI-3.0");
local isOpened = false;
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
        wlTitle = wlTitle .." (" .. countWL .. ")";
        wlDisabled = false;
    end

    tree = {{
        value = "waitingList",
        text = wlTitle,
        icon = "Interface\\Icons\\Inv_misc_scrollunrolled04b",
        disabled = wlDisabled,
      },{
        value = "raid",
        text = "Raid",
        icon = "Interface\\Icons\\SPELL_SHADOW_SKULL",
        disabled = not IsInRaid(),
      },
      {
        value = "roster",
        text = "Joueurs",
        icon = "Interface\\Icons\\INV_Drink_05",
        children = playersTree
    }};
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
        local groupTitle = {strsplit("\001", group)};
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
            RDKP:CreateRosterList(RDKP.db.global.players, container);
        elseif group:find("roster", 1, true) and #groupTitle > 1 then
            local groupTitle = {strsplit("\001", group)};
            local id = tonumber(groupTitle[2]);
            local player = RDKP.Database:FindPlayer(id);
            if nil ~= player then
                RDKP:Debug("Player selected: "..player.name);
                RDKP:CreatePlayerDetails(player, container);
            end
        else
            local icon = AceGUI:Create("Label");
            icon:SetText("Selected: " .. group);
            icon:SetImage("Interface\\AddOns\\RasadeDKP\\images\\logo_medium.tga");
            icon:SetImageSize(128, 128);
            container:AddChild(icon);
        end
    end);
    if nil ~= treeSelectedItem then
        treeGroup:SelectByValue(treeSelectedItem);
    end

    parent:AddChild(treeGroup);
end

function RDKP:OpenMainWindow()
    -- Don't open multiple windows
    if isOpened then return end

    local frame = AceGUI:Create("Window");
    frame:SetTitle(L["UI_MAINWINDOW_TITLE"]);
    frame:SetStatusText(L["UI_MAINWINDOW_STATUS"]);
    frame:SetWidth(960);
    frame:SetHeight(675);
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, -10);
    frame:SetCallback("OnClose", function(widget)
        RDKP.Database:UnregisterPlayersUpdated("mainwindow_OpenMainWindow");
        RDKP.Database:UnregisterWaitingListUpdated("mainwindow_OpenMainWindow");
        frame:ReleaseChildren();
        AceGUI:Release(widget);
        isOpened = false;
    end)
    frame:SetLayout("Flow");

    local iconFrame = CreateFrame("Frame", nil, frame.frame);
    iconFrame:SetFrameStrata("TOOLTIP")
	iconFrame:SetFrameLevel(100)
    iconFrame:SetWidth(100);
    iconFrame:SetHeight(100);
    local icon = iconFrame:CreateTexture(nil, "OVERLAY", nil);
    icon:SetTexture("Interface\\AddOns\\RasadeDKP\\images\\logo_medium.tga");
    icon:SetAllPoints(iconFrame);
    iconFrame.texture = icon;
    iconFrame:SetPoint("TOPLEFT", -20, 20);
    iconFrame:Show();

    local topGroup = AceGUI:Create("SimpleGroup");
    topGroup:SetFullWidth(true);
    topGroup:SetLayout("Flow");

    local emptyArea = AceGUI:Create("SimpleGroup");
    emptyArea:SetWidth(50);
    emptyArea:SetHeight(50);
    emptyArea:SetLayout("Fill");
    topGroup:AddChild(emptyArea);

    -- local share = AceGUI:Create("Button");
    -- share:SetText("Share data (todo)");
    -- share:SetDisabled(true);
    -- topGroup:AddChild(share);

    local auctions = AceGUI:Create("Button");
    auctions:SetText("Ouvrir les enchères");
    auctions:SetCallback("OnClick", function()
        RDKP:OpenAuctionsWindow();
    end);
    topGroup:AddChild(auctions);

    -- local resetDB = AceGUI:Create("Button");
    -- resetDB:SetText("Reset DB");
    -- resetDB:SetCallback("OnClick", function()
    --     RDKP.Database:ResetPlayerDatabase();
    -- end);
    -- topGroup:AddChild(resetDB);


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

    isOpened = true;
    _G["RDKP_Mainwindow"] = frame.frame;
end
