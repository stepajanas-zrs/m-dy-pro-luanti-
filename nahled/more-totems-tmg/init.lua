local modname = minetest.get_current_modname()

-- Pomocná funkce pro zobrazení animace totemu na obrazovce (HUD)
local function show_totem_hud(player, texture)
    local hud_id = player:hud_add({
        hud_elem_type = "image",
        position = {x = 0.5, y = 0.5},
        scale = {x = 8, y = 8},
        text = texture,
    })
    minetest.after(1.2, function()
        if player and player:is_player() then
            player:hud_remove(hud_id)
        end
    end)
end

-- Pomocná funkce pro dočasné zvýšení rychlosti a skoku (Minetest Game nemá vestavěné lektvary)
local function apply_temp_physics(player, speed_mult, jump_mult, duration)
    local name = player:get_player_name()
    player:set_physics_override({
        speed = speed_mult,
        jump = jump_mult,
    })
    minetest.after(duration, function()
        local p = minetest.get_player_by_name(name)
        if p then
            p:set_physics_override({ speed = 1.0, jump = 1.0 })
        end
    end)
end

-- Pomocná funkce pro dočasnou neviditelnost
local function apply_invisibility(player, duration)
    local name = player:get_player_name()
    local orig_props = player:get_properties()
    local orig_textures = orig_props.textures
    player:set_properties({
        textures = {"blank.png"},
        makes_footstep_sound = false,
    })
    minetest.after(duration, function()
        local p = minetest.get_player_by_name(name)
        if p then
            p:set_properties({
                textures = orig_textures,
                makes_footstep_sound = true,
            })
        end
    end)
end

-- Pomocná funkce pro postupnou regeneraci HP
local function apply_regeneration(player, ticks, amount)
    local name = player:get_player_name()
    for i = 1, ticks do
        minetest.after(i * 1.5, function()
            local p = minetest.get_player_by_name(name)
            if p and p:get_hp() > 0 then
                p:set_hp(math.min(20, p:get_hp() + amount))
            end
        end)
    end
end

-- Pomocná funkce pro registraci totemu
local function register_custom_totem(name, description, on_activate)
    local tex = "more_totems_" .. name .. ".png"
    minetest.register_craftitem(modname .. ":" .. name .. "_totem", {
        description = description,
        inventory_image = tex,
        wield_image = tex,
        stack_max = 1,
        groups = { totem = 1 },
        _on_totem_use = on_activate,
        _totem_tex = tex,
    })
end

-- ==========================================
-- DEFINICE 10 TOTEMŮ PRO MINETEST GAME
-- ==========================================

-- 1. TOTEM OHNĚ (Uhasí hráče, regeneruje a zraní okolní entity)
register_custom_totem("fire", "Totem ohně", function(player)
    apply_regeneration(player, 8, 1)
    local pos = player:get_pos()
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
        if obj ~= player then
            obj:punch(player, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 6 } }, nil)
        end
    end
end)

-- 2. TOTEM ÚNIKU (Rychlost, vysoký skok a neviditelnost)
register_custom_totem("swift", "Totem úniku", function(player)
    apply_temp_physics(player, 1.8, 1.5, 20)
    apply_invisibility(player, 15)
    apply_regeneration(player, 5, 1)
end)

-- 3. TOTEM TLAKOVÉ VLNY (Odhodí všechny entity v okolí)
register_custom_totem("blast", "Totem tlakové vlny", function(player)
    apply_regeneration(player, 6, 1)
    local pos = player:get_pos()
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 8)) do
        if obj ~= player then
            local opos = obj:get_pos()
            local dir = vector.direction(pos, opos)
            dir.y = 0.6
            obj:add_velocity(vector.multiply(dir, 18))
            obj:punch(player, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 8 } }, nil)
        end
    end
end)

-- 4. TOTEM HLUBIN (Doplní kyslík, regeneruje a zrychlí pohyb)
register_custom_totem("ocean", "Totem hlubin", function(player)
    player:set_breath(11)
    apply_regeneration(player, 10, 1)
    apply_temp_physics(player, 1.4, 1.2, 30)
end)

-- 5. TOTEM ENDU (Teleportace do bezpečí v okruhu 14 bloků)
register_custom_totem("ender", "Totem endu", function(player)
    apply_regeneration(player, 6, 1)
    local pos = player:get_pos()
    for i = 1, 20 do
        local target = {
            x = pos.x + math.random(-14, 14),
            y = pos.y + math.random(1, 6),
            z = pos.z + math.random(-14, 14)
        }
        if minetest.get_node(target).name == "air" then
            player:set_pos(target)
            break
        end
    end
end)

