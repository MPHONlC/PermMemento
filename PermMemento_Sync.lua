-----------------------------------------------------------
-- PM.Sync (Standalone – Latest ESO API version 101047)
-- This module implements synchronized memento usage via
-- the party chat channel.
--
-- Usage:
--     /pmsync <searchterm>
--
-- When a party chat message arrives in one of the recognized
-- formats, this module will attempt to use the specified memento.
-----------------------------------------------------------

-- Ensure the global add-on table exists
PM = PM or {}
PM.name = "PM"
PM.Sync = PM.Sync or {}
local Sync = PM.Sync

---------------------------------------------------------------------
-- Minimal Logging Functions
---------------------------------------------------------------------
-- These functions assume the ESO debug function "d" is available.
function PM:dbg(msg)
    if self.savedOptions and self.savedOptions.general and self.savedOptions.general.debug then
        d("[PM DEBUG] " .. tostring(msg))
    end
end

function PM:msg(msg)
    d("[PM MSG] " .. tostring(msg))
end

---------------------------------------------------------------------
-- Minimal Saved Options
---------------------------------------------------------------------
PM.savedOptions = PM.savedOptions or {
    general = {
        debug = false,  -- Set to true to enable debug output.
    },
    sync = {
        mementos = {
            party          = true,  -- Listen for sync messages in party chat.
            delay          = 0,     -- Delay (in milliseconds) before using the collectible.
            random         = false, -- If true, randomize the delay between 0 and `delay`.
            ignoreInCombat = true,  -- Do not trigger if the player is in combat.
        },
    },
}

---------------------------------------------------------------------
-- Slash Command Handler: /pmsync <searchterm>
---------------------------------------------------------------------
local function HandleSyncCommand(argString)
    if not argString or string.len(argString) < 1 then
        PM:msg("Usage: /pmsync <searchterm>\nExample: /pmsync cadwell's surprise")
        return
    end

    local search = string.lower(argString)
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if id and string.find(string.lower(GetCollectibleName(id)), search, 1, true) then
            StartChatInput(string.format("PM %s", GetCollectibleLink(id, LINK_STYLE_BRACKETS)), CHAT_CHANNEL_PARTY)
            return
        end
    end
end

---------------------------------------------------------------------
-- Internal Function: Attempt Collectible
-- Attempts to use the collectible if usable and (if configured)
-- not in combat.
---------------------------------------------------------------------
local function AttemptCollectible(id)
    if not IsCollectibleUsable(id) then 
        return 
    end

    if IsUnitInCombat("player") and PM.savedOptions.sync.mementos.ignoreInCombat then
        PM:dbg("ignoring sync because in combat")
        return
    end

    UseCollectible(id)
end

---------------------------------------------------------------------
-- Chat Handler: Parse incoming party chat messages.
-- Recognizes both clickable link format and plain text format.
---------------------------------------------------------------------
local function OnSyncChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    if channelType ~= CHAT_CHANNEL_PARTY then 
        return 
    end

    local id
    -- Attempt to parse clickable collectible link format.
    for collectibleId in string.gmatch(text, "^PM |H1:collectible:(%d+)|h|h$") do
        id = tonumber(collectibleId)
    end
    -- Fallback: parse plain text format.
    if not id then
        for collectibleId in string.gmatch(text, "^PM (%d+)$") do
            id = tonumber(collectibleId)
        end
    end

    if not id or not IsCollectibleUnlocked(id) then 
        return 
    end

    local delay = PM.savedOptions.sync.mementos.delay
    if PM.savedOptions.sync.mementos.random then
        delay = math.random(0, delay)
        PM:dbg(string.format("waiting %dms", delay))
    end

    if delay == 0 then
        AttemptCollectible(id)
    else
        zo_callLater(function()
            AttemptCollectible(id)
        end, delay)
    end
end

---------------------------------------------------------------------
-- Initialization:
-- Register slash command and party chat event handler.
---------------------------------------------------------------------
function Sync.Initialize()
    PM:dbg("Initializing Sync module...")

    SLASH_COMMANDS["/pmsync"] = HandleSyncCommand

    EVENT_MANAGER:UnregisterForEvent(PM.name .. "SyncChatMessage", EVENT_CHAT_MESSAGE_CHANNEL)
    if PM.savedOptions.sync.mementos.party then
        EVENT_MANAGER:RegisterForEvent(PM.name .. "SyncChatMessage", EVENT_CHAT_MESSAGE_CHANNEL, OnSyncChatMessage)
    end
end
