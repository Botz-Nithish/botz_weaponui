local currentWeapon = nil
local isEquipped = false
local uiVisible = false

-- Use local variables for runtime config to allow KVP overrides
local runtimeConfig = {
    ammoColor = Config.DefaultAmmoColor,
    progressColor = Config.DefaultProgressBarColor,
    weaponWait = Config.WeaponCheckWait,
    uiWait = Config.UiUpdateWait
}

local function DebugPrint(msg)
    print("^3[WeaponUI] ^7" .. msg)
end

-- Load KVP Settings
local function LoadSettings()
    if not Config.AllowUserCustomization then return end
    
    local kvpAmmo = GetResourceKvpString("botz_weaponui_ammo_color")
    local kvpProg = GetResourceKvpString("botz_weaponui_progress_color")
    
    if kvpAmmo then runtimeConfig.ammoColor = kvpAmmo end
    if kvpProg then runtimeConfig.progressColor = kvpProg end
    
    -- Send updated styling to UI
    SendNUIMessage({
        type = "updateStyle",
        ammoColor = runtimeConfig.ammoColor,
        progressColor = runtimeConfig.progressColor
    })
end

-- Show/Hide Logic
local function ShowUI()
    if uiVisible then return end
    uiVisible = true
    SendNUIMessage({
        type = "toggle",
        show = true
    })
    -- Force style update on show just in case
    SendNUIMessage({
        type = "updateStyle",
        ammoColor = runtimeConfig.ammoColor,
        progressColor = runtimeConfig.progressColor
    })
end

local function HideUI()
    if not uiVisible then return end
    uiVisible = false
    SendNUIMessage({
        type = "toggle",
        show = false
    })
end

-- UI Loop (High Frequency)
Citizen.CreateThread(function()
    while true do
        if isEquipped and currentWeapon then
            local ped = PlayerPedId()
            
            -- Get Ammo Data
            local _, ammoClip = GetAmmoInClip(ped, currentWeapon)
            local maxClip = GetMaxAmmoInClip(ped, currentWeapon, 1)
            -- local totalAmmo = GetAmmoInPedWeapon(ped, currentWeapon) -- Removed as per request
            
            -- Get Coordinates
            -- 60309 = Right Hand
            local boneCoords = GetPedBoneCoords(ped, 60309, 0.0, 0.0, 0.0)
            local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y, boneCoords.z)
            
            if onScreen then
                if not uiVisible then ShowUI() end
                
                SendNUIMessage({
                    type = "update",
                    ammoClip = ammoClip,
                    maxClip = maxClip,
                    x = screenX,
                    y = screenY
                })
            else
                HideUI()
            end
            
            Wait(runtimeConfig.uiWait)
        else
            HideUI()
            -- Wait longer if not equipped to save perf? 
            -- No, this thread handles updates. If not equipped, we wait for state change.
            Wait(40) 
        end
    end
end)

-- Weapon Check Loop (Low Frequency)
Citizen.CreateThread(function()
    -- Load initial settings
    Wait(1000)
    LoadSettings()

    while true do
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        
        if weapon ~= GetHashKey("WEAPON_UNARMED") and weapon ~= 966099553 then
            currentWeapon = weapon
            isEquipped = true
        else
            isEquipped = false
            currentWeapon = nil
        end
        
        Wait(runtimeConfig.weaponWait)
    end
end)

-- Ox Lib Menu
if Config.AllowUserCustomization then
    RegisterCommand('weaponui', function()
        local input = lib.inputDialog('Weapon UI Settings', {
            {
                type = 'color',
                label = 'Ammo Text Color',
                description = 'Color of ammo number text',
                default = runtimeConfig.ammoColor or Config.DefaultAmmoColor
            },
            {
                type = 'color',
                label = 'Progress Bar Color',
                description = 'Color of ammo bar segments',
                default = runtimeConfig.progressColor or Config.DefaultProgressBarColor
            },
            {
                type = 'checkbox',
                label = 'Reset to default colors'
            }
        })

        if not input then return end

        local ammoColor = input[1]
        local progressColor = input[2]
        if input[3] then
            DeleteResourceKvp("botz_weaponui_ammo_color")
            DeleteResourceKvp("botz_weaponui_progress_color")

            runtimeConfig.ammoColor = Config.DefaultAmmoColor
            runtimeConfig.progressColor = Config.DefaultProgressBarColor
            ammoColor = Config.DefaultAmmoColor
            progressColor = Config.DefaultProgressBarColor
        end

        -- Persist to KVP
        SetResourceKvp("botz_weaponui_ammo_color", ammoColor)
        SetResourceKvp("botz_weaponui_progress_color", progressColor)

        -- Apply immediately
        runtimeConfig.ammoColor = ammoColor
        runtimeConfig.progressColor = progressColor

        SendNUIMessage({
            type = "updateStyle",
            ammoColor = ammoColor,
            progressColor = progressColor
        })
    end)
end
