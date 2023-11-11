local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);
local AceGUI = LibStub("AceGUI-3.0");

local frame = AceGUI:Create("Window");
frame:SetTitle(L["UI_EXPORTWINDOW_TITLE"]);
frame:SetWidth(600);
frame:SetHeight(300);
frame:SetPoint("CENTER", UIParent, "CENTER");
frame:SetCallback("OnClose", function(widget)
    frame:Hide();
end)
frame:SetLayout("Flow");

-- create edit box
local editBox = AceGUI:Create("MultiLineEditBox");
editBox:SetFullWidth(true);
editBox:SetFullHeight(true);
editBox:DisableButton(true);
editBox:SetLabel('');
frame:AddChild(editBox);

frame:Hide();

---@param data string
function RDKP:OpenExportWindow(data)
    editBox:SetText(data);
    frame:Show();

    -- give focus and select
    editBox:SetFocus();
    editBox:HighlightText();
end

_G["RDKP_Exportwindow"] = frame.frame;
