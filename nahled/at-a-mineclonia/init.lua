-- Pomocná funkce pro získání jména nejbližšího hráče (vyjma autora, pokud je to možné)
local function get_closest_player(sender_name)
    local sender = minetest.get_player_by_name(sender_name)
    if not sender then return sender_name end -- Pokud příkaz běží z konzole

    local sender_pos = sender:get_pos()
    local closest_player = nil
    local shortest_distance = math.huge

    for _, player in ipairs(minetest.get_connected_players()) do
        local p_name = player:get_player_name()
        -- Hledáme nejbližšího JINÉHO hráče. Pokud je na serveru sám, vybere to jeho.
        if p_name ~= sender_name or #minetest.get_connected_players() == 1 then
            local p_pos = player:get_pos()
            local dist = vector.distance(sender_pos, p_pos)
            if dist < shortest_distance then
                shortest_distance = dist
                closest_player = p_name
            end
        end
    end
    return closest_player or sender_name
end

-- Pomocná funkce pro získání jména jednoho náhodného online hráče
local function get_random_player()
    local players = minetest.get_connected_players()
    if #players == 0 then return nil end
    local random_index = math.random(1, #players)
    return players[random_index]:get_player_name()
end

-- Pomocná funkce pro získání seznamu všech online hráčů
local function get_all_players()
    local players = minetest.get_connected_players()
    local names = {}
    for _, player in ipairs(players) do
        table.insert(names, player:get_player_name())
    end
    return names
end


-- Hlavní zachytávač chatovacích příkazů
minetest.register_on_chatcommand(function(name, cmd, params)
    -- Kontrola, zda příkaz obsahuje nějaký z našich selektorů
    local has_a = params:find("@a")
    local has_p = params:find("@p")
    local has_r = params:find("@r")

    -- Pokud neobsahuje žádný selektor, předáme řízení zpět Luanti
    if not (has_a or has_p or has_r) then
        return
    end

    -- Najdeme definici příkazu
    local command_def = minetest.chatcommands[cmd]
    if not command_def then
        return
    end

    -- Ověření práv hráče
    local has_privs, missing_privs = minetest.check_player_privs(name, command_def.privs)
    if not has_privs then
        local missing_str = ""
        for priv, _ in pairs(missing_privs) do
            missing_str = missing_str .. priv .. " "
        end
        minetest.chat_send_player(name, "Chybějící práva pro příkaz /" .. cmd .. ": " .. missing_str)
        return true
    end

    -- Zpracování podle typu selektoru
    if has_a then
        -- VŠICHNI HRÁČI (@a)
        local player_list = get_all_players()
        if #player_list == 0 then
            minetest.chat_send_player(name, "Žádní hráči nejsou online.")
            return true
        end

        local success_count = 0
        for _, player_name in ipairs(player_list) do
            local customized_params = params:gsub("@a", player_name)
            local success, message = command_def.func(name, customized_params)
            if success then success_count = success_count + 1 end
            if message and message ~= "" then
                minetest.chat_send_player(name, "[" .. player_name .. "]: " .. message)
            end
        end
        minetest.chat_send_player(name, "Příkaz /" .. cmd .. " proveden pro " .. success_count .. " hráčů.")

    elseif has_p then
        -- NEJBLIŽŠÍ HRÁČ (@p)
        local target_player = get_closest_player(name)
        local customized_params = params:gsub("@p", target_player)

        local success, message = command_def.func(name, customized_params)
        if message and message ~= "" then
            minetest.chat_send_player(name, message)
        end

    elseif has_r then
        -- NÁHODNÝ HRÁČ (@r)
        local target_player = get_random_player()
        if not target_player then
            minetest.chat_send_player(name, "Žádní hráči nejsou online.")
            return true
        end

        local customized_params = params:gsub("@r", target_player)
        local success, message = command_def.func(name, customized_params)
        if message and message ~= "" then
            minetest.chat_send_player(name, message)
        end
    end

    return true -- Zastaví původní zpracování a zabrání chybě "Hráč neexistuje"
end)
