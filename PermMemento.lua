-----------------------------------------------------------
-- PermMemento Add-on (@APHONlC) | API: 101049
-----------------------------------------------------------
local PM = {
    name = "PermMemento",
    version = "0.7.7",
    -- Default settings
    defaults = {
        activeId = nil, paused = false, logEnabled = true, csaEnabled = true,
        randomOnLogin = false, randomOnZone = false, loopInCombat = false, performanceMode = true,
        lastVersion = "0.7.7", versionHistory = {},
         -- Delays (3000ms)
        delayMove=3000, delaySprint=3000, delayBlock=3000, delayCast=3000,
        delaySwim=3000, delaySneak=3000, delayMount=3000, delayIdle=3000,
        delayTeleport=3000, delayResurrect=3000, delayInMenu=3000,
        -- CSA Durations (6000ms)
        csaDurations = {
            activation=6000, stop=6000, sync=6000, ui=6000, random=6000, error=6000
        },
        -- UI Defaults
        ui = { left=1627, top=32, locked=false, hidden=false, scale=(IsConsoleUI() and 0.7 or 1.0) },
        sync = { delay=0, random=false, ignoreInCombat=true }
    },
    charDefaults = { useAccountSettings = true },
    isLooping = false, loopToken = 0, lastPos = {x=0,y=0,z=0,t=0}, isMoving = false,
    activeNames = {}, activeIDs = {}, syncNames = {}, syncIDs = {},
    selectedSyncId = nil, pendingId = nil, menuBuilt = false, Sync = {}
}

-- MEMENTO TABLE
PM.mementoData = {
    [336]   = {id = 336,   aid = 21226,  dur = 13000,  name = "Finvir's Trinket"},
    [341]   = {id = 341,   aid = 26829,  dur = 30000,  name = "Almalexia's Enchanted Lantern"},
    [349]   = {id = 349,   aid = 42008,  dur = 30000,  name = "Token of Root Sunder"},
    [594]   = {id = 594,   aid = 85344,  dur = 180000, name = "Storm Atronach Aura"},
    [758]   = {id = 758,   aid = 86978,  dur = 180000, name = "Floral Swirl Aura"},
    [759]   = {id = 759,   aid = 86977,  dur = 180000, name = "Wild Hunt Transform"},
    [760]   = {id = 760,   aid = 86976,  dur = 180000, name = "Wild Hunt Leaf-Dance Aura"},
    [1183]  = {id = 1183,  aid = 92868,  dur = 36000,  name = "Dwemervamidium Mirage"},
    [9361]  = {id = 9361,  aid = 153672, dur = 18000,  name = "Inferno Cleats"},
    [9862]  = {id = 9862,  aid = 162813, dur = 180000, name = "Astral Aurora Projector "},
    [10652] = {id = 10652, aid = 175730, dur = 180000, name = "Soul Crystals of the Returned"},
    [10706] = {id = 10706, aid = 176334, dur = 180000, name = "Blossom Bloom"},
    [13092] = {id = 13092, aid = 229843, dur = 69000,  name = "Remnant of Meridia's Light"},
    [347]   = {id = 347,   aid = 41950,  dur = 33000,  name = "Fetish of Anger"},
    [596]   = {id = 596,   aid = 85349,  dur = 18000,  name = "Storm Atronach Transform"},
    [1167]  = {id = 1167,  aid = 91365,  dur = 30000,  name = "The Pie of Misrule"},
    [1182]  = {id = 1182,  aid = 92867,  dur = 10000,  name = "Dwarven Tonal Forks"},
    [1384]  = {id = 1384,  aid = 97274,  dur = 18000,  name = "Swarm of Crows"},
    [10236] = {id = 10236, aid = 166513, dur = 30000,  name = "Mariner's Nimbus Stone"},
    [10371] = {id = 10371, aid = 170722, dur = 30000,  name = "Fargrave Occult Curio"},
    [11480] = {id = 11480, aid = 195745, dur = 18000,  name = "Summoned Booknado"},
    [13105] = {id = 13105, aid = 229989, dur = 18000,  name = "Surprising Snowglobe"},
}

function PM:UpdateSettingsReference()
    if self.charSaved and self.charSaved.useAccountSettings then self.settings = self.acctSaved else self.settings = self.charSaved end
    if not self.settings then return end
    
    if not self.settings.ui then self.settings.ui = {left=self.defaults.ui.left, top=self.defaults.ui.top, locked=false, hidden=false, scale=self.defaults.ui.scale} end
    if not self.settings.sync then self.settings.sync = {delay=0, random=false, ignoreInCombat=true} end
    if not self.settings.csaDurations then self.settings.csaDurations = {activation=6000, stop=6000, sync=6000, ui=6000, random=6000, error=6000} end
    if self.settings.ui.scale == nil then self.settings.ui.scale = 1.0 end
    
    -- Delays
    if self.settings.loopDelay then self.settings.delayIdle = self.settings.loopDelay; self.settings.loopDelay = nil end
    
    if self.uiWindow then
        self.uiWindow:ClearAnchors()
        if self.settings.ui.left == self.defaults.ui.left then self.uiWindow:SetAnchor(LEFT, ZO_Compass, RIGHT, 25, 0)
        else self.uiWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.settings.ui.left, self.settings.ui.top) end
        self.uiWindow:SetMovable(not self.settings.ui.locked); self.uiWindow:SetHidden(self.settings.ui.hidden); self.uiWindow:SetScale(self.settings.ui.scale)
    end
    
    self.settings.lastVersion = self.version
    if not self.settings.versionHistory then self.settings.versionHistory = {} end
    if #self.settings.versionHistory == 0 or self.settings.versionHistory[1] ~= self.version then
        table.insert(self.settings.versionHistory, 1, self.version)
    end
    while #self.settings.versionHistory > 5 do table.remove(self.settings.versionHistory) end
