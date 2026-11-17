local spear_charging = {}

-- 1. DEFINICE STATISTIK PRO VARIANTY OŠTĚPŮ
local spear_materials = {
    wood = { desc = "Dřevěný oštěp", material = "mcl_core:wood", jab_interval = 0.95, jab_damage = 4, charge_mult = 0.7, durability = 590, enchant_val = 15 },
    stone = { desc = "Kamenný oštěp", material = "mcl_core:cobble", jab_interval = 1.0, jab_damage = 5, charge_mult = 0.82, durability = 1310, enchant_val = 5 },
    copper = { desc = "Měděný oštěp", material = "mcl_core:copper_ingot", jab_interval = 1.05, jab_damage = 6, charge_mult = 0.85, durability = 1900, enchant_val = 9 },
    iron = { desc = "Železný oštěp", material = "mcl_core:iron_ingot", jab_interval = 1.1, jab_damage = 7, charge_mult = 0.95, durability = 2500, enchant_val = 14 },
    gold = { desc = "Zlatý oštěp", material = "mcl_core:gold_ingot", jab_interval = 0.9, jab_damage = 5, charge_mult = 0.7, durability = 320, enchant_val = 22 },
    diamond = { desc = "Diamantový oštěp", material = "mcl_core:diamond", jab_interval = 1.15, jab_damage = 9, charge_mult = 1.075, durability = 15610, enchant_val = 10 },
    netherite = { desc = "Netheritový oštěp", material = nil, jab_interval = 1.2, jab_damage = 11, charge_mult = 1.2, durability = 20310, enchant_val = 15 }
}

-- FUNKCE PRO UDĚLENÍ DAMAGE
local function deal_damage(user, target, damage, interval)
    if not target or not user then return end

    local itemstack = user:get_wielded_item()
    local meta = itemstack:get_meta()
    local sharpness_lvl = meta:get_int("enchantment_sharpness") or 0
    local bonus = 0
    if sharpness_lvl > 0 then bonus = sharpness_lvl * 0.5 + 0.5 end

    target:punch(user, 1.0, {
        full_punch_interval = interval,
        damage_groups = {fleshy = damage + math.floor(bonus)}
    }, nil)

    minetest.sound_play("mcl_bow_hit", {pos = user:get_pos(), gain = 0.8}, true)
end

-- FUNKCE PRO PROVEDENÍ DASH / LUNGE (I PRO ELYTRU)
local function execute_lunge(itemstack, user, stats)
    local p_name = user:get_player_name()
    local dir = user:get_look_dir()

    local is_gliding = false
    if minetest.global_exists("mcl_elytra") and mcl_elytra.is_flying then
        is_gliding = mcl_elytra.is_flying(user)
    end

    if is_gliding then
        user:add_player_velocity({
            x = dir.x * 35,
            y = dir.y * 35,
            z = dir.z * 35
        })
    else
        user:add_player_velocity({
            x = dir.x * 24,
            y = (dir.y * 12) + 7.5,
            z = dir.z * 24
        })
    end

    minetest.sound_play("mcl_bow_strict", {pos = user:get_pos(), gain = 1.0}, true)
    minetest.add_particlespawner({
        amount = 25, time = 0.1,
        minpos = user:get_pos(), maxpos = user:get_pos(),
        minvel = {x=-2, y=0.1, z=-2}, maxvel = {x=2, y=1, z=2},
        minexptime = 0.4, maxexptime = 0.8, minsize = 1, maxsize = 3,
        texture = "mcl_particles_smoke.png",
    })

    if not minetest.is_creative_enabled(p_name) then
        itemstack:add_wear(65535 / (stats.durability / 3))
    end
    return itemstack
end

-- 2. REGISTRACE VŠECH VARIANT OŠTĚPŮ
for name, stats in pairs(spear_materials) do
    local item_name = "muj_ostep:spear_" .. name
    local texture_file = "muj_ostep_" .. name .. ".png"

    minetest.register_tool(item_name, {
        description = stats.desc,
        inventory_image = texture_file,
        wield_image = texture_file,

        tool_capabilities = {
            full_punch_interval = stats.jab_interval,
            max_drop_level = 0,
            groupcaps = {},
            damage_groups = {fleshy = stats.jab_damage},
        },
        groups = {
            weapon = 1, sword = 1, spear = 1,
            combat_element = 1, enchantable = 1,
            enchantability = stats.enchant_val
        },

        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.type ~= "object" then return itemstack end
            local target = pointed_thing.ref
            local distance = vector.distance(user:get_pos(), target:get_pos())

            if distance < 2.0 or distance > 4.5 then return itemstack end

            deal_damage(user, target, stats.jab_damage, stats.jab_interval)

            if not minetest.is_creative_enabled(user:get_player_name()) then
                itemstack:add_wear(65535 / stats.durability)
            end
            return itemstack
        end,

        on_secondary_use = function(itemstack, user, pointed_thing)
            return execute_lunge(itemstack, user, stats)
        end,

        on_place = function(itemstack, placer, pointed_thing)
            if pointed_thing and pointed_thing.type == "object" then
                local target = pointed_thing.ref
                if target and target ~= placer then
                    deal_damage(placer, target, stats.jab_damage, stats.jab_interval)

                    if not minetest.is_creative_enabled(placer:get_player_name()) then
                        itemstack:add_wear(65535 / stats.durability)
                    end
                    return itemstack
                end
            end

            return execute_lunge(itemstack, placer, stats)
        end
    })

    if stats.material then
        minetest.register_craft({
            output = item_name,
            recipe = {
                {"", "", stats.material},
                {"", "mcl_core:stick", ""},
                {"mcl_core:stick", "", ""},
            }
        })
    end
end

-- 3. RECEPT PRO NETHERITE
minetest.register_craft({
    type = "shapeless",
    output = "muj_ostep:spear_netherite",
    recipe = { "muj_ostep:spear_diamond", "mcl_netherite:netherite_ingot" },
})
