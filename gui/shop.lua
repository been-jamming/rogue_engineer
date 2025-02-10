local space_gui = {}

function re_gui_click(event)
	if not in_space then return end

	local player_name = game.get_player(event.player_index).name
end

function re_gui_closed(event)
	if not in_space then return end

	local player_name = game.get_player(event.player_index).name

	if event.element == space_gui[player_name].frame then
		space_gui[player_name].frame.visible = false
	end
end

function re_create_space_gui()
	for player_index, player in pairs(game.players) do
		local player_name = player.name
		space_gui[player_name] = {}
		space_gui[player_name].frame = player.gui.center.add{type = "frame", caption = "Shop", direction = "vertical"}
		space_gui[player_name].frame.maximum_height = 750
		space_gui[player_name].tab_pane = space_gui[player_name].frame.add{type = "tabbed-pane"}
		space_gui[player_name].production_tab = space_gui[player_name].tab_pane.add{type = "tab", caption = "Production"}
		space_gui[player_name].storage_tab = space_gui[player_name].tab_pane.add{type = "tab", caption = "Storage"}
		space_gui[player_name].planets_tab = space_gui[player_name].tab_pane.add{type = "tab", caption = "Planets"}
		space_gui[player_name].production_flow = space_gui[player_name].tab_pane.add{type = "flow", direction = "vertical"}
		space_gui[player_name].production_search = space_gui[player_name].production_flow.add{type = "textfield"}
		space_gui[player_name].production_table_label = space_gui[player_name].production_flow.add{type = "label", caption = "Production per second"}
		space_gui[player_name].production_scroll = space_gui[player_name].production_flow.add{type = "scroll-pane"}
		space_gui[player_name].production_table = space_gui[player_name].production_scroll.add{type = "table", column_count = 10}
		space_gui[player_name].storage_flow = space_gui[player_name].tab_pane.add{type = "flow", direction = "vertical"}
		space_gui[player_name].planets_tabpane = space_gui[player_name].tab_pane.add{type = "tabbed-pane"}
		space_gui[player_name].planet_tab = {}
		space_gui[player_name].planet_flow = {}
		space_gui[player_name].planet_drop = {}
		for planet_name, planet in pairs(game.planets) do
			space_gui[player_name].planet_tab[planet_name] = space_gui[player_name].planets_tabpane.add{type = "tab", caption = "[space-location=" .. planet_name .. "]"}
			space_gui[player_name].planet_flow[planet_name] = space_gui[player_name].planets_tabpane.add{type = "flow", direction = "vertical"}
			space_gui[player_name].planet_flow[planet_name].add{type = "label", caption = "[color=1,0,0]This is some info about the planet" .. planet_name .. ".[/color]"}
			space_gui[player_name].planet_drop[planet_name] = space_gui[player_name].planet_flow[planet_name].add{type = "button", caption = "Drop here"}
			space_gui[player_name].planets_tabpane.add_tab(space_gui[player_name].planet_tab[planet_name], space_gui[player_name].planet_flow[planet_name])
		end
		space_gui[player_name].storage_flow.add{type = "label", caption = "[color=0,0,1]Some info about storage[/color]"}

		space_gui[player_name].tab_pane.add_tab(space_gui[player_name].production_tab, space_gui[player_name].production_flow)
		space_gui[player_name].tab_pane.add_tab(space_gui[player_name].storage_tab, space_gui[player_name].storage_flow)
		space_gui[player_name].tab_pane.add_tab(space_gui[player_name].planets_tab, space_gui[player_name].planets_tabpane)
	end
end

local function rate_string(rate)
	local per_sec = rate*60
	if per_sec < 10 then
		return string.format("%.1f", rate*60)
	elseif per_sec >= 10 and per_sec < 1000 then
		return tostring(math.floor(rate*60))
	elseif per_sec >= 1000 and per_sec < 1000000 then
		return tostring(math.floor(rate*60/1000))
	elseif per_sec >= 1000000 then
		return tostring(math.floor(rate*60/1000000))
	else
		return "0"
	end
end

local function generate_production_gui(player_name, item_production)
	local search_text = space_gui[player_name].production_search.text

	if not space_gui[player_name].production_elements_item then
		space_gui[player_name].production_elements_item = {}
		space_gui[player_name].production_elements_quality = {}
		space_gui[player_name].production_elements_count = {}
	end

	for item_name, amounts in pairs(item_production) do
		if not space_gui[player_name].production_elements_item[item_name] then
			space_gui[player_name].production_elements_item[item_name] = {}
			space_gui[player_name].production_elements_quality[item_name] = {}
			space_gui[player_name].production_elements_count[item_name] = {}
		end

		for quality, amount in pairs(amounts) do
			if not space_gui[player_name].production_elements_item[item_name][quality] then
				space_gui[player_name].production_elements_item[item_name][quality] = space_gui[player_name].production_table.add{type = "sprite-button", sprite = "item/" .. item_name}
				if quality ~= "normal" then
					space_gui[player_name].production_elements_quality[item_name][quality] = space_gui[player_name].production_elements_item[item_name][quality].add{type = "sprite", sprite = "quality/" .. quality, style = "quality_style"}
				end
				space_gui[player_name].production_elements_count[item_name][quality] = space_gui[player_name].production_elements_item[item_name][quality].add{type = "label"}
				space_gui[player_name].production_elements_count[item_name][quality].style.font = "default-semibold"
				space_gui[player_name].production_elements_count[item_name][quality].style.top_padding = 16
			end
			space_gui[player_name].production_elements_count[item_name][quality].caption = rate_string(amount) 
			space_gui[player_name].production_elements_item[item_name][quality].visible = ((string.find(item_name, search_text) ~= nil or string.find(quality, search_text) ~= nil) and amount > 0)
		end

	end
end

function re_update_space_gui(item_production)
	for player_index, player in pairs(game.players) do
		generate_production_gui(player.name, item_production)
	end
end
