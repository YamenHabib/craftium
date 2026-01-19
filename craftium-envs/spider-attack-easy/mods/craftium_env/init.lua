voxel_radius = {
	x = minetest.settings:get("voxel_obs_rx"),
	y = minetest.settings:get("voxel_obs_ry"),
	z = minetest.settings:get("voxel_obs_rz")
}

-- Set the random seed
if minetest.settings:has("fixed_map_seed") then
	math.randomseed(minetest.settings:get("fixed_map_seed"))
end

-- Wave system: 1 → 2 → 3 → 4 → 5 spiders
local max_spiders = 5
local num_spiders = 1
local dead_spiders = 0
local spawn_pos = {x = -2.5, y = 5, z = -5.0}  -- Closer spawn (was z = -10)

local spawn_monster = function(pos)
	minetest.after(1, function()
		local monster = mobs:add_mob(pos, {
			name = "craftium:easy_spider",
			ignore_count = true, -- ignores mob count per map area
		})

		-- Disable monster's infotext
		monster.update_tag = function()
		end
	end)
end

mobs:register_mob("craftium:easy_spider", {
	docile_by_day = false,
	group_attack = true,
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 100,               -- Very high damage to kill player in one hit
	hp_min = 1,                 -- One hit to kill
	hp_max = 1,
	armor = 100,                -- No armor reduction (100% damage taken)
	collisionbox = {-0.8, -0.5, -0.8, 0.8, 0, 0.8},
	visual_size = {x = 1, y = 1},
	visual = "mesh",
	mesh = "mobs_spider.b3d",
	textures = {
		{"mobs_spider_orange.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider"
	},
	walk_velocity = 2,   -- was 1 (faster patrol)
	run_velocity = 7,    -- was 3 (much faster chase)
	jump = true,
	view_range = 20,
	floats = 1,
	drops = {},
	water_damage = 5,
	lava_damage = 5,
	light_damage = 0,
	node_damage = false,
	animation = {
		speed_normal = 15,
		speed_run = 20,
		stand_start = 0,
		stand_end = 0,
		walk_start = 1,
		walk_end = 21,
		run_start = 1,
		run_end = 21,
		punch_start = 25,
		punch_end = 45
	},

	-- make spiders jump at you on attack
	custom_attack = function(self, pos)
		local vel = self.object:get_velocity()

		self.object:set_velocity({
			x = vel.x * self.run_velocity,
			y = self.jump_height * 1.5,
			z = vel.z * self.run_velocity
		})

		self.pausetimer = 0.5

		return true -- continue rest of attack function
	end,

	on_die = function(self, pos)
		-- Reward +1 for killing a spider
		set_reward_once(1.0, 0.0)

		-- Increase number of dead spiders
		dead_spiders = dead_spiders + 1

		if dead_spiders < num_spiders then
			return -- One or more spider is still alive!
		end

		-- At this point, all spiders are dead...
		-- prepare the next round!
		dead_spiders = 0
		num_spiders = num_spiders + 1

		-- If the maximum number of spiders is surpassed, finish the episode
		if num_spiders > max_spiders then
			set_termination()
			return
		end

		-- Else, spawn more spiders
		for i=1,num_spiders do
			spawn_monster({ x = 3.7 - i, y = spawn_pos.y, z = spawn_pos.z})
		end
	end
})

-- Executed when the player joins the game
minetest.register_on_joinplayer(function(player, _last_login)
	-- Set the players initial position and yaw
	player:set_pos({x = -2.5, y = 4.5, z = -1.7})
	player:set_look_horizontal(3.1416) -- Look to the spiders' spawn point

	-- Set player HP to 1 so spider kills in one hit
	player:set_hp(1, {type = "set_hp"})

	spawn_monster(spawn_pos)

	-- Disable HUD elements
	player:hud_set_flags({
		hotbar = false,
		crosshair = false,
		healthbar = false,
	})
end)

minetest.register_globalstep(function(dtime)
	-- Set timeofday to midday
	minetest.set_timeofday(0.5)

	local player = minetest.get_connected_players()[1]

	-- if the player is not connected end here
	if player == nil then
		return nil
	end

	-- if the player is connected:
	local player_pos = player:get_pos()
	if minetest.settings:get("voxel_obs") then
		local voxel_data, voxel_light_data, voxel_param2_data = voxel_api:get_voxel_data(player_pos, voxel_radius)
		set_voxel_data(voxel_data)
		set_voxel_light_data(voxel_light_data)
		set_voxel_param2_data(voxel_param2_data)
	end
end)

minetest.register_on_dieplayer(function(_player, _reason)
	-- Spider killed the player: reward -1 and end episode
	set_reward_once(-1.0, 0.0)
	set_termination()
end)
