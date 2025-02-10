--make the rocket take 30 minutes to craft
--data.raw["rocket-silo"]["rocket-silo"].rocket_parts_required = 600
data.raw["rocket-silo"]["rocket-silo"].rocket_parts_required = 3
--disable speed and productivity effects for the rocket silo
data.raw["rocket-silo"]["rocket-silo"].allowed_effects = {"consumption", "pollution"}
--make rocket silos require no power input
data.raw["rocket-silo"]["rocket-silo"].energy_source.type = "void"

--make rocket parts require no ingredients
--causes the rocket silo to act as a timer once powered
data.raw["recipe"]["rocket-part"].ingredients = {}

--remove space platform hub inventory
--stops player from sending materials to space
data.raw["space-platform-hub"]["space-platform-hub"].inventory_size = 0

--A new projectile to create the effect of the surface being destroyed when time is up
local time_over_projectile = table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
time_over_projectile.name = "re-time-over-projectile"
time_over_projectile.action.action_delivery.target_effects[1].action.action_delivery.target_effects[1].type = "create-fire"
time_over_projectile.action.action_delivery.target_effects[1].action.action_delivery.target_effects[1].entity_name = "fire-flame"
time_over_projectile.action.action_delivery.target_effects[1].action.action_delivery.target_effects[1].damage = nil
time_over_projectile.action.action_delivery.target_effects[1].action.action_delivery.target_effects[2].damage.amount = 100
time_over_projectile.action.action_delivery.target_effects[3] = nil
time_over_projectile.action.action_delivery.target_effects[4] = nil

data:extend{time_over_projectile}

data.raw["gui-style"].default["quality_style"] = {
	type = "image_style",
	left_padding = 16
}