end

function PM:Log(msg, isCSA, durKey)
    if not self.settings then return end
    if self.settings.csaEnabled and isCSA and CENTER_SCREEN_ANNOUNCE then
        local dur = (durKey and self.settings.csaDurations[durKey]) or 6000
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        params:SetText("|cFFD700" .. tostring(msg) .. "|r"); params:SetLifespanMS(dur)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end
    if self.settings.logEnabled then
        local formattedMsg = "|cFF9900[PM]|r " .. tostring(msg)
        if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage(formattedMsg) else d(formattedMsg) end
    end
end

function PM:GetRandomSupported()
    local available = {}
    for id, _ in pairs(self.mementoData) do if IsCollectibleUnlocked(id) then table.insert(available, id) end end
    return #available > 0 and available[math.random(#available)] or nil
end

function PM:GetRandomAny()
    local available = {}
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if id and IsCollectibleUnlocked(id) then table.insert(available, id) end
    end
    return #available > 0 and available[math.random(#available)] or nil
end

function PM:UpdateMovementState()
    if not GetUnitRawWorldPosition then return end
    local x, _, z = GetUnitRawWorldPosition("player"); local time = GetGameTimeMilliseconds()
    if self.lastPos.t == 0 then self.lastPos = {x=x, z=z, t=time}; self.isMoving = false; return end
    if (time - self.lastPos.t) > 100 then 
        local dist = zo_sqrt((x - self.lastPos.x)^2 + (z - self.lastPos.z)^2); self.isMoving = (dist > 0.5); self.lastPos = {x=x, z=z, t=time}
    end
end

function PM:GetActionState()
    if IsResurrecting and IsResurrecting() then return true, "|cFF0000(Resurrecting)|r", (self.settings.delayResurrect or 3000) end
    
    local blocking = false
    if IsBlockActive and IsBlockActive() then blocking = true elseif IsUnitBlocking and IsUnitBlocking("player") then blocking = true end
    if blocking then return true, "|cFF4500(Blocking)|r", (self.settings.delayBlock or 3000) end
    if IsSprinting and IsSprinting() then return true, "|c00CED1(Sprinting)|r", (self.settings.delaySprint or 3000) end
    if IsUnitSwimming and IsUnitSwimming("player") then return true, "|c0064D2(Swimming)|r", (self.settings.delaySwim or 3000) end
    if IsMounted and IsMounted("player") then return true, "|cFFF000(Mounted)|r", (self.settings.delayMount or 3000) end
    if GetUnitStealthState and GetUnitStealthState("player") ~= STEALTH_STATE_NONE then return true, "|c1EBEA5(Sneaking)|r", (self.settings.delaySneak or 3000) end
    if self.isMoving then return true, "|c00CED1(Moving)|r", (self.settings.delayMove or 3000) end
    return false, "", 0
end

