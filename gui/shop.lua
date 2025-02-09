local space_gui = {}

local function hide_top_flows(player_name)
	space_gui[player_name].production_flow.visible = false
	space_gui[player_name].storage_flow.visible = false
	space_gui[player_name].planets_flow.visible = false
end

local function hide_planet_flows(player_name)
	for planet_name, planet in pairs(game.planets) do
		space_gui[player_name].planet_flow[planet_name].visible = false
	end
end

function re_click(event)
	if not in_space then return end

	print(event.player_index)
	local player_name = game.get_player(event.player_index).name
	print(player_name)

	if event.element == space_gui[player_name].production_tab then
		hide_top_flows(player_name)
		space_gui[player_name].production_flow.visible = true
	elseif event.element == space_gui[player_name].storage_tab then
		hide_top_flows(player_name)
		space_gui[player_name].storage_flow.visible = true
	elseif event.element == space_gui[player_name].planets_tab then
		hide_top_flows(player_name)
		space_gui[player_name].planets_flow.visible = true
	else
		for planet_name, planet in pairs(game.planets) do
			if event.element == space_gui[player_name].planet_tab[planet_name] then
				hide_planet_flows(player_name)
				space_gui[player_name].planet_flow[planet_name].visible = true
				break
			end
		end
	end
end

function re_create_space_gui()
	for player_index, player in pairs(game.players) do
		local player_name = player.name
		space_gui[player_name] = {}
		space_gui[player_name].frame = player.gui.center.add{type = "frame", caption = "Shop", direction = "vertical"}
		space_gui[player_name].frame.style.natural_width = 500
		space_gui[player_name].frame.style.natural_height = 500
		space_gui[player_name].tabflow = space_gui[player_name].frame.add{type = "flow", direction = "horizontal"}
		space_gui[player_name].production_tab = space_gui[player_name].tabflow.add{type = "tab", caption = "Production"}
		space_gui[player_name].storage_tab = space_gui[player_name].tabflow.add{type = "tab", caption = "Storage"}
		space_gui[player_name].planets_tab = space_gui[player_name].tabflow.add{type = "tab", caption = "Planets"}
		space_gui[player_name].production_flow = space_gui[player_name].frame.add{type = "flow", direction = "vertical", visible = true}
		space_gui[player_name].storage_flow = space_gui[player_name].frame.add{type = "flow", direction = "vertical", visible = false}
		space_gui[player_name].planets_flow = space_gui[player_name].frame.add{type = "flow", direction = "vertical", visible = false}
		space_gui[player_name].planets_tabflow = space_gui[player_name].planets_flow.add{type = "flow", direction = "horizontal"}
		space_gui[player_name].planet_tab = {}
		space_gui[player_name].planet_flow = {}
		space_gui[player_name].planet_drop = {}
		local index = 0
		for planet_name, planet in pairs(game.planets) do
			space_gui[player_name].planet_tab[planet_name] = space_gui[player_name]["planets_tabflow"].add{type = "tab", caption = "[space-location=" .. planet_name .. "]"}
			space_gui[player_name].planet_flow[planet_name] = space_gui[player_name]["planets_flow"].add{type = "flow", direction = "vertical", visible = (index == 0)}
			space_gui[player_name].planet_flow[planet_name].add{type = "label", caption = "[color=1,0,0]This is some info about the planet" .. planet_name .. ".[/color]"}
			space_gui[player_name].planet_drop[planet_name] = space_gui[player_name]["planet_flow"][planet_name].add{type = "button", caption = "Drop here"}
			index = index + 1
		end
		space_gui[player_name].storage_flow.add{type = "label", caption = "[color=0,0,1]Some info about storage[/color]"}
	end
end

local function generate_production_gui(player_name, item_production)
	if not space_gui[player_name].production_elements then
		space_gui[player_name].production_elements = {}
	end

	for item_name, amounts in pairs(item_production) do
		if not space_gui[player_name].production_elements[item_name] then
			space_gui[player_name].production_elements[item_name] = {}
		end

		for quality, amount in pairs(amounts) do
			if not space_gui[player_name].production_elements[item_name][quality] then
				space_gui[player_name].production_elements[item_name][quality] = space_gui[player_name].production_flow.add{type = "label"}
			end
			space_gui[player_name].production_elements[item_name][quality].caption = "[item=" .. item_name .. ",quality=" .. quality .. "] " .. tostring(amount*60.0) .. "/s"
		end

	end
end

function re_update_space_gui(item_production)
	for player_index, player in pairs(game.players) do
		generate_production_gui(player.name, item_production)
	end
end
