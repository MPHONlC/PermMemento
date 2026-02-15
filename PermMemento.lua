-----------------------------------------------------------
-- PermMemento Add-on (@APHONlC) | API: 101049
-----------------------------------------------------------
local PM = {
    name = "PermMemento",
    version = "0.7.9",
    -- Default settings
    defaults = {
        activeId = nil, paused = false, logEnabled = not IsConsoleUI(), csaEnabled = true,
        csaCleanupEnabled = true,
        randomOnLogin = false, randomOnZone = false, loopInCombat = false, performanceMode = true,
        useAccountSettings = false, showInHUD = true, unrestricted = false, autoCleanup = true,
        lastVersion = "0.7.9", versionHistory = {},
        learnedData = {}, 
        favorites = {}, 
        stopSpinning = true, 
        totalLoops = 0,
        mementoUsage = {},
        installDate = nil,
         -- Delays
        delayIdle=3, delayInMenu=5, delayCombatEnd=5, 
        delayResurrect=5, delayTeleport=5, delayMove=3, delaySprint=3, 
        delayBlock=3, delaySwim=5, delaySneak=3, delayMount=5, delayCast=3,
        -- CSA Durations
        csaDurations = {
            activation=3, stop=3, sync=3, ui=3, random=3, error=3, settings=3, cleanup=3
        },
        -- UI Defaults
        ui = { left=1627, top=32, locked=false, hidden=false, scale=(IsConsoleUI() and 1.0 or 1.0) },
        uiMenu = { left=-1, top=-1, scale=(IsConsoleUI() and 1.2 or 1.0) },
        -- Sync Defaults
        sync = { delay=0, random=false, ignoreInCombat=true, enabled=false }
    },
    isLooping = false, isScanning = false, isMemCheckQueued = false,
    loopToken = 0, lastPos = {x=0,y=0,z=0,t=0}, isMoving = false,
    
    -- Sync Flags
    isSyncFiring = false,
    pendingSyncId = nil, 
    
    -- Timer Tracking & UI State
    nextFireTime = 0,
    learnedCount = 0,
    sessionLoops = 0,
    currentFavCount = 0,
    currentSVSizeKB = 0,
    nextRandomPrecalc = nil,
    
    -- Memory Auto Cleanup States
    memState = 0, -- 0=idle, 1=cleaning, 2=freed, 3=cooldown
    memFreed = 0,
    memNextSweep = 0,
    memDisplayUntil = 0,
    
    -- Tables for Dropdowns
    activeNames = {}, activeIDs = {}, 
    syncNames = {}, syncIDs = {},
    learnedListNames = {}, learnedListValues = {},
    
    -- Favorite Dropdown Data
    favAllNames = {}, favAllIDs = {}, 
    favCurrentNames = {}, favCurrentIDs = {}, 
    selectedFavCandidate = nil, 
    selectedFavRemoval = nil, 

    -- Selection Variables
    selectedSyncId = nil, pendingId = nil, menuBuilt = false, Sync = {},
    charListValues = {}, charListNames = {}, selectedCharCopy = nil, selectedCharDelete = nil,
    selectedLearnedId = nil, 
    
    -- Controls References
    ctrlActiveDropdown = nil, ctrlSyncDropdown = nil, ctrlLearnedDropdown = nil,
    ctrlFavCandidateDropdown = nil, ctrlFavRemoveDropdown = nil
}

-- MEMENTO TABLE
PM.mementoData = {
    [336]   = {id = 336,   refID = 21226,  dur = 13000,  name = "Finvir's Trinket"},
    [341]   = {id = 341,   refID = 26829,  dur = 27000,  name = "Almalexia's Enchanted Lantern"},
    [349]   = {id = 349,   refID = 42008,  dur = 16000,  name = "Token of Root Sunder"},
    [594]   = {id = 594,   refID = 85344,  dur = 180000, name = "Storm Atronach Aura"},
    [758]   = {id = 758,   refID = 86978,  dur = 180000, name = "Floral Swirl Aura"},
    [759]   = {id = 759,   refID = 86977,  dur = 180000, name = "Wild Hunt Transform"},
    [760]   = {id = 760,   refID = 86976,  dur = 180000, name = "Wild Hunt Leaf-Dance Aura"},
    [1183]  = {id = 1183,  refID = 92868,  dur = 180000, name = "Dwemervamidium Mirage"},
    [9361]  = {id = 9361,  refID = 153672, dur = 18000,  name = "Inferno Cleats"},
    [9862]  = {id = 9862,  refID = 162813, dur = 180000, name = "Astral Aurora Projector"},
    [10652] = {id = 10652, refID = 175730, dur = 180000, name = "Soul Crystals of the Returned"},
    [10706] = {id = 10706, refID = 176334, dur = 180000, name = "Blossom Bloom"},
    [13092] = {id = 13092, refID = 229843, dur = 70500,  name = "Remnant of Meridia's Light"},
    [347]   = {id = 347,   refID = 41950,  dur = 33000,  name = "Fetish of Anger"},
    [596]   = {id = 596,   refID = 85349,  dur = 18000,  name = "Storm Atronach Transform"},
    [1167]  = {id = 1167,  refID = 91365,  dur = 6000,   name = "The Pie of Misrule"},
    [1182]  = {id = 1182,  refID = 92867,  dur = 10000,  name = "Dwarven Tonal Forks"},
    [1384]  = {id = 1384,  refID = 97274,  dur = 18000,  name = "Swarm of Crows"},
    [10236] = {id = 10236, refID = 166513, dur = 30000,  name = "Mariner's Nimbus Stone"},
    [10371] = {id = 10371, refID = 170722, dur = 60000,  name = "Fargrave Occult Curio"},
    [11480] = {id = 11480, refID = 195745, dur = 180000,  name = "Summoned Booknado"},
    [13105] = {id = 13105, refID = 229989, dur = 60000,  name = "Surprising Snowglobe"},
    [13736] = {id = 13736, refID = 242404, dur = 195000,  name = "Shimmering Gala Gown Veil"},
}
-- Return memento data or savedvariables data
function PM:GetData(id)
    if self.mementoData[id] then return self.mementoData[id] end
    if self.acctSaved and self.acctSaved.learnedData and self.acctSaved.learnedData[id] then
        return self.acctSaved.learnedData[id]
    end
    if self.settings.unrestricted then
        return { id = id, refID = 0, dur = 10000, name = (GetCollectibleName(id) or "Unknown") }
    end
    return nil
end
-- Estimate size of data table
function PM:EstimateTableSize(t, seen)
    if type(t) ~= "table" then return 0 end
    seen = seen or {}
    if seen[t] then return 0 end
    seen[t] = true
    local size = 0
    for k, v in pairs(t) do
        if type(k) == "string" then size = size + string.len(k) else size = size + 8 end
        if type(v) == "string" then size = size + string.len(v)
        elseif type(v) == "number" then size = size + 8
        elseif type(v) == "boolean" then size = size + 4
        elseif type(v) == "table" then size = size + self:EstimateTableSize(v, seen)
        end
    end
    return size
