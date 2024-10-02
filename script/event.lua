minetest.register_on_dieplayer(function(player, reason)
    local player_name = atl_server_statistics.get_player_name(player)
    atl_server_statistics.increment_event_stat(player_name, "Deaths Count", 1)
    if reason.type == "punch" and reason.object and reason.object:is_player() then
        atl_server_statistics.increment_event_stat(atl_server_statistics.get_player_name(reason.object), "Kills Count", 1)
    end
end)

minetest.register_on_craft(function(itemstack, player)
    atl_server_statistics.increment_event_stat(atl_server_statistics.get_player_name(player), "Items Crafted", itemstack:get_count())
end)

minetest.register_on_placenode(function(_, _, placer)
    atl_server_statistics.increment_event_stat(atl_server_statistics.get_player_name(placer), "Nodes Placed", 1)
end)

minetest.register_on_dignode(function(_, _, digger)
    atl_server_statistics.increment_event_stat(atl_server_statistics.get_player_name(digger), "Nodes Dug", 1)
end)

minetest.register_on_chat_message(function(player_name)
    atl_server_statistics.increment_event_stat(player_name, "Messages Count", 1)
end)

function atl_server_statistics.on_player_leave(player)
    atl_server_statistics.update_playtime_on_stats(atl_server_statistics.get_player_name(player))
end

function atl_server_statistics.on_player_join(player)
    local player_name = atl_server_statistics.get_player_name(player)
    atl_server_statistics.mod_storage:set_int(player_name .. "_connect_time", os.time())
    for _, stat in ipairs(atl_server_statistics.statistics) do
        atl_server_statistics.mod_storage:set_int(player_name .. "_" .. stat, atl_server_statistics.mod_storage:contains(player_name .. "_" .. stat) and atl_server_statistics.get_value(player_name, stat) or 0)
    end
end

function atl_server_statistics.on_shutdown()
    for _, player in ipairs(minetest.get_connected_players()) do
        atl_server_statistics.update_playtime_on_stats(atl_server_statistics.get_player_name(player))
    end
end

minetest.register_on_joinplayer(atl_server_statistics.on_player_join)
minetest.register_on_shutdown(atl_server_statistics.on_shutdown)
minetest.register_on_leaveplayer(atl_server_statistics.on_player_leave)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if fields.leaderboard_tabs then
        local selected_tab = tonumber(fields.leaderboard_tabs)
        local stats_list = atl_server_statistics.statistics
        local selected_stat = stats_list[selected_tab]

        local formspec = atl_server_statistics.create_base_formspec(stats_list, selected_tab, name)
        formspec = formspec .. atl_server_statistics.generate_stats_table(selected_stat, name)

        minetest.show_formspec(name, "leaderboard:form", formspec)
    end
end)
