--[[
RasadeDKP
- accès à l'historique
- bet, résultats du bet, attribution
- automatisation des transactions
]]--

local addonName, addon = ...;
local DF = _G ["DetailsFramework"]
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

-- DEFAULTS
local dbDefaults = {
    global = {
        options = {
            fallback = true,
        },
        players = {},
        waitingList = {},
        archivedPlayers = {},
        auctions = {},
        minimap = {},
    }
};

---@class RDKP: AceAddon
---@field Database Database
---@field version string
local RDKP = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0");
local MinimapIcon = LibStub("LibDBIcon-1.0");

-- CONFIGURATION
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata;
RDKP.version = GetAddOnMetadata(addonName, "Version");
RDKP.COMM_PREFIX = addonName;
RDKP.COMM_CHANNEL = "RAID";
RDKP.COMM_CHAT = "CHAT_MSG_RAID";
RDKP.CURRENT_PLAYER = UnitName("player");
RDKP.DEFAULT_DKP_AMOUNT = 100;

-- DEV MODE
---@type LazyConsole-1.0
local Console = nil;
if "dev" == RDKP.version then
    Console = LibStub("LazyConsole-1.0");
    RDKP.COMM_CHANNEL = "SAY";
    RDKP.COMM_CHAT = "CHAT_MSG_SAY";
end

local options = {
    name = addonName,
    desc = L["ADDON_DESCRIPTION"],
    handler = RDKP,
    type = "group",
    args = {
        intro = {
            order = 1,
            type = "description",
            name = L["ADDON_DESCRIPTION"],
            cmdHidden = true
        },
        vers = {
            order = 2,
            type = "description",
            name = "|cffffd700    "..L["ADDON_VERSION"].."|r "..RDKP.version,
            cmdHidden = true
        },
        desc = {
            order = 3,
            type = "description",
            name = "|cffffd700    "..L["ADDON_AUTHOR"].."|r Tzinn\n\n",
            cmdHidden = true
        },
    }
};
LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options);
local AceConfigDialog = LibStub("AceConfigDialog-3.0");

function RDKP:OnInitialize()
    -- init database
    RDKP.db = LibStub("AceDB-3.0"):New("RasadeDKPDB", dbDefaults, true);

    -- init options
    RDKP.optionsFrames = AceConfigDialog:AddToBlizOptions(addonName, L["ADDON_NAME"]);
    -- Register the global variable `MyGlobalFrameName` as a "special frame"
    -- so that it is closed when the escape key is pressed.
    table.insert(UISpecialFrames, "RDKP_Mainwindow");
    table.insert(UISpecialFrames, "RDKP_Exportwindow");

    ---@diagnostic disable-next-line: missing-fields
    local RDKPLDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "data source",
        label = addonName,
        icon = "Interface\\AddOns\\RasadeDKP\\images\\logo_minimap.tga",
        OnClick = function() RDKP:OpenMainWindow() end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(addonName);
            tooltip:AddLine(L["ADDON_DESCRIPTION"], 1, 1, 1);
        end,
    });
    MinimapIcon:Register(addonName, RDKPLDB, RDKP.db.global.minimap);
end

function RDKP:OnEnable()
    -- init commands
    RDKP:RegisterChatCommand("rdkp", "OnSlashCommand");
    RDKP:RegisterChatCommand("loot", "OnSlashCommandLoot");

    -- hook to events
    RDKP:RegisterComm(RDKP.COMM_PREFIX);
    RDKP:RegisterEvent(RDKP.COMM_CHAT, "OnChatMessage");
    RDKP:RegisterEvent("CHAT_MSG_RAID_LEADER", "OnChatMessage");
    RDKP:RegisterEvent("CHAT_MSG_WHISPER", "OnWhisperMessage");

    -- say hello
    RDKP.Database:Load();
    RDKP:Print(L["ADDON_MOTD"]);

    -- if "dev" == RDKP.version then
    --     RDKP.Database:AddPlayer("Shadz", 24, {"Shadz-Archimonde"});
    --     RDKP.Database:AddPlayer("Ritaal", 235, {"Ritaal-Archimonde"});
    --     RDKP.Database:AddPlayer("Haji", 69, {"Haji-Archimonde"});
    -- end
end

function RDKP:OnSlashCommand(input)
    if nil ~= input and "" ~= input then
        local command, nextposition = RDKP:GetArgs(input, 1);
        if 'export' == command then
            local csv = RDKP:ExportDataAsCSV();
            RDKP:OpenExportWindow(csv);
        end
    else
        RDKP:OpenMainWindow();
    end
end

function RDKP:OnSlashCommandLoot(input)
    if nil ~= input and "" ~= input then
        RDKP:StartAuction(input);
    else
        RDKP:OpenAuctionsWindow();
    end
end

local function startsWith(text, start)
    return text:find(start, 1, true) == 1;
end

function RDKP:OnChatMessage(event, message, from)
    if startsWith(message, "!dkp") then
        -- from = "Shadz-Archimonde";
        local player = self.Database:FindPlayerByCharacterName(from);
        if nil ~= player then
            self:Debug(player);

            if startsWith(from, RDKP.CURRENT_PLAYER) then
                -- Addon owner sent this message
                RDKP:Print(L["DEFAULT_DKP_MESSAGE"](player.dkp));
            else
                -- send /w
                RDKP:SendPrivateMessage(L["DEFAULT_DKP_MESSAGE"](player.dkp), from);
            end
        else
            local added = RDKP.Database:AddPlayerToWaitingList(from);
            if added then
                self:Debug("Player ".. from .." added to waiting list");
                RDKP:SendPrivateMessage(L["DEFAULT_WAITING_LIST_MESSAGE"], from);
            else
                self:Debug("Player ".. from .." already in waiting list");
            end
        end
    end
end

function RDKP:GrantDKPToRaidPlayers(amount)
    local raid = GetNumGroupMembers();
    for i = 1, raid do
        local name = GetRaidRosterInfo(i);
        local player = RDKP.Database:FindPlayerByCharacterName(name);
        if nil ~= player then
            RDKP.Database:CreditPlayer(player, name, amount, L["DEFAULT_DKP_RAID_GRANT_MESSAGE"]);
        end
    end
    RDKP:SendChatMessage(L["RL_MESSAGE_RAID_PARTICIPATION"](amount));
end

function RDKP:PrintError(message)
    if "dev" ~= self.version then
        return;
    end
    Console:Log(message, "FFCC3333", 1);
end

function RDKP:Debug(message)
    if "dev" ~= self.version then
        return;
    end
    Console:Log(message, nil, 1);
end

_G["RasadeDKP"] = RDKP;