function PM:CreateUI()
    local ui = WINDOW_MANAGER:CreateControl("PermMementoUI", GuiRoot, CT_TOPLEVELCONTROL)
    ui:SetClampedToScreen(true); ui:SetMouseEnabled(true)
    if self.settings and self.settings.ui then
        ui:SetMovable(not self.settings.ui.locked); ui:SetHidden(self.settings.ui.hidden); ui:SetScale(self.settings.ui.scale or 1.0)
        if self.settings.ui.left == self.defaults.ui.left and self.settings.ui.top == self.defaults.ui.top then
            ui:SetAnchor(LEFT, ZO_Compass, RIGHT, 25, 0)
        else ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.settings.ui.left, self.settings.ui.top) end
    else ui:SetAnchor(LEFT, ZO_Compass, RIGHT, 25, 0) end

    ui:SetHandler("OnMoveStop", function(control) 
        if PM.settings and PM.settings.ui then PM.settings.ui.left = control:GetLeft(); PM.settings.ui.top = control:GetTop() end 
    end)
    
    local bg = WINDOW_MANAGER:CreateControl("PermMementoBG", ui, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, ui, TOPLEFT, 0, 0); bg:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0.6); bg:SetEdgeColor(0.6, 0.6, 0.6, 0.8); bg:SetEdgeTexture(nil, 1, 1, 1, 0)
    
    local label = WINDOW_MANAGER:CreateControl("PermMementoLabel", ui, CT_LABEL)
    if IsInGamepadPreferredMode() then label:SetFont("ZoFontGamepad22") else label:SetFont("ZoFontGameSmall") end
    label:SetColor(1, 1, 1, 1); label:SetText("[PM] Ready"); label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    
    local function UpdateSize() ui:SetDimensions(label:GetTextWidth() + 20, label:GetTextHeight() + 10) end
    local lastUpdate = 0
    ui:SetHandler("OnUpdate", function(control, time)
        PM:UpdateMovementState()
        if not PM.settings then return end 
        if PM.settings.performanceMode and (time - lastUpdate < 0.25) then return end
        lastUpdate = time
        if PM.settings.ui and PM.settings.ui.hidden and not control:IsHidden() then control:SetHidden(true) end
        
        if not PM.settings.activeId or not PM.mementoData[PM.settings.activeId] then label:SetText("[PM] Inactive"); UpdateSize(); return end
        if PM.settings.paused then label:SetText(string.format("[PM] %s |cFF0000(Paused)|r", PM.mementoData[PM.settings.activeId].name)); UpdateSize(); return end
        
        local stateInfo = ""
        if IsUnitDead and IsUnitDead("player") then stateInfo = "|c881EE4(Dead)|r"
        elseif IsUnitInCombat and IsUnitInCombat("player") and not PM.settings.loopInCombat then stateInfo = "|cEF008C(Combat)|r"
        else
            local isBusy, actionText, _ = PM:GetActionState()
            if isBusy then stateInfo = actionText
            elseif (IsInteracting and IsInteracting()) or (IsPlayerInteractingWithObject and IsPlayerInteractingWithObject()) then stateInfo = "|cF18F49(Busy)|r" end
        end
        local cooldownText = ""; local remaining = 0
        if GetCollectibleCooldownAndDuration then remaining, _ = GetCollectibleCooldownAndDuration(PM.settings.activeId) end
        if remaining > 0 then cooldownText = string.format(" |cFFA500(%.1fs)|r", remaining / 1000) else if stateInfo == "" then cooldownText = " |c00FF00(Ready)|r" end end
        label:SetText(string.format("[PM] %s %s%s", PM.mementoData[PM.settings.activeId].name, stateInfo, cooldownText))
        UpdateSize()
    end)
    self.uiWindow = ui; self.uiLabel = label
    
    local fragment = ZO_HUDFadeSceneFragment:New(ui)
    local scenes = {"hud", "hudui", "gamepad_hud", "interact"}
    for _, name in ipairs(scenes) do
        local scene = SCENE_MANAGER:GetScene(name)
        if scene then scene:AddFragment(fragment) end
    end
end