-- 6. TOTEM MRAZU (Zmrazí vodu pod hráčem na led a zpomalí okolí)
register_custom_totem("frost", "Totem mrazu", function(player)
    apply_regeneration(player, 8, 1)
    local pos = vector.round(player:get_pos())
    for x = -3, 3 do
        for z = -3, 3 do
            local p = { x = pos.x + x, y = pos.y - 1, z = pos.z + z }
            local n = minetest.get_node(p).name
            if n == "default:water_source" or n == "default:water_flowing" then
                minetest.set_node(p, { name = "default:ice" })
            end
        end
    end
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 7)) do
        if obj ~= player and obj:is_player() then
            apply_temp_physics(obj, 0.4, 0.5, 10)
        end
    end
end)

-- 7. TOTEM SÍLY (Silná regenerace a zrychlení)
register_custom_totem("berserk", "Totem síly", function(player)
    apply_regeneration(player, 10, 2)
    apply_temp_physics(player, 1.3, 1.2, 20)
end)

-- 8. TOTEM GRAVITACE (Vystřelí hráče vysoko a sníží gravitaci pro pomalý pád)
register_custom_totem("sky", "Totem gravitace", function(player)
    local name = player:get_player_name()
    apply_regeneration(player, 6, 1)
    player:add_velocity({ x = 0, y = 20, z = 0 })
    player:set_physics_override({ gravity = 0.25 })
    minetest.after(15, function()
        local p = minetest.get_player_by_name(name)
        if p then
            p:set_physics_override({ gravity = 1.0 })
        end
    end)
end)

-- 9. TOTEM STÍNŮ (Neviditelnost a vysoká rychlost)
register_custom_totem("shadow", "Totem stínů", function(player)
    apply_invisibility(player, 25)
    apply_temp_physics(player, 1.5, 1.2, 25)
end)

-- 10. TOTEM TITÁNA (Okamžité plné vyléčení + silná regenerace)
register_custom_totem("titan", "Totem titána", function(player)
    player:set_hp(20)
    apply_regeneration(player, 10, 2)
end)

-- ==========================================
-- ZACHYCENÍ SMRTI (V MINETEST GAME STAČÍ MÍT TOTEM V RUCE NEBO V HOTBARU)
-- ==========================================

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    local current_hp = player:get_hp()
    
    if current_hp + hp_change <= 0 then
        local inv = player:get_inventory()
        local wielded = player:get_wielded_item()
        local used_stack = nil
        local slot_index = nil

        -- 1. Nejprve zkontroluje držený předmět
        if minetest.get_item_group(wielded:get_name(), "totem") > 0 then
            used_stack = wielded
            slot_index = player:get_wield_index()
        else
            -- 2. Minetest Game nemá druhou ruku, proto zkontroluje celý první řádek inventáře (hotbar 1-8)
            for i = 1, 8 do
                local stack = inv:get_stack("main", i)
                if minetest.get_item_group(stack:get_name(), "totem") > 0 then
                    used_stack = stack
                    slot_index = i
                    break
                end
            end
        end

        if used_stack then
            local def = used_stack:get_definition()
            
            used_stack:take_item(1)
            inv:set_stack("main", slot_index, used_stack)

            player:set_hp(2)

            if def._on_totem_use then
                def._on_totem_use(player)
            end

            show_totem_hud(player, def._totem_tex)

            -- Částicový efekt kolem hráče
            minetest.add_particlespawner({
                amount = 35,
                time = 0.5,
                minpos = vector.subtract(player:get_pos(), 1),
                maxpos = vector.add(player:get_pos(), 1),
                minvel = {x = -2, y = 1, z = -2},
                maxvel = {x = 2, y = 4, z = 2},
                exptime = 1.2,
                size = 3,
                texture = def._totem_tex,
            })

            return 0
        end
    end
    
    return hp_change
end, true)

-- ==========================================
-- RECEPTY PRO MINETEST GAME (POMOCÍ SUROVIN Z DEFAULT MODU)
-- ==========================================

local recipes = {
    fire_totem    = { top = "default:torch",           side = "default:coal_lump" },
    swift_totem   = { top = "default:papyrus",         side = "default:pine_needles" },
    blast_totem   = { top = "default:flint",           side = "default:steel_ingot" },
    ocean_totem   = { top = "default:coral_orange",    side = "default:glass" },
    ender_totem   = { top = "default:obsidian_shard",  side = "default:mese_crystal_fragment" },
    frost_totem   = { top = "default:snowblock",       side = "default:ice" },
    berserk_totem = { top = "default:diamond",         side = "default:bronze_ingot" },
    sky_totem     = { top = "default:leaves",          side = "default:mese_crystal_fragment" },
    shadow_totem  = { top = "default:obsidian",        side = "default:coalblock" },
    titan_totem   = { top = "default:goldblock",       side = "default:diamond" },
}

for name, mat in pairs(recipes) do
    minetest.register_craft({
        output = modname .. ":" .. name,
        recipe = {
            { "default:gold_ingot", mat.top, "default:gold_ingot" },
            { mat.side, "default:mese_crystal", mat.side },
            { "", "default:gold_ingot", "" }
        }
    })
end
