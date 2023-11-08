local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local AceGUI = LibStub("AceGUI-3.0");

local function CreatePlayerRow(player)
    local row = AceGUI:Create("SimpleGroup");
    row:SetLayout("Flow");
    row:SetFullWidth(true);
    row:SetHeight(20);

    local playerName = AceGUI:Create("Label");
    playerName:SetRelativeWidth(0.3);
    playerName:SetText(player.name);
    row:AddChild(playerName);

    local playerCharacters = AceGUI:Create("Label");
    playerCharacters:SetRelativeWidth(0.6);
    playerCharacters:SetText(table.concat(player.characters, ", "));
    row:AddChild(playerCharacters);

    local playerDKP = AceGUI:Create("Label");
    playerDKP:SetRelativeWidth(0.1);
    playerDKP:SetText(player.dkp);
    row:AddChild(playerDKP);

    return row;
end

local function CreateHeaderRow()
    local row = AceGUI:Create("SimpleGroup");
    row:SetLayout("Flow");
    row:SetFullWidth(true);
    row:SetHeight(20);

    local playerCharacter = AceGUI:Create("Label");
    playerCharacter:SetRelativeWidth(0.3);
    playerCharacter:SetText(L["UI_ROSTER_HEADER_PLAYER"]);
    row:AddChild(playerCharacter);

    local playerName = AceGUI:Create("Label");
    playerName:SetRelativeWidth(0.6);
    playerName:SetText(L["UI_ROSTER_HEADER_CHARACTERS"]);
    row:AddChild(playerName);

    local playerDKP = AceGUI:Create("Label");
    playerDKP:SetRelativeWidth(0.1);
    playerDKP:SetText(L["UI_ROSTER_HEADER_DKP"]);
    row:AddChild(playerDKP);

    return row;
end

function RDKP:CreateRosterList(players, container)
    local playerList = AceGUI:Create("SimpleGroup");
    playerList:SetFullWidth(true);
    playerList:SetFullHeight(true);
    playerList:SetLayout("Fill");

    local scrollFrame = AceGUI:Create("ScrollFrame");
    scrollFrame:SetLayout("Flow");
    scrollFrame:AddChild(CreateHeaderRow());
    playerList:AddChild(scrollFrame);

    for _, player in ipairs(players) do
        local row = CreatePlayerRow(player);
        scrollFrame:AddChild(row);
    end

    container:AddChild(playerList);
end