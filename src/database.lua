local addonName, addon = ...;
---@class RDKP
local RDKP = addon;
local setmetatable = _G.setmetatable;

---@class Database
local Database = {};
Database.__index = Database;

Database.callbacks = Database.callbacks or LibStub("CallbackHandler-1.0"):New(Database);

---@param id string
---@param callback fun(event: string, players: table)
function Database:RegisterPlayersUpdated(id, callback, ...)
    if nil ~= arg and 0 < #arg then
        RDKP:Debug(arg);
        Database.RegisterCallback(id, "PlayersUpdate", callback, unpack(arg));
    end
    Database.RegisterCallback(id, "PlayersUpdate", callback);
end

---@param id string
---@param callback fun(event: string, players: table)
function Database:RegisterWaitingListUpdated(id, callback, ...)
    if nil ~= arg and 0 < #arg then
        RDKP:Debug(arg);
        Database.RegisterCallback(id, "WaitingListUpdate", callback, unpack(arg));
    end
    Database.RegisterCallback(id, "WaitingListUpdate", callback);
end

---@param id string
---@param callback fun(event: string, players: table)
function Database:RegisterAuctionsUpdated(id, callback, ...)
    if nil ~= arg and 0 < #arg then
        RDKP:Debug(arg);
        Database.RegisterCallback(id, "AuctionsUpdate", callback, unpack(arg));
    end
    Database.RegisterCallback(id, "AuctionsUpdate", callback);
end

---@param id string
function Database:UnregisterPlayersUpdated(id)
    Database.UnregisterCallback(id, "PlayersUpdate");
end

---@param id string
function Database:UnregisterWaitingListUpdated(id)
    Database.UnregisterCallback(id, "WaitingListUpdate");
end

---@param id string
function Database:UnregisterAuctionsUpdated(id)
    Database.UnregisterCallback(id, "AuctionsUpdate");
end

function Database:Load()
    self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);
end

---@return table<Player>
function Database:GetPlayers()
    local players = RDKP.db.global.players or {};
    table.sort(players, function(a, b) return a.name < b.name end);

    return players;
end

---@param id number
---@return Player | nil
function Database:FindPlayer(id)
    local players = RDKP.db.global.players;
    for index, player in ipairs(players) do
        if player.id == id then
            setmetatable(player, Player);
            return player;
        end
    end

    return nil;
end

---@param name string
---@return Player | nil
function Database:FindPlayerByName(name)
    local players = RDKP.db.global.players;
    for index, player in ipairs(players) do
        if player.name == name then
            setmetatable(player, Player);
            return player;
        end
    end

    return nil;
end

---@param name string
---@return Player | nil
function Database:FindPlayerByCharacterName(name)
    local players = RDKP.db.global.players;
    for index, player in ipairs(players) do
        for _, character in ipairs(player.characters) do
            local alternate = string.match(character, "(.*)-.*");
            if character == name or alternate == name then
                setmetatable(player, Player);
                return player;
            end
        end
    end

    return nil;
end

---@param name string
---@return boolean
function Database:FindWaitingByName(name)
    local players = RDKP.db.global.waitingList;
    for _, player in ipairs(players) do
        if player.name == name then
            return true;
        end
    end

    return false;
end

---@param playerName string
---@param dkp number
---@return Player | false
function Database:AddPlayer(playerName, dkp, characters)
    local found = self:FindPlayerByName(playerName);
    if nil ~= found then
        return false;
    end

    for _, character in ipairs(characters) do
        found = self:FindPlayerByCharacterName(character);
        if found then
            return false;
        end
    end

    characters = characters or {};
    ---@type Player
    local player = RDKP.Player:new{
        id = #RDKP.db.global.players + 1,
        name = playerName,
        dkp = 0,
        characters = characters,
        movements = {},
    };
    table.insert(RDKP.db.global.players, player);
    self:CreditPlayer(player, characters[1] or playerName, dkp, "Solde initial", nil);
    self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);

    return player;
end

function Database:UpdatePlayer(player)
    local found = self:FindPlayerByName(player.name);
    if nil == found then
        return false;
    end

    found.dkp = player.dkp;
    found.characters = player.characters;
    found.movements = player.movements;
    self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);

    return found;
end

---@param playerName string
---@param characterName string
---@return Player | false
function Database:AddCharacterToPlayer(playerName, characterName)
    local found = self:FindPlayerByName(playerName);
    if nil == found then
        return false;
    end

    for _, character in ipairs(found.characters) do
        if character == characterName then
            return false;
        end
    end

    table.insert(found.characters, characterName);
    self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);

    return found;
end

