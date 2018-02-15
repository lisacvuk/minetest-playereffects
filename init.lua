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
	
	current_effects[effect.name] = {}

	effects_api.registered_effects[effect.name].on_add(name) -- Handle the on_add function.

	player:set_attribute("effects_api:effects", minetest.serialize(current_effects))
	print(minetest.serialize(current_effects))
end

effects_api.register_effect({
	name = "test",
	on_loop = function(name)
		--minetest.chat_send_all("Test!")
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

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects"))
		for effect,data in pairs(current_effects) do
			effects_api.registered_effects[effect].on_loop(name)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	effects_api.give_effect_to_player("test", name)
end)