-- PermMemento - Copyright 2025-2026 @APHONlC.
-- Licensed under the GNU General Public License v3.0 (GPLv3).
-- See LICENSE.md and NOTICE.md.

PermMementoCore = PermMementoCore or {}
local PM = PermMementoCore

function PM.create_gamepad_mover(target)
    return LibAPH.CreateGamepadMover(target)
end
