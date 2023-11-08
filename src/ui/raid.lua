local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local AceGUI = LibStub("AceGUI-3.0");

function RDKP:CreateRaidView(container)
    -- add button and text field to add DKP to all players
    local addDKPGroup = AceGUI:Create("SimpleGroup");
    addDKPGroup:SetFullWidth(true);
    addDKPGroup:SetLayout("Flow");

    -- warning label
    local addDKPWarning = AceGUI:Create("Label");
    addDKPWarning:SetRelativeWidth(0.5);
    addDKPWarning:SetText(L["UI_RAID_ADD_DKP_WARNING"]);
    addDKPGroup:AddChild(addDKPWarning);

    local addDKPInput = AceGUI:Create("EditBox");
    addDKPInput:SetLabel(L["UI_RAID_ADD_DKP"]);
    addDKPInput:SetText(100);
    addDKPInput:SetRelativeWidth(0.3);
    addDKPGroup:AddChild(addDKPInput);

    local addDKPButton = AceGUI:Create("Button");
    addDKPButton:SetText(L["UI_RAID_ADD_DKP"]);
    addDKPButton:SetRelativeWidth(0.2);
    addDKPButton:SetCallback("OnClick", function()
        local dkp = tonumber(addDKPInput:GetText());
        if nil ~= dkp and dkp > 0 then
            RDKP:GrantDKPToRaidPlayers(dkp);
            addDKPButton:SetDisabled(true);
        end
    end);
    addDKPGroup:AddChild(addDKPButton);

    container:AddChild(addDKPGroup);
end
