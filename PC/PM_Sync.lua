-- PermMemento - Copyright 2025-2026 @APHONlC.
-- Licensed under the GNU General Public License v3.0 (GPLv3).
-- See LICENSE.md and NOTICE.md.

PermMementoCore = PermMementoCore or {}
local PM = PermMementoCore

function PM.sync_engine.initialize()
	SLASH_COMMANDS["/pmsync"] = function(arg_str)
		if not PM.settings.sync_module.is_enabled then
			PM.log_msg(PM.L("CHAT_GROUP_SYNC_DISABLED"), true, "error"); return
		end
		if not arg_str or string.len(arg_str) < 1 then
			PM.log_msg(PM.L("CHAT_SYNC_USAGE"), true, "error", 70)
			return
		end
		local c_arg = string.lower(arg_str)

		if c_arg == "stop" then
			StartChatInput("PM STOP", CHAT_CHANNEL_PARTY)
			if PM.settings then
				PM.settings.active_id = nil; PM.state.loop_token = (PM.state.loop_token or 0) + 1
			end
			PM.state.next_fire_time = 0; return
		elseif c_arg == "random" then
			local r_id = PM.call_optional(PM.get_random_any, "Loop module (get_random_any)")
			if r_id then
				local l_str = GetCollectibleLink(r_id, LINK_STYLE_BRACKETS)
				StartChatInput(string.format("PM %s", l_str), CHAT_CHANNEL_PARTY)
				PM.log_msg(PM.L("CHAT_SENT_RANDOM_SYNC"), true, "sync", 90); return
			end
		end

		local max_cat = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
		for i = 1, max_cat do
			local f_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
			if f_id and IsCollectibleUnlocked(f_id) then
				if string.find(string.lower(GetCollectibleName(f_id)), c_arg, 1, true) then
					local l_str = GetCollectibleLink(f_id, LINK_STYLE_BRACKETS)
					StartChatInput(string.format("PM %s", l_str), CHAT_CHANNEL_PARTY)
					return
				end
			end
		end
		PM.log_msg(PM.L("CHAT_MEMENTO_NOT_FOUND"), true, "error", 90)
	end
	SLASH_COMMANDS["/permmementosync"] = SLASH_COMMANDS["/pmsync"]

	local function attempt_col(c_id)
		if not IsCollectibleUsable(c_id) then return end
		if not PM.settings or not PM.settings.sync_module.is_enabled then return end
		if IsUnitInCombat("player") and PM.settings.sync_module.ignore_in_combat then
			return
		end

		if PM.settings.active_id then
			PM.log_msg(PM.L("CHAT_SYNC_RECEIVED_QUEUING"), true, "sync", 70); PM.state.pending_sync_id = c_id
		else
			local c_rem, _ = GetCollectibleCooldownAndDuration(c_id)
			if c_rem and c_rem > 0 then
				PM.log_msg(PM.L("CHAT_SYNC_RECEIVED_COOLDOWN"), true, "sync", 70)
				zo_callLater(function() attempt_col(c_id) end, c_rem + 1000)
			else
				PM.log_msg(PM.L("CHAT_SYNC_RECEIVED_PLAYING"), true, "sync", 80)
				PM.state.is_sync_firing = true; UseCollectible(c_id)
				zo_callLater(function() PM.state.is_sync_firing = false end, 1000)
			end
		end
	end

	PM.state.on_sync_chat_message = function(eventCode, channelType, fromName, text)
		if channelType ~= CHAT_CHANNEL_PARTY then return end
		local cl_name = zo_strformat("<<1>>", fromName)
		if string.match(text, "^PM STOP") then
			if cl_name == GetUnitDisplayName("player") then
				PM.log_msg(PM.L("CHAT_SENT_GROUP_STOP"), true, "sync", 90); return
			end
			if PM.settings then
				PM.settings.active_id = nil; PM.state.loop_token = (PM.state.loop_token or 0) + 1
				PM.state.pending_sync_id = nil; PM.state.next_fire_time = 0
				PM.log_msg(PM.L("CHAT_GROUP_STOP_RECEIVED", cl_name), true, "stop", 90)
			end
			return
		end

		local rest = string.match(text, "^PM (.+)$")
		if not rest then return end
		local f_id
		if string.match(rest, "^|H%d+:collectible:") then
			f_id = GetCollectibleIdFromLink(rest)
		else
			f_id = tonumber(rest)
		end
		if not f_id or f_id == 0 or not IsCollectibleUnlocked(f_id) then return end
		if cl_name == GetUnitDisplayName("player") then
			PM.log_msg(PM.L("CHAT_SENT_GROUP_SYNC"), true, "sync", 90); return
		end
		if not PM.settings then return end

		local s_delay = PM.settings.sync_module.delay or 0
		if PM.settings.sync_module.is_random then s_delay = math.random(0, s_delay) end
		if s_delay == 0 then
			attempt_col(f_id)
		else
			zo_callLater(function() attempt_col(f_id) end, s_delay * 1000)
		end
	end
	PM.toggle_sync_listener()
end

LibAPH.RegisterModuleLifecycle("sync", {
	onUnload = function()
		EVENT_MANAGER:UnregisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL)
		PM.state.on_sync_chat_message = nil
		SLASH_COMMANDS["/pmsync"] = nil
		SLASH_COMMANDS["/permmementosync"] = nil
	end,
	onLoad = function()
		local init_fn = (PM.sync_engine and PM.sync_engine.initialize) or LibAPH.GetStashedFunc("sync", "sync_engine.initialize")
		if init_fn then
			PM.sync_engine = PM.sync_engine or {}
			PM.sync_engine.initialize = init_fn
			init_fn()
		end
	end,
})

PM._modules.sync = true
