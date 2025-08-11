local mod = get_mod("bordercheck")

--[[
Vermintide 2 Useful APIs for mod development:

Position/Movement:
- Unit.world_position(unit, node_index) - Get world position of unit
- Vector3(x, y, z) - Create Vector3
- Vector3.distance(pos1, pos2) - Calculate distance

Physics/Raycasting:
- PhysicsWorld.immediate_raycast(physics_world, from, to, mode, collision_filter, ...)
- Managers.world:world("level_world") - Get level world
- World.get_data(world, "physics_world") - Get physics world

Player:
- Managers.player:local_player() - Get local player
- local_player.player_unit - Get player unit
- Unit.alive(unit) - Check if unit is alive

Rendering/Debug:
- QuickDrawer:sphere(position, radius, color) - Draw sphere
- QuickDrawer:line(from, to, color) - Draw line
- Managers.state.debug_text:output_world_text(text, font_size, position, ...)
- LineObject.add_line(world, color, start_pos, end_pos)

Colors:
- Color(alpha, red, green, blue) - ARGB format (0-255)
--]]

-- Simple and reliable border detection mod
local enabled = false
local boundary_markers = {}
local scan_timer = 0
local scan_interval = 2.0

-- Debug function
local function debug_print(text)
    mod:echo("[BorderCheck] " .. tostring(text))
end

-- Get player position safely
local function get_player_position()
    local local_player = Managers.player:local_player()
    if local_player and local_player.player_unit and Unit.alive(local_player.player_unit) then
        local pos = Unit.world_position(local_player.player_unit, 0)
        -- Ensure we return a proper Vector3
        if pos then
            return Vector3(pos[1] or pos.x or 0, pos[2] or pos.y or 0, pos[3] or pos.z or 0)
        end
    end
    return nil
end

-- Simple raycast function
local function simple_raycast(from_pos, direction, distance)
    local world = Managers.world:world("level_world")
    if not world then return nil end
    
    local physics_world = World.get_data(world, "physics_world")
    if not physics_world then return nil end
    
    local to_pos = from_pos + (direction * distance)
    
    local success, result = pcall(function()
        return PhysicsWorld.immediate_raycast(physics_world, from_pos, to_pos, "closest", "collision_filter", "filter_player_mover")
    end)
    
    if success and result and result.position then
        -- Ensure we return a proper Vector3 by creating a new one
        local pos = result.position
        return Vector3(pos[1] or pos.x or 0, pos[2] or pos.y or 0, pos[3] or pos.z or 0)
    end
    return nil
end

-- Scan for boundaries around player
local function scan_boundaries()
    local player_pos = get_player_position()
    if not player_pos then
        debug_print("Cannot get player position")
        return
    end
    
    boundary_markers = {}
    local scan_distance = 10
    local step = 3
    
    debug_print("Scanning for boundaries...")
    
    -- Simple grid scan
    for x = -scan_distance, scan_distance, step do
        for z = -scan_distance, scan_distance, step do
            local scan_pos = Vector3(player_pos.x + x, player_pos.y + 1.5, player_pos.z + z)
            
            -- Test 4 horizontal directions
            local directions = {
                Vector3(1, 0, 0),   -- East
                Vector3(-1, 0, 0),  -- West  
                Vector3(0, 0, 1),   -- North
                Vector3(0, 0, -1)   -- South
            }
            
            for _, dir in ipairs(directions) do
                local hit_pos = simple_raycast(scan_pos, dir, 2)
                if hit_pos then
                    local distance = Vector3.distance(scan_pos, hit_pos)
                    if distance < 1.8 then
                        table.insert(boundary_markers, {
                            position = hit_pos,
                            color = Color(255, 255, 0, 255), -- Yellow
                            type = "wall"
                        })
                    end
                end
            end
        end
    end
    
    debug_print("Found " .. #boundary_markers .. " boundary markers")
end

-- Render boundary markers
local function render_boundaries()
    if not enabled or #boundary_markers == 0 then
        return
    end
    
    -- Use multiple rendering methods for maximum compatibility
    for _, marker in ipairs(boundary_markers) do
        -- Validate marker position
        if not marker or not marker.position then
            debug_print("Invalid marker found, skipping")
            goto continue
        end
        
        -- Ensure position is a proper Vector3
        local pos = marker.position
        local safe_pos
        pcall(function()
            safe_pos = Vector3(pos[1] or pos.x or 0, pos[2] or pos.y or 0, pos[3] or pos.z or 0)
        end)
        
        if not safe_pos then
            debug_print("Failed to create safe position, skipping marker")
            goto continue
        end
        
        -- Method 1: Try QuickDrawer
        pcall(function()
            if QuickDrawer then
                QuickDrawer:sphere(safe_pos, 0.2, marker.color)
            end
        end)
        
        -- Method 2: Try debug text
        pcall(function()
            if Managers.state.debug_text then
                Managers.state.debug_text:output_world_text(
                    "●",
                    2,
                    safe_pos,
                    nil,
                    nil,
                    marker.color
                )
            end
        end)
        
        -- Method 3: Try LineObject
        pcall(function()
            local world = Managers.world:world("level_world")
            if world then
                local start_pos = safe_pos
                local end_pos = safe_pos + Vector3(0, 0.5, 0)
                LineObject.add_line(world, marker.color, start_pos, end_pos)
            end
        end)
        
        ::continue::
    end
end

-- Commands
mod:command("bordercheck_toggle", "Toggle border visualization", function()
    enabled = not enabled
    if enabled then
        debug_print("Border Check: ENABLED")
        scan_boundaries()
    else
        debug_print("Border Check: DISABLED")
        boundary_markers = {}
    end
end)

mod:command("bordercheck_scan", "Rescan boundaries", function()
    if enabled then
        debug_print("Rescanning boundaries...")
        scan_boundaries()
    else
        debug_print("Border check is disabled. Use /bordercheck_toggle to enable.")
    end
end)

mod:command("bordercheck_info", "Show mod information", function()
    debug_print("=== Border Check Mod Info ===")
    debug_print("Status: " .. (enabled and "ENABLED" or "DISABLED"))
    debug_print("Boundary markers: " .. #boundary_markers)
    
    local player_pos = get_player_position()
    if player_pos then
        debug_print(string.format("Player position: %.1f, %.1f, %.1f", player_pos.x, player_pos.y, player_pos.z))
    else
        debug_print("Player position: Not available")
    end
    
    debug_print("Commands:")
    debug_print("  /bordercheck_toggle - Enable/disable")
    debug_print("  /bordercheck_scan - Rescan area")
    debug_print("  /bordercheck_info - Show this info")
end)

-- Game state management
mod.on_game_state_changed = function(status, state_name)
    debug_print("Game state: " .. tostring(state_name))
    
    if state_name == "StateIngame" then
        if enabled then
            scan_timer = 1.0 -- Delay initial scan
        end
    elseif state_name == "StateLoading" then
        boundary_markers = {}
    end
end

-- Update loop
mod.update = function(dt)
    if not enabled then
        return
    end
    
    -- Auto-rescan periodically
    scan_timer = scan_timer + dt
    if scan_timer >= scan_interval then
        scan_timer = 0
        if Managers.state.game_mode then
            scan_boundaries()
        end
    end
    
    -- Render every frame
    render_boundaries()
end

-- Mod lifecycle
mod.on_enabled = function(initial_call)
    if not initial_call then
        debug_print("Border Check mod enabled!")
        debug_print("Use /bordercheck_info for help")
    end
end

mod.on_disabled = function()
    enabled = false
    boundary_markers = {}
    debug_print("Border Check mod disabled")
end