end
-- print stats on the statistics UI panel
function PM:GetTopMementos()
    if not self.acctSaved or not self.acctSaved.mementoUsage then return "\n  None" end
    local sortable = {}
    for id, count in pairs(self.acctSaved.mementoUsage) do
        table.insert(sortable, {id = id, count = count})
    end
    table.sort(sortable, function(a, b) return a.count > b.count end)
    
    local result = ""
    for i = 1, math.min(5, #sortable) do
        local name = GetCollectibleName(sortable[i].id) or "Unknown"
        result = result .. string.format("\n  %d. %s (%d loops)", i, name, sortable[i].count)
    end
    if result == "" then return "\n  None" end
    return result
end

function PM:GetStatsText()
    local currentMB = 0
    if IsConsoleUI() and GetTotalUserAddOnMemoryPoolUsageMB then
        currentMB = GetTotalUserAddOnMemoryPoolUsageMB()
    else
        currentMB = collectgarbage("count") / 1024
    end

    local pmMemMB = PM:EstimateTableSize(PM) / (1024 * 1024)
    local memWarning = ""
    local luaLimitTxt = ""
    if IsConsoleUI() then
        luaLimitTxt = "100 MB (Hard Limit)"
        if currentMB > 85 then memWarning = "|cFF0000(EXCEEDS CONSOLE LIMIT)|r"
        else memWarning = "|c00FF00(Safe)|r" end
    else
        luaLimitTxt = "Dynamic [512MB] (Auto-Scaling)"
        if currentMB > 400 then memWarning = "|cFFA500(High Global Memory)|r"
        else memWarning = "|c00FF00(Safe)|r" end
    end

    local favCount = PM.currentFavCount or 0
    local totalLoops = (PM.acctSaved and PM.acctSaved.totalLoops) or 0
    local installDate = (PM.acctSaved and PM.acctSaved.installDate) or "Unknown"
    local vHistory = (PM.acctSaved and PM.acctSaved.versionHistory) or {PM.version}
    local vHistoryText = table.concat(vHistory, ", ")
    
    local svStatus = _G["PermMementoSaved"] and "|c00FF00Healthy|r" or "|cFF0000Corrupted|r"
    local svSizeKB = PM.currentSVSizeKB or 0
    local svWarning = ""
    
    if IsConsoleUI() then
        if svSizeKB > 1000 then svWarning = "|cFFA500(WARNING: Large Console File)|r" else svWarning = "|c00FF00(Safe)|r" end
    else
        if svSizeKB > 5000 then svWarning = "|cFFA500(Large File)|r" else svWarning = "|c00FF00(Safe)|r" end
    end
    
    local topMementos = PM:GetTopMementos()

    return string.format(
        "Installed Since: %s\nVersion History: %s\nMax Lua Memory: %s\nGlobal Addon Memory: %.2f MB %s\nPermMemento Data Footprint: ~%.2f MB (Estimated)\nSV Disk Size: ~%d KB (%s) %s\nSession Loops: %d | Total Loops: %d\nFavorites: %d | Learned: %d\n\nMost Used Mementos:%s", 
        installDate, vHistoryText, luaLimitTxt, currentMB, memWarning, pmMemMB, svSizeKB, svStatus, svWarning, PM.sessionLoops, totalLoops, favCount, PM.learnedCount, topMementos
    )
end

function PM:UpdateLearnedCount()
    local count = 0
    if self.acctSaved and self.acctSaved.learnedData then
        for _ in pairs(self.acctSaved.learnedData) do count = count + 1 end
    end
    self.learnedCount = count
end

function PM:UpdateFavCount()
    local count = 0
    if self.settings and self.settings.favorites then
        for k, v in pairs(self.settings.favorites) do
            if v then count = count + 1 end
        end
    end
    self.currentFavCount = count
end

function PM:UpdateSettingsReference()
    if self.charSaved and self.charSaved.useAccountSettings then self.settings = self.acctSaved else self.settings = self.charSaved end
    if not self.settings then return end
    
    if type(self.settings.ui) ~= "table" then self.settings.ui = ZO_DeepTableCopy(self.defaults.ui) end
    if type(self.settings.uiMenu) ~= "table" then self.settings.uiMenu = ZO_DeepTableCopy(self.defaults.uiMenu) end
    if type(self.settings.sync) ~= "table" then self.settings.sync = ZO_DeepTableCopy(self.defaults.sync) end
    if type(self.settings.csaDurations) ~= "table" then self.settings.csaDurations = ZO_DeepTableCopy(self.defaults.csaDurations) end
    
    if self.acctSaved and type(self.acctSaved.learnedData) ~= "table" then self.acctSaved.learnedData = {} end
    if self.settings.favorites == nil then self.settings.favorites = {} end
    if self.settings.autoCleanup == nil then self.settings.autoCleanup = true end
    if self.settings.csaCleanupEnabled == nil then self.settings.csaCleanupEnabled = true end
    
    if self.settings.ui.scale == nil then self.settings.ui.scale = (IsConsoleUI() and 1.0 or 1.0) end
    if self.settings.uiMenu.scale == nil then self.settings.uiMenu.scale = (IsConsoleUI() and 1.2 or 1.0) end
    if self.settings.showInHUD == nil then self.settings.showInHUD = true end
    if self.settings.unrestricted == nil then self.settings.unrestricted = false end
    if self.settings.stopSpinning == nil then self.settings.stopSpinning = true end
    if self.settings.sync.enabled == nil then self.settings.sync.enabled = false end
    
    if self.settings.delayCombatEnd == nil then self.settings.delayCombatEnd = self.defaults.delayCombatEnd end

    self:UpdateLearnedCount()
    self:UpdateUIAnchor()
    self:UpdateUIScenes()
    self:UpdateFavoritesChoices()
    PM:ApplySpinStop()
end

-- Data Management & Migration
function PM:MigrateData()
    local delaysToConvert = {"delayMove", "delaySprint", "delayBlock", "delayCast", "delaySwim", "delaySneak", "delayMount", "delayIdle", "delayTeleport", "delayResurrect", "delayInMenu", "delayCombatEnd"}
    
    if self.settings then
        for _, key in ipairs(delaysToConvert) do
            if self.settings[key] and self.settings[key] > 20 then
                self.settings[key] = self.settings[key] / 1000
            end
        end
        for k, v in pairs(self.settings.csaDurations) do
            if v > 10 then self.settings.csaDurations[k] = v / 1000 end
        end
        if self.settings.sync and self.settings.sync.delay and self.settings.sync.delay > 20 then
            self.settings.sync.delay = self.settings.sync.delay / 1000
        end
    end

    if self.acctSaved and self.acctSaved.learnedData then
        local migratedCount = 0
        for id, data in pairs(self.acctSaved.learnedData) do
            if data.aid and not data.refID then
                data.refID = data.aid
                data.aid = nil
                migratedCount = migratedCount + 1
            end
        end
    end
    
    -- Erase obsolete data from savedvariables
    if _G["PermMementoSaved"] then
        for worldName, worldData in pairs(_G["PermMementoSaved"]) do
            if type(worldData) == "table" then
                for accountName, accountData in pairs(worldData) do
                    if type(accountData) == "table" then
                        for profileId, profileData in pairs(accountData) do
                            if type(profileData) == "table" then
                                -- Clean Accountwide Data
                                if profileId == "$AccountWide" then
                                    profileData["autoResumeScan"] = nil
                                -- Clean Per Character Data
                                elseif profileData["Character"] then
                                    profileData["Character"]["autoResumeScan"] = nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- safety check for currently loaded references
    if self.acctSaved then self.acctSaved.autoResumeScan = nil end
    if self.charSaved then self.charSaved.autoResumeScan = nil end
end
-- Logs
function PM:Log(msg, isCSA, durKey)
    if not self.settings then return end
    if self.settings.csaEnabled and isCSA and CENTER_SCREEN_ANNOUNCE then
        local durSec = (durKey and self.settings.csaDurations[durKey]) or 6
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        params:SetText("|cFFD700" .. tostring(msg) .. "|r"); params:SetLifespanMS(durSec * 1000)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end
    if self.settings.logEnabled then
        local formattedMsg = "|cFF9900[PM]|r " .. string.gsub(tostring(msg), "\n", " ")
        if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage(formattedMsg) end
    end
end
-- Prevent camera spinning in certain Menus
function PM:ApplySpinStop()
    if IsConsoleUI() then return end
    local scenes = { "character", "stats", "inventory", "interact" }
    for _, sceneName in ipairs(scenes) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            if self.settings.stopSpinning and scene:HasFragment(FRAME_PLAYER_FRAGMENT) then
                scene:RemoveFragment(FRAME_PLAYER_FRAGMENT)
            elseif not self.settings.stopSpinning and not scene:HasFragment(FRAME_PLAYER_FRAGMENT) then
                scene:AddFragment(FRAME_PLAYER_FRAGMENT)
            end
        end
    end
end

-- Fave selection
function PM:GetRandomSupported()
    local available = {}
    if self.settings.favorites then
        for id, enabled in pairs(self.settings.favorites) do
            if enabled and IsCollectibleUnlocked(id) then
                local isHardcoded = (self.mementoData[id] ~= nil)
                -- Only allow it into the pool if UNRESTRICTED MODE is ON or in PM.mementoData
                if self.settings.unrestricted or isHardcoded then
                     table.insert(available, id)
                end
            end
        end
    end
    if #available > 0 then return available[math.random(#available)] end
    for id, _ in pairs(self.mementoData) do if IsCollectibleUnlocked(id) then table.insert(available, id) end end
    if self.settings.unrestricted and self.acctSaved and self.acctSaved.learnedData then
        for id, _ in pairs(self.acctSaved.learnedData) do
             if IsCollectibleUnlocked(id) then table.insert(available, id) end
        end
    end
    return #available > 0 and available[math.random(#available)] or nil
end

function PM:GetRandomLearned()
    if not self.acctSaved or not self.acctSaved.learnedData then return nil end
    local available = {}
    for id, _ in pairs(self.acctSaved.learnedData) do
        if IsCollectibleUnlocked(id) then table.insert(available, id) end
    end
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
-- Calculate 3D distance for Movement Checks
function PM:UpdateMovementState()
    if not GetUnitRawWorldPosition then return end
    local x, _, z = GetUnitRawWorldPosition("player"); local time = GetGameTimeMilliseconds()
    if self.lastPos.t == 0 then self.lastPos = {x=x, z=z, t=time}; self.isMoving = false; return end
    if (time - self.lastPos.t) > 100 then 
        local dist = zo_sqrt((x - self.lastPos.x)^2 + (z - self.lastPos.z)^2); self.isMoving = (dist > 0.5); self.lastPos = {x=x, z=z, t=time}
    end
end
-- Return the current action state and appropriate delay
function PM:GetActionState()
    if IsResurrecting and IsResurrecting() then return true, "|cFF0000(Resurrecting)|r", (self.settings.delayResurrect or 5) * 1000 end
    if IsUnitReincarnating and IsUnitReincarnating("player") then return true, "|cFF0000(Reviving)|r", (self.settings.delayResurrect or 5) * 1000 end
    local blocking = false
    if IsBlockActive and IsBlockActive() then blocking = true elseif IsUnitBlocking and IsUnitBlocking("player") then blocking = true end
    if blocking then return true, "|cFF4500(Blocking)|r", (self.settings.delayBlock or 5) * 1000 end
    if IsSprinting and IsSprinting() then return true, "|c00CED1(Sprinting)|r", (self.settings.delaySprint or 5) * 1000 end
    if IsUnitSwimming and IsUnitSwimming("player") then return true, "|c0064D2(Swimming)|r", (self.settings.delaySwim or 5) * 1000 end
    if IsMounted and IsMounted("player") then return true, "|cFFF000(Mounted)|r", (self.settings.delayMount or 5) * 1000 end
    if GetUnitStealthState and GetUnitStealthState("player") ~= STEALTH_STATE_NONE then return true, "|c1EBEA5(Sneaking)|r", (self.settings.delaySneak or 5) * 1000 end
    if self.isMoving then return true, "|c00CED1(Moving)|r", (self.settings.delayMove or 5) * 1000 end
    return false, "", 0
end
-- UI Anchor Management
function PM:UpdateUIAnchor()
    if not self.uiWindow or not self.settings then return end
    self.uiWindow:ClearAnchors()
    self.uiWindow:SetMovable(not self.settings.ui.locked)
    if self.settings.ui.hidden then self.uiWindow:SetHidden(true) end
    
    local xOffset = 0
    if _G["PP"] then xOffset = 0.5 end 
    
    if self.settings.showInHUD then
        self.uiWindow:SetScale(self.settings.ui.scale or (IsConsoleUI() and 1.0 or 1.0))
        
        if self.settings.ui.left == self.defaults.ui.left and self.settings.ui.top == self.defaults.ui.top then
            if IsConsoleUI() then self.uiWindow:SetAnchor(LEFT, ZO_Compass, RIGHT, 15, 0)
            else self.uiWindow:SetAnchor(LEFT, ZO_Compass, RIGHT, 25 + xOffset, -5) end
        else 
            self.uiWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.settings.ui.left, self.settings.ui.top) 
        end
    else
        self.uiWindow:SetScale(self.settings.uiMenu.scale or (IsConsoleUI() and 1.2 or 1.0))
        if self.settings.uiMenu.left == -1 and self.settings.uiMenu.top == -1 then
            if IsConsoleUI() then
                if ZO_GamepadGenericHeader then self.uiWindow:SetAnchor(TOPLEFT, ZO_GamepadGenericHeader, TOPLEFT, 1012.5 + xOffset, 1139.6)
                else self.uiWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 1012.5 + xOffset, 1139.6) end
            else
                if ZO_CollectionsBook_TopLevelSearchBox then self.uiWindow:SetAnchor(LEFT, ZO_CollectionsBook_TopLevelSearchBox, RIGHT, 10 + xOffset, 0)
                else self.uiWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100 + xOffset, 100) end
            end
        else
            self.uiWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.settings.uiMenu.left, self.settings.uiMenu.top)
        end
    end
end
-- UI management, where it shows up
function PM:UpdateUIScenes()
    if not self.hudFragment or not self.menuFragment then return end
    local hudScenes = {"hud", "hudui", "gamepad_hud", "interact"}
    local menuScenes = {"collectionsBook", "gamepad_collections_book", "gamepadCollectionsBook"}
    
    for _, name in ipairs(hudScenes) do
        local scene = SCENE_MANAGER:GetScene(name)
        if scene and scene:HasFragment(self.hudFragment) then scene:RemoveFragment(self.hudFragment) end
    end
    for _, name in ipairs(menuScenes) do
        local scene = SCENE_MANAGER:GetScene(name)
        if scene and scene:HasFragment(self.menuFragment) then scene:RemoveFragment(self.menuFragment) end
    end
    if self.settings.showInHUD then
        for _, name in ipairs(hudScenes) do
            local scene = SCENE_MANAGER:GetScene(name)
            if scene then scene:AddFragment(self.hudFragment) end
        end
    else
        for _, name in ipairs(menuScenes) do
            local scene = SCENE_MANAGER:GetScene(name)
            if scene then scene:AddFragment(self.menuFragment) end
        end
    end
    if self.settings.ui.hidden then
        self.uiWindow:SetHidden(true)
    else
        local currentScene = SCENE_MANAGER:GetCurrentScene()
        if currentScene then
            if self.settings.showInHUD and currentScene:HasFragment(self.hudFragment) then self.uiWindow:SetHidden(false)
            elseif not self.settings.showInHUD and currentScene:HasFragment(self.menuFragment) then self.uiWindow:SetHidden(false)
            else self.uiWindow:SetHidden(true) end
        else self.uiWindow:SetHidden(true) end
    end
    self:UpdateUIAnchor()
end

