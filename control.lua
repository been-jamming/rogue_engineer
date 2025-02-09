require("gui.shop")

local mod_active = true
local warning = nil
local warning_button = nil
local cargo = nil
local silo = nil
local platform = nil
local item_exports = {}
local item_storage = {}
local item_imports = {}
local item_production = {}
local tick = 0
local starting_tick = 0
--local total_time = 60*60*30
local total_time = 60*10
local in_space = false

local function place_starting_entities(surface)
	cargo = surface.create_entity{name = "cargo-landing-pad", position = {-20, 10}, force = "player"}
	silo = surface.create_entity{name = "rocket-silo", position = {20, 10}, force = "player"}
end

local function handle_silo_items()
	if not silo.valid then
		return
	end

	local inventory = silo.get_inventory(defines.inventory.rocket_silo_rocket)
	local item_counts = inventory.get_contents()
	for _, item in pairs(item_counts) do
		if not item_exports[item.name] then
			item_exports[item.name] = {}
		end
		if not item_exports[item.name][item.quality] then
			item_exports[item.name][item.quality] = 0
		end
		item_exports[item.name][item.quality] = item_exports[item.name][item.quality] + item.count

		if not item_storage[item.name] then
			item_storage[item.name] = {}
		end
		if not item_storage[item.name][item.quality] then
			item_storage[item.name][item.quality] = 0
		end
		item_storage[item.name][item.quality] = item_storage[item.name][item.quality] + item.count
	end
	inventory.clear()
end

local function exports_imports_to_production()
	local total_ticks = tick - starting_tick
	for item_name, item in pairs(item_exports) do
		for item_quality, count in pairs(item) do
			if not item_production[item_name] then
				item_production[item_name] = {}
			end
			if not item_production[item_name][item_quality] then
				--Index 1 in this list is for import rate in items/tick
				--Index 2 in this list stores the backlog of each item
				item_production[item_name][item_quality] = 0
			end

			if not item_imports[item_name] then
				item_imports[item_name] = {}
			end
			if not item_imports[item_name][item_quality] then
				item_imports[item_name][item_quality] = 0
			end

			item_production[item_name][item_quality]= item_production[item_name][item_quality] +
				item_exports[item_name][item_quality]/total_ticks -
				item_imports[item_name][item_quality]/total_ticks
			if item_production[item_name][item_quality] < 0 then item_production[item_name][item_quality] = 0 end
		end
	end
end

local function summon_projectiles(first_tick)
	local prob = ((tick - first_tick)/24000)^3

	for _, player in pairs(game.players) do
		if not player.surface.platform then
			for k = 1, 100 do
				if math.random() < prob then
					local target_x = player.physical_position.x - 100 + math.random()*200
					local target_y = player.physical_position.y - 100 + math.random()*200
					player.surface.create_entity{name = "re-time-over-projectile", position = {target_x, target_y - 15}, target = {target_x, target_y}}
				end
			end
		end
	end
end

local function update(event)
	tick = event.tick
	if tick - starting_tick < total_time then
		handle_silo_items()
	else
		--summon_projectiles(starting_tick + total_time)
		if in_space then
			re_update_space_gui(item_production)
		end

		local next_in_space = true
		for _, player in pairs(game.players) do
			if not player.surface.platform then
				next_in_space = false
			end
		end
		if not in_space and next_in_space then
			in_space = true
			exports_imports_to_production()
			re_create_space_gui()
		end
	end
end

local function init_space_platform()
	platform = game.forces["player"].create_space_platform{planet = "nauvis", starter_pack = "space-platform-starter-pack"}
	platform.apply_starter_pack()
end

local function init()
	place_starting_entities(game.surfaces[1])
	init_space_platform()

	script.on_event(defines.events.on_tick, update)
end

script.on_init(init)
script.on_event(defines.events.on_gui_click, re_click)

