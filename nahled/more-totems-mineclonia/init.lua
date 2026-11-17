local modname = minetest.get_current_modname()

-- Pomocná funkce pro registraci totemu (s opravou pro druhou ruku a automatickou barvou textury)
local function register_custom_totem(name, description, color, on_activate)
    -- Automaticky obarví výchozí texturu totemu z Mineclonie
    local tex = "mcl_totems_totem.png^[colorize:" .. color .. ":140"

    minetest.register_craftitem(modname .. ":" .. name, {
        description = description,
        inventory_image = tex,
        wield_image = tex,
        stack_max = 1,
        -- offhand_item = 1 povoluje vložení do slotu pro druhou ruku
        groups = { combat_item = 1, totem = 1, offhand_item = 1 },
        _on_totem_use = on_activate,
    })
end

-- ==========================================
-- DEFINICE 10 NOVÝCH TOTEMŮ
-- ==========================================

-- 1. TOTEM OHNĚ (Červenooranžový)
register_custom_totem("fire_totem", "Totem ohně", "#FF4500", function(player)
    mcl_potions.give_effect("fire_resistance", player, 1, 60)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    local pos = player:get_pos()
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
        if obj ~= player and (obj:is_player() or (obj:get_luaentity() and obj:get_luaentity()._cmi_is_mob)) then
            obj:punch(player, 1.0, { full_punch_interval = 1.0, damage_groups = { fleshy = 6 } }, nil)
        end
    end
end)

-- 2. TOTEM ÚNIKU (Světle modrý)
register_custom_totem("swift_totem", "Totem úniku", "#00FFFF", function(player)
    mcl_potions.give_effect_by_level("swiftness", player, 3, 30)
    mcl_potions.give_effect_by_level("leaping", player, 2, 30)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    mcl_potions.give_effect("invisibility", player, 1, 15)
end)

-- 3. TOTEM TLAKOVÉ VLNY (Šedý / Kouřový)
register_custom_totem("blast_totem", "Totem tlakové vlny", "#808080", function(player)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 15)
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

-- 4. TOTEM HLUBIN (Tmavě modrý)
register_custom_totem("ocean_totem", "Totem hlubin", "#0055FF", function(player)
    mcl_potions.give_effect("water_breathing", player, 1, 90)
    mcl_potions.give_effect("night_vision", player, 1, 90)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    player:set_breath(player:get_properties().breath_max or 10)
end)

-- 5. TOTEM ENDU (Fialový)
register_custom_totem("ender_totem", "Totem endu", "#9900FF", function(player)
    mcl_potions.give_effect("slow_falling", player, 1, 15)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    local pos = player:get_pos()
    for i = 1, 15 do
        local target = {
            x = pos.x + math.random(-14, 14),
            y = pos.y + math.random(1, 6),
            z = pos.z + math.random(-14, 14)
        }
        local node = minetest.get_node(target)
        if node.name == "air" then
            player:set_pos(target)
            break
        end
    end
end)

-- 6. TOTEM MRAZU (Ledově bílý)
register_custom_totem("frost_totem", "Totem mrazu", "#AEEEEE", function(player)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    local pos = vector.round(player:get_pos())
    for x = -3, 3 do
        for z = -3, 3 do
            local p = { x = pos.x + x, y = pos.y - 1, z = pos.z + z }
            local n = minetest.get_node(p).name
            if n == "mcl_core:water_source" or n == "mcl_core:water_flowing" then
                minetest.set_node(p, { name = "mcl_core:ice" })
            end
        end
    end
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 7)) do
        if obj ~= player and obj:is_player() then
            mcl_potions.give_effect_by_level("slowness", obj, 3, 15)
        end
    end
end)

-- 7. TOTEM SÍLY (Karmínově rudý)
register_custom_totem("berserk_totem", "Totem síly", "#B22222", function(player)
    mcl_potions.give_effect_by_level("strength", player, 2, 25)
    mcl_potions.give_effect_by_level("resistance", player, 2, 25)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
end)

-- 8. TOTEM GRAVITACE (Žlutozlatý)
register_custom_totem("sky_totem", "Totem gravitace", "#FFFF66", function(player)
    mcl_potions.give_effect("slow_falling", player, 1, 25)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    player:add_velocity({ x = 0, y = 22, z = 0 })
end)