function PM:CreateUI()
    local ui = WINDOW_MANAGER:CreateControl("PermMementoUI", GuiRoot, CT_TOPLEVELCONTROL)
    ui:SetClampedToScreen(true); ui:SetMouseEnabled(true)
    ui:SetDrawTier(DT_OVERLAY); ui:SetDrawLayer(DL_OVERLAY); ui:SetDrawLevel(100)
    ui:SetHidden(true)
    self.uiWindow = ui
    self:UpdateUIAnchor()

    ui:SetHandler("OnMoveStop", function(control) 
        if not PM.settings then return end 
        if PM.settings.showInHUD then
            PM.settings.ui.left = control:GetLeft(); PM.settings.ui.top = control:GetTop()
        else
            PM.settings.uiMenu.left = control:GetLeft(); PM.settings.uiMenu.top = control:GetTop()
        end
    end)
    
    local bg = WINDOW_MANAGER:CreateControl("PermMementoBG", ui, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, ui, TOPLEFT, 0, 0); bg:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0.6); bg:SetEdgeColor(0.6, 0.6, 0.6, 0.8); bg:SetEdgeTexture(nil, 1, 1, 1, 0)
    
    local label = WINDOW_MANAGER:CreateControl("PermMementoLabel", ui, CT_LABEL)
    if IsInGamepadPreferredMode() then label:SetFont("ZoFontGamepad22") else label:SetFont("ZoFontGameSmall") end
    label:SetColor(1, 1, 1, 1); label:SetText("[PM] Ready"); label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    
    local function UpdateSize() ui:SetDimensions(label:GetTextWidth() + 20, label:GetTextHeight() + 10) end
    local lastUpdate = 0
    -- UI Update Loop control
    ui:SetHandler("OnUpdate", function(control, time)
        PM:UpdateMovementState()
        if not PM.settings then return end 
        
        local refreshRate = 0.25
        if (time - lastUpdate < refreshRate) then return end
        lastUpdate = time

        local data = PM:GetData(PM.settings.activeId)
        if not PM.settings.activeId or not data then 
            local idleText = "[PM] Inactive"
            local line2 = ""
            if PM.settings.unrestricted then line2 = line2 .. "|cFF0000[UNRESTRICTED]|r " end
            if PM.settings.sync.enabled then line2 = line2 .. "|c00BFFF(Sync: ON)|r " end
            
            if PM.memState == 1 then line2 = line2 .. "|cFFFF00[Cleaning LUA Memory...]|r "
            elseif PM.memState == 2 then line2 = line2 .. string.format("|c00FF00[%.2f MB Freed]|r ", PM.memFreed)
            elseif PM.memState == 3 then 
                local sec = math.max(0, math.floor((PM.memNextSweep - GetGameTimeMilliseconds()) / 1000))
                line2 = line2 .. string.format("|cAAAAAA[Next Memory Sweep %ds]|r ", sec)
            end
            
            line2 = string.match(line2, "^%s*(.-)%s*$")
            if line2 ~= "" then idleText = idleText .. "\n" .. line2 end
            
            label:SetText(idleText); UpdateSize(); return 
        end
        
        if PM.settings.paused then label:SetText(string.format("[PM] %s |cFF0000(Paused)|r", data.name)); UpdateSize(); return end
        
        local stateInfo = ""
        if IsUnitDead and IsUnitDead("player") then stateInfo = "|c881EE4(Dead)|r"
        elseif IsUnitInCombat and IsUnitInCombat("player") and not PM.settings.loopInCombat then stateInfo = "|cEF008C(Combat)|r"
        else
            local isBusy, actionText, _ = PM:GetActionState()
            if isBusy then stateInfo = actionText 
            elseif (IsInteracting and IsInteracting()) or (IsPlayerInteractingWithObject and IsPlayerInteractingWithObject()) then stateInfo = "|cFFA500(Busy)|r" end
        end
        
        local cooldownText = ""
        local remaining = 0
        if GetCollectibleCooldownAndDuration then remaining, _ = GetCollectibleCooldownAndDuration(PM.settings.activeId) end
        
        if remaining > 0 then 
            cooldownText = string.format(" |cFFA500(%.1fs)|r", remaining / 1000) 
        else 
            if stateInfo == "" then 
                local now = GetGameTimeMilliseconds()
                if now < PM.nextFireTime then 
                    local delaySecs = (PM.nextFireTime - now) / 1000
                    cooldownText = string.format(" |cFF69B4(Delaying... %.1fs)|r", delaySecs)
                else 
                    cooldownText = " |c00FF00(Ready)|r" 
                end
            end 
        end
        
        local finalText = string.format("[PM] %s", data.name)
        
        local extraInfo = ""
        if stateInfo ~= "" or cooldownText ~= "" then extraInfo = extraInfo .. stateInfo .. cooldownText end
        if PM.acctSaved and PM.acctSaved.learnedData and PM.acctSaved.learnedData[PM.settings.activeId] then extraInfo = extraInfo .. string.format(" |cAAAAAA(Learned: %d)|r", PM.learnedCount) end
        
        if extraInfo ~= "" then finalText = finalText .. " " .. string.match(extraInfo, "^%s*(.-)%s*$") end

        if PM.pendingSyncId then finalText = finalText .. " |cFF8800(Queued: " .. (GetCollectibleName(PM.pendingSyncId) or "?") .. ")|r" end
        if (PM.settings.randomOnZone or PM.settings.randomOnLogin) and PM.nextRandomPrecalc then finalText = finalText .. " |cAA88FF(Next: " .. (GetCollectibleName(PM.nextRandomPrecalc) or "?") .. ")|r" end

        local line2 = ""
        if PM.settings.unrestricted then line2 = line2 .. "|cFF0000[UNRESTRICTED]|r " end
        if PM.settings.sync.enabled then line2 = line2 .. "|c00BFFF(Sync: ON)|r " end
        
        if PM.memState == 1 then line2 = line2 .. "|cFFFF00[Cleaning LUA Memory...]|r "
        elseif PM.memState == 2 then line2 = line2 .. string.format("|c00FF00[%.2f MB Freed]|r ", PM.memFreed)
        elseif PM.memState == 3 then 
            local sec = math.max(0, math.floor((PM.memNextSweep - GetGameTimeMilliseconds()) / 1000))
            line2 = line2 .. string.format("|cAAAAAA[Next Memory Sweep %ds]|r ", sec)
        end
        
        line2 = string.match(line2, "^%s*(.-)%s*$")
        if line2 ~= "" then finalText = finalText .. "\n" .. line2 end

        label:SetText(finalText)
        UpdateSize()
    end)
    self.uiLabel = label
    
    self.hudFragment = ZO_HUDFadeSceneFragment:New(ui)
    self.menuFragment = ZO_FadeSceneFragment:New(ui)
    self:UpdateUIScenes()
end

-- Auto LUA Cleanup
function PM:RunManualCleanup(isAuto)
    self.memState = 1
    zo_callLater(function()
        local before = collectgarbage("count") / 1024
        collectgarbage("collect")
        local after = collectgarbage("count") / 1024
        self.memFreed = before - after
        self.memState = 0
        
        local msg = string.format("Memory Freed %.2f MB", self.memFreed)
        
        if PM.settings.logEnabled and CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("|cFF9900[PM]|r " .. msg)
        end
        
        local showCSA = PM.settings.csaEnabled
        if isAuto and not PM.settings.csaCleanupEnabled then showCSA = false end
        
        if showCSA and CENTER_SCREEN_ANNOUNCE then
            local durSec = PM.settings.csaDurations.cleanup or 6
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            params:SetText("|cFFD700" .. msg .. "|r"); params:SetLifespanMS(durSec * 1000)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end
    end, 500)
end

