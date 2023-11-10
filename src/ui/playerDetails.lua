local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

local AceGUI = LibStub("AceGUI-3.0");

---@param player Player
---@param container AceGUIContainer 
function RDKP:CreatePlayerDetails(player, container)
    local playerDetails = AceGUI:Create("SimpleGroup");
    playerDetails:SetFullWidth(true);
    playerDetails:SetFullHeight(true);
    playerDetails:SetLayout("Flow");

    -- delete button
    -- local deleteButton = AceGUI:Create("Button");
    -- deleteButton:SetText(L["UI_PLAYER_DETAILS_ACTION_DELETE"]);
    -- deleteButton:SetRelativeWidth(1);
    -- deleteButton:SetCallback("OnClick", function()
    --     RDKP.Database:RemovePlayer(player);
    -- end);
    -- playerDetails:AddChild(deleteButton);

    local playerName = AceGUI:Create("EditBox");
    playerName:SetLabel(L["UI_PLAYER_DETAILS_NAME"]);
    playerName:SetRelativeWidth(0.5);
    playerName:SetText(player.name);
    playerName:SetCallback("OnEnterPressed", function(widget, event, text)
        player.name = text;
        RDKP.Database:UpdatePlayer(player);
    end);
    playerDetails:AddChild(playerName);

    local playerDKP = AceGUI:Create("EditBox");
    playerDKP:SetLabel(L["UI_PLAYER_DETAILS_DKP"]);
    playerDKP:SetRelativeWidth(0.5);
    playerDKP:SetText(player.dkp);
    playerDKP:SetCallback("OnEnterPressed", function(widget, event, text)
        local newAmount = (tonumber(text) or 0);
        local diff = abs(tonumber(player.dkp) - newAmount);
        if newAmount > player.dkp then
            RDKP.Database:CreditPlayer(player, player.name, diff, L["MOVEMENT_HARD_SET"]);
        elseif newAmount < player.dkp then
            RDKP.Database:DebitPlayer(player, player.name, diff, L["MOVEMENT_HARD_SET"]);
        end
    end);
    playerDetails:AddChild(playerDKP);

    local playerCharacters = AceGUI:Create("Heading");
    playerCharacters:SetText(L["UI_PLAYER_DETAILS_CHARACTERS"]);
    playerCharacters:SetRelativeWidth(1);
    playerDetails:AddChild(playerCharacters);

    for _, character in ipairs(player.characters) do
        local playerCharacter = AceGUI:Create("EditBox");
        playerCharacter:SetRelativeWidth(0.75);
        playerCharacter:SetText(character);
        playerCharacter:SetDisabled(true);
        playerDetails:AddChild(playerCharacter);

        --add remove button
        local removeButton = AceGUI:Create("Button");
        removeButton:SetText(L["UI_PLAYER_DETAILS_ACTION_REMOVE"]);
        removeButton:SetRelativeWidth(0.25);
        removeButton:SetCallback("OnClick", function()
            RDKP.Database:RemoveCharacterFromPlayer(player, character);
        end);
        playerDetails:AddChild(removeButton);
    end

    local playerMovements = AceGUI:Create("Heading");
    playerMovements:SetText(L["UI_PLAYER_DETAILS_MOVEMENTS"]);
    playerMovements:SetRelativeWidth(1);
    playerDetails:AddChild(playerMovements);

    local movementRowHeader = AceGUI:Create("SimpleGroup");
    movementRowHeader:SetLayout("Flow");
    movementRowHeader:SetFullWidth(true);
    movementRowHeader:SetHeight(20);

    local movementDateHeader = AceGUI:Create("Label");
    movementDateHeader:SetRelativeWidth(0.2);
    movementDateHeader:SetText(L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_DATE"]);
    movementRowHeader:AddChild(movementDateHeader);

    local movementTypeHeader = AceGUI:Create("Label");
    movementTypeHeader:SetRelativeWidth(0.1);
    movementTypeHeader:SetText(L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_TYPE"]);
    movementRowHeader:AddChild(movementTypeHeader);

    local movementDKPHeader = AceGUI:Create("Label");
    movementDKPHeader:SetRelativeWidth(0.1);
    movementDKPHeader:SetText(L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_DKP"]);
    movementRowHeader:AddChild(movementDKPHeader);

    local movementReasonHeader = AceGUI:Create("Label");
    movementReasonHeader:SetRelativeWidth(0.3);
    movementReasonHeader:SetText(L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_REASON"]);
    movementRowHeader:AddChild(movementReasonHeader);

    local movementCharHeader = AceGUI:Create("Label");
    movementCharHeader:SetRelativeWidth(0.3);
    movementCharHeader:SetText(L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_CHAR"]);
    movementRowHeader:AddChild(movementCharHeader);

    playerDetails:AddChild(movementRowHeader);

    for _, movement in ipairs(player.movements) do
        local movementRow = AceGUI:Create("SimpleGroup");
        movementRow:SetLayout("Flow");
        movementRow:SetFullWidth(true);
        movementRow:SetHeight(20);

        local movementDate = AceGUI:Create("Label");
        movementDate:SetRelativeWidth(0.2);
        movementDate:SetText(date("%d/%m/%y %H:%M:%S", movement.date));
        movementRow:AddChild(movementDate);

        local movementType = AceGUI:Create("Label");
        movementType:SetRelativeWidth(0.1);
        movementType:SetText(L["UI_PLAYER_DETAILS_MOVEMENT_".. movement.type]);
        movementRow:AddChild(movementType);

        local movementDKP = AceGUI:Create("Label");
        movementDKP:SetRelativeWidth(0.1);
        movementDKP:SetText(movement.amount);
        movementRow:AddChild(movementDKP);

        local movementReason = AceGUI:Create("Label");
        movementReason:SetRelativeWidth(0.3);
        local reason = movement.reason;
        if nil ~= movement.object then
            reason = reason .. " (" .. movement.object .. ")";
        end
        movementReason:SetText(reason);
        movementRow:AddChild(movementReason);

        local movementChar = AceGUI:Create("Label");
        movementChar:SetRelativeWidth(0.3);
        movementChar:SetText(movement.character);
        movementRow:AddChild(movementChar);

        playerDetails:AddChild(movementRow);
    end

    container:AddChild(playerDetails);
end
