# Mouse Controller module for Roblox

## Description
This module provides an advanced and flexible mouse system for Roblox games. It allows you to lock the mouse to the center, unlock it, hide or show the mouse icon, and even enable a free mouse mode with custom icons. This module is perfect for games where precise control over the mouse is required.

### Features:
- Lock and unlock the mouse to the center of the screen.
- Toggle between locked and unlocked states.
- Hide or show the mouse icon based on game requirements.
- Allow the mouse to move freely with a custom interface.
- Set custom mouse icons using asset IDs.
- Full support for player interaction with the mouse.

## Installation

To use the module in your Roblox project, follow these steps:

1. Download the module or clone this repository.
2. Insert the module into the `ReplicatedStorage` (or wherever preferred) within your Roblox game.
3. In your script, require the module like this:

   ```lua
     local MouseModule = require(game.ReplicatedStorage:WaitForChild("MouseModule")) -- Path to module.
   ```

## Methods
Below are the available functions and their descriptions:

- `SetIcon(ID)` -  Sets the custom mouse icon. The `ID` can be a number (asset ID) or a string (with the format `rbxassetid://<ID>`).
- `LockCenter()` - Locks the mouse to the center of the screen. This prevents free movement.
- `UnlockCenter()` - Unlocks the mouse from the center, allowing it to move freely.
- `ToggleLockCenter()` - Toggles between locking and unlocking the mouse from the center.
- `HideMouseIcon()` - Hides the mouse icon on the screen.
- `ShowMouseIcon()` - Restores the mouse icon if it was previously hidden.
- `GetPosition()` - Returns the current X and Y position of the mouse on the screen.
- `FreeMouse()` - Enables free mouse movement with a custom GUI interface for capturing mouse input.
- `UnFreeMouse()` - Disables free mouse mode and restores the previous state.
- `Release()` - Safely disconnects all active connections.

## Exapmle Usage:

   ```lua
   local Mouse = require(game.ReplicatedStorage:WaitForChild("MouseModule")) -- Path to modle

   Mouse:SetIcon(123456789) -- Set a custom mouse icon
   Mouse:LockCenter() -- Lock the mouse to the center
   Mouse:UnlockCenter() -- Unlock the mouse from the center
   Mouse:FreeMouse() -- Enable free mouse movement
   Mouse:UnFreeMouse() -- Disable free mouse movement
   ```

## Notes:
- The module supports toggling the mouse lock state and allows for custom mouse icon settings.
- Debugging messages can be enabled/disabled by setting the `Debug` variable to `true` or `false`.
- Free mouse mode is implemented with a modal `TextButton` GUI that captures mouse input.

`This module was created by @ CordeliusVox for easy mouse management in Roblox games.`