function PM:TriggerMemoryCheck(checkType, delay)
    if not self.settings.autoCleanup then return end
    if self.memState == 1 or self.isMemCheckQueued then return end -- Prevent overlapping checks if a cleanup is already happening

    -- Check if memory is above platform threshold. If not, IGNORE.
    local currentMB = IsConsoleUI() and GetTotalUserAddOnMemoryPoolUsageMB() or (collectgarbage("count") / 1024)
    local threshold = IsConsoleUI() and 85 or 400

    if currentMB >= threshold then
        
        -- Combat Check
        local inCombat = IsUnitInCombat and IsUnitInCombat("player")
        if inCombat or IsUnitDead("player") then return end

        self.isMemCheckQueued = true -- Lock the queue

        -- Start delay 
        zo_callLater(function()
            self.isMemCheckQueued = false
            if self.memState == 1 then return end

            -- check state after delay
            local stillInCombat = IsUnitInCombat and IsUnitInCombat("player")
            if stillInCombat or IsUnitDead("player") then return end

            -- Menu Intent Check
            if checkType == "Menu" then
                local inMenu = SCENE_MANAGER and not (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui"))
                if not inMenu then return end -- Exited before 2s ran out, IGNORE
            end

            -- Memory Check & Execution
            local recheckMB = IsConsoleUI() and GetTotalUserAddOnMemoryPoolUsageMB() or (collectgarbage("count") / 1024)
            if recheckMB >= threshold then
                self:RunManualCleanup(true)
                
                -- Fallback timer
                EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_MemFallback")
                EVENT_MANAGER:RegisterForUpdate(PM.name .. "_MemFallback", 300000, function() PM:TriggerMemoryCheck("Fallback", 0) end)
            end
        end, delay)
    else
        -- Go Dormant and kill Timers
        EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_MemFallback")
        self.memState = 0
    end
end

function PM:IsBusy()
    -- Loading Screen Check
    if not IsPlayerActivated() then return true, (self.settings.delayTeleport or 5) * 1000 end
    -- Combat Checks
    if IsUnitDead and IsUnitDead("player") then return true, 2000 end
    local inCombat = IsUnitInCombat and IsUnitInCombat("player")
    if inCombat then 
        if not self.settings.loopInCombat then
            return true, (self.settings.delayCombatEnd or 5) * 1000 
        end
    end
    -- Interaction Checks
    if GetCraftingInteractionType and GetCraftingInteractionType() ~= 0 then return true, 2000 end
    if ZO_CraftingUtils_IsPerformingCrafting and ZO_CraftingUtils_IsPerformingCrafting() then return true, 2000 end
    if SCENE_MANAGER and SCENE_MANAGER:IsShowing("interact") then return true, 2000 end
    if (IsInteracting and IsInteracting()) or (GetInteractionType and GetInteractionType() ~= INTERACTION_NONE) or (IsPlayerInteractingWithObject and IsPlayerInteractingWithObject()) then return true, 1000 end
    -- UI Checks
    if SCENE_MANAGER and not (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")) then
        return true, (self.settings.delayInMenu or 5) * 1000
    end
    -- Action States
    local isActionBusy, _, actionDelay = self:GetActionState()
    if isActionBusy then return true, actionDelay end
    return false, 0
end
-- Monitor PM:OnEffectChanged to trigger next loop
function PM:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitId)
    if not self.settings or not self.settings.activeId then return end
    
    if (self.settings.unrestricted or self.isScanning) and changeType == EFFECT_RESULT_GAINED then
          local activeId = self.settings.activeId
          if not self.mementoData[activeId] and (self.acctSaved and self.acctSaved.learnedData and not self.acctSaved.learnedData[activeId]) then
              local remaining = 0
              local cooldownDur = 10000
              if GetCollectibleCooldownAndDuration then remaining, cooldownDur = GetCollectibleCooldownAndDuration(activeId) end
              local durMS = (cooldownDur > 0) and cooldownDur or 10000 
              local name = GetCollectibleName(activeId)
              if not self.acctSaved.learnedData then self.acctSaved.learnedData = {} end
              local refId = 0
              local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(activeId)
              if collectibleData and collectibleData.GetReferenceId then refId = collectibleData:GetReferenceId() end
              if refId == 0 then refId = abilityId end 

              self.acctSaved.learnedData[activeId] = { id = activeId, refID = refId, dur = durMS, name = name }
              self:UpdateLearnedCount()
              local logMsg = string.format("Saved: %s\nID: %d | RefID: %d | Dur: %dms | Total Learned: %d", name, activeId, refId, durMS, self.learnedCount)
              PM:Log(logMsg, true, "settings")
          end
    end
    
    local data = PM:GetData(self.settings.activeId)
    local match = false
    if data and data.refID > 0 and abilityId == data.refID then match = true end
    
    if match and changeType == EFFECT_RESULT_FADED then
        self.loopToken = (self.loopToken or 0) + 1
        self:Loop(self.loopToken)
    end
end

-- LEARN
function PM:AutoScanMementos()
    if self.isScanning then return end
    self.isScanning = true
    local count = 0
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
    
    self:Log("Starting Silent Auto-Scan...", true, "settings")
    
    -- Temp Table
    self.acctSaved.recentScans = {} 
    
    for i = 1, total do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if id and IsCollectibleUnlocked(id) then
            local known = false
            if self.acctSaved and self.acctSaved.learnedData and self.acctSaved.learnedData[id] then known = true end
            
            if not known then 
                local _, cooldownDur = GetCollectibleCooldownAndDuration(id)
                local saveDur = (cooldownDur > 0) and cooldownDur or 10000 
                local cName = GetCollectibleName(id)
                
                if not self.acctSaved.learnedData then self.acctSaved.learnedData = {} end
                local refId = 0
                local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(id)
                if collectibleData and collectibleData.GetReferenceId then refId = collectibleData:GetReferenceId() end
                
                self.acctSaved.learnedData[id] = { id = id, refID = refId, dur = saveDur, name = cName }
                
                -- Temp ID
                table.insert(self.acctSaved.recentScans, id)
                count = count + 1
            end
        end
    end
    
    self.isScanning = false
    
    if count == 0 then
        self:Log("All owned mementos have already been learned.", true, "settings")
        self.acctSaved.recentScans = nil -- Delete temp table so it doesn't print again
    else
        self:UpdateLearnedCount()
        -- Print to chat
        self:Log("Successfully Learned " .. count .. " new mementos! Reloading UI...", false)
        PM.menuBuilt = false 
        zo_callLater(function() ReloadUI("ingame") end, 3000)
    end
end
-- Loop Logic
function PM:Loop(loopID)
    if not self.settings or self.settings.paused or not self.settings.activeId then return end
    if loopID ~= self.loopToken then return end
    local data = PM:GetData(self.settings.activeId)
    if not data then self.settings.activeId = nil; return end
    
    -- Cleanup AFK check
    local isBusy, busyDelay = self:IsBusy()
    if isBusy then 
        local wait = (busyDelay > 0) and busyDelay or ((self.settings.delayIdle or 0) * 1000)
        if wait < 100 then wait = 100 end
        if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + wait end
        zo_callLater(function() self:Loop(loopID) end, wait)
        return 
    end
    -- Occasional dormant memory check during long AFK loops
    self:TriggerMemoryCheck("Loop", 0)
    
    local currentTargetId = self.settings.activeId
    if self.pendingSyncId then currentTargetId = self.pendingSyncId end
    
    local remaining = 0
    if GetCollectibleCooldownAndDuration then 
        remaining, _ = GetCollectibleCooldownAndDuration(currentTargetId)
    end
    if remaining and remaining > 500 then 
        local wait = remaining + ((self.settings.delayIdle or 0) * 1000)
        if wait < 1000 then wait = 1000 end
        if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + wait end
        zo_callLater(function() self:Loop(loopID) end, wait)
        return 
    end
    
    self.isLooping = true 
    -- Play Group Sync Memento
    if self.pendingSyncId then
         self.isSyncFiring = true
         UseCollectible(self.pendingSyncId)
         zo_callLater(function()
             if loopID ~= self.loopToken then return end
             local syncRemaining, cooldownDur = 0, 10000
             if GetCollectibleCooldownAndDuration then syncRemaining, cooldownDur = GetCollectibleCooldownAndDuration(self.pendingSyncId) end
             local waitTime = (syncRemaining > 0) and syncRemaining or cooldownDur
             PM:Log("Sync Finished. Resuming loop in " .. math.floor(waitTime/1000) .. "s", true, "sync")
             self.pendingSyncId = nil; self.isSyncFiring = false; self.isLooping = false
             if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + waitTime + 1000 end
             zo_callLater(function() self:Loop(loopID) end, waitTime + 1000)
         end, 500)
         return 
    end

    UseCollectible(self.settings.activeId) 
    self.sessionLoops = self.sessionLoops + 1
    if self.acctSaved then
        self.acctSaved.totalLoops = (self.acctSaved.totalLoops or 0) + 1
        if not self.acctSaved.mementoUsage then self.acctSaved.mementoUsage = {} end
        self.acctSaved.mementoUsage[self.settings.activeId] = (self.acctSaved.mementoUsage[self.settings.activeId] or 0) + 1
    end
    
    if self.settings.randomOnZone or self.settings.randomOnLogin then
         self.nextRandomPrecalc = self:GetRandomSupported()
    end
    
    self.isLooping = false
    if not self.mementoData[self.settings.activeId] and not self.settings.unrestricted then
        self.settings.activeId = nil; return
    end
    
    local nextDelay = data.dur + 1000 + ((self.settings.delayIdle or 0) * 1000)
    if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + nextDelay end
    zo_callLater(function() self:Loop(loopID) end, nextDelay)
end

function PM:StartLoop(collectibleId, ignoreRestriction)
    local data = PM:GetData(collectibleId)
    if not data then return end
    if not self.mementoData[collectibleId] and not self.settings.unrestricted and not ignoreRestriction then
        PM:Log("Activating " .. data.name .. " (Looping Disabled - Unrestricted Mode Required)", true, "activation")
        UseCollectible(collectibleId)
        return 
    end

    self.settings.activeId = collectibleId; self.settings.paused = false; self.loopToken = (self.loopToken or 0) + 1
    if self.settings.randomOnZone or self.settings.randomOnLogin then self.nextRandomPrecalc = self:GetRandomSupported() end
    
    local currentToken = self.loopToken; 
    local isBusy, busyDelay = self:IsBusy()
    if isBusy then 
        local wait = (busyDelay > 0) and busyDelay or ((self.settings.delayIdle or 0) * 1000)
        if wait < 100 then wait = 100 end
        if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + wait end
        zo_callLater(function() self:Loop(currentToken) end, wait)
    else 
        self.isLooping = true; UseCollectible(collectibleId); self.isLooping = false
        self.sessionLoops = self.sessionLoops + 1
        if self.acctSaved then
            self.acctSaved.totalLoops = (self.acctSaved.totalLoops or 0) + 1
            if not self.acctSaved.mementoUsage then self.acctSaved.mementoUsage = {} end
            self.acctSaved.mementoUsage[collectibleId] = (self.acctSaved.mementoUsage[collectibleId] or 0) + 1
        end
        local nextDelay = data.dur + 1000 + ((self.settings.delayIdle or 0) * 1000)
        if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + nextDelay end
        zo_callLater(function() self:Loop(currentToken) end, nextDelay) 
    end
end
-- Bind UI clicks
function PM:HookGameUI()
    ZO_PreHook("UseCollectible", function(collectibleId)
        if not PM.settings then return end
        if PM.isLooping or PM.isScanning then return end
        if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
        if PM.isSyncFiring then return end
        
        if (collectibleId == 336 or collectibleId == 341) and PM.settings.activeId ~= collectibleId then
            local isCollectionsMenu = SCENE_MANAGER and (SCENE_MANAGER:IsShowing("collectionsBook") or SCENE_MANAGER:IsShowing("gamepadCollectionsBook"))
            local isQuickslot = SCENE_MANAGER and SCENE_MANAGER:IsShowing("quickslot")
            if not isCollectionsMenu and not isQuickslot then return end
        end
        
        local data = PM:GetData(collectibleId)
        local isCollectionsMenu = SCENE_MANAGER and (SCENE_MANAGER:IsShowing("collectionsBook") or SCENE_MANAGER:IsShowing("gamepadCollectionsBook"))
        
        if not data and PM.settings.unrestricted and isCollectionsMenu then
             local cName = GetCollectibleName(collectibleId)
             if not PM.acctSaved.learnedData then PM.acctSaved.learnedData = {} end
             local refId = 0
             local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
             if collectibleData and collectibleData.GetReferenceId then refId = collectibleData:GetReferenceId() end
             
             zo_callLater(function()
                 local remaining = 0
                 local cooldownDur = 10000
                 if GetCollectibleCooldownAndDuration then remaining, cooldownDur = GetCollectibleCooldownAndDuration(collectibleId) end
                 local durMS = (cooldownDur > 0) and cooldownDur or 10000 
                 PM.acctSaved.learnedData[collectibleId] = { id = collectibleId, refID = refId, dur = durMS, name = cName }
                 self:UpdateLearnedCount()
                 local logMsg = string.format("Saved: %s\nID: %d | RefID: %d | Dur: %dms | Total Learned: %d", cName, collectibleId, refId, durMS, self.learnedCount)
                 PM:Log(logMsg, true, "settings")
                 PM.menuBuilt = false 
             end, 500)
        end

        if PM.settings.activeId == collectibleId then
             PM.settings.activeId = nil; PM.settings.paused = false; PM.loopToken = (PM.loopToken or 0) + 1
             PM:Log("Auto-loop Stopped", true, "stop"); PM.pendingId = 0; PM.nextFireTime = 0; return
        end
        
        if data then
            if not self.mementoData[collectibleId] and not self.settings.unrestricted then
                 PM:Log("Activating " .. data.name .. " (Looping Disabled - Unrestricted Mode Required)", true, "activation")
                 return
            end
            local isSwitching = (PM.settings.activeId ~= nil)
            PM.settings.activeId = collectibleId; PM.settings.paused = false; PM.loopToken = (PM.loopToken or 0) + 1; PM.pendingId = collectibleId 
            if isSwitching then PM:Log("Memento switched to: " .. data.name, true, "activation") else PM:Log("Auto-loop started: " .. data.name, true, "activation") end
            
            local currentToken = PM.loopToken
            zo_callLater(function() PM:Loop(currentToken) end, 100)
        else
            if PM.settings.activeId then
                PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1; PM.pendingId = 0
                PM.nextFireTime = 0
                PM:Log("Auto-loop Stopped", true, "stop")
            end
        end
    end)
end
-- Group Sync
function PM.Sync:Initialize()
  SLASH_COMMANDS["/pmsync"] = function(argString)
    if not argString or string.len(argString) < 1 then PM:Log("Usage: /pmsync <searchterm>, /pmsync random OR /pmsync stop", true, "error"); return end
    local cmd = string.lower(argString)
    
    if cmd == "stop" then
         local function TryChat() StartChatInput("PM STOP", CHAT_CHANNEL_PARTY) end
         if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry("PM STOP") end
         if PM.settings then PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1 end
         PM.nextFireTime = 0 
         return
    elseif cmd == "random" then 
         local randId = PM:GetRandomAny(); if randId then
            local link = GetCollectibleLink(randId, LINK_STYLE_BRACKETS)
            local function TryChat() StartChatInput(string.format("PM %s", link), CHAT_CHANNEL_PARTY) end
            if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry(string.format("PM %s", link)) end
            PM:Log("Sent Random Sync Request", true, "sync")
            return
         end
    end
    
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
      local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
      if id and IsCollectibleUnlocked(id) then
          if string.find(string.lower(GetCollectibleName(id)), cmd, 1, true) then
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
    if not PM.settings.sync.enabled then return end
    if IsUnitInCombat and IsUnitInCombat("player") and PM.settings.sync.ignoreInCombat then return end
    if PM.settings.activeId then
         PM:Log("Sync received! Queuing after current loop: " .. GetCollectibleName(id), true, "sync")
         PM.pendingSyncId = id
    else
         local remaining = 0
         if GetCollectibleCooldownAndDuration then remaining, _ = GetCollectibleCooldownAndDuration(id) end
         if remaining and remaining > 0 then
             PM:Log("Sync received but on cooldown: " .. GetCollectibleName(id), true, "sync")
             zo_callLater(function() attemptCollectible(id) end, remaining + 1000)
         else
             PM:Log("Sync received! Playing: " .. GetCollectibleName(id), true, "sync")
             PM.isSyncFiring = true
             UseCollectible(id)
             zo_callLater(function() PM.isSyncFiring = false end, 1000)
         end
    end
  end

  local function onSyncChatMessage(eventCode, channelType, fromName, text)
    if channelType ~= CHAT_CHANNEL_PARTY then return end
    local cleanName = zo_strformat("<<1>>", fromName)
    if string.match(text, "^PM STOP") then
        if cleanName == GetUnitDisplayName("player") then PM:Log("Sent Group Stop Command.", true, "sync"); return end
        if PM.settings then PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1; PM.pendingSyncId = nil; PM.nextFireTime = 0; PM:Log("Group Stop received from " .. cleanName, true, "stop") end
        return
    end
    local id
    for collectibleId in string.gmatch(text, "^PM |H1:collectible:(%d+)|h|h$") do id = tonumber(collectibleId) end
    if not id then for collectibleId in string.gmatch(text, "^PM (%d+)$") do id = tonumber(collectibleId) end end
    if not id or not IsCollectibleUnlocked(id) then return end
    if cleanName == GetUnitDisplayName("player") then PM:Log("Sent Group Sync Command.", true, "sync"); return end
    if not PM.settings then return end 
    local delay = PM.settings.sync.delay or 0
    if PM.settings.sync.random then delay = math.random(0, delay) end
    if delay == 0 then attemptCollectible(id) else zo_callLater(function() attemptCollectible(id) end, delay * 1000) end
  end
  EVENT_MANAGER:UnregisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL)
  EVENT_MANAGER:RegisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL, onSyncChatMessage)
end

function PM:GetCharacterList(skipCurrent)
    local names, ids = {}, {}
    local sv = _G["PermMementoSaved"]; local acct = GetDisplayName(); local currentId = GetCurrentCharacterId()
    local world = GetWorldName() or "Default"
    
    if sv and sv[world] and sv[world][acct] then
        for id, data in pairs(sv[world][acct]) do
            if id ~= "$AccountWide" and type(data) == "table" and data["Character"] then
                if not skipCurrent or id ~= currentId then
                    local cName = data["$LastCharacterName"] or zo_strformat("<<1>>", GetCharacterNameById(id))
                    if not cName or cName == "" then cName = "Unknown ID: " .. id end
                    table.insert(names, cName); table.insert(ids, id)
                end
            end
        end
    end
    if #names == 0 then return {"None"}, {""} end
    return names, ids
end

function PM:CopyCharacterSettings(sourceId)
    if not sourceId or sourceId == "" then PM:Log("No character selected to copy.", true, "error"); return end
    local acct = GetDisplayName()
    local world = GetWorldName() or "Default"
    
    local src = _G["PermMementoSaved"][world][acct][sourceId]["Character"]
    if src then 
        _G["PermMementoSaved"][world][acct][GetCurrentCharacterId()]["Character"] = ZO_DeepTableCopy(src)
        ReloadUI("ingame") 
    end
end

