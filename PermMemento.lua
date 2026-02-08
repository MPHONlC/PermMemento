-----------------------------------------------------------
-- PermMemento Add-on (@APHONlC) | API: 101049
-----------------------------------------------------------
local PM = {
    name = "PermMemento",
    version = "0.6.0",
    defaults = {
        activeId = nil,
        paused = false,
        logEnabled = true,
        performanceMode = true,
        sync = {            -- Settings for the Sync module
            delay = 0,
            random = false,
            ignoreInCombat = true,
        }
    }
}

-- MEMENTO TABLE
-- Durations here are only used if the Game API fails to return a cooldown.
PM.mementoData = {
    [341]   = {id = 341,   aid = 26829,  dur = 30000,  name = "Almalexia's Lantern"},
    [9862]  = {id = 9862,  aid = 162813, dur = 180000, name = "Astral Aurora"},
    [10706] = {id = 10706, aid = 176334, dur = 180000, name = "Blossom of the Rose"},
    [1182]  = {id = 1182,  aid = 92867,  dur = 10000,  name = "Dwarven Dynamo"},
    [1183]  = {id = 1183,  aid = 92868,  dur = 36000,  name = "Dwemer Puzzle Box"},
    [10371] = {id = 10371, aid = 170722, dur = 30000,  name = "Fargrave Guardian"},
    [347]   = {id = 347,   aid = 41950,  dur = 33000,  name = "Fetish of Zenithar"},
    [336]   = {id = 336,   aid = 21226,  dur = 13000,  name = "Finvir's Trinket"},
    [758]   = {id = 758,   aid = 86978,  dur = 180000, name = "Floral Swirl"},
    [9361]  = {id = 9361,  aid = 153672, dur = 18000,  name = "Infernal Flames"},
    [10236] = {id = 10236, aid = 166513, dur = 30000,  name = "Mariner's Pipe"},
    [10652] = {id = 10652, aid = 175730, dur = 180000, name = "Soul Crystals of the Returned"}, --
    [594]   = {id = 594,   aid = 85344,  dur = 180000, name = "Storm Atronach Aura"},
    [596]   = {id = 596,   aid = 85349,  dur = 18000,  name = "Storm Atronach Transformation"},
    [11480] = {id = 11480, aid = 195745, dur = 18000,  name = "Tornado of Tomes"},
    [1384]  = {id = 1384,  aid = 97274,  dur = 18000,  name = "Murder of Crows"},
    [13105] = {id = 13105, aid = 229989, dur = 18000,  name = "Snowglobe"},
    [1167]  = {id = 1167,  aid = 91365,  dur = 30000,  name = "Pie of Misrule"},
    [349]   = {id = 349,   aid = 42008,  dur = 30000,  name = "Root Sunder Token"},
    [760]   = {id = 760,   aid = 86976,  dur = 180000, name = "Leaf Dancer"},
    [759]   = {id = 759,   aid = 86977,  dur = 180000, name = "Wild Hunt"},
    [13092] = {id = 13092, aid = 229843, dur = 69000,  name = "Remnant of Meridia's Light"},
}

function PM:Log(msg)
    if not self.settings.logEnabled then return end
    CHAT_SYSTEM:AddMessage("|cFF9900[PM]|r " .. tostring(msg))
end

-----------------------------------------------------------
-- Safety Checks
-----------------------------------------------------------
function PM:IsBusy()
    -- State Checks
    if IsMounted("player") or IsUnitSwimming("player") or IsUnitDead("player") 
       or (GetUnitStealthState("player") ~= STEALTH_STATE_NONE) then
        return true
    end

    if IsInteracting() then return true end

    if GetInteractionType() ~= INTERACTION_NONE then return true end

    if IsPlayerInteractingWithObject() then return true end

    return false
end

-----------------------------------------------------------
-- Main Loop
-----------------------------------------------------------
function PM:Loop()
    if self.settings.paused or not self.settings.activeId then return end
    
    local data = self.mementoData[self.settings.activeId]
    if not data then 
        self.settings.activeId = nil
        return 
    end

    -- 1. BUSY CHECK
    if self:IsBusy() then
        -- Retry in 2 seconds if busy
        zo_callLater(function() self:Loop() end, 2000)
        return
    end

    -- 2. COMBAT CHECK
    if IsUnitInCombat("player") and self.settings.performanceMode then
        local _, duration = GetCollectibleCooldownAndDuration(self.settings.activeId)
        if duration > 1000 then 
            zo_callLater(function() self:Loop() end, 3000)
            return 
        end
    end

    -- 3. COOLDOWN CHECK
    local remaining, _ = GetCollectibleCooldownAndDuration(self.settings.activeId)
    if remaining > 1000 then
        -- If still on cooldown, wait for 500ms buffer
        zo_callLater(function() self:Loop() end, remaining + 500)
        return
    end

    -- 4. FIRE MEMENTO
    UseCollectible(self.settings.activeId)
    
    -- 5. SCHEDULE NEXT LOOP
    zo_callLater(function() 
        if not self.settings.activeId then return end
        
        local cooldown, _ = GetCollectibleCooldownAndDuration(self.settings.activeId)
        local nextDelay = 0

        if cooldown > 0 then
            -- Success: use returned cooldown.
            nextDelay = cooldown + 500
        else
            -- Fallback: If API returns 0, use hardcoded table.
            nextDelay = data.dur + 1000
        end

        zo_callLater(function() self:Loop() end, nextDelay)
    end, 1000)