-- 9. TOTEM STÍNŮ (Černý / Temný)
register_custom_totem("shadow_totem", "Totem stínů", "#1C1C1C", function(player)
    mcl_potions.give_effect("invisibility", player, 1, 25)
    mcl_potions.give_effect("night_vision", player, 1, 30)
    mcl_potions.give_effect_by_level("swiftness", player, 2, 20)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    local pos = player:get_pos()
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 8)) do
        if obj ~= player and obj:is_player() then
            mcl_potions.give_effect("blindness", obj, 1, 15)
        end
    end
end)

-- 10. TOTEM TITÁNA (Smaragdově zelený)
register_custom_totem("titan_totem", "Totem titána", "#00FF7F", function(player)
    player:set_hp(20)
    mcl_potions.give_effect_by_level("regeneration", player, 2, 20)
    mcl_potions.give_effect_by_level("resistance", player, 3, 15)
    mcl_potions.give_effect_by_level("absorption", player, 2, 60)
end)

-- ==========================================
-- ZACHYCENÍ SMRTI A AKTIVACE TOTEMU
-- ==========================================

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    local current_hp = player:get_hp()

    if current_hp + hp_change <= 0 then
        local inv = player:get_inventory()
        local wielded = player:get_wielded_item()
        local offhand = inv:get_stack("offhand", 1)

        local used_stack = nil
        local is_offhand = false

        -- Kontrola hlavní ruky nebo druhé ruky (offhand)
        if minetest.get_item_group(wielded:get_name(), "totem") > 0 and wielded:get_name():find("^" .. modname .. ":") then
            used_stack = wielded
        elseif minetest.get_item_group(offhand:get_name(), "totem") > 0 and offhand:get_name():find("^" .. modname .. ":") then
            used_stack = offhand
            is_offhand = true
        end

        if used_stack then
            local def = used_stack:get_definition()
            local item_name = used_stack:get_name()

            -- Spotřebování totemu z příslušné ruky
            used_stack:take_item(1)
            if is_offhand then
                inv:set_stack("offhand", 1, used_stack)
            else
                player:set_wielded_item(used_stack)
            end

            -- Nastavení 1 HP a zrušení smrti
            player:set_hp(1)

            -- Spuštění schopnosti konkrétního totemu
            if def._on_totem_use then
                def._on_totem_use(player)
            end

            -- Zvuk a animace na obrazovce
            minetest.sound_play("mcl_totems_totem", { pos = player:get_pos(), gain = 1.0 }, true)

            if mcl_totems and mcl_totems.show_totem_hud then
                mcl_totems.show_totem_hud(player, item_name)
            end

            return 0
        end
    end

    return hp_change
end, true)

-- ==========================================
-- RECEPTY PRO VÝROBU (CRAFTING)
-- ==========================================

local recipes = {
    fire_totem    = { top = "mcl_mobitems:blaze_powder",  side = "mcl_mobitems:magma_cream" },
    swift_totem   = { top = "mcl_core:sugar",             side = "mcl_mobitems:feather" },
    blast_totem   = { top = "mcl_mobitems:gunpowder",     side = "mcl_core:iron_ingot" },
    ocean_totem   = { top = "mcl_ocean:prismarine_shard", side = "mcl_core:emerald" },
    ender_totem   = { top = "mcl_end:ender_eye",          side = "mcl_mobitems:ender_pearl" },
    frost_totem   = { top = "mcl_core:snowblock",         side = "mcl_core:ice" },
    berserk_totem = { top = "mcl_core:diamond",           side = "mcl_mobitems:blaze_rod" },
    sky_totem     = { top = "mcl_mobitems:feather",       side = "mcl_mobitems:phantom_membrane" },
    shadow_totem  = { top = "mcl_core:coal_lump",         side = "mcl_mobitems:spider_eye" },
    titan_totem   = { top = "mcl_core:goldblock",         side = "mcl_core:diamond" },
}

for name, mat in pairs(recipes) do
    minetest.register_craft({
        output = modname .. ":" .. name,
        recipe = {
            { "mcl_core:gold_ingot", mat.top, "mcl_core:gold_ingot" },
            { mat.side, "mcl_totems:totem", mat.side },
            { "", "mcl_core:gold_ingot", "" }
        }
    })
end