function PM:DeleteCharacterSettings(targetId)
    if not targetId or targetId == "" then PM:Log("No character selected for deletion.", true, "error"); return end
    if targetId == GetCurrentCharacterId() then PM:Log("Cannot delete current character's data while logged in.", true, "error"); return end
    
    local acct = GetDisplayName()
    local world = GetWorldName() or "Default"
    
    if _G["PermMementoSaved"][world] and _G["PermMementoSaved"][world][acct] then
        _G["PermMementoSaved"][world][acct][targetId] = nil
        ReloadUI("ingame")
    end
end

function PM:DeleteLearnedData(targetId)
    if not targetId or targetId == 0 then return end
    if self.acctSaved and self.acctSaved.learnedData then
        self.acctSaved.learnedData[targetId] = nil; PM:Log("Learned data deleted.", true, "settings"); PM.menuBuilt = false; ReloadUI("ingame")
    end
end

function PM:DeleteAllLearnedData()
    if self.acctSaved and self.acctSaved.learnedData then
        self.acctSaved.learnedData = {}; PM:Log("ALL Learned data deleted.", true, "settings"); PM.menuBuilt = false; ReloadUI("ingame")
    end
end

function PM:UpdateFavoritesChoices()
    PM:UpdateFavCount()
    
    PM.favAllNames, PM.favAllIDs = {}, {}
    PM.favCurrentNames, PM.favCurrentIDs = {"None"}, {0}
    
    local sortedAll = {}
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if id and IsCollectibleUnlocked(id) then table.insert(sortedAll, {name=GetCollectibleName(id), id=id}) end
    end
    table.sort(sortedAll, function(a,b) return a.name < b.name end)
    for _, t in ipairs(sortedAll) do
        local name = t.name
        local data = PM:GetData(t.id)
        if data then name = name .. string.format(" (%ds)", data.dur / 1000) end
        
        if PM.settings.favorites[t.id] then name = "|c00FF00" .. name .. " (Fav)|r" end
        table.insert(PM.favAllNames, name); table.insert(PM.favAllIDs, t.id)
    end
    
    local sortedFavs = {}
    if self.settings and self.settings.favorites then
        for id, enabled in pairs(self.settings.favorites) do
            if enabled and IsCollectibleUnlocked(id) then table.insert(sortedFavs, {name=GetCollectibleName(id), id=id}) end
        end
    end
    table.sort(sortedFavs, function(a,b) return a.name < b.name end)
    for _, t in ipairs(sortedFavs) do 
        local name = t.name
        local data = PM:GetData(t.id)
        if data then name = name .. string.format(" (%ds)", data.dur / 1000) end
        table.insert(PM.favCurrentNames, name); table.insert(PM.favCurrentIDs, t.id) 
    end
    
    if PM.ctrlFavCandidateDropdown then 
        PM.ctrlFavCandidateDropdown:UpdateChoices(PM.favAllNames, PM.favAllIDs)
        PM.ctrlFavCandidateDropdown:UpdateValue()
    end
    if PM.ctrlFavRemoveDropdown then 
        PM.ctrlFavRemoveDropdown:UpdateChoices(PM.favCurrentNames, PM.favCurrentIDs)
        PM.ctrlFavRemoveDropdown:UpdateValue()
    end
end

function PM:ToggleFavorite(id)
    if not id or id == 0 then return end
    if not self.settings.favorites then self.settings.favorites = {} end
    if self.settings.favorites[id] then
        self.settings.favorites[id] = nil
        PM:Log("Removed from Favorites: " .. GetCollectibleName(id), true, "settings")
    else
        self.settings.favorites[id] = true
        PM:Log("Added to Favorites: " .. GetCollectibleName(id), true, "settings")
    end
    PM:UpdateFavoritesChoices()
end

function PM:DeleteAllFavorites()
    if self.settings then self.settings.favorites = {} end
    PM:Log("All Favorites Cleared.", true, "settings")
    PM:UpdateFavoritesChoices()
end
-- Refresh UI Dropdown Data
function PM:UpdateMenuChoices()
    PM.activeNames, PM.activeIDs = {"None"}, {0}
    local sortedActive = {}
    for id, data in pairs(self.mementoData) do
        if IsCollectibleUnlocked(id) then table.insert(sortedActive, {name=data.name, id=id, dur=data.dur, stat=data.stationary}) end
    end
    table.sort(sortedActive, function(a,b) return a.name < b.name end)
    for i, t in ipairs(sortedActive) do
        local durSec = t.dur / 1000; local infoText = string.format("%s (%ds)%s", t.name, durSec, t.stat and " (Stationary)" or "")
        table.insert(PM.activeNames, infoText); table.insert(PM.activeIDs, t.id)
    end
    if PM.ctrlActiveDropdown then PM.ctrlActiveDropdown:UpdateChoices(PM.activeNames, PM.activeIDs) end

    PM.syncNames, PM.syncIDs = {"None"}, {0}
    local sortedSync = {}
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if id and IsCollectibleUnlocked(id) then local name = GetCollectibleName(id); table.insert(sortedSync, {name=name, id=id}) end
    end
    table.sort(sortedSync, function(a,b) return a.name < b.name end)
    for i, t in ipairs(sortedSync) do 
        local name = t.name
        local data = PM:GetData(t.id)
        if data then name = name .. string.format(" (%ds)", data.dur / 1000) end
        table.insert(PM.syncNames, name); table.insert(PM.syncIDs, t.id) 
    end
    if PM.ctrlSyncDropdown then PM.ctrlSyncDropdown:UpdateChoices(PM.syncNames, PM.syncIDs) end
    
    PM.learnedListNames, PM.learnedListValues = {"None"}, {0}
    if self.acctSaved and self.acctSaved.learnedData then
        local sortedLearned = {}
        for id, data in pairs(self.acctSaved.learnedData) do table.insert(sortedLearned, data) end
        table.sort(sortedLearned, function(a,b) return a.name < b.name end)
        for i, data in ipairs(sortedLearned) do 
            local name = data.name .. string.format(" (%ds)", data.dur / 1000)
            table.insert(PM.learnedListNames, name); table.insert(PM.learnedListValues, data.id) 
        end
    end
    if PM.ctrlLearnedDropdown then PM.ctrlLearnedDropdown:UpdateChoices(PM.learnedListNames, PM.learnedListValues) end