function PM:IsBusy()
    if IsUnitDead and IsUnitDead("player") then return true, 2000 end
    if IsUnitInCombat and IsUnitInCombat("player") and not self.settings.loopInCombat then return true, 1000 end
    if GetCraftingInteractionType and GetCraftingInteractionType() ~= 0 then return true, 2000 end
    
    -- Interaction Checks
    if (IsInteracting and IsInteracting()) or (GetInteractionType and GetInteractionType() ~= INTERACTION_NONE) or (IsPlayerInteractingWithObject and IsPlayerInteractingWithObject()) then return true, 1000 end
    
    -- Menu Checks
    if SCENE_MANAGER and not (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")) then
        return true, (self.settings.delayInMenu or 3000)
    end
    
    local isActionBusy, _, actionDelay = self:GetActionState()
    if isActionBusy then return true, actionDelay end
    return false, 0
end

function PM:Loop(loopID)
    if not self.settings or self.settings.paused or not self.settings.activeId then return end
    if loopID ~= self.loopToken then return end
    local data = self.mementoData[self.settings.activeId]
    if not data then self.settings.activeId = nil; return end
    
    local isBusy, busyDelay = self:IsBusy()
    if isBusy then 
        local wait = (busyDelay > 0) and busyDelay or (self.settings.delayIdle or 3000)
        zo_callLater(function() self:Loop(loopID) end, wait)
        return 
    end
    
    local remaining = 0
    if GetCollectibleCooldownAndDuration then remaining, _ = GetCollectibleCooldownAndDuration(self.settings.activeId) end
    if remaining > 1000 then zo_callLater(function() self:Loop(loopID) end, remaining + 500); return end
    
    self.isLooping = true; UseCollectible(self.settings.activeId); self.isLooping = false
    zo_callLater(function() 
        if not self.settings or not self.settings.activeId then return end
        if loopID ~= self.loopToken then return end
        local cooldown = 0
        if GetCollectibleCooldownAndDuration then cooldown, _ = GetCollectibleCooldownAndDuration(self.settings.activeId) end
        local nextDelay = (cooldown > 0) and (cooldown + 500) or (data.dur + (self.settings.delayIdle or 3000))
        zo_callLater(function() self:Loop(loopID) end, nextDelay)
    end, 1000)
end

function PM:StartLoop(collectibleId)
    self.settings.activeId = collectibleId; self.settings.paused = false; self.loopToken = (self.loopToken or 0) + 1
    local currentToken = self.loopToken; local isBusy, busyDelay = self:IsBusy()
    if isBusy then 
        local wait = (busyDelay > 0) and busyDelay or (self.settings.delayIdle or 3000)
        zo_callLater(function() self:Loop(currentToken) end, wait)
    else 
        self.isLooping = true; UseCollectible(collectibleId); self.isLooping = false
        zo_callLater(function() self:Loop(currentToken) end, self.mementoData[collectibleId].dur) 
    end
end

function PM:HookGameUI()
    ZO_PreHook("UseCollectible", function(collectibleId)
        if not PM.settings then return end
        if PM.isLooping then return end
        if PM.settings.activeId == collectibleId then
             PM.settings.activeId = nil; PM.settings.paused = false; PM.loopToken = (PM.loopToken or 0) + 1
             PM:Log("Auto-loop Stopped", true, "stop"); PM.pendingId = 0; return
        end
        if PM.mementoData[collectibleId] then
            local isSwitching = (PM.settings.activeId ~= nil)
            PM.settings.activeId = collectibleId; PM.settings.paused = false; PM.loopToken = (PM.loopToken or 0) + 1; PM.pendingId = collectibleId 
            if isSwitching then PM:Log("Memento switched to: " .. PM.mementoData[collectibleId].name, true, "activation")
            else PM:Log("Auto-loop started: " .. PM.mementoData[collectibleId].name, true, "activation") end
            local currentToken = PM.loopToken
            zo_callLater(function() PM:Loop(currentToken) end, PM.mementoData[collectibleId].dur)
        else
            if PM.settings.activeId then
                PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1; PM.pendingId = 0
                PM:Log("Auto-loop Stopped", true, "stop")
            end
        end
    end)
end

function PM.Sync:Initialize()
  SLASH_COMMANDS["/pmsync"] = function(argString)
    if not argString or string.len(argString) < 1 then PM:Log("Usage: /pmsync <searchterm> OR /pmsync stop", true, "error"); return end
    if string.lower(argString) == "stop" then
         local function TryChat() StartChatInput("PM STOP", CHAT_CHANNEL_PARTY) end
         if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry("PM STOP") end
         PM:Log("Sent Group Sync Command.", true, "sync")
         if PM.settings then PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1 end
         return
    end
    local search = string.lower(argString)
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
      local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
      if id and IsCollectibleUnlocked(id) then
          if string.find(string.lower(GetCollectibleName(id)), search, 1, true) then
            local link = GetCollectibleLink(id, LINK_STYLE_BRACKETS)
            local function TryChat() StartChatInput(string.format("PM %s", link), CHAT_CHANNEL_PARTY) end
            if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry(string.format("PM %s", link)) end
            return
          end
      end
    end
    PM:Log("Memento not found or not unlocked.", true, "error")
  end

  local function attemptCollectible(id)
    if not IsCollectibleUsable(id) then return end
    if not PM.settings then return end 
    if IsUnitInCombat and IsUnitInCombat("player") and PM.settings.sync.ignoreInCombat then return end
    PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1
    if PM.mementoData[id] then
        PM:Log("Sync received! Looping: " .. PM.mementoData[id].name, true, "sync")
        PM:StartLoop(id)
    else
        PM:Log("Sync received! Playing: " .. GetCollectibleName(id), true, "sync")
        UseCollectible(id)
    end
  end

  local function onSyncChatMessage(eventCode, channelType, fromName, text)
    if channelType ~= CHAT_CHANNEL_PARTY then return end
    if string.match(text, "^PM STOP") then
        if PM.settings then 
            PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1
            PM:Log("Group Stop received from " .. fromName, true, "stop") 
        end
        return
    end
    local id
    for collectibleId in string.gmatch(text, "^PM |H1:collectible:(%d+)|h|h$") do id = tonumber(collectibleId) end
    if not id then for collectibleId in string.gmatch(text, "^PM (%d+)$") do id = tonumber(collectibleId) end end
    if not id or not IsCollectibleUnlocked(id) then return end
    if fromName == GetUnitDisplayName("player") then return end
    if not PM.settings then return end 
    local delay = PM.settings.sync.delay or 0
    if PM.settings.sync.random then delay = math.random(0, delay) end
    if delay == 0 then attemptCollectible(id) else zo_callLater(function() attemptCollectible(id) end, delay) end
  end
  EVENT_MANAGER:UnregisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL)
  EVENT_MANAGER:RegisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL, onSyncChatMessage)
end

