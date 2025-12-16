# Standalone DUI Weapon UI

A futuristic, standalone weapon UI for FiveM that displays ammo count and a segmented progress bar dynamically positioned near the weapon.

## Features

-   **Dynamic Positioning**: The UI floats near the weapon/hand bone (Bone ID: 60309).
-   **Standalone**: Works with any framework (ESX, QBCore, Custom) as it relies on GTA natives.
-   **Optimized**: Separate threads for state checking and UI rendering to ensure minimal performance impact (`0.00ms` when idle).
-   **Customizable**: Users can change the ammo text color and progress bar color in-game.
-   **Persistent Settings**: Saves user preferences using Resource KVPs.
-   **Low Ammo Warning**: The UI turns red when ammo drops below 25%.

## Dependencies

-   [ox_lib](https://github.com/overextended/ox_lib) (Required for the customization menu)

## Installation

1.  Download the repository and place it in your `resources` folder.
2.  Ensure you have `ox_lib` installed and started.
3.  Add `ensure botz_weaponui` to your `server.cfg` (after `ox_lib`).

## Configuration

The `config.lua` file allows you to set default values:

```lua
Config.AllowUserCustomization = true -- Enable/Disable the /weaponui command
Config.DefaultAmmoColor = "#00f0ff"
Config.DefaultProgressBarColor = "#00f0ff"
```

## Usage

-   **Equip a weapon**: The UI appears automatically.
-   **Shoot**: The ammo count and progress bar update in real-time.
-   **Customize**: Type `/weaponui` to open the settings menu (if enabled). You can change colors or reset to defaults.

## Developer Info

-   **Author**: Botz
-   **Version**: 1.0.0