end
-- LibAddonMenu UI Settings
function PM:BuildMenu()
    if PM.menuBuilt then return end
    PM.menuBuilt = true
    PM:UpdateMenuChoices()
    PM:UpdateFavoritesChoices()
    PM.charListNames, PM.charListValues = PM:GetCharacterList(false)
    
    local LAM = LibAddonMenu2 or _G["LibAddonMenu"]
    if not LAM then return end
    local panelData = { type = "panel", name = "Permanent Memento", displayName = "|c9CD04CPermanent Memento|r", author = "|ca500f3A|r|cb400e6P|r|cc300daH|r|cd200cdO|r|ce100c1NlC|r", version = self.version, registerForRefresh = true }
    
    local optionsData = {}

    if IsConsoleUI() then
        table.insert(optionsData, { type = "button", name = "|c00FF00PERMANENT MEMENTO STATS|r", tooltip = function() return PM:GetStatsText() end, func = function() end, width = "full" })
        local consoleCmds = "|c00FF00/pmem <name>|r - Start\n|c00FF00/pmemstop|r - Stop loop\n|c00FF00/pmemrandom|r - Random\n|c00FF00/pmemautolearn|r - Auto-Scan\n|c00FF00/pmemui|r - Toggle UI\n|c00FF00/pmemuimode|r - HUD/Menu\n|c00FF00/pmemlock|r - Lock UI\n|c00FF00/pmemcsa|r - Toggle CSA\n|c00FF00/pmemunrestrict|r - Unrestrict\n|c00FF00/pmemcleanup|r - Run memory cleanup\n|c00FF00/pmemcsacleanup|r - Toggle auto cleanup CSA\n|c00FF00/pmemlearned|r - List learned data\n|c00FF00/pmsync <name>|r - Sync\n|c00FF00/pmsyncstop|r - Stop group\n|c00FF00/pmsyncrandom|r - Sync Rand"
        table.insert(optionsData, { type = "button", name = "|c00FF00COMMANDS INFO|r", tooltip = consoleCmds, func = function() end, width = "full" })
    end
    
    local isEU = (GetWorldName() == "EU Megaserver")

    if not IsConsoleUI() and not isEU then
        table.insert(optionsData, {
            type = "button",
            name = "|cFFD700DONATE|r to @|ca500f3A|r|cb400e6P|r|cc300daH|r|cd200cdO|r|ce100c1NlC|r",
            tooltip = "Opens the in-game mail. Thank you! This donation will be used to buy new mementos to accurately input their data to the addon.",
            func = function()
                SCENE_MANAGER:Show("mailSend")
                zo_callLater(function()
                    ZO_MailSendToField:SetText("@APHONlC")
                    ZO_MailSendSubjectField:SetText("PermMemento Support")
                    ZO_MailSendBodyField:TakeFocus()
                end, 200)
            end,
            width = "half"
        })
    end

    table.insert(optionsData, {
        type = "button",
        name = "|c00FFFFMigrate SavedVariables|r",
        tooltip = "Manually triggers the data migration process.",
        func = function()
            PM:MigrateData()
            PM:Log("Data migration complete. Reloading UI to apply changes...", true, "settings")
            zo_callLater(function() ReloadUI("ingame") end, 2000)
        end,
        width = (IsConsoleUI() or isEU) and "full" or "half"
    })

    local generalControls = {
        { type = "checkbox", name = "Use Account-Wide Settings", tooltip = "If ON, settings are shared across all characters.", getFunc = function() return PM.charSaved.useAccountSettings end, setFunc = function(value) PM.charSaved.useAccountSettings = value; PM:UpdateSettingsReference(); ReloadUI("ingame") end },
        { type = "dropdown", name = "Select Active Memento", tooltip = "Select a memento. Click 'Apply' to start.", choices = PM.activeNames, choicesValues = PM.activeIDs, getFunc = function() if PM.pendingId == nil then return PM.settings.activeId or 0 end return PM.pendingId end, setFunc = function(value) PM.pendingId = value end, disabled = function() return PM.settings.randomOnZone end, reference = "PM_ActiveDropdown" },
        { type = "button", name = "Activate Random Memento", tooltip = "Immediately picks and starts a random supported memento.", width = "half", func = function() local randId = PM:GetRandomSupported(); if randId then PM.settings.activeId = randId; PM:Log("Randomly Selected: " .. PM:GetData(randId).name, true, "random"); PM:StartLoop(randId) end end },
        { type = "button", name = "|c00FF00Apply Selected Memento|r", tooltip = "|c00FF00Starts the memento selected above.|r", width = "half", func = function() if PM.pendingId and PM.pendingId ~= 0 then PM.settings.activeId = PM.pendingId; local data = PM:GetData(PM.pendingId); PM:Log("Selected via Menu: " .. (data.name or "Unknown"), true, "activation"); PM:StartLoop(PM.pendingId); PM.pendingId = nil elseif PM.pendingId == 0 then PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1; PM:Log("Auto-loop Stopped", true, "stop"); PM.pendingId = nil; PM.nextFireTime = 0 end end },
        { type = "button", name = "|cFF0000STOP LOOP|r", tooltip = "Stops the currently running memento loop.", width = "full", func = function() PM.settings.activeId = nil; PM.loopToken = (PM.loopToken or 0) + 1; PM.pendingId = 0; PM.settings.randomOnZone = false; PM.settings.randomOnLogin = false; PM:Log("Auto-loop Stopped", true, "stop"); PM.nextFireTime = 0 end },
        { type = "checkbox", name = "Randomize on Zone Change", tooltip = "Randomly picks a supported memento whenever you change zones.", getFunc = function() return PM.settings.randomOnZone end, setFunc = function(value) PM.settings.randomOnZone = value end },
        { type = "checkbox", name = "Randomize on Login", tooltip = "Picks a random memento when you login.", getFunc = function() return PM.settings.randomOnLogin end, setFunc = function(value) PM.settings.randomOnLogin = value end },
        { type = "checkbox", name = "Loop in Combat", tooltip = "Allows the memento to attempt firing during combat.", getFunc = function() return PM.settings.loopInCombat end, setFunc = function(value) PM.settings.loopInCombat = value end },
        { type = "checkbox", name = "Screen Announcements", tooltip = "Shows large text alerts on screen.", getFunc = function() return PM.settings.csaEnabled end, setFunc = function(value) PM.settings.csaEnabled = value end },
        { type = "checkbox", name = "Show Auto Cleanup Announcements", tooltip = "Shows large text alerts on screen when Lua Memory is automatically cleaned.", getFunc = function() return PM.settings.csaCleanupEnabled end, setFunc = function(value) PM.settings.csaCleanupEnabled = value end },
        { type = "checkbox", name = "Performance Mode", tooltip = "Reduces UI update frequency to save resources.", getFunc = function() return PM.settings.performanceMode end, setFunc = function(value) PM.settings.performanceMode = value end },
        { type = "checkbox", name = "Auto Lua Cleanup", tooltip = "Background memory cleaner. Automatically runs when memory hits 400MB (PC) or 85MB (Console) to prevent performance stuttering. Only triggers outside combat.", getFunc = function() return PM.settings.autoCleanup end, setFunc = function(value) PM.settings.autoCleanup = value end }
    }

    if IsConsoleUI() then
        table.insert(optionsData, { type = "submenu", name = "General Settings", tooltip = "Core configuration and active memento selection.", controls = generalControls })
    else
        table.insert(optionsData, { type = "header", name = "General Settings" })
        for _, ctrl in ipairs(generalControls) do table.insert(optionsData, ctrl) end
        table.insert(optionsData, { type = "checkbox", name = "Enable Chat Logs", tooltip = "Shows status messages in your chat window.", getFunc = function() return PM.settings.logEnabled end, setFunc = function(value) PM.settings.logEnabled = value end })
        table.insert(optionsData, { type = "checkbox", name = "Stop Character Spinning in Menus", tooltip = "Prevents camera from shifting in Stats/Inventory.", getFunc = function() return PM.settings.stopSpinning end, setFunc = function(value) PM.settings.stopSpinning = value; PM:ApplySpinStop() end })
    end

    local uiVisibilityControls = {
        { type = "checkbox", name = "UI Visibility", tooltip = "Shows or hides the status text completely.", getFunc = function() return not PM.settings.ui.hidden end, setFunc = function(value) PM.settings.ui.hidden = not value; PM:UpdateUIScenes(); PM:Log("UI Visibility: " .. (PM.settings.ui.hidden and "HIDDEN" or "VISIBLE"), true, "ui") end },
        { type = "checkbox", name = "UI Mode", tooltip = "ON: Shows during normal gameplay (HUD).\nOFF: Shows ONLY inside the Collectibles menu.", getFunc = function() return PM.settings.showInHUD end, setFunc = function(value) PM.settings.showInHUD = value; PM:UpdateUIScenes(); PM:Log("UI Mode: " .. (value and "HUD Only" or "Menu Only"), true, "ui") end, disabled = function() return PM.settings.ui.hidden end },
        { type = "checkbox", name = "Lock UI Position", tooltip = "Prevents the on-screen status text UI from being moved.", getFunc = function() return PM.settings.ui.locked end, setFunc = function(value) PM.settings.ui.locked = value; if PM.uiWindow then PM.uiWindow:SetMovable(not value) end end },
        { type = "slider", name = "HUD UI Scale", tooltip = "Adjusts the size of the status text UI in HUD mode.", min = 0.5, max = 2.0, step = 0.1, decimals = 1, getFunc = function() return PM.settings.ui.scale or (IsConsoleUI() and 1.0 or 1.0) end, setFunc = function(value) PM.settings.ui.scale = value; PM:UpdateUIAnchor() end },
        { type = "slider", name = "Menu UI Scale", tooltip = "Adjusts the size of the status text UI in Menu mode.", min = 0.5, max = 2.0, step = 0.1, decimals = 1, getFunc = function() return PM.settings.uiMenu.scale or (IsConsoleUI() and 1.2 or 1.0) end, setFunc = function(value) PM.settings.uiMenu.scale = value; PM:UpdateUIAnchor() end },
        { type = "button", name = "|cFF0000RESET UI POSITION|r", tooltip = "Resets the status text UI position to default.", func = function() PM.settings.ui.left = PM.defaults.ui.left; PM.settings.ui.top = PM.defaults.ui.top; PM.settings.uiMenu.left = PM.defaults.uiMenu.left; PM.settings.uiMenu.top = PM.defaults.uiMenu.top; PM:UpdateUIAnchor(); PM:Log("UI Position Reset.", true, "ui") end }
    }
    table.insert(optionsData, { type = "submenu", name = "UI Visibility Settings", tooltip = "Options for the on-screen status text.", controls = uiVisibilityControls })

    local favoritesControls = {
        { type = "description", text = "If you have favorites in this list, 'Randomize' features will ONLY pick from here. If empty, they pick from all supported/learned mementos. (RELOAD UI) after adding stuffs to your list" },
        { type = "dropdown", name = "Select Memento to Favorite", tooltip = "Select any memento to Add or Remove from favorites.", choices = PM.favAllNames, choicesValues = PM.favAllIDs, getFunc = function() return PM.selectedFavCandidate or 0 end, setFunc = function(value) PM.selectedFavCandidate = value end, reference = "PM_FavCandidateDropdown" },
        { type = "button", name = "Apply to Favorites", tooltip = "Adds or Removes the selected memento above from your favorites.", func = function() PM:ToggleFavorite(PM.selectedFavCandidate) end },
        { type = "divider" },
        { type = "dropdown", name = "View Current Favorites", tooltip = "Select a favorite here to remove it.", choices = PM.favCurrentNames, choicesValues = PM.favCurrentIDs, getFunc = function() return PM.selectedFavRemoval or 0 end, setFunc = function(value) PM.selectedFavRemoval = value end, reference = "PM_FavRemoveDropdown" },
        { type = "button", name = "Remove Selected Favorite", tooltip = "Removes the memento selected in 'View Current Favorites'.", func = function() PM:ToggleFavorite(PM.selectedFavRemoval) end },
        { type = "button", name = "|cFF0000Clear All Favorites|r", tooltip = "|cFF0000Removes all mementos from your favorites list.|r", func = function() PM:DeleteAllFavorites() end }
    }
    table.insert(optionsData, { type = "submenu", name = "Favorites Manager", tooltip = "Manage your list of favorite mementos for randomization.", controls = favoritesControls })

    local charDataControls = {
        { type = "dropdown", name = "Copy Settings From...", tooltip = "Select a character to copy settings FROM to your CURRENT character.", choices = PM.charListNames, choicesValues = PM.charListValues, getFunc = function() return "" end, setFunc = function(value) PM.selectedCharCopy = value end },
        { type = "button", name = "Copy Settings & Reload", tooltip = "Overwrites current character settings with the selected character's data and reloads the UI.", func = function() PM:CopyCharacterSettings(PM.selectedCharCopy) end },
        { type = "dropdown", name = "|cFF0000DELETE Data For...|r", tooltip = "|cFF0000Select an obsolete character to delete their saved data.|r", choices = PM.charListNames, choicesValues = PM.charListValues, getFunc = function() return "" end, setFunc = function(value) PM.selectedCharDelete = value end },
        { type = "button", name = "|cFF0000DELETE Data & Reload|r", tooltip = "|cFF0000WARNING: PERMANENTLY deletes saved data for the selected character and reloads the UI.|r", func = function() PM:DeleteCharacterSettings(PM.selectedCharDelete) end }
    }
    table.insert(optionsData, { type = "submenu", name = "Character Data Management", tooltip = "Manage individual character settings profiles.", controls = charDataControls })

    local learnedDataControls = {
        { type = "dropdown", name = "Learned Mementos", tooltip = "Select a learned memento to manage.", choices = PM.learnedListNames, choicesValues = PM.learnedListValues, getFunc = function() return PM.selectedLearnedId or 0 end, setFunc = function(value) PM.selectedLearnedId = value end, reference = "PM_LearnedDropdown" },
        { type = "button", name = "|c00FF00Activate Selected Memento|r", tooltip = "|c00FF00Activates the memento currently selected in the dropdown above.|r", width = "half", func = function() if PM.selectedLearnedId and PM.selectedLearnedId ~= 0 then PM.settings.activeId = PM.selectedLearnedId; local data = PM:GetData(PM.selectedLearnedId); PM:Log("Selected (Learned): " .. (data and data.name or "Unknown"), true, "activation"); PM:StartLoop(PM.selectedLearnedId) end end },
        { type = "button", name = "|cFFFF00LEARN: Auto-Scan|r", tooltip = "|cFFFF00Scans all owned mementos, activates them once to learn their Effect ID, and saves them to memory. Skips already known mementos.|r", width = "half", func = function() PM:AutoScanMementos() end },
        { type = "button", name = "Delete Selected Memento", tooltip = "Removes the selected memento from Learned Data and reloads UI.", width = "half", func = function() PM:DeleteLearnedData(PM.selectedLearnedId) end },
        { type = "button", name = "Randomize Learned Memento", tooltip = "Picks a random memento from your Learned Data list.", width = "half", func = function() local randId = PM:GetRandomLearned(); if randId then PM.settings.activeId = randId; PM:Log("Randomly Selected (Learned): " .. PM:GetData(randId).name, true, "random"); PM:StartLoop(randId) else PM:Log("No learned data found.", true, "error") end end },
        { type = "button", name = "|cFF0000DELETE ALL LEARNED DATA|r", tooltip = "|cFF0000WARNING: Deletes ALL manual and auto-scanned learned memento data. This cannot be undone.|r", width = "half", func = function() PM:DeleteAllLearnedData() end }
    }
    table.insert(optionsData, { type = "submenu", name = "Learned Data Management", tooltip = "Manage mementos scanned by the Auto-Scan feature.", controls = learnedDataControls })

    local durControls = {
        { type = "slider", name = "Activate Messages Duration", tooltip = "Duration for 'Started' messages.", min=1, max=10, step=1, getFunc=function() return PM.settings.csaDurations.activation end, setFunc=function(v) PM.settings.csaDurations.activation = v end },
        { type = "slider", name = "Stop Messages Duration", tooltip = "Duration for 'Stopped' messages.", min=1, max=10, step=1, getFunc=function() return PM.settings.csaDurations.stop end, setFunc=function(v) PM.settings.csaDurations.stop = v end },
        { type = "slider", name = "UI Toggle Messages Duration", tooltip = "Duration for UI Hidden/Visible messages.", min=1, max=10, step=1, getFunc=function() return PM.settings.csaDurations.ui end, setFunc=function(v) PM.settings.csaDurations.ui = v end },
        { type = "slider", name = "Random/Zoning Messages Duration", tooltip = "Duration for Randomizer messages.", min=1, max=10, step=1, getFunc=function() return PM.settings.csaDurations.random end, setFunc=function(v) PM.settings.csaDurations.random = v end },
        { type = "slider", name = "Settings Messages Duration", tooltip = "Duration for Settings change messages.", min=1, max=10, step=1, getFunc=function() return PM.settings.csaDurations.settings end, setFunc=function(v) PM.settings.csaDurations.settings = v end },
        { type = "slider", name = "Cleanup Messages Duration", tooltip = "Duration for Auto Cleanup messages.", min=1, max=10, step=1, getFunc=function() return PM.settings.csaDurations.cleanup end, setFunc=function(v) PM.settings.csaDurations.cleanup = v end }
    }
    if not IsConsoleUI() then table.insert(durControls, 3, { type = "slider", name = "Sync Messages Duration", tooltip = "Duration for Sync related messages.", min=1, max=10, step=1, getFunc=function() return PM.settings.csaDurations.sync end, setFunc=function(v) PM.settings.csaDurations.sync = v end }) end
    table.insert(optionsData, { type = "submenu", name = "Announcement Durations (Seconds)", tooltip = "Configure how long text stays on screen.", controls = durControls })

    if not IsConsoleUI() then
        local syncControls = {
            { type = "checkbox", name = "Allow Incoming Sync Requests", tooltip = "If ON, your client will respond to group sync commands.", getFunc = function() return PM.settings.sync.enabled end, setFunc = function(value) PM.settings.sync.enabled = value; PM:Log("Sync Listening: " .. (value and "ON" or "OFF"), true, "settings") end },
            { type = "dropdown", name = "Select Sync Request", tooltip = "Broadcasts a memento to your group to sync up animations.", choices = PM.syncNames, choicesValues = PM.syncIDs, getFunc = function() return 0 end, setFunc = function(value) if value and value ~= 0 then local link = GetCollectibleLink(value, LINK_STYLE_BRACKETS); local function TryChat() StartChatInput(string.format("PM %s", link), CHAT_CHANNEL_PARTY) end; if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry(string.format("PM %s", link)) end end end, reference = "PM_SyncDropdown" },
            { type = "button", name = "Send Random Sync", tooltip = "Picks a random unlocked memento and broadcasts it to group.", func = function() local randId = PM:GetRandomAny(); if randId then local link = GetCollectibleLink(randId, LINK_STYLE_BRACKETS); local function TryChat() StartChatInput(string.format("PM %s", link), CHAT_CHANNEL_PARTY) end; if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry(string.format("PM %s", link)) end end end },
            { type = "button", name = "Send Stop Command", tooltip = "Sends a STOP command to your group, halting their loops.", func = function() local function TryChat() StartChatInput("PM STOP", CHAT_CHANNEL_PARTY) end; if not pcall(TryChat) and CHAT_SYSTEM then CHAT_SYSTEM:StartTextEntry("PM STOP") end end },
            { type = "checkbox", name = "Randomize Sync Delay", tooltip = "Adds random variation to the sync start time.", getFunc = function() return PM.settings.sync.random end, setFunc = function(value) PM.settings.sync.random = value end },
            { type = "slider", name = "Sync Delay (Seconds)", tooltip = "Fixed delay before starting a synced memento.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.sync.delay end, setFunc = function(value) PM.settings.sync.delay = value end, disabled = function() return PM.settings.sync.random end }
        }
        table.insert(optionsData, { type = "submenu", name = "Sync Settings", tooltip = "Group synchronization options.", controls = syncControls })
    end

    local delayControls = {
        { type = "slider", name = "Delay After Going Idle", tooltip = "Base delay between loops when not busy.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayIdle end, setFunc = function(value) PM.settings.delayIdle = value end },
        { type = "slider", name = "Menu/Interaction Delay", tooltip = "Wait time when in menus or interacting.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayInMenu end, setFunc = function(value) PM.settings.delayInMenu = value end },
        { type = "slider", name = "Delay After Casting Skill", tooltip = "Time to wait after casting a skill before resuming loop.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayCast end, setFunc = function(value) PM.settings.delayCast = value end },
        { type = "slider", name = "Delay After Exiting Combat", tooltip = "Wait time after leaving combat before resuming loop.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayCombatEnd end, setFunc = function(value) PM.settings.delayCombatEnd = value end },
        { type = "slider", name = "Delay After Resurrecting/Reviving", tooltip = "Wait time when resurrecting a player.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayResurrect end, setFunc = function(value) PM.settings.delayResurrect = value end },
        { type = "slider", name = "Delay After Teleport/ReloadUI", tooltip = "Wait time after zoning, reloading, or logging in (affects Loop and Auto-Scan resume).", min = 0, max = 20, step = 1, getFunc = function() return PM.settings.delayTeleport end, setFunc = function(value) PM.settings.delayTeleport = value end },
        { type = "slider", name = "Delay After Moving", tooltip = "Wait time when moving.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayMove end, setFunc = function(value) PM.settings.delayMove = value end },
        { type = "slider", name = "Delay After Sprinting", tooltip = "Wait time when sprinting.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delaySprint end, setFunc = function(value) PM.settings.delaySprint = value end },
        { type = "slider", name = "Delay After Blocking", tooltip = "Wait time when blocking.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayBlock end, setFunc = function(value) PM.settings.delayBlock = value end },
        { type = "slider", name = "Delay After Exiting Swimming", tooltip = "Wait time when swimming.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delaySwim end, setFunc = function(value) PM.settings.delaySwim = value end },
        { type = "slider", name = "Delay After Sneaking", tooltip = "Wait time when sneaking.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delaySneak end, setFunc = function(value) PM.settings.delaySneak = value end },
        { type = "slider", name = "Delay After Un-Mounting", tooltip = "Wait time when mounted.", min = 0, max = 10, step = 1, getFunc = function() return PM.settings.delayMount end, setFunc = function(value) PM.settings.delayMount = value end }
    }
    table.insert(optionsData, { type = "submenu", name = "Delays (Seconds)", tooltip = "Fine-tune how long the addon waits after specific actions.", controls = delayControls })

    local cmdControls = {}
    if not IsConsoleUI() then table.insert(cmdControls, { type = "button", name = "|cFF0000FORCE CONSOLE MODE|r", tooltip = "|cFF0000WARNING: SIMULATES CONSOLE FLOW ON PC. REQUIRES RELOAD TO APPLY.\nIF STUCK, USE COMMAND:\n/script SetCVar(\"ForceConsoleFlow.2\", \"0\")\nTHEN TYPE /reloadui|r", func = function() local current = GetCVar("ForceConsoleFlow.2"); local newVal = (current == "1") and "0" or "1"; SetCVar("ForceConsoleFlow.2", newVal); ReloadUI("ingame") end }) end
    table.insert(cmdControls, { type = "button", name = "|cFF0000UNRESTRICTED MODE|r", tooltip = "|cFF0000WARNING: ALLOWS LOOPING ANY MEMENTO. MAY CAUSE ISSUES.|r", func = function() PM.settings.unrestricted = not PM.settings.unrestricted; PM:Log("Unrestricted Mode: " .. (PM.settings.unrestricted and "ON" or "OFF"), true, "settings") end })
    table.insert(cmdControls, { type = "button", name = "|c00FFFFCLEAN LUA MEMORY|r", tooltip = "Manually triggers Lua garbage collection to free up unused memory and prevent crashes.", func = function() PM:RunManualCleanup(false) end })
    table.insert(cmdControls, { type = "button", name = "Reload UI", tooltip = "Reloads the User Interface.", func = function() ReloadUI("ingame") end })
    table.insert(cmdControls, { type = "button", name = "|cFF0000RESET TO DEFAULTS|r", tooltip = "|cFF0000RESETS ALL SETTINGS TO DEFAULT VALUES.|r", func = function() local d = PM.defaults; PM.settings.activeId = d.activeId; PM.settings.paused = d.paused; PM.settings.logEnabled = d.logEnabled; PM.settings.csaEnabled = d.csaEnabled; PM.settings.csaCleanupEnabled = d.csaCleanupEnabled; PM.settings.randomOnLogin = d.randomOnLogin; PM.settings.randomOnZone = d.randomOnZone; PM.settings.loopInCombat = d.loopInCombat; PM.settings.performanceMode = d.performanceMode; PM.settings.showInHUD = d.showInHUD; PM.settings.unrestricted = d.unrestricted; PM.settings.autoCleanup = d.autoCleanup; PM.settings.delayMove = d.delayMove; PM.settings.delaySprint = d.delaySprint; PM.settings.delayBlock = d.delayBlock; PM.settings.delayCast = d.delayCast; PM.settings.delaySwim = d.delaySwim; PM.settings.delaySneak = d.delaySneak; PM.settings.delayMount = d.delayMount; PM.settings.delayIdle = d.delayIdle; PM.settings.delayTeleport = d.delayTeleport; PM.settings.delayResurrect = d.delayResurrect; PM.settings.delayInMenu = d.delayInMenu; PM.settings.delayCombatEnd = d.delayCombatEnd; PM.settings.sync = ZO_DeepTableCopy(d.sync); PM.settings.ui = ZO_DeepTableCopy(d.ui); PM.settings.uiMenu = ZO_DeepTableCopy(d.uiMenu); PM.settings.csaDurations = ZO_DeepTableCopy(d.csaDurations); ReloadUI("ingame") end })
    table.insert(optionsData, { type = "submenu", name = "Commands", tooltip = "Available chat commands and utility buttons.", controls = cmdControls })

    if not IsConsoleUI() then
        local liveStatsBlock = { type = "submenu", name = "Permanent Memento Stats", tooltip = "Live tracking of memory and usage data.", controls = {
            { type = "description", title = "|c00FFFFLive Statistics|r", text = "Loading statistics...", reference = "PM_StatsText" }
        }}
        
        local pcCmdsText = "|c00FF00/pmem <name>|r - Force loop a memento\n|c00FF00/pmemstop|r - Stops loop & Auto-Scan\n|c00FF00/pmemrandom|r - Activate random memento\n|c00FF00/pmemrandomzonechange|r - Toggle Zone Random\n|c00FF00/pmemrandomlogin|r - Toggle Login Random\n|c00FF00/pmemautolearn|r - Starts Auto-Scan\n|c00FF00/pmemcleanup|r - Manual Lua cleanup\n|c00FF00/pmemcsacleanup|r - Toggle auto-cleanup CSA\n|c00FF00/pmemui|r - Toggle status display\n|c00FF00/pmemuimode|r - Toggle HUD/Menu mode\n|c00FF00/pmemlock|r - Lock/unlock UI dragging\n|c00FF00/pmemuireset|r - Reset UI scale/position\n|c00FF00/pmemcsa|r - Toggle Screen Announcements\n|c00FF00/pmemunrestrict|r - Toggle Unrestricted Mode\n|c00FF00/pmsync <name>|r - Send party sync request\n|c00FF00/pmsyncrandom|r - Send random party sync\n|c00FF00/pmsyncstop|r - Send party stop request\n|c00FF00/pmemcurrent|r - Print current loop in chat\n|c00FF00/pmemlearned|r - List all learned data\n|c00FF00/pmemactivatelearned <name>|r - Force loop learned memento\n|c00FF00/pmemdeletealllearned|r - Wipe all learned data\n\n|cFF0000WARNING:|r Force Console Mode requires reload. To revert if stuck:\n|cFFFF00/script SetCVar(\"ForceConsoleFlow.2\", \"0\")|r"
        local commandsInfoBlock = { type = "description", title = "Commands Info", text = pcCmdsText }
        table.insert(optionsData, liveStatsBlock)
        table.insert(optionsData, commandsInfoBlock)
    end
    
    if not IsConsoleUI() then
        table.insert(optionsData, { type = "divider" })
        table.insert(optionsData, {
            type = "button",
            name = "|cFFD700Buy Me A Coffee|r",
            tooltip = "Support the development of PermMemento! Opens a secure link to my Buy Me A Coffee page in your default web browser.",
            func = function() 
                RequestOpenUnsafeURL("https://buymeacoffee.com/aph0nlc") 
            end,
            width = "full"
        })
        table.insert(optionsData, {
            type = "button",
            name = "|cFF0000BUG REPORT|r",
            tooltip = "Found an issue? Opens the PermMemento Bug Portal on ESOUI in your default web browser.",
            func = function() 
                RequestOpenUnsafeURL("https://www.esoui.com/portal.php?id=360&a=listbugs") 
            end,
            width = "full"
        })
    end

    LAM:RegisterAddonPanel("PermMementoOptions", panelData)
    LAM:RegisterOptionControls("PermMementoOptions", optionsData)
    
    PM.ctrlActiveDropdown = _G["PM_ActiveDropdown"]
    PM.ctrlSyncDropdown = _G["PM_SyncDropdown"]
    PM.ctrlLearnedDropdown = _G["PM_LearnedDropdown"]
    PM.ctrlFavCandidateDropdown = _G["PM_FavCandidateDropdown"]
    PM.ctrlFavRemoveDropdown = _G["PM_FavRemoveDropdown"]
end

function PM:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, actionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL then
        self.loopToken = (self.loopToken or 0) + 1
        local newToken = self.loopToken
        local duration = (self.settings.delayCast or 3) * 1000
        
        if GetAbilityCastInfo then
            local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
            if castTime and castTime > 0 then duration = castTime + 500 end
            if channeled and channelTime and channelTime > 0 then duration = channelTime + 500 end
        end
        
        if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + duration end
        zo_callLater(function() self:Loop(newToken) end, duration)
    end
end

function PM:OnCollectibleUseResult(eventCode, result, isAttemptingActivation)
    if not self.settings or not self.settings.activeId then return end
    
    if isAttemptingActivation and result ~= 0 then
        self.loopToken = (self.loopToken or 0) + 1
        local newToken = self.loopToken
        
        local retryDelay = 2000 
        
        if GetGameTimeMilliseconds then PM.nextFireTime = GetGameTimeMilliseconds() + retryDelay end
        zo_callLater(function() self:Loop(newToken) end, retryDelay)
    end
end

-- Migration
function PM:Init(eventCode, addOnName)
    if addOnName ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated(); self:BuildMenu(); self.pendingId = self.settings.activeId end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COLLECTIBLE_USE_RESULT, function(eventCode, result, isAttemptingActivation) self:OnCollectibleUseResult(eventCode, result, isAttemptingActivation) end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_Combat", EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "_Combat", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_Effect", EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "_Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    local world = GetWorldName() or "Default"
    self.acctSaved = ZO_SavedVars:NewAccountWide("PermMementoSaved", 1, "AccountWide", self.defaults, world)
    self.charSaved = ZO_SavedVars:NewCharacterIdSettings("PermMementoSaved", 1, "Character", self.defaults, world)
    
    if self.charSaved.useAccountSettings == nil then self.charSaved.useAccountSettings = self.defaults.useAccountSettings end
    
    self:UpdateSettingsReference()
    self:MigrateData() 
    
    -- Delete old data
    if self.acctSaved then self.acctSaved.autoResumeScan = nil end
    if self.charSaved then self.charSaved.autoResumeScan = nil end

    if not self.loopToken then self.loopToken = 0 end
    
    if not self.acctSaved.installDate then
        local d = GetDate()
        if d and type(d) == "number" then d = tostring(d) end
        if d and string.len(d) == 8 then
            self.acctSaved.installDate = string.sub(d, 1, 4) .. "/" .. string.sub(d, 5, 6) .. "/" .. string.sub(d, 7, 8)
        else
            self.acctSaved.installDate = GetDateStringFromTimestamp(GetTimeStamp())
        end
    end
    
    if not self.acctSaved.versionHistory then self.acctSaved.versionHistory = {} end
    if #self.acctSaved.versionHistory == 0 and self.acctSaved.lastVersion and self.acctSaved.lastVersion ~= self.version then
        table.insert(self.acctSaved.versionHistory, self.acctSaved.lastVersion)
    end
    local vLen = #self.acctSaved.versionHistory
    if vLen == 0 or self.acctSaved.versionHistory[vLen] ~= self.version then
        table.insert(self.acctSaved.versionHistory, self.version)
        if #self.acctSaved.versionHistory > 3 then
            table.remove(self.acctSaved.versionHistory, 1)
        end
    end
    self.acctSaved.lastVersion = self.version
    PM.currentSVSizeKB = math.floor(PM:EstimateTableSize(_G["PermMementoSaved"] or {}) / 1024)
    
    self:CreateUI(); self:HookGameUI(); PM.Sync:Initialize()
    
    if not IsConsoleUI() then
        EVENT_MANAGER:RegisterForUpdate(PM.name .. "_StatsUpdate", 1000, function()
            local statsCtrl = _G["PM_StatsText"]
            if statsCtrl and statsCtrl.desc and not statsCtrl:IsHidden() then
                statsCtrl.desc:SetText(PM:GetStatsText())
            end
        end)
    end

    -- Cleanup Event: Combat Exit Trigger
    EVENT_MANAGER:RegisterForEvent(PM.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
        if not inCombat then PM:TriggerMemoryCheck("CombatEnd", 3000) end
    end)
    
    -- Cleanup Event: Menu Enter Trigger
    if SCENE_MANAGER then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            if newState == SCENE_SHOWN then
                if scene.name ~= "hud" and scene.name ~= "hudui" then
                    PM:TriggerMemoryCheck("Menu", 2000)
                end
            end
        end)
    end
    
    -- PMEM Handler
    SLASH_COMMANDS["/pmem"] = function(extra)
        if not self.settings then return end
        local cmd = extra:lower()
        if cmd == "" then
            -- Available Commands
            local cmds = "|c00FF00Available Commands:|r |cFF5733/pmemstop|r, |c33FFF5/pmemrandom|r, |cFFFF33/pmemautolearn|r, |cFF69B4/pmemcleanup|r, |c87CEEB/pmemui|r, |cFFD700/pmemuimode|r, |cDDA0DD/pmemlock|r, |c00FF7F/pmemuireset|r, |cFF7F50/pmemcsa|r, |c7FFFD4/pmemcsacleanup|r, |cDA70D6/pmemunrestrict|r, |c1E90FF/pmemlearned|r, |cFF6347/pmemcurrent|r, |cCCFF00/pmsync <name>|r, |cE6E6FA/pmsyncrandom|r, |cFFB6C1/pmsyncstop|r"
            PM:Log(cmds, false)
            
            PM:Log("You can also type |c00FF00/pmem <name>|r to activate a specific memento. Example: |c00FF00/pmem alma|r", false)
            
            -- Supported Mementos List Dump
            local listStr = "|c00FF00Supported Mementos:|r\n"
            local sortedActive = {}
            for id, data in pairs(self.mementoData) do
                if IsCollectibleUnlocked(id) then table.insert(sortedActive, data) end
            end
            table.sort(sortedActive, function(a,b) return a.name < b.name end)
            
            local palette = {"FF5733", "33FF57", "3357FF", "F333FF", "FF33A8", "33FFF5", "F5FF33", "FF8F33", "8F33FF", "33FF8F", "FF3333", "33FFFF", "FFFF33", "FF00FF", "00FFCC", "CC00FF", "FFCC00", "00BFFF", "FF1493", "7CFC00"}
            
            for _, data in ipairs(sortedActive) do
                local randomColor = palette[math.random(#palette)]
                listStr = listStr .. "- |c" .. randomColor .. data.name .. "|r (" .. (data.dur/1000) .. "s)\n"
            end
            
            PM:Log(listStr, false)
            return
        end
        
        -- Partial Name Logic
        local found = false
        for id, info in pairs(self.mementoData) do 
            if string.find(string.lower(info.name), cmd, 1, true) then 
                if IsCollectibleUnlocked(id) then 
                    self:Log("Auto-loop started: " .. info.name, true, "activation")
                    self:StartLoop(id)
                    found = true
                    break 
                else 
                    self:Log("Memento found but NOT unlocked: " .. info.name, true, "error")
                    found = true
                    break 
                end 
            end 
        end
        if not found then self:Log("Memento not found or not supported.", true, "error") end
    end
    
    -- Command Aliases
    SLASH_COMMANDS["/pmemstop"] = function()
        self.settings.activeId = nil; self.loopToken = (self.loopToken or 0) + 1; self:Log("Auto-loop Stopped", true, "stop"); self.pendingId = 0
        PM.nextFireTime = 0
    end
    
    SLASH_COMMANDS["/pmemcleanup"] = function() PM:RunManualCleanup(false) end
    
    SLASH_COMMANDS["/pmemcsacleanup"] = function() 
        self.settings.csaCleanupEnabled = not self.settings.csaCleanupEnabled
        self:Log("Auto-Cleanup CSA: " .. (self.settings.csaCleanupEnabled and "ON" or "OFF"), true, "settings") 
    end
    
    SLASH_COMMANDS["/pmemui"] = function() 
        self.settings.ui.hidden = not self.settings.ui.hidden; PM:UpdateUIScenes()
        self:Log("UI Visibility: " .. (self.settings.ui.hidden and "HIDDEN" or "VISIBLE"), true, "ui") 
    end
    
    SLASH_COMMANDS["/pmemuimode"] = function() 
        self.settings.showInHUD = not self.settings.showInHUD; PM:UpdateUIScenes()
        self:Log("UI Mode: " .. (self.settings.showInHUD and "HUD" or "Menu"), true, "settings") 
    end
    
    SLASH_COMMANDS["/pmemrandomzonechange"] = function() 
        self.settings.randomOnZone = not self.settings.randomOnZone
        self:Log("Random on Zone: " .. (self.settings.randomOnZone and "ON" or "OFF"), true, "settings") 
    end
    
    SLASH_COMMANDS["/pmemrandomlogin"] = function() 
        self.settings.randomOnLogin = not self.settings.randomOnLogin
        self:Log("Random on Login: " .. (self.settings.randomOnLogin and "ON" or "OFF"), true, "settings") 
    end
    
    SLASH_COMMANDS["/pmemrandom"] = function() 
        local randId = self:GetRandomSupported()
        if randId then local data = PM:GetData(randId); self.settings.activeId = randId; self:Log("Randomly Selected: " .. data.name, true, "random"); self:StartLoop(randId) end 
    end
    
    SLASH_COMMANDS["/pmemrandomlearned"] = function() 
        local randId = self:GetRandomLearned()
        if randId then local data = PM:GetData(randId); self.settings.activeId = randId; self:Log("Randomly Selected (Learned): " .. data.name, true, "random"); self:StartLoop(randId) 
        else self:Log("No learned data found.", true, "error") end 
    end
    
    SLASH_COMMANDS["/pmemcsa"] = function() 
        self.settings.csaEnabled = not self.settings.csaEnabled
        self:Log("Screen Announcements: " .. (self.settings.csaEnabled and "ON" or "OFF"), true, "settings") 
    end
    
    SLASH_COMMANDS["/pmemunrestrict"] = function() 
        self.settings.unrestricted = not self.settings.unrestricted
        self:Log("Unrestricted Mode: " .. (self.settings.unrestricted and "ON" or "OFF"), true, "settings") 
    end
    
    SLASH_COMMANDS["/pmemlock"] = function() 
        self.settings.ui.locked = not self.settings.ui.locked; self.uiWindow:SetMovable(not self.settings.ui.locked)
        self:Log("UI " .. (self.settings.ui.locked and "Locked" or "Unlocked"), true, "ui") 
    end
    
    SLASH_COMMANDS["/pmemuireset"] = function() 
        self.settings.ui.left = self.defaults.ui.left; self.settings.ui.top = self.defaults.ui.top
        self.settings.uiMenu.left = self.defaults.uiMenu.left; self.settings.uiMenu.top = self.defaults.uiMenu.top
        self:UpdateUIAnchor(); self:Log("UI Position Reset.", true, "ui") 
    end
    
    SLASH_COMMANDS["/pmemdeletealllearned"] = function() PM:DeleteAllLearnedData() end
    
    SLASH_COMMANDS["/pmemautolearn"] = function() PM:AutoScanMementos() end
    
    SLASH_COMMANDS["/pmemlearned"] = function() 
        if self.acctSaved and self.acctSaved.learnedData then 
            local msg = "Learned Data:\n"
            local count = 0
            for id, data in pairs(self.acctSaved.learnedData) do msg = msg .. "- " .. data.name .. " (" .. (data.dur/1000) .. "s)\n"; count = count + 1 end
            if count == 0 then PM:Log("Learned Data is empty.", false) else PM:Log(msg, false) end
        else PM:Log("Learned Data is empty.", false) end
    end
    
    SLASH_COMMANDS["/pmemactivatelearned"] = function(extra) 
        local term = extra:lower()
        if term and term ~= "" then 
            if self.acctSaved and self.acctSaved.learnedData then 
                for id, data in pairs(self.acctSaved.learnedData) do 
                    if string.find(string.lower(data.name), term, 1, true) then 
                        self.settings.activeId = id; self:Log("Activated (Learned): " .. data.name, true, "activation"); self:StartLoop(id); return 
                    end 
                end 
            end
            self:Log("Learned Memento not found: " .. term, true, "error") 
        end 
    end
    
    SLASH_COMMANDS["/pmemcurrent"] = function() 
        local data = PM:GetData(self.settings.activeId)
        if self.settings.activeId and data then PM:Log("Active: " .. (data.name or "Unknown"), false) else PM:Log("Inactive", false) end 
    end

end

function PM:OnPlayerActivated()
    PM:TriggerMemoryCheck("ZoneLoad", 5000) -- Cleanup EVENT: Zone Load Trigger
    
    -- Print recent scans to chat log after reload
    if self.acctSaved and self.acctSaved.recentScans and #self.acctSaved.recentScans > 0 then
        zo_callLater(function()
            PM:Log("Newly Learned Mementos from Auto-Scan:", false)
            for _, id in ipairs(self.acctSaved.recentScans) do
                local data = self.acctSaved.learnedData[id]
                if data then
                    local msg = string.format("- %s (ID: %d | RefID: %d | Dur: %dms)", data.name, data.id, data.refID, data.dur)
                    PM:Log(msg, false) -- no CSA
                end
            end
            -- Delete temp table so it doesn't print again
            self.acctSaved.recentScans = nil 
        end, 2000)
    end

    local delay = (self.settings.delayTeleport or 5) * 1000
    if self.settings.randomOnZone then 
        local randId = self:GetRandomSupported()
        if randId then 
            local data = PM:GetData(randId)
            self.settings.activeId = randId
            self:Log("Zone Random: " .. data.name, true, "random") 
        end
    elseif self.settings.randomOnLogin and not self.settings.activeId then 
        local randId = self:GetRandomSupported()
        if randId then 
            local data = PM:GetData(randId)
            self.settings.activeId = randId
            self:Log("Login Random: " .. data.name, true, "random") 
        end 
    end
    
    if self.settings and self.settings.activeId and not self.settings.paused then 
        local currentToken = self.loopToken
        zo_callLater(function() 
            if self.settings.activeId then PM:Loop(currentToken) end 
        end, delay) 
    end
end

EVENT_MANAGER:RegisterForEvent(PM.name, EVENT_ADD_ON_LOADED, function(...) PM:Init(...) end)
_G.PermMementoCore = PM
