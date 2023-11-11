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

    local playerCharacter = AceGUI:Create("EditBox");
    playerCharacter:SetRelativeWidth(0.3);
    playerCharacter:SetText(player.characters[1]);
    playerCharacter:SetDisabled(true);
    row:AddChild(playerCharacter);

    local playerDKP = AceGUI:Create("EditBox");
    playerDKP:SetRelativeWidth(0.2);
    playerDKP:SetText(RDKP.DEFAULT_DKP_AMOUNT);

    local playerName = AceGUI:Create("Dropdown");
    local existing = nil;
    playerName:SetRelativeWidth(0.3);
    playerName:SetText("Nouveau: "..player.name);
    for _, p in ipairs(RDKP.db.global.players) do
        playerName:AddItem(p.name, p.name);
    end
    playerName:SetCallback("OnValueChanged", function(_, _, value)
        existing = value;
        playerDKP:SetDisabled(true);
        playerDKP:SetText("");
    end);
    row:AddChild(playerName);

    row:AddChild(playerDKP);

    -- Add ok button
    local okButton = AceGUI:Create("Button");
    okButton:SetText(L["UI_WL_HEADER_ACTION_OK"]);
    okButton:SetRelativeWidth(0.1);
    okButton:SetCallback("OnClick", function()
        local dkp = tonumber(playerDKP:GetText());
        local character = player.characters[1];
        if existing then
            local updated = RDKP.Database:AddCharacterToPlayer(existing, character);
            RDKP.Database:RemoveFromWaitingList(character);
            if false ~= updated then
                RDKP:Debug(updated);
                RDKP:SendPrivateMessage(string.gsub(L["DEFAULT_WAITING_LIST_ACCEPTED_MESSAGE"], "%%dkp%%", updated.dkp), character);
            end
        else
            if dkp then
                local added = RDKP.Database:AddPlayer(player.name, dkp, player.characters);
                RDKP.Database:RemoveFromWaitingList(character);
                if false ~= added then
                    RDKP:Debug(added);
                    RDKP:SendPrivateMessage(string.gsub(L["DEFAULT_WAITING_LIST_ACCEPTED_MESSAGE"], "%%dkp%%", added.dkp), character);
                end
            end
        end
    end);
    row:AddChild(okButton);

    -- Add remove button
    local removeButton = AceGUI:Create("Button");
    removeButton:SetText(L["UI_WL_HEADER_ACTION_REMOVE"]);
    removeButton:SetRelativeWidth(0.1);
    removeButton:SetCallback("OnClick", function()
        RDKP.Database:RemoveFromWaitingList(player.characters[1]);
    end);
    row:AddChild(removeButton);

    return row;
end

local function CreateHeaderRow()
    local row = AceGUI:Create("SimpleGroup");
    row:SetLayout("Flow");
    row:SetFullWidth(true);
    row:SetHeight(20);

    local playerCharacter = AceGUI:Create("Label");
    playerCharacter:SetRelativeWidth(0.3);
    playerCharacter:SetText(L["UI_WL_HEADER_CHARACTER"]);
    row:AddChild(playerCharacter);

    local playerName = AceGUI:Create("Label");
    playerName:SetRelativeWidth(0.3);
    playerName:SetText(L["UI_WL_HEADER_PLAYER"]);
    row:AddChild(playerName);

    local playerDKP = AceGUI:Create("Label");
    playerDKP:SetRelativeWidth(0.2);
    playerDKP:SetText(L["UI_WL_HEADER_DKP"]);
    row:AddChild(playerDKP);

    local actions = AceGUI:Create("Label");
    actions:SetText(L["UI_WL_HEADER_ACTIONS"]);
    actions:SetRelativeWidth(0.2);
    row:AddChild(actions);

    return row;
end

function RDKP:CreatePlayerList(players, container)
    local scrollFrame = AceGUI:Create("ScrollFrame");
    scrollFrame:SetFullWidth(true);
    scrollFrame:SetFullHeight(true);
    scrollFrame:SetLayout("Flow");
    scrollFrame:AddChild(CreateHeaderRow());

    for _, player in ipairs(players) do
        local row = CreatePlayerRow(player);
        scrollFrame:AddChild(row);
    end

    container:AddChild(scrollFrame);
end