function PM:BuildMenu()
    if PM.menuBuilt then return end
    PM.menuBuilt = true
    PM.activeNames, PM.activeIDs = {"None"}, {0}
    PM.syncNames, PM.syncIDs = {"None"}, {0}
    local sortedActive = {}
    for id, data in pairs(self.mementoData) do
        if IsCollectibleUnlocked(id) then table.insert(sortedActive, {name=data.name, id=id, dur=data.dur, stat=data.stationary}) end
    end
    table.sort(sortedActive, function(a,b) return a.name < b.name end)
    for _, t in ipairs(sortedActive) do
        local durSec = t.dur / 1000; local infoText = string.format("%s (%ds)%s", t.name, durSec, t.stat and " (Stationary)" or "")
        table.insert(PM.activeNames, infoText); table.insert(PM.activeIDs, t.id)
    end
    local sortedSync = {}
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if IsCollectibleUnlocked(id) then table.insert(sortedSync, {name=GetCollectibleName(id), id=id}) end
    end
    table.sort(sortedSync, function(a,b) return a.name < b.name end)
    for _, t in ipairs(sortedSync) do table.insert(PM.syncNames, t.name); table.insert(PM.syncIDs, t.id) end
    local LAM = LibAddonMenu2 or _G["LibAddonMenu"]
    if not LAM then return end
    local panelData = { type = "panel", name = "Permanent Memento", displayName = "|c9CD04CPermanent Memento|r", author = "@APHONlC", version = self.version, registerForRefresh = true }
    local optionsData = {}
    local function AddOption(opt) table.insert(optionsData, opt) end

    AddOption({ type = "header", name = "General Settings" })
    AddOption({
        type = "dropdown", name = "Select Active Memento", tooltip = "Select a memento. Click 'Apply' to start.", choices = PM.activeNames, choicesValues = PM.activeIDs,
        getFunc = function() if PM.pendingId == nil then return PM.settings.activeId or 0 end return PM.pendingId end,
        setFunc = function(value) PM.pendingId = value end, disabled = function() return PM.settings.randomOnZone end
    })
    AddOption({
        type = "button", name = "Activate Random Memento", tooltip = "Immediately picks and starts a random supported memento.", width = "half",
        func = function() local randId = PM:GetRandomSupported(); if randId then PM.settings.activeId = randId; PM:Log("Randomly Selected: " .. PM.mementoData[randId].name, true, "random"); PM:StartLoop(randId) end end,
    })
    AddOption({
        type = "button", name = "|c00FF00Apply Selected Memento|r", tooltip = "|c00FF00Starts the memento selected above.|r", width = "half",
        func = function()
            if PM.pendingId and PM.pendingId ~= 0 then
                PM.settings.activeId = PM.pendingId
                PM:Log("Selected via Menu: " .. (PM.mementoData[PM.pendingId].name or "Unknown"), true, "activation")
                PM:StartLoop(PM.pendingId); PM.pendingId = nil 
            elseif PM.pendingId == 0 then
                PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1; PM:Log("Auto-loop Stopped", true, "stop"); PM.pendingId = nil
            end
        end
    })
    AddOption({
        type = "checkbox", name = "Randomize on Zone Change", tooltip = "Randomly picks a supported memento whenever you change zones or reloadui.",
        getFunc = function() return PM.settings.randomOnZone end, setFunc = function(value) PM.settings.randomOnZone = value end,
    })
    AddOption({
        type = "checkbox", name = "Randomize on Login", tooltip = "Picks a random memento when you login (and keeps it active).",
        getFunc = function() return PM.settings.randomOnLogin end, setFunc = function(value) PM.settings.randomOnLogin = value end,
    })
    AddOption({
        type = "checkbox", name = "Loop in Combat", tooltip = "Allows the memento to attempt firing during combat.",
        getFunc = function() return PM.settings.loopInCombat end, setFunc = function(value) PM.settings.loopInCombat = value end,
    })
    if not IsConsoleUI() then
        AddOption({
            type = "checkbox", name = "Enable Chat Logs", tooltip = "Shows status messages in your chat window.",
            getFunc = function() return PM.settings.logEnabled end, setFunc = function(value) PM.settings.logEnabled = value end,
        })
    end
    AddOption({
        type = "checkbox", name = "Screen Announcements", tooltip = "Shows large text alerts on screen.",
        getFunc = function() return PM.settings.csaEnabled end, setFunc = function(value) PM.settings.csaEnabled = value end,
    })
    AddOption({
        type = "checkbox", name = "Performance Mode", tooltip = "Reduces UI update frequency to save resources.",
        getFunc = function() return PM.settings.performanceMode end, setFunc = function(value) PM.settings.performanceMode = value end,
    })
    AddOption({
        type = "checkbox", name = "Lock UI Position", tooltip = "Prevents the on-screen status text UI from being moved.",
        getFunc = function() return PM.settings.ui.locked end, setFunc = function(value) PM.settings.ui.locked = value; if PM.uiWindow then PM.uiWindow:SetMovable(not value) end end,
    })
    AddOption({
        type = "checkbox", name = "Toggle UI Visibility", tooltip = "Shows or hides the status text UI.",
        getFunc = function() return not PM.settings.ui.hidden end, 
        setFunc = function(value) 
            PM.settings.ui.hidden = not value
            if PM.uiWindow then PM.uiWindow:SetHidden(PM.settings.ui.hidden) end
            PM:Log("UI Visibility: " .. (PM.settings.ui.hidden and "HIDDEN" or "VISIBLE"), true, "ui")
        end,
    })
    AddOption({
        type = "slider", name = "UI Scale", tooltip = "Adjusts the size of the status text UI.", min = 0.5, max = 2.0, step = 0.1, decimals = 1,
        getFunc = function() return PM.settings.ui.scale or 1.0 end, setFunc = function(value) PM.settings.ui.scale = value; if PM.uiWindow then PM.uiWindow:SetScale(value) end end,
    })

    AddOption({ type = "header", name = "Announcement Durations (Seconds)" })
    AddOption({ type = "slider", name = "Activation Duration", tooltip = "Duration for 'Started' messages.", min=1, max=6, step=0.5, getFunc=function() return PM.settings.csaDurations.activation/1000 end, setFunc=function(v) PM.settings.csaDurations.activation = v*1000 end })
    AddOption({ type = "slider", name = "Stop Duration", tooltip = "Duration for 'Stopped' messages.", min=1, max=6, step=0.5, getFunc=function() return PM.settings.csaDurations.stop/1000 end, setFunc=function(v) PM.settings.csaDurations.stop = v*1000 end })
    AddOption({ type = "slider", name = "Sync Duration", tooltip = "Duration for Sync related messages.", min=1, max=6, step=0.5, getFunc=function() return PM.settings.csaDurations.sync/1000 end, setFunc=function(v) PM.settings.csaDurations.sync = v*1000 end })
    AddOption({ type = "slider", name = "UI Toggle Duration", tooltip = "Duration for UI Hidden/Visible messages.", min=1, max=6, step=0.5, getFunc=function() return PM.settings.csaDurations.ui/1000 end, setFunc=function(v) PM.settings.csaDurations.ui = v*1000 end })
    AddOption({ type = "slider", name = "Random/Zone Duration", tooltip = "Duration for Randomizer messages.", min=1, max=6, step=0.5, getFunc=function() return PM.settings.csaDurations.random/1000 end, setFunc=function(v) PM.settings.csaDurations.random = v*1000 end })

    AddOption({ type = "header", name = "Sync Settings" })
    AddOption({
        type = "dropdown", name = "Send Sync Request", tooltip = "Broadcasts a memento to your group to sync up animations.", choices = PM.syncNames, choicesValues = PM.syncIDs,
        getFunc = function() return 0 end, 
        setFunc = function(value) 
            if IsConsoleUI() then PM.selectedSyncId = value
            else
                if value and value ~= 0 then
                    local link = GetCollectibleLink(value, LINK_STYLE_BRACKETS)
                    local function TryChat() StartChatInput(string.format("PM %s", link), CHAT_CHANNEL_PARTY) end
                    if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry(string.format("PM %s", link)) end
                    PM:Log("Sent Group Sync Command.", true, "sync")
                end
            end
        end,
    })
    if IsConsoleUI() then
        AddOption({
            type = "button", name = "Apply Sync Request", tooltip = "Sends the sync request selected in the dropdown above.",
            func = function()
                if PM.selectedSyncId and PM.selectedSyncId ~= 0 then
                    local link = GetCollectibleLink(PM.selectedSyncId, LINK_STYLE_BRACKETS)
                    local function TryChat() StartChatInput(string.format("PM %s", link), CHAT_CHANNEL_PARTY) end
                    if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry(string.format("PM %s", link)) end
                    PM:Log("Sent Group Sync Command.", true, "sync")
                end
            end
        })
    end
    AddOption({
        type = "button", name = "Send Random Sync Request", tooltip = "Picks a random unlocked memento and broadcasts it to group.",
        func = function()
            local randId = PM:GetRandomAny(); if randId then
                local link = GetCollectibleLink(randId, LINK_STYLE_BRACKETS)
                local function TryChat() StartChatInput(string.format("PM %s", link), CHAT_CHANNEL_PARTY) end
                if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry(string.format("PM %s", link)) end
                PM:Log("Sent Group Sync Command.", true, "sync")
            end
        end
    })
    AddOption({
        type = "button", name = "Send Group Stop Command", tooltip = "Sends a STOP command to your group, halting their loops.",
        func = function()
            local function TryChat() StartChatInput("PM STOP", CHAT_CHANNEL_PARTY) end
            if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry("PM STOP") end
            PM:Log("Sent Group Sync Command.", true, "sync")
        end
    })
    AddOption({
        type = "checkbox", name = "Randomize Sync Delay", tooltip = "Adds random variation to the sync start time.",
        getFunc = function() return PM.settings.sync.random end, setFunc = function(value) PM.settings.sync.random = value end,
    })
    AddOption({
        type = "slider", name = "Sync Delay (ms)", tooltip = "Fixed delay before starting a synced memento.", min = 0, max = 5000, step = 100,
        getFunc = function() return PM.settings.sync.delay end, setFunc = function(value) PM.settings.sync.delay = value end,
        disabled = function() return PM.settings.sync.random end
    })

    AddOption({ type = "header", name = "Delays" })
    AddOption({ type = "slider", name = "Idle Loop Delay", tooltip = "Base delay between loops when not busy.", min = 500, max = 10000, step = 100, getFunc = function() return PM.settings.delayIdle end, setFunc = function(value) PM.settings.delayIdle = value end })
    AddOption({ type = "slider", name = "Menu/Interaction Delay (ms)", tooltip = "Wait time when in menus or interacting.", min = 500, max = 10000, step = 100, getFunc = function() return PM.settings.delayInMenu end, setFunc = function(value) PM.settings.delayInMenu = value end })
    AddOption({ type = "slider", name = "Resurrecting Delay (ms)", tooltip = "Wait time when resurrecting a player.", min = 500, max = 5000, step = 100, getFunc = function() return PM.settings.delayResurrect end, setFunc = function(value) PM.settings.delayResurrect = value end })
    AddOption({ type = "slider", name = "Teleport/Reload Delay", tooltip = "Wait time after zoning or reloading.", min = 1000, max = 10000, step = 100, getFunc = function() return PM.settings.delayTeleport end, setFunc = function(value) PM.settings.delayTeleport = value end })
    AddOption({ type = "slider", name = "Move/Walk Delay (ms)", tooltip = "Wait time when moving.", min = 500, max = 5000, step = 100, getFunc = function() return PM.settings.delayMove end, setFunc = function(value) PM.settings.delayMove = value end })
    AddOption({ type = "slider", name = "Sprinting Delay (ms)", tooltip = "Wait time when sprinting.", min = 500, max = 5000, step = 100, getFunc = function() return PM.settings.delaySprint end, setFunc = function(value) PM.settings.delaySprint = value end })
    AddOption({ type = "slider", name = "Blocking Delay (ms)", tooltip = "Wait time when blocking.", min = 500, max = 5000, step = 100, getFunc = function() return PM.settings.delayBlock end, setFunc = function(value) PM.settings.delayBlock = value end })
    AddOption({ type = "slider", name = "Swimming Delay (ms)", tooltip = "Wait time when swimming.", min = 500, max = 5000, step = 100, getFunc = function() return PM.settings.delaySwim end, setFunc = function(value) PM.settings.delaySwim = value end })
    AddOption({ type = "slider", name = "Sneaking Delay (ms)", tooltip = "Wait time when sneaking.", min = 500, max = 5000, step = 100, getFunc = function() return PM.settings.delaySneak end, setFunc = function(value) PM.settings.delaySneak = value end })
    AddOption({ type = "slider", name = "Mount Delay (ms)", tooltip = "Wait time when mounted.", min = 500, max = 5000, step = 100, getFunc = function() return PM.settings.delayMount end, setFunc = function(value) PM.settings.delayMount = value end })

    AddOption({ type = "header", name = "Commands" })
    if not IsConsoleUI() then
        AddOption({
            type = "button", name = "|cFF0000Force Console Mode|r", tooltip = "Simulates Console flow on PC.",
            func = function() local current = GetCVar("ForceConsoleFlow.2"); local newVal = (current == "1") and "0" or "1"; SetCVar("ForceConsoleFlow.2", newVal); ReloadUI("ingame") end,
        })
    end
    AddOption({
        type = "button", name = "Stop Loop", tooltip = "Stops the currently running memento loop.",
        func = function() PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1; PM.pendingId = 0; PM.settings.randomOnZone = false; PM.settings.randomOnLogin = false; PM:Log("Auto-loop Stopped", true, "stop") end,
    })
    AddOption({
        type = "button", name = "Reset UI Position", tooltip = "Resets the status text UI position (Compass).",
        func = function() PM.settings.ui.left = PM.defaults.ui.left; PM.settings.ui.top = PM.defaults.ui.top; PM.uiWindow:ClearAnchors(); PM.uiWindow:SetAnchor(LEFT, ZO_Compass, RIGHT, 25, 0); PM:Log("UI Position Reset.", true, "ui") end,
    })
    AddOption({
        type = "button", name = "Reload UI", tooltip = "Reloads the User Interface.", func = function() ReloadUI("ingame") end,
    })
    AddOption({
        type = "button", name = "|cFF0000Reset to Defaults|r", tooltip = "|cFF0000Resets all settings to default values.|r",
        func = function() 
            local d = PM.defaults
            PM.settings.activeId = nil; PM.settings.paused = false; PM.settings.logEnabled = d.logEnabled; PM.settings.csaEnabled = d.csaEnabled
            PM.settings.randomOnLogin = d.randomOnLogin; PM.settings.randomOnZone = d.randomOnZone; PM.settings.loopInCombat = d.loopInCombat; PM.settings.performanceMode = d.performanceMode
            PM.settings.delayMove=d.delayMove; PM.settings.delaySprint=d.delaySprint; PM.settings.delayBlock=d.delayBlock; PM.settings.delayCast=d.delayCast
            PM.settings.delaySwim=d.delaySwim; PM.settings.delaySneak=d.delaySneak; PM.settings.delayMount=d.delayMount; PM.settings.delayIdle=d.delayIdle
            PM.settings.delayTeleport=d.delayTeleport; PM.settings.delayResurrect=d.delayResurrect; PM.settings.delayInMenu=d.delayInMenu
            PM.settings.sync.delay=d.sync.delay; PM.settings.sync.random=d.sync.random; PM.settings.sync.ignoreInCombat=d.sync.ignoreInCombat
            PM.settings.ui.left=d.ui.left; PM.settings.ui.top=d.ui.top; PM.settings.ui.locked=d.ui.locked; PM.settings.ui.hidden=d.ui.hidden; PM.settings.ui.scale=(IsConsoleUI() and 0.7 or 1.0)
            PM.settings.csaDurations = {activation=6000, stop=6000, sync=6000, ui=6000, random=6000, error=6000}
            ReloadUI("ingame") 
        end,
    })
    
    AddOption({
        type = "description", title = "Commands Info",
        text = "|c00FF00/pmem <name>|r - Start memento\n|c00FF00/pmem stop|r - Stop loop\n|c00FF00/pmem ui|r - Toggle UI\n|c00FF00/pmem lock|r - Lock UI\n|c00FF00/pmsync <name>|r - Sync memento\n|c00FF00/pmsync stop|r - Stop group\n\n|cFF0000WARNING:|r Force Console Mode requires reload. To revert if stuck:\n|cFFFF00/script SetCVar(\"ForceConsoleFlow.2\", \"0\")|r",
    })

    LAM:RegisterAddonPanel("PermMementoOptions", panelData)
    LAM:RegisterOptionControls("PermMementoOptions", optionsData)