---@param player Player
---@param dkp number
---@param reason string
---@param item string | number | nil
function Database:CreditPlayer(player, characterName, dkp, reason, item)
    local movement = RDKP.Movement:new{
        type = "credit",
        amount = dkp,
        character = characterName,
        item = item,
        reason = reason,
    };
    table.insert(player.movements, movement);
    player.dkp = player.dkp + abs(dkp);
    self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);
end

---@param player Player
---@param characterName string
---@param dkp number
---@param reason string
---@param item string | number | nil
function Database:DebitPlayer(player, characterName, dkp, reason, item)
    local movement = RDKP.Movement:new{
        type = "debit",
        amount = dkp,
        character = characterName,
        item = item,
        reason = reason,
    };
    table.insert(player.movements, movement);
    player.dkp = player.dkp - abs(dkp);
    self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);
end

---@param player Player
---@return boolean
function Database:RemovePlayer(player)
    local index = nil;
    for i, p in ipairs(RDKP.db.global.players) do
        if p.id == player.id then
            index = i;
        end
    end

    if nil ~= index then
        table.insert(RDKP.db.global.archivedPlayers, player);
        table.remove(RDKP.db.global.players, index);
        self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);

        return true;
    end

    return false;
end

---@param charName string
---@return Player | false
function Database:AddPlayerToWaitingList(charName)
    local found = self:FindPlayerByName(charName);
    if nil ~= found then
        return false;
    end

    -- charName = "Shadz-Archimonde";
    local playerName = string.match(charName, "(.*)-.*") or charName;
    local inWL = self:FindWaitingByName(playerName);
    if false ~= inWL then
        return false;
    end

    ---@type Player
    local player = RDKP.Player:new{
        name = playerName,
        dkp = 0,
        characters = {charName},
        movements = {},
    };
    table.insert(RDKP.db.global.waitingList, player);
    self.callbacks:Fire("WaitingListUpdate", RDKP.db.global.waitingList);

    return player;
end

function Database:RemoveCharacterFromPlayer(player, charName)
    local index = nil;
    for i, character in ipairs(player.characters) do
        if character == charName then
            index = i;
        end
    end

    if nil ~= index then
        table.remove(player.characters, index);
        self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);

        return true;
    end

    return false;
end

---@param charName string
---@return boolean
function Database:RemoveFromWaitingList(charName)
    local index = nil;
    for i, player in ipairs(RDKP.db.global.waitingList) do
        if player.characters[1] == charName then
            index = i;
        end
    end

    if nil ~= index then
        table.remove(RDKP.db.global.waitingList, index);
        self.callbacks:Fire("WaitingListUpdate", RDKP.db.global.waitingList);

        return true;
    end

    return false;
end

---@return table<Player>
function Database:GetAuctions()
    local auctions = RDKP.db.global.auctions or {};
    for _, auction in ipairs(auctions) do
        table.sort(auction.bids, function(a, b) return a.dkp > b.dkp end);
    end

    return auctions;
end

---@param player Player
---@param character string
---@param dkp number
---@return boolean
function Database:PlaceBid(player, character, dkp)
    local auction = RDKP.db.global.auctions[#RDKP.db.global.auctions];
    if nil == auction then
        return false;
    end

    -- check if character already bid in auction
    local found = false;
    for _, bid in ipairs(auction.bids) do
        if bid.character == character then
            found = bid;
        end
    end

    if false == found then
        -- we copy the player to avoid modifying the original and keep too many informations in the database
        local copy = {};
        copy.id = player.id;
        copy.name = player.name;
        copy.dkp = player.dkp;
        local bid = RDKP.Bid:new{
            player = copy,
            character = character,
            dkp = dkp,
            won = false,
        };
        table.insert(auction.bids, bid);
    else
        found.dkp = dkp;
    end
    self.callbacks:Fire("AuctionsUpdate", RDKP.db.global.auctions);

    return true;
end

---@param auction Auction
---@param bid Bid
function Database:CloseAuction(auction, bid)
    auction.closed = true;
    bid.won = true;

    self.callbacks:Fire("AuctionsUpdate", RDKP.db.global.auctions);
end

---@param auction Auction
function Database:CancelAuction(auction)
    auction.closed = true;
    auction.cancelled = true;

    self.callbacks:Fire("AuctionsUpdate", RDKP.db.global.auctions);
end

function Database:ResetPlayerDatabase()
    RDKP.db.global.players = {};
    RDKP.db.global.waitingList = {};
    RDKP.db.global.archivedPlayers = {};
    RDKP.db.global.auctions = {};
    self.callbacks:Fire("PlayersUpdate", RDKP.db.global.players);
    self.callbacks:Fire("WaitingListUpdate", RDKP.db.global.waitingList);
    self.callbacks:Fire("AuctionsUpdate", RDKP.db.global.auctions);
end

RDKP.Database = Database;