end

function PM:HookGameUI()
    ZO_PreHook("UseCollectible", function(collectibleId)
        if self.mementoData[collectibleId] then
            if self.settings.activeId == collectibleId then return end

            self.settings.activeId = collectibleId
            self.settings.paused = false
            self:Log("Auto-loop started: " .. self.mementoData[collectibleId].name)
            
            -- Start loop using the memento's duration as the first delay
            zo_callLater(function() self:Loop() end, self.mementoData[collectibleId].dur)
        end
    end)
end

-----------------------------------------------------------
-- Sync Module
-----------------------------------------------------------
local Sync = {}

function Sync:initialize()
  SLASH_COMMANDS["/pmsync"] = function(argString)
    if not argString or string.len(argString) < 1 then
      PM:Log("Usage: /pmsync <searchterm> (e.g., /pmsync crow)")
      return
    end
    
    local search = string.lower(argString)
    -- Search for the memento link to share in chat
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
      local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
      if id and string.find(string.lower(GetCollectibleName(id)), search, 1, true) then
        StartChatInput(string.format("PM %s", GetCollectibleLink(id, LINK_STYLE_BRACKETS)), CHAT_CHANNEL_PARTY)
        return
      end
    end
    PM:Log("Memento not found.")
  end

  local function attemptCollectible(id)
    if not IsCollectibleUsable(id) then return end
    if IsUnitInCombat("player") and PM.settings.sync.ignoreInCombat then return end
    
    -- If valid, set it as our active loop and fire
    if PM.mementoData[id] then
        PM.settings.activeId = id
        PM.settings.paused = false
        PM:Log("Sync received! Switching to: " .. PM.mementoData[id].name)
        UseCollectible(id)
        zo_callLater(function() PM:Loop() end, PM.mementoData[id].dur)
    else
        -- Just fire it once if we don't support looping it
        UseCollectible(id)
    end
  end

  local function onSyncChatMessage(eventCode, channelType, fromName, text)
    if channelType ~= CHAT_CHANNEL_PARTY then return end
    
    -- Parse "PM <Link>" or "PM <ID>"
    local id
    for collectibleId in string.gmatch(text, "^PM |H1:collectible:(%d+)|h|h$") do
      id = tonumber(collectibleId)
    end
    if not id then
      for collectibleId in string.gmatch(text, "^PM (%d+)$") do
        id = tonumber(collectibleId)
      end
    end
    
    if not id or not IsCollectibleUnlocked(id) then return end
    
    -- Check if it's the player themselves
    local pName = GetUnitDisplayName("player")
    if fromName == pName then return end

    local delay = PM.settings.sync.delay or 0
    if PM.settings.sync.random then
      delay = math.random(0, delay)
    end
    
    if delay == 0 then
      attemptCollectible(id)
    else
      zo_callLater(function() attemptCollectible(id) end, delay)
    end
  end

  EVENT_MANAGER:UnregisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL)
  EVENT_MANAGER:RegisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL, onSyncChatMessage)
end

-----------------------------------------------------------
-- Initialization
-----------------------------------------------------------
function PM:Init(eventCode, addOnName)
    if addOnName ~= self.name then return end
    
    self.settings = ZO_SavedVars:NewAccountWide("PermMemento_SavedVars", 1, nil, self.defaults)
    self:HookGameUI()
    Sync:initialize()
    
    -- Commands
    SLASH_COMMANDS["/pmem"] = function(extra)
        local cmd = extra:lower()
        
        if cmd == "stop" or cmd == "off" then
            self.settings.activeId = nil
            self:Log("Auto-loop disabled.")
        
        elseif cmd == "list" or cmd == "" then
            d("--------------------------------")
            d("[PM] Supported Mementos:")
            local sorted = {}
            for id, info in pairs(self.mementoData) do table.insert(sorted, info) end
            table.sort(sorted, function(a,b) return a.name < b.name end)
            
            for _, info in ipairs(sorted) do
                d(string.format("- %s (ID: %d)", info.name, info.id))
            end
            d("--------------------------------")
            d("Usage: /pmem stop | /pmem list | /pmsync <name>")

        elseif cmd == "current" then
             if self.settings.activeId then
                d("[PM] Active: " .. (self.mementoData[self.settings.activeId].name or "Unknown"))
             else
                d("[PM] Inactive")
             end
        end
    end

    -- Resume on login
    if self.settings.activeId and not self.settings.paused then
        zo_callLater(function() self:Loop() end, 5000)
    end
end

EVENT_MANAGER:RegisterForEvent(PM.name, EVENT_ADD_ON_LOADED, function(...) PM:Init(...) end)
