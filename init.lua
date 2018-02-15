effects_api = {}

effects_api.registered_effects = {}

effects_api.register_effect = function(definition)
	local name = definition.name
	
	if not effects_api.registered_effects[name] then
		effects_api.registered_effects[name] = definition
	end
end

effects_api.give_effect_to_player = function(effect_n, name)
	local player = minetest.get_player_by_name(name)
	local effect = effects_api.registered_effects[effect_n]
	local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects")) or {}
	
	if not effect then
		minetest.log("[EFFECTS API] effects_api.give_effect_to_player(effect_n, name): Effect is nil")
		return
	end
	
	current_effects[effect.name] = {}

	effects_api.registered_effects[effect.name].on_add(name) -- Handle the on_add function.

	player:set_attribute("effects_api:effects", minetest.serialize(current_effects))
	print(minetest.serialize(current_effects))
end

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects")) or {}
		for effect,data in pairs(current_effects) do
			if not effect or not effects_api.registered_effects[effect] then
				break
			end
			effects_api.registered_effects[effect].on_loop(name)
		end
	end
end)

effects_api.remove_effect_to_player = function(effect_n, name)
	local player = minetest.get_player_by_name(name)
	local effect = effects_api.registered_effects[effect_n]
	local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects")) or {}
	
	current_effects[effect.name] = nil

    effects_api.registered_effects[effect.name].on_remove(name)
    
	player:set_attribute("effects_api:effects", minetest.serialize(current_effects))
	print(minetest.serialize(current_effects))
end

minetest.register_chatcommand("remove_effect_test", {
    params = "",
    description = "Removes the test effect.",
    func = function(name, param)
        effects_api.remove_effect_to_player("test", name)
    end,
})

minetest.register_chatcommand("effects", {
    params = "",
    description = "Lists the current effects.",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local message = "Your effects are: "
        local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects")) or {}
        for iter,data in pairs(current_effects) do
            message = message .. iter .. " "
        end
        minetest.chat_send_all(message)
    end,
})

-- Effects --

effects_api.register_effect({
	name = "flight",
	on_loop = function(name)
		minetest.chat_send_all(name .. " is flying!")
	end,
	on_add = function(name)
		minetest.set_player_privs(name, {fly=true})
		minetest.chat_send_all("Player " .. name .. " can fly like a bird!")
	end,
	on_remove = function(name)
		minetest.set_player_privs(name, {fly=false})
		minetest.chat_send_all("Player " .. name .. " can fly like a stone!")
	end,
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	effects_api.give_effect_to_player("flight", name)
end)
