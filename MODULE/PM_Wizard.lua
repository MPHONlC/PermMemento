-- PermMemento - Copyright 2025-2026 @APHONlC.
-- Licensed under the GNU General Public License v3.0 (GPLv3).
-- See LICENSE.md and NOTICE.md.

PermMementoCore = PermMementoCore or {}
local PM = PermMementoCore

local function wizard_title(suffix)
    local t = "|c9CD04CPermanent Memento|r " .. PM.L("WIZARD_SETUP_WORD")
    if suffix then t = t .. " " .. suffix end
    return t
end

local function show_dialog(dialog_id, title, body, buttons)
    LibAPH.ShowDialogChained(dialog_id, title, body, buttons)
end

function PM.finish_wizard()
    PM.acct_saved.wizard_completed = true
    PM.acct_saved.wizard_skipped = false
    PM.state.cached_stats_suffix = nil
    local function auto_unload_wizard()
        LibAPH.AutoUnloadWizardModule(PM.acct_saved, PM.toggle_module_disabled)
    end
    show_dialog("PM_WIZARD_MODULES",
        wizard_title("- " .. PM.L("WIZARD_ALMOST_DONE")),
        PM.L("WIZARD_MODULES_BODY"),
        {
            {
                text = PM.L("WIZARD_MODULES_UNLOAD_BOTH"), keybind = "DIALOG_PRIMARY",
                callback = function()
                    local md = PM.acct_saved.module_disabled or {}
                    if not md.migration then PM.toggle_module_disabled("migration", true) end
                    if not md.sync then PM.toggle_module_disabled("sync", true) end
                    auto_unload_wizard()
                    PM.log_msg(PM.L("CHAT_WIZARD_SETUP_COMPLETE"), true, "settings", 90)
                end
            },
            {
                text = PM.L("WIZARD_MODULES_KEEP_ALL"), keybind = "DIALOG_NEGATIVE",
                callback = function()
                    auto_unload_wizard()
                    PM.log_msg(PM.L("CHAT_WIZARD_SETUP_COMPLETE"), true, "settings", 90)
                end
            }
        }
    )
end

local function step_cleanup()
    show_dialog("PM_WIZARD_CLEANUP",
        wizard_title("(3/3)"),
        PM.L("WIZARD_CLEANUP_BODY"),
        {
            {
                text = PM.L("WIZARD_YES"), keybind = "DIALOG_PRIMARY",
                callback = function()
                    PM.settings.is_auto_cleanup = true
                    PM.call_optional(PM.toggle_cleanup_events, "Core (toggle_cleanup_events)")
                    PM.finish_wizard()
                end
            },
            {
                text = PM.L("WIZARD_NO"), keybind = "DIALOG_NEGATIVE",
                callback = function()
                    PM.settings.is_auto_cleanup = false
                    PM.finish_wizard()
                end
            }
        }
    )
end

local function step_logs()
    show_dialog("PM_WIZARD_LOGS",
        wizard_title("(2/3)"),
        PM.L("WIZARD_LOGS_BODY"),
        {
            {
                text = PM.L("WIZARD_YES"), keybind = "DIALOG_PRIMARY",
                callback = function() PM.settings.is_log_enabled = true; step_cleanup() end
            },
            {
                text = PM.L("WIZARD_NO"), keybind = "DIALOG_NEGATIVE",
                callback = function() PM.settings.is_log_enabled = false; step_cleanup() end
            }
        }
    )
end

local function step_hud()
    show_dialog("PM_WIZARD_HUD",
        wizard_title("(1/3)"),
        PM.L("WIZARD_HUD_BODY"),
        {
            {
                text = PM.L("WIZARD_YES"), keybind = "DIALOG_PRIMARY",
                callback = function()
                    PM.settings.ui.is_hidden = false
                    PM.call_optional(PM.toggle_ui_update, "UI module (toggle_ui_update)")
                    step_logs()
                end
            },
            {
                text = PM.L("WIZARD_NO"), keybind = "DIALOG_NEGATIVE",
                callback = function()
                    PM.settings.ui.is_hidden = true
                    step_logs()
                end
            }
        }
    )
end

local function finish_lite_mode()
    PM.apply_lite_mode()
    PM.acct_saved.wizard_completed = true
    PM.acct_saved.wizard_skipped = false
    PM.state.cached_stats_suffix = nil
    LibAPH.AutoUnloadWizardModule(PM.acct_saved, PM.toggle_module_disabled)
    PM.log_msg(PM.L("CHAT_LITE_MODE_COMPLETE"), true, "settings", 90)
    zo_callLater(function() ReloadUI("ingame") end, 5000)
end

local function step_mode_choice()
    show_dialog("PM_WIZARD_MODE",
        wizard_title(nil),
        PM.L("WIZARD_MODE_BODY"),
        {
            { text = PM.L("WIZARD_MODE_LITE_BTN"), keybind = "DIALOG_PRIMARY", callback = finish_lite_mode },
            { text = PM.L("WIZARD_MODE_FULL_BTN"), keybind = "DIALOG_NEGATIVE", callback = step_hud }
        }
    )
end

function PM.run_wizard()
    show_dialog("PM_WIZARD_WELCOME",
        "|c9CD04C" .. PM.L("WIZARD_WELCOME_TITLE") .. "|r",
        PM.L("WIZARD_WELCOME_BODY"),
        {
            { text = PM.L("WIZARD_QUICK_SETUP"), keybind = "DIALOG_PRIMARY", callback = step_mode_choice },
            {
                text = PM.L("WIZARD_SKIP"), keybind = "DIALOG_NEGATIVE",
                callback = function()
                    PM.acct_saved.wizard_completed = true
                    PM.acct_saved.wizard_skipped = true
                    PM.state.cached_stats_suffix = nil
                end
            }
        }
    )
end

function PM.run_wizard_if_needed()
    LibAPH.ScheduleWizardIfNeeded(PM.acct_saved.wizard_completed, PM.run_wizard)
end

PM._modules.wizard = true
