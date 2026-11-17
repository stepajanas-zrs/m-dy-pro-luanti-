-- Pomocna funkce pro ziskani jmena nejblizsiho hrace
local function get_closest_player(sender_name)
    local sender = minetest.get_player_by_name(sender_name)
    if not sender then return sender_name end

    local sender_pos = sender:get_pos()
    local closest_player = nil
    local shortest_distance = math.huge
    local players = minetest.get_connected_players()

    for _, player in ipairs(players) do
        local p_name = player:get_player_name()
        if p_name ~= sender_name or #players == 1 then
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

-- Pomocna funkce pro ziskani jmena jednoho nahodneho online hrace
local function get_random_player()
    local players = minetest.get_connected_players()
    if #players == 0 then return nil end
    local random_index = math.random(1, #players)
    return players[random_index]:get_player_name()
end

-- Pomocna funkce pro ziskani seznamu vsech online hracu
local function get_all_players()
    local players = minetest.get_connected_players()
    local names = {}
    for _, player in ipairs(players) do
        table.insert(names, player:get_player_name())
    end
    return names
end

-- Hlavni zachytavac chatovacich prikazu
minetest.register_on_chatcommand(function(name, cmd, params)
    local has_a = params:find("@a")
    local has_p = params:find("@p")
    local has_r = params:find("@r")

    if not (has_a or has_p or has_r) then
        return
    end

    local command_def = minetest.chatcommands[cmd]
    if not command_def then
        return
    end

    local has_privs, missing_privs = minetest.check_player_privs(name, command_def.privs)
    if not has_privs then
        local missing_str = ""
        for priv, _ in pairs(missing_privs) do
            missing_str = missing_str .. priv .. " "
        end
        minetest.chat_send_player(name, "Chybejici prava pro prikaz /" .. cmd .. ": " .. missing_str)
        return true
    end

    if has_a then
        local player_list = get_all_players()
        if #player_list == 0 then
            minetest.chat_send_player(name, "Zadni hraci nejsou online.")
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
        minetest.chat_send_player(name, "Prikaz /" .. cmd .. " proveden pro " .. success_count .. " hracu.")

    elseif has_p then
        local target_player = get_closest_player(name)
        local customized_params = params:gsub("@p", target_player)
        
        local success, message = command_def.func(name, customized_params)
        if message and message ~= "" then
            minetest.chat_send_player(name, message)
        end

    elseif has_r then
        local target_player = get_random_player()
        if not target_player then
            minetest.chat_send_player(name, "Zadni hraci nejsou online.")
            return true
        end
        
        local customized_params = params:gsub("@r", target_player)
        local success, message = command_def.func(name, customized_params)
        if message and message ~= "" then
            minetest.chat_send_player(name, message)
        end
    end

    return true
end)
