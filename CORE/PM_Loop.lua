-- PermMemento - Copyright 2025-2026 @APHONlC.
-- Licensed under the GNU General Public License v3.0 (GPLv3).
-- See LICENSE.md and NOTICE.md.

PermMementoCore = PermMementoCore or {}
local PM = PermMementoCore

function PM.get_stats_text()
    local install_d_raw = (PM.acct_saved and PM.acct_saved.install_date) or PM.L("INSTALL_DATE_UNKNOWN")
    local today_str = PM.get_today_date_str()
    local install_d = LibAPH.FormatInstallDateLine(install_d_raw, today_str)
    local install_line = PM.L("FIELD_INSTALLED_SINCE") .. " " .. install_d

    if PM.state.cached_stats_suffix then
        return install_line .. PM.state.cached_stats_suffix
    end

    local v_hist = (PM.acct_saved and PM.acct_saved.version_history) or {PM.version}
    local v_hist_str = LibAPH.FormatVersionHistory(v_hist, PM.version)

    local lam_ver, lam_en, lhas_ver, lhas_en = PM.get_settings_library()

    local function get_lib_str(ver, en, name, req)
        return LibAPH.FormatLibraryVersion(ver, en, req, {
            missing = function() return string.format("|cFF0000%s (%s)|r", name, PM.L("STATE_MISSING")) end,
            disabled = function(v) return string.format("|cFF0000%s %s|r", name, PM.L("STATE_DISABLED_VER", v)) end,
            exact = function(v) return string.format("|c00FF00%s (v%d)|r", name, v) end,
            old = function(v, r) return string.format("|c888888%s|r |cFF0000%s|r |c00FFFF%s|r", name, PM.L("STATE_OLD", v), PM.L("STATE_EXPECTED", r)) end,
            newer = function(v, r) return string.format("|c00FFFF%s %s %s|r", name, PM.L("STATE_NEWER", v), PM.L("STATE_EXPECTED", r)) end,
        })
    end

    local lib_parts = { "|c00FF00LibAPH (v" .. LibAPH.VERSION .. ")|r" }
    if PM._modules.menu then
        table.insert(lib_parts, get_lib_str(lam_ver, lam_en, "LAM2", PM.REQUIRED_LAM_VERSION))
        if IsConsoleUI() then
            table.insert(lib_parts, get_lib_str(lhas_ver, lhas_en, "LHAS", PM.REQUIRED_LHAS_VERSION))
        end
    end
    local lib_str = (#lib_parts > 0) and table.concat(lib_parts, " | ") or ("|c888888" .. PM.L("LIB_NA") .. "|r")

    local module_files = {
        migration = "MODULE/PM_Migration.lua",
        menu = "MODULE/PM_Menu.lua",
        ui = "MODULE/PM_UI.lua",
        sync = "PC/PM_Sync.lua",
        wizard = "MODULE/PM_Wizard.lua"
    }
    local module_order = { "migration", "ui", "wizard", "menu", "sync" }
    local function pm_module_state(mod_key)
        if PM._modules[mod_key] then return "loaded" end
        local disabled_by_user = PM.acct_saved.module_disabled and PM.acct_saved.module_disabled[mod_key]
        return disabled_by_user and "unloaded" or "missing"
    end
    local modules_str = LibAPH.BuildModuleFileList(
        module_order, module_files, pm_module_state,
        { loaded = PM.L("STATE_LOADED"), unloaded = PM.L("STATE_UNLOADED"), missing = PM.L("STATE_MISSING_FILE") }
    )

    local wizard_status = ""
    if PM.acct_saved.wizard_skipped then
        wizard_status = "\n" .. PM.L("FIELD_WIZARD") .. " |cFF0000" .. PM.L("STATE_SETUP_SKIPPED") .. "|r"
    elseif PM.acct_saved.wizard_completed then
        if PM.acct_saved.wizard_lite_mode and PM.matches_lite_mode_config() then
            wizard_status = "\n" .. PM.L("FIELD_WIZARD") .. " |c00FF00" .. PM.L("STATE_SETUP_DONE_LITE") .. "|r"
        else
            wizard_status = "\n" .. PM.L("FIELD_WIZARD") .. " |c00FF00" .. PM.L("STATE_SETUP_DONE") .. "|r"
        end
    end

    local platform_line = "\n" .. PM.L("FIELD_PLATFORM") .. " |cFFFFFF" .. PM.get_platform_str() .. "|r"

    local lang_code = PM.settings and PM.settings.override_language or GetCVar("Language.2")
    local lang_line = "\n" .. PM.L("FIELD_CURRENT_LANGUAGE") .. " |cFFFFFF" .. PM.get_language_display_name(lang_code) .. "|r"

    local suffix = "\n" .. PM.L("FIELD_VERSION_HISTORY") .. " " .. v_hist_str
        .. "\n" .. PM.L("FIELD_LIBRARY_VERSION") .. " " .. lib_str
        .. platform_line .. wizard_status .. lang_line .. "\n" .. PM.L("FIELD_MODULES") .. "\n  " .. modules_str
    PM.state.cached_stats_suffix = suffix
    return install_line .. suffix
end

function PM.update_learned_count()
    local cc = 0
    if PM.acct_saved and PM.acct_saved.learned_data then
        for _ in pairs(PM.acct_saved.learned_data) do cc = cc + 1 end
    end
    PM.state.learned_count = cc
end

function PM.update_fav_count()
    local cc = 0
    if PM.settings and PM.settings.favorites then
        for k, v in pairs(PM.settings.favorites) do if v then cc = cc + 1 end end
    end
    PM.state.current_fav_count = cc
end

function PM.safe_csa(title, body, lifespan_ms)
    LibAPH.SafeCSA(PM.settings.is_csa_enabled, title, body, lifespan_ms or 6000)
end

function PM.log_msg(msg, is_csa, dur_key, limit_override)
    if not PM.settings then return end
    if PM.settings.is_csa_enabled and is_csa then
        PM.state.csa_debounce_token = (PM.state.csa_debounce_token or 0) + 1
        local my_token = PM.state.csa_debounce_token
        local csa_text = "|cFFD700" .. tostring(msg) .. "|r"
        zo_callLater(function()
            if PM.state.csa_debounce_token == my_token then
                PM.safe_csa(csa_text)
            end
        end, 1500)
    end
    if PM.settings.is_log_enabled then
        PM.chat:Print((string.gsub(tostring(msg), "\n", " ")))
        if IsConsoleUI() and not is_csa and PM.settings.is_csa_enabled then
            PM.safe_csa("|cFFD700" .. tostring(msg) .. "|r")
        end
    end
end

function PM.apply_spin_stop()
    if IsConsoleUI() then return end
    local scene_list = { "character", "stats", "interact" }
    for _, s_name in ipairs(scene_list) do
        local scene_obj = SCENE_MANAGER:GetScene(s_name)
        if scene_obj then
            local has_frag = scene_obj:HasFragment(FRAME_PLAYER_FRAGMENT)
            if PM.settings.is_stop_spinning and has_frag then
                scene_obj:RemoveFragment(FRAME_PLAYER_FRAGMENT)
            elseif not PM.settings.is_stop_spinning and not has_frag then
                scene_obj:AddFragment(FRAME_PLAYER_FRAGMENT)
            end
        end
    end
end

function PM.get_random_supported()
    if not PM.settings.enable_random_fav then return nil end
    local avail = {}
    if PM.settings.favorites then
        for f_id, is_fav in pairs(PM.settings.favorites) do
            if is_fav and IsCollectibleUnlocked(f_id) then
                local is_hardcoded = (PM.memento_data[f_id] ~= nil)
                if PM.settings.is_unrestricted or is_hardcoded then table.insert(avail, f_id) end
            end
        end
    end
    if #avail > 0 then return avail[math.random(#avail)] end

    for f_id, _ in pairs(PM.memento_data) do
        if IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
    end

    if PM.settings.is_unrestricted and PM.acct_saved and PM.acct_saved.learned_data then
        for f_id, _ in pairs(PM.acct_saved.learned_data) do
            if IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
        end
    end
    return #avail > 0 and avail[math.random(#avail)] or nil
end

function PM.get_random_learned()
    if not PM.settings.enable_random_fav then return nil end
    if not PM.acct_saved or not PM.acct_saved.learned_data then return nil end
    local avail = {}
    for f_id, _ in pairs(PM.acct_saved.learned_data) do
        if IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
    end
    return #avail > 0 and avail[math.random(#avail)] or nil
end

function PM.get_random_any()
    if not PM.settings.enable_random_fav then return nil end
    local avail = {}
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local f_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if f_id and IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
    end
    return #avail > 0 and avail[math.random(#avail)] or nil
end

function PM.update_movement_state()
    if not GetUnitRawWorldPosition then return end
    PM.movement_tracker:Update()
    PM.state.is_moving = PM.movement_tracker:IsMoving()
end

function PM.run_manual_cleanup(is_auto, is_emergency)
    PM.state.mem_state = 1
    LibAPH.RunDoubleGCPass({
        getPoolMB = PM.get_console_pool_mb,
        extraPass = is_emergency,
        onDone = function(before_lua, after_lua, freed, before_pool, after_pool, freed_pool)
            PM.state.mem_freed = freed
            PM.state.mem_state = 0

            local show_csa = PM.settings.is_csa_enabled
            if is_auto and not PM.settings.is_csa_cleanup_enabled then show_csa = false end

            if freed > 0.001 or freed_pool > 0.001 then
                local msg = PM.build_memory_status_line(after_lua, freed, after_pool, freed_pool)
                if PM.settings.is_log_enabled then
                    PM.chat:Print(msg)
                end
                if show_csa then
                    PM.safe_csa(PM.L("CSA_TITLE_CLEANED"), PM.build_memory_status_lines(after_lua, freed, after_pool, freed_pool))
                end
            elseif not is_auto then
                local msg = PM.build_memory_status_line(after_lua, 0, after_pool, 0) .. " |c888888" .. PM.L("LABEL_ALREADY_CLEAN") .. "|r"
                if PM.settings.is_log_enabled then
                    PM.chat:Print(msg)
                end
                if show_csa then
                    PM.safe_csa(PM.L("CSA_TITLE_ALREADY_CLEAN"), PM.build_memory_status_lines(after_lua, 0, after_pool, 0))
                end
            end
        end,
    })
end

function PM.trigger_memory_check(check_type, delay)
    if PM.is_alc_enabled() then return end
    if PM.state.mem_state == 1 or PM.state.is_mem_check_queued then return end

    local is_console = IsConsoleUI()
    local current_mb = is_console and GetTotalUserAddOnMemoryPoolUsageMB() or (collectgarbage("count") / 1024)
    local limit_threshold = is_console and 85 or 400

    if current_mb >= limit_threshold then
        local in_combat = IsUnitInCombat("player")
        if in_combat or IsUnitDead("player") then return end
        PM.state.is_mem_check_queued = true

        zo_callLater(function()
            PM.state.is_mem_check_queued = false
            if PM.state.mem_state == 1 then return end

            local still_in_combat = IsUnitInCombat("player")
            if still_in_combat or IsUnitDead("player") then return end

            if check_type == "Menu" then
                local in_menu = not (
                    SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
                )
                if not in_menu then return end
            end

            local recheck_mb = is_console and GetTotalUserAddOnMemoryPoolUsageMB() or (collectgarbage("count") / 1024)
            if recheck_mb >= limit_threshold then
                PM.run_manual_cleanup(true)
                EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_MemFallback")
                EVENT_MANAGER:RegisterForUpdate(PM.name .. "_MemFallback", 300000, function()
                    PM.trigger_memory_check("Fallback", 0)
                end)
            end
        end, delay)
    else
        EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_MemFallback")
        PM.state.mem_state = 0
    end
end

function PM.is_busy()
    return LibAPH.CheckBusyReason({
        { enabled = PM.settings.busy_check_teleport, check = function() return PM.teleport_tracker:IsTeleporting() end,
          delayMs = (PM.settings.delay_teleport or 5) * 1000 },
        { enabled = PM.settings.busy_check_resurrecting, check = IsResurrectPending,
          reasonKey = PM.L("LABEL_RESURRECTING"), delayMs = (PM.settings.delay_resurrect or 5) * 1000 },
        { enabled = PM.settings.busy_check_resurrecting, check = function() return IsUnitReincarnating("player") end,
          reasonKey = PM.L("LABEL_REVIVING"), delayMs = (PM.settings.delay_resurrect or 5) * 1000 },
        { enabled = PM.settings.busy_check_dead, check = function() return IsUnitDead("player") end,
          reasonKey = PM.L("LABEL_DEAD"), delayMs = (PM.settings.delay_dead or 2) * 1000 },
        { enabled = not PM.settings.is_loop_in_combat, check = function() return IsUnitInCombat("player") end,
          reasonKey = PM.L("LABEL_COMBAT"), delayMs = (PM.settings.delay_combat_end or 5) * 1000 },
        { enabled = PM.settings.busy_check_crafting, check = LibAPH.IsPlayerCrafting,
          reasonKey = PM.L("LABEL_CRAFTING"), delayMs = (PM.settings.delay_crafting or 2) * 1000 },
        { enabled = PM.settings.busy_check_interacting, check = LibAPH.IsPlayerInteracting,
          reasonKey = PM.L("LABEL_INTERACTING"), delayMs = (PM.settings.delay_in_menu or 5) * 1000 },
        { enabled = PM.settings.busy_check_menu, check = LibAPH.IsPlayerInMenu,
          reasonKey = PM.L("LABEL_MENU"), delayMs = (PM.settings.delay_in_menu or 5) * 1000 },
        { enabled = PM.settings.busy_check_blocking, check = IsBlockActive,
          reasonKey = PM.L("LABEL_BLOCKING"), delayMs = (PM.settings.delay_block or 5) * 1000 },
        { enabled = PM.settings.busy_check_swimming, check = function() return IsUnitSwimming("player") end,
          reasonKey = PM.L("LABEL_SWIMMING"), delayMs = (PM.settings.delay_swim or 5) * 1000 },
        { enabled = PM.settings.busy_check_mounted, check = function() return IsMounted("player") end,
          reasonKey = PM.L("LABEL_MOUNTED"), delayMs = (PM.settings.delay_mount or 5) * 1000 },
        { enabled = PM.settings.busy_check_sneaking, check = function() return GetUnitStealthState("player") ~= STEALTH_STATE_NONE end,
          reasonKey = PM.L("LABEL_SNEAKING"), delayMs = (PM.settings.delay_sneak or 5) * 1000 },
        { enabled = PM.settings.busy_check_moving, check = function() return PM.state.is_moving end,
          reasonKey = PM.L("LABEL_MOVING"), delayMs = (PM.settings.delay_move or 5) * 1000 },
    })
end

function PM.resolve_memento_duration_ms(c_id, r_id, begin_s, end_s)
    if begin_s and end_s and end_s > begin_s then
        return zo_floor((end_s - begin_s) * 1000 + 0.5)
    end
    if r_id and r_id > 0 and GetAbilityDuration then
        local ab_dur = GetAbilityDuration(r_id)
        if ab_dur and ab_dur > 0 then return ab_dur end
    end
    local _, cd_dur = GetCollectibleCooldownAndDuration(c_id)
    if cd_dur and cd_dur > 0 then return cd_dur end
    return 10000
end

function PM.on_effect_changed(eventCode, changeType, effectSlot, effectName, unitTag, beginTime,
                              endTime, stackCount, iconName, buffType, effectType, abilityType,
                              statusEffectType, unitName, unitId, abilityId, sourceUnitId)
    if not PM.settings then return end
    local is_gain = (changeType == EFFECT_RESULT_GAINED)

    if is_gain and not PM.settings.is_paused then
        local matched_id = nil
        for fid, fmd in pairs(PM.memento_data) do
            if fmd.ref_id and fmd.ref_id > 0 and fmd.ref_id == abilityId then
                matched_id = fid; break
            end
        end
        if not matched_id and PM.acct_saved and PM.acct_saved.learned_data then
            for fid, fmd in pairs(PM.acct_saved.learned_data) do
                if fmd.ref_id and fmd.ref_id > 0 and fmd.ref_id == abilityId then
                    matched_id = fid; break
                end
            end
        end
        if not matched_id and PM.settings.is_unrestricted then
            local max_cat = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
            for i = 1, max_cat do
                local c_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
                if c_id then
                    local c_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(c_id)
                    local r_id = c_data and c_data.GetReferenceId and c_data:GetReferenceId()
                    if r_id and r_id > 0 and r_id == abilityId then
                        matched_id = c_id; break
                    end
                end
            end
        end
        if matched_id and matched_id ~= PM.settings.active_id then
            PM.settings.active_id = matched_id
            PM.state.loop_token = (PM.state.loop_token or 0) + 1
        end
    end

    if not PM.settings.active_id then return end

    if PM.settings.enable_learning and (PM.settings.is_unrestricted or PM.state.is_scanning) and is_gain then
         local act_id = PM.settings.active_id
         local is_unlearned = (PM.acct_saved and PM.acct_saved.learned_data and
                               not PM.acct_saved.learned_data[act_id])

         if not PM.memento_data[act_id] and is_unlearned then
             local c_name = GetCollectibleName(act_id)
             PM.ensure_table(PM.acct_saved, "learned_data")
             local r_id = 0
             local c_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(act_id)
             if c_data and c_data.GetReferenceId then r_id = c_data:GetReferenceId() end
             if r_id == 0 then r_id = abilityId end
             local s_dur = PM.resolve_memento_duration_ms(act_id, r_id, beginTime, endTime)
             PM.acct_saved.learned_data[act_id] = {
                 id = act_id, ref_id = r_id, dur = s_dur, name = c_name
             }
             PM.update_learned_count()
             local out_msg = string.format(
                 "Saved: %s\nID: %d | RefID: %d | Dur: %dms | Total Learned: %d",
                 c_name, act_id, r_id, s_dur, PM.state.learned_count
             )
             PM.log_msg(out_msg, true, "settings", 70)
         end
    end

    local md = PM.get_data(PM.settings.active_id)
    local is_match = false
    if md and md.ref_id > 0 and abilityId == md.ref_id then is_match = true end

    if is_match and changeType == EFFECT_RESULT_FADED then
        PM.state.loop_token = (PM.state.loop_token or 0) + 1
        PM.run_loop(PM.state.loop_token)
    end
end

function PM.auto_scan_mementos()
    if not PM.settings.enable_learning then
        PM.log_msg(PM.L("CHAT_LEARNING_DISABLED"), true, "error"); return
    end
    if PM.state.is_scanning then return end
    PM.state.is_scanning = true
    local c_count = 0
    local max_col = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
    PM.log_msg(PM.L("CHAT_AUTOSCAN_STARTING"), true, "settings", 90)
    PM.acct_saved.recentScans = {}

    for i = 1, max_col do
        local m_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if m_id and IsCollectibleUnlocked(m_id) then
            local r_id = 0
            local c_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(m_id)
            if c_data and c_data.GetReferenceId then r_id = c_data:GetReferenceId() end
            local s_dur = PM.resolve_memento_duration_ms(m_id, r_id)
            local prev = PM.acct_saved.learned_data and PM.acct_saved.learned_data[m_id]
            if not prev or prev.dur ~= s_dur or prev.ref_id ~= r_id then
                local c_name = GetCollectibleName(m_id)
                PM.ensure_table(PM.acct_saved, "learned_data")
                PM.acct_saved.learned_data[m_id] = {
                    id = m_id, ref_id = r_id, dur = s_dur, name = c_name
                }
                table.insert(PM.acct_saved.recentScans, m_id)
                c_count = c_count + 1
            end
        end
    end

    PM.state.is_scanning = false
    if c_count == 0 then
        PM.log_msg(PM.L("CHAT_ALL_ALREADY_LEARNED"), true, "settings", 90)
        PM.acct_saved.recentScans = nil
    else
        PM.update_learned_count()
        PM.log_msg(PM.L("CHAT_SUCCESSFULLY_LEARNED", c_count), false)
        PM.state.is_menu_built = false; zo_callLater(function() ReloadUI("ingame") end, 3000)
    end
end

function PM.run_loop(req_token)
    local state = PM.state
    if not PM.settings or PM.settings.is_paused or not PM.settings.active_id then return end
    if req_token ~= state.loop_token then return end

    local md = PM.get_data(PM.settings.active_id)
    if not md then PM.settings.active_id = nil; return end

    local is_busy, reason, w_delay = PM.is_busy()
    if is_busy then
        local wait_ms = (w_delay > 0) and w_delay or ((PM.settings.delay_idle or 0) * 1000)
        if wait_ms < 100 then wait_ms = 100 end
        state.delay_reason = reason
        if GetGameTimeMilliseconds then
            state.next_fire_time = GetGameTimeMilliseconds() + wait_ms
        end
        zo_callLater(function() PM.run_loop(req_token) end, wait_ms); return
    end
    state.delay_reason = nil
    PM.trigger_memory_check("Loop", 0)

    local cur_target = PM.settings.active_id
    if state.pending_sync_id then cur_target = state.pending_sync_id end

    local cd_rem, _ = GetCollectibleCooldownAndDuration(cur_target)
    if cd_rem and cd_rem > 500 then
        local wait_ms = cd_rem + ((PM.settings.delay_idle or 0) * 1000)
        if wait_ms < 1000 then wait_ms = 1000 end
        if GetGameTimeMilliseconds then
            state.next_fire_time = GetGameTimeMilliseconds() + wait_ms
        end
        zo_callLater(function() PM.run_loop(req_token) end, wait_ms); return
    end

    state.is_looping = true
    if state.pending_sync_id then
         state.is_sync_firing = true; UseCollectible(state.pending_sync_id)
         zo_callLater(function()
             if req_token ~= state.loop_token then return end
             local s_rem, s_dur = GetCollectibleCooldownAndDuration(state.pending_sync_id)
             local wait_ms = (s_rem > 0) and s_rem or s_dur
             PM.log_msg(PM.L("CHAT_SYNC_FINISHED"), true, "sync", 80)
             state.pending_sync_id = nil; state.is_sync_firing = false; state.is_looping = false
             if GetGameTimeMilliseconds then
                 state.next_fire_time = GetGameTimeMilliseconds() + wait_ms + 1000
             end
             zo_callLater(function() PM.run_loop(req_token) end, wait_ms + 1000)
         end, 500); return
    end

    UseCollectible(PM.settings.active_id)
    state.session_loops = state.session_loops + 1
    if PM.acct_saved then
        PM.acct_saved.total_loops = (PM.acct_saved.total_loops or 0) + 1
        PM.ensure_table(PM.acct_saved, "memento_usage")
        local curr_use = PM.acct_saved.memento_usage[PM.settings.active_id] or 0
        PM.acct_saved.memento_usage[PM.settings.active_id] = curr_use + 1
        PM.trigger_priority_save()
    end

    local rand_zone = PM.settings.is_random_on_zone
    local rand_log = PM.settings.is_random_on_login
    if (rand_zone or rand_log) and PM.settings.enable_random_fav then
        state.next_random_precalc = PM.get_random_supported()
    end
    state.is_looping = false

    local is_unres = PM.settings.is_unrestricted
    if not PM.memento_data[PM.settings.active_id] and not is_unres then
        PM.settings.active_id = nil; return
    end

    local wait_ms = md.dur + 1000 + ((PM.settings.delay_idle or 0) * 1000)
    if GetGameTimeMilliseconds then state.next_fire_time = GetGameTimeMilliseconds() + wait_ms end
    zo_callLater(function() PM.run_loop(req_token) end, wait_ms)
end

function PM.start_loop(c_id, bypass_res)
    local md = PM.get_data(c_id)
    if not md then return end

    if not PM.memento_data[c_id] and not PM.settings.is_unrestricted and not bypass_res then
        PM.log_msg(
            "Activating " .. md.name .. " (Looping Disabled - Unrestricted Mode Required)",
            true, "activation", 70
        )
        UseCollectible(c_id); return
    end

    PM.settings.active_id = c_id; PM.settings.is_paused = false
    PM.state.loop_token = (PM.state.loop_token or 0) + 1

    local rand_zone = PM.settings.is_random_on_zone
    local rand_log = PM.settings.is_random_on_login
    if (rand_zone or rand_log) and PM.settings.enable_random_fav then
        PM.state.next_random_precalc = PM.get_random_supported()
    end

    local cur_token = PM.state.loop_token
    local is_busy, reason, w_delay = PM.is_busy()
    if is_busy then
        local wait_ms = (w_delay > 0) and w_delay or ((PM.settings.delay_idle or 0) * 1000)
        if wait_ms < 100 then wait_ms = 100 end
        PM.state.delay_reason = reason
        if GetGameTimeMilliseconds then PM.state.next_fire_time = GetGameTimeMilliseconds() + wait_ms end
        zo_callLater(function() PM.run_loop(cur_token) end, wait_ms)
    else
        PM.state.delay_reason = nil
        PM.state.is_looping = true; UseCollectible(c_id); PM.state.is_looping = false
        PM.state.session_loops = PM.state.session_loops + 1
        if PM.acct_saved then
            PM.acct_saved.total_loops = (PM.acct_saved.total_loops or 0) + 1
            PM.ensure_table(PM.acct_saved, "memento_usage")
            local curr_use = PM.acct_saved.memento_usage[c_id] or 0
            PM.acct_saved.memento_usage[c_id] = curr_use + 1
            PM.trigger_priority_save()
        end
        local wait_ms = md.dur + 1000 + ((PM.settings.delay_idle or 0) * 1000)
        if GetGameTimeMilliseconds then PM.state.next_fire_time = GetGameTimeMilliseconds() + wait_ms end
        zo_callLater(function() PM.run_loop(cur_token) end, wait_ms)
    end
end

function PM.on_combat_event(eventCode, result, isError, abilityName, abilityGraphic,
                            actionSlotType, sourceName, sourceType, targetName, targetType,
                            hitValue, powerType, damageType, log, sourceUnitId, targetUnitId,
                            abilityId, overflow)
    if not PM.settings or not PM.settings.active_id then return end
    if not PM.settings.busy_check_attacking then return end

    local is_attack = actionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK
        or actionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK
        or actionSlotType == ACTION_SLOT_TYPE_WEAPON_ATTACK
    if not is_attack then return end

    PM.state.loop_token = (PM.state.loop_token or 0) + 1
    local tkn = PM.state.loop_token
    local w_ms = (PM.settings.delay_attack or 2) * 1000

    PM.state.delay_reason = PM.L("LABEL_ATTACKING")
    if GetGameTimeMilliseconds then
        PM.state.next_fire_time = GetGameTimeMilliseconds() + w_ms
    end
    zo_callLater(function() PM.run_loop(tkn) end, w_ms)
end

function PM.on_ability_used(eventCode, actionSlotIndex)
    if not PM.settings or not PM.settings.active_id then return end
    if not PM.settings.busy_check_casting then return end
    if actionSlotIndex <= ACTION_BAR_FIRST_NORMAL_SLOT_INDEX then return end

    PM.state.loop_token = (PM.state.loop_token or 0) + 1
    local tkn = PM.state.loop_token
    local w_ms = (PM.settings.delay_cast or 3) * 1000

    local ability_id = GetSlotBoundId(actionSlotIndex)
    if ability_id and ability_id ~= 0 then
        local is_chan, c_time, chan_time = GetAbilityCastInfo(ability_id)
        if c_time and c_time > 0 then w_ms = c_time + 500 end
        if is_chan and chan_time and chan_time > 0 then w_ms = chan_time + 500 end
    end

    PM.state.delay_reason = PM.L("LABEL_CASTING")
    if GetGameTimeMilliseconds then
        PM.state.next_fire_time = GetGameTimeMilliseconds() + w_ms
    end
    zo_callLater(function() PM.run_loop(tkn) end, w_ms)
end

function PM.on_collectible_use_result(eventCode, result, isAttemptingActivation)
    if not PM.settings or not PM.settings.active_id then return end

    if isAttemptingActivation and result ~= 0 then
        PM.state.loop_token = (PM.state.loop_token or 0) + 1
        local tkn = PM.state.loop_token
        local w_ms = 2000

        if GetGameTimeMilliseconds then
            PM.state.next_fire_time = GetGameTimeMilliseconds() + w_ms
        end
        zo_callLater(function() PM.run_loop(tkn) end, w_ms)
    end
end

function PM.hook_collectible_activation()
    ZO_PreHook("UseCollectible", function(c_id)
        if not PM.settings then return end
        if PM.state.is_looping or PM.state.is_scanning then return end
        if GetCollectibleCategoryType(c_id) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
        if PM.state.is_sync_firing then return end

        if (c_id == 336 or c_id == 341) and PM.settings.active_id ~= c_id then
            if PM.state.is_bmu_teleport_animating then return end

            local is_col = SCENE_MANAGER:IsShowing("collectionsBook") or
                SCENE_MANAGER:IsShowing("gamepadCollectionsBook")
            local is_qs = SCENE_MANAGER:IsShowing("quickslot")
            if not is_col and not is_qs then return end
        end

        local md = PM.get_data(c_id)
        local is_col = SCENE_MANAGER:IsShowing("collectionsBook") or
            SCENE_MANAGER:IsShowing("gamepadCollectionsBook")

        if not md and PM.settings.is_unrestricted and is_col and PM.settings.enable_learning then
             local c_name = GetCollectibleName(c_id)
             PM.ensure_table(PM.acct_saved, "learned_data")
             local r_id = 0
             local c_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(c_id)
             if c_data and c_data.GetReferenceId then r_id = c_data:GetReferenceId() end

             zo_callLater(function()
                 local s_dur = PM.resolve_memento_duration_ms(c_id, r_id)
                 PM.acct_saved.learned_data[c_id] = {
                     id = c_id, ref_id = r_id, dur = s_dur, name = c_name
                 }
                 PM.call_optional(PM.update_learned_count, "Loop module (update_learned_count)")
                 local out_msg = PM.L(
                     "CHAT_LEARNED_SAVED",
                     c_name, c_id, r_id, s_dur, PM.state.learned_count
                 )
                 PM.log_msg(out_msg, true, "settings", 70)
                 PM.call_optional(PM.update_menu_choices, "Menu module (update_menu_choices)")
             end, 500)
        end

        if PM.settings.active_id == c_id then
             PM.settings.active_id = nil; PM.settings.is_paused = false
             PM.state.loop_token = (PM.state.loop_token or 0) + 1
             PM.log_msg(PM.L("CHAT_AUTOLOOP_STOPPED"), true, "stop", 90)
             PM.state.pending_id = 0; PM.state.next_fire_time = 0; return
        end

        if md then
            if not PM.memento_data[c_id] and not PM.settings.is_unrestricted then
                 PM.log_msg(
                     PM.L("CHAT_ACTIVATING_UNRESTRICTED_REQUIRED", md.name),
                     true, "activation", 70
                 ); return
            end
            local is_sw = (PM.settings.active_id ~= nil)
            PM.settings.active_id = c_id; PM.settings.is_paused = false
            PM.state.loop_token = (PM.state.loop_token or 0) + 1; PM.state.pending_id = c_id

            if is_sw then
                PM.log_msg(PM.L("CHAT_MEMENTO_SWITCHED", md.name), true, "activation", 90)
            else
                PM.log_msg(PM.L("CHAT_AUTOLOOP_STARTED", md.name), true, "activation", 90)
            end

            local tkn = PM.state.loop_token
            zo_callLater(function() PM.call_optional(PM.run_loop, "Loop module (run_loop)", tkn) end, 100)
        else
            if PM.settings.active_id then
                PM.settings.active_id = nil; PM.state.loop_token = (PM.state.loop_token or 0) + 1
                PM.state.pending_id = 0; PM.state.next_fire_time = 0
                PM.log_msg(PM.L("CHAT_AUTOLOOP_STOPPED"), true, "stop", 90)
            end
        end
    end)
end

function PM.hook_beam_me_up_animation()
    if type(BMU) ~= "table" or type(BMU.showTeleportAnimation) ~= "function" then return end
    ZO_PreHook(BMU, "showTeleportAnimation", function()
        PM.state.is_bmu_teleport_animating = true
        zo_callLater(function() PM.state.is_bmu_teleport_animating = false end, 100)
    end)
end

function PM.integrate_with_beam_me_up()
    if type(BMU) ~= "table" or type(BMU.savedVarsAcc) ~= "table" then return end
    BMU.savedVarsAcc.showTeleportAnimation = false
end

PM._modules.loop = true