end

function PM:Init(eventCode, addOnName)
    if addOnName ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated(); self:BuildMenu(); self.pendingId = self.settings.activeId end)
    local world = GetWorldName() or "Default"
    self.acctSaved = ZO_SavedVars:NewAccountWide("PermMementoSaved", 1, world, self.defaults)
    self.charSaved = ZO_SavedVars:NewCharacterIdSettings("PermMementoSaved", 1, "Character", self.defaults)
    if self.charSaved.useAccountSettings == nil then self.charSaved.useAccountSettings = self.charDefaults.useAccountSettings end
    self:UpdateSettingsReference()
    if not self.loopToken then self.loopToken = 0 end
    self:CreateUI(); self:HookGameUI(); PM.Sync:Initialize()
    
    SLASH_COMMANDS["/pmem"] = function(extra)
        if not self.settings then return end
        local cmd = extra:lower()
        if cmd == "stop" or cmd == "off" then
            self.settings.activeId = nil; self.loopToken = (self.loopToken or 0) + 1; self:Log("Auto-loop Stopped", true, "stop"); self.pendingId = 0
        elseif cmd == "ui" then
             self.settings.ui.hidden = not self.settings.ui.hidden; self.uiWindow:SetHidden(self.settings.ui.hidden); self:Log("UI Visibility: " .. (self.settings.ui.hidden and "HIDDEN" or "VISIBLE"), true, "ui")
        elseif cmd == "lock" then
            self.settings.ui.locked = not self.settings.ui.locked; self.uiWindow:SetMovable(not self.settings.ui.locked); self:Log("UI " .. (self.settings.ui.locked and "Locked" or "Unlocked"), true, "ui")
        elseif cmd == "uireset" then
            self.settings.ui.left = self.defaults.ui.left; self.settings.ui.top = self.defaults.ui.top; self.uiWindow:ClearAnchors(); self.uiWindow:SetAnchor(LEFT, ZO_Compass, RIGHT, 25, 0); self:Log("UI Position Reset.", true, "ui")
        elseif cmd == "current" then
             if self.settings.activeId then d("[PM] Active: " .. (self.mementoData[self.settings.activeId].name or "Unknown")) else d("[PM] Inactive") end
        else
            local found = false
            for id, info in pairs(self.mementoData) do
                if string.find(string.lower(info.name), cmd, 1, true) then
                    if IsCollectibleUnlocked(id) then self:Log("Auto-loop started: " .. info.name, true, "activation"); self:StartLoop(id); found = true; break else self:Log("Memento found but NOT unlocked: " .. info.name, true, "error"); found = true; break end
                end
            end
            if not found then self:Log("Memento not found or not supported.", true, "error") end
        end
    end
end

function PM:OnPlayerActivated()
    local delay = self.settings.delayTeleport or 3000
    if self.settings.randomOnZone then
        local randId = self:GetRandomSupported()
        if randId then self.settings.activeId = randId; self:Log("Zone Random: " .. self.mementoData[randId].name, true, "random") end
    elseif self.settings.randomOnLogin and not self.settings.activeId then
        local randId = self:GetRandomSupported()
        if randId then self.settings.activeId = randId; self:Log("Login Random: " .. self.mementoData[randId].name, true, "random") end
    end
    if self.settings and self.settings.activeId and not self.settings.paused then
        local currentToken = self.loopToken; zo_callLater(function() self:Loop(currentToken) end, delay)
    end
end

EVENT_MANAGER:RegisterForEvent(PM.name, EVENT_ADD_ON_LOADED, function(...) PM:Init(...) end)
