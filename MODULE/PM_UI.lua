-- PermMemento - Copyright 2025-2026 @APHONlC.
-- Licensed under the GNU General Public License v3.0 (GPLv3).
-- See LICENSE.md and NOTICE.md.

PMCore = PMCore or {}
local PM = PMCore

function PM.update_ui_anchor()
	if not PM.ui_refs.ui_window or not PM.settings then return end
	PM.ui_refs.ui_window:ClearAnchors(); PM.ui_refs.ui_window:SetMovable(not PM.settings.ui.is_locked)
	local x_offset = 0; if _G["PP"] then x_offset = 0.5 end
	local is_pad = IsConsoleUI() or IsInGamepadPreferredMode()

	if PM.settings.show_in_hud then
		PM.ui_refs.ui_window:SetScale(PM.settings.ui.scale or (is_pad and 1.0 or 1.0))
		if PM.settings.ui.left == PM.defaults.ui.left and PM.settings.ui.top == PM.defaults.ui.top then
			if is_pad then PM.ui_refs.ui_window:SetAnchor(LEFT, ZO_Compass, RIGHT, 15, 0)
			else PM.ui_refs.ui_window:SetAnchor(LEFT, ZO_Compass, RIGHT, 15 + x_offset, 0) end
		else
			PM.ui_refs.ui_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PM.settings.ui.left, PM.settings.ui.top)
		end
	else
		PM.ui_refs.ui_window:SetScale(PM.settings.ui_menu.scale or (is_pad and 1.2 or 1.0))
		local d_left, d_top = PM.defaults.ui_menu.left, PM.defaults.ui_menu.top
		if PM.settings.ui_menu.left == d_left and PM.settings.ui_menu.top == d_top then
			if is_pad then
				PM.ui_refs.ui_window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -50, 50)
			else
				if ZO_CollectionsBook_TopLevelSearchBox then
					PM.ui_refs.ui_window:SetAnchor(LEFT, ZO_CollectionsBook_TopLevelSearchBox, RIGHT, 10 + x_offset, 0)
				else PM.ui_refs.ui_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100 + x_offset, 100) end
			end
		else
			PM.ui_refs.ui_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PM.settings.ui_menu.left, PM.settings.ui_menu.top)
		end
	end
end

function PM.update_ui_scenes()
	if not PM.ui_refs.hudFragment or not PM.ui_refs.menuFragment then return end
	local hud_arr = {"hud", "hudui", "gamepad_hud", "interact"}
	local menu_arr = {"collectionsBook", "gamepad_collections_book", "gamepadCollectionsBook"}

	LibAPH.RemoveFragmentFromScenes(PM.ui_refs.hudFragment, hud_arr)
	LibAPH.RemoveFragmentFromScenes(PM.ui_refs.menuFragment, menu_arr)

	if not PM.settings.ui.is_hidden then
		if PM.settings.show_in_hud then
			if not PM.settings.is_ui_global then
				LibAPH.AddFragmentToScenes(PM.ui_refs.hudFragment, hud_arr)
			end
		else
			LibAPH.AddFragmentToScenes(PM.ui_refs.menuFragment, menu_arr)
		end
	end
	PM.update_ui_anchor()

	if PM.ui_refs.ui_window then
		if PM.settings.ui.is_hidden then
			PM.ui_refs.ui_window:SetHidden(true)
		else
			local cur_scene = SCENE_MANAGER:GetCurrentScene()
			local should_show = false
			if cur_scene then
				if PM.settings.show_in_hud then
					should_show = PM.settings.is_ui_global or cur_scene:HasFragment(PM.ui_refs.hudFragment)
				elseif cur_scene:HasFragment(PM.ui_refs.menuFragment) then
					should_show = true
				end
			end
			PM.ui_refs.ui_window:SetHidden(not should_show)
		end
	end
end

function PM.toggle_ui_update()
	if not PM.ui_refs.ui_window then return end
	if PM.settings.ui.is_hidden then
		PM.ui_refs.ui_window:SetHandler("OnUpdate", nil)
	else
		PM.ui_refs.ui_window:SetHandler("OnUpdate", PM.ui_refs.ui_update_fn)
	end
	PM.update_ui_scenes()
end

function PM.create_ui()
	local is_pad = IsConsoleUI() or IsInGamepadPreferredMode()

	local win, text_lbl = LibAPH.CreateStatusWindow({
		name = "PermMementoUI",
		movable = not PM.settings.ui.is_locked,
		isGamepad = is_pad,
		onMoveStop = function(left, top)
			if not PM.settings then return end
			if PM.settings.show_in_hud then
				PM.settings.ui.left = left; PM.settings.ui.top = top
			else
				PM.settings.ui_menu.left = left; PM.settings.ui_menu.top = top
			end
		end,
	})

	PM.ui_refs.ui_window = win
	PM.update_ui_anchor()

	PM.ui_refs.ui_mover = PM.call_optional(PM.create_gamepad_mover, "Console UI module (create_gamepad_mover)", win)
	if PM.ui_refs.ui_mover then
		PM.ui_refs.ui_mover:RegisterCallback(PM.name .. "_UI", 2, function(new_pos)
			if not PM.settings then return end
			if type(new_pos.left) == "number" and type(new_pos.top) == "number" then
				if PM.settings.show_in_hud then
					PM.settings.ui.left = new_pos.left
					PM.settings.ui.top = new_pos.top
				else
					PM.settings.ui_menu.left = new_pos.left
					PM.settings.ui_menu.top = new_pos.top
				end
			end
		end)
	end

	local function force_resize()
		win:SetDimensions(text_lbl:GetTextWidth() + 20, text_lbl:GetTextHeight() + 10)
	end
	local resize_opts = { onResize = force_resize }
	local last_tick = 0

	PM.ui_refs.ui_update_fn = function(ctrl, f_time)
		if PM._modules.loop then PM.update_movement_state() end
		if not PM.settings then return end
		local r_rate = 1.0
		if (f_time - last_tick < r_rate) then return end
		last_tick = f_time

		local md = PM.get_data(PM.settings.active_id)
		if not LibAPH.SetWindowActive(win, text_lbl, PM.settings.active_id and md, resize_opts) then
			return
		end

		if PM.settings.is_paused then
			text_lbl:SetText(string.format("%s |cFF0000(%s)|r", md.name, PM.L("LABEL_PAUSED")))
			force_resize(); return
		end

		local cd_txt
		local cd_rem, _ = GetCollectibleCooldownAndDuration(PM.settings.active_id)

		if cd_rem > 0 then cd_txt = string.format(" |cFFA500(%.1fs)|r", cd_rem / 1000)
		else
			local tick_ms = GetGameTimeMilliseconds()
			if tick_ms < PM.state.next_fire_time then
				local d_sec = (PM.state.next_fire_time - tick_ms) / 1000
				local reason = PM.state.delay_reason or PM.L("LABEL_DELAYING")
				cd_txt = string.format(" |cFF69B4(%s... %.1fs)|r", reason, d_sec)
			else cd_txt = " |c00FF00(Ready)|r" end
		end

		text_lbl:SetText(md.name .. cd_txt); force_resize()
	end

	PM.ui_refs.uiLabel = text_lbl
	PM.ui_refs.hudFragment = ZO_HUDFadeSceneFragment:New(win)
	PM.ui_refs.menuFragment = ZO_FadeSceneFragment:New(win)
end

PM._modules.ui = true
