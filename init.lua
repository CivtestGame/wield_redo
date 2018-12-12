wield_redo = {}
wield_redo.player_items = {}
wield_redo.handed = "Arm_Right" -- Unsupported, may implement later if this becomes more standard to the point where widely used animation mods are implementing it.
wield_redo.systemd = minetest.get_modpath("minetest_systemd")
wield_redo.moveModelUp = 0
if tonumber(string.sub(minetest.get_version().string, 1, 1)) and tonumber(string.sub(minetest.get_version().string, 1, 1)) > 4 then
	wield_redo.moveModelUp = 10
end
wield_redo.itemOffsets = { 
	--[name, or group/table. Tables can be used as keys to apply the same offset to multiple items.] {rotation (pitch), vertical offset (higher numbers move downward)} 
	[{
		"default:shovel_wood",
		"default:shovel_stone",
		"default:shovel_steel",
		"default:shovel_bronze",
		"default:shovel_diamond",
		"default:shovel_mese",
		"moreores:shovel_silver",
		"moreores:shovel_mithril",
		"group:tooltype_shovel",
	}] = {50,0.9},
	
	[{
		"default:axe_wood",
		"default:axe_stone",
		"default:axe_steel",
		"default:axe_bronze",
		"default:axe_diamond",
		"default:axe_mese",
		"moreores:axe_silver",
		"moreores:axe_mithril",
		"group:tooltype_axe",
		
	}] = {-15,0},
	
	[{
		"default:sword_wood",
		"default:sword_stone",
		"default:sword_steel",
		"default:sword_bronze",
		"default:sword_diamond",
		"default:sword_mese",
		"moreores:sword_silver",
		"moreores:sword_mithril",
		"group:tooltype_sword",
	}] = {-30,0.4,1.33},
	
	[{ 
		"default:pick_wood",
		"default:pick_stone",
		"default:pick_steel",
		"default:pick_bronze",
		"default:pick_diamond",
		"default:pick_mese",
		"moreores:pick_silver",
		"moreores:pick_mithril",
		"mobs:pick_lava",
		"group:tooltype_pick",
	}] = {-15,0},
	[{
		"farming:hoe_wood",
		"farming:hoe_stone",
		"farming:hoe_steel",
		"farming:hoe_bronze",
		"farming:hoe_diamond",
		"farming:hoe_mese",
		"moreores:hoe_silver",
		"moreores:hoe_mithril",
		"group:tooltype_hoe",
	}] = {-15,0},
	
	["mobs:net"] = {0,0},
	
	["bonemeal:bone"] = {0,0.8},
	["default:stick"] = {0,0.8},
	
	["banners:wooden_pole"] = {0,0.8},
	["banners:steel_pole"] = {0,0.8},
	
	["fancy_vend:copy_tool"] = {0,0.8},
	
	["ma_pops_furniture:hammer"] = {0,0.8},
	["xdecor:hammer"] = {0,0.8},
	
	["screwdriver:screwdriver"] = {77,0},
	["minetest:node"] = {45, 0.8, 0.75},
}


wield_redo.set_item_offset = function(k, v)
	wield_redo.itemOffsets[k] = v
	wield_redo.update_known_items()
end

wield_redo.update_known_items = function()
	if not wield_redo.systemd then
		local flat = false
		while (not flat) do --Flatten the table, because we can't use minetestd.utils.check_item_match
			flat = true
			for item,offset in pairs(wield_redo.itemOffsets) do
				if type(item) == "table" then
					for _,iname in pairs(item) do
						wield_redo.itemOffsets[iname] = offset
						flat = false
					end
					wield_redo.itemOffsets[item] = nil
				end
			end
		end
		print("Table flattened.")
		local group
		for item,offset in pairs(wield_redo.itemOffsets) do
			if type(item) == "string" and string.sub(item,1,6) == "group:" then
				group = string.sub(item,7)
				for iname,reg in pairs(minetest.registered_items) do
					if reg.groups[group] then
						wield_redo.itemOffsets[iname] = offset
					end
				end
				wield_redo.itemOffsets[item] = nil
			end
		end
		print("Groups resolved.")
		if wield_redo.itemOffsets["minetest:node"] then
			for n,_ in pairs(minetest.registered_nodes) do
				if not wield_redo.itemOffsets[n] then
					wield_redo.itemOffsets[n] = wield_redo.itemOffsets["minetest:node"]
				end
			end
			 wield_redo.itemOffsets["minetest:node"] = nil
		end
	end
	
	wield_redo.knownItems = {}
	for item,_ in pairs( wield_redo.itemOffsets ) do
		wield_redo.knownItems[#(wield_redo.knownItems)+1] = item
	end
end
minetest.after(0,wield_redo.update_known_items)

wield_redo.update = function(player)
	if wield_redo.systemd and not minetestd.services.wield_redo.enabled then return end
	local name = player:get_player_name()
	local wield_ent = wield_redo.player_items[name]
	local item = player:get_wielded_item()
	if ( wield_ent and wield_ent:get_attach("parent") == player) then
		if item and item:get_name() ~= "" and not item:is_empty() then
			local itemname = item:get_name()
			if wield_ent:get_properties().textures[1] ~= itemname then
				local offset = ((
					wield_redo.itemOffsets[itemname] or
					wield_redo.itemOffsets[
						wield_redo.systemd and 
						minetestd.utils.check_item_match(itemname, wield_redo.knownItems)
					]
					) or {65, 0.8, 1.0}
				)
				offset[3] = offset[3] or 1.0
				wield_redo.player_items[name]:set_attach(player, wield_redo.handed, {x=-0.25,y=3.6+offset[2],z=2.5}, {x=90,y=offset[1],z=-90}) 
				wield_ent:set_properties({textures = {itemname}, visual_size = {x=0.3*offset[3], y=0.3*offset[3]}})
				if minetest.get_modpath("playeranim") then
					player:set_bone_position(wield_redo.handed, {x = -3,  y = 5.5,  z = 0}, {x = 0, y = 0, z = 0})
				end
				--Update this sometimes, as it tends to glitch out. 
				--(Seriously, set_attach needs a SERIOUS overhaul. It's been a thorn in my side when making better_nametags, hanggliders, and now, this).
			end
		else
			wield_ent:set_properties({textures = {"wield_redo:nothing"}})
		end
	else
		wield_redo.player_items[name] = minetest.add_entity(player:get_pos(), "wield_redo:item")
		wield_redo.player_items[name]:set_properties({textures = {"wield_redo:nothing"}})
		wield_redo.player_items[name]:set_attach(player, wield_redo.handed, {x=0,y=0,z=0}, {x=0,y=0,z=0})
		--wield_redo.player_items[name]:set_attach(player, "", {x=2.5,y=5.8,z=0}, {x=0,y=0,z=0})
	end
	
end



if minetest.get_modpath("playeranim") then -- A hack for a hack, and a bone for a bone
	
	wield_redo.do_satanic_stuff = function(player, bone, rotation)
		if bone ~= wield_redo.handed then return end
		local wieldEnt = wield_redo.player_items[player:get_player_name()]
		if wieldEnt then
			local itemname = player:get_wielded_item():get_name()
			local offset = ((
				wield_redo.itemOffsets[itemname] or
				wield_redo.itemOffsets[
					wield_redo.systemd and 
					minetestd.utils.check_item_match(itemname, wield_redo.knownItems)
				]
				) or {65, 0.8}
			)
			bonePos = {x=2.8,y=2.0+wield_redo.moveModelUp,z=0}
			local radius = 3.75
			local forwardOffset = 2.5
			--If you can fix my crappy trigonometry, PLEASE DO.
			bonePos.z = bonePos.z + (math.sin(rotation.x*3.1416/180)*math.cos(rotation.y*3.1416/180))*(radius+offset[2]) + --Placement in a circle from the bone's center
				math.cos(rotation.x*3.1416/180)*forwardOffset --Move item forward in hand
				
				
			bonePos.y = bonePos.y - (math.cos(rotation.x*3.1416/180))*(radius+offset[2]) +
				math.sin(rotation.x*3.1416/180)*forwardOffset
				
				
			bonePos.x = bonePos.x + (math.sin(rotation.y*3.1416/180))*(radius+offset[2]) --Whatever this does, it's not good at it
			--minetest.chat_send_all(rotation.x.." _ "..rotation.y.." _ "..rotation.z)
			
			local bRotate = {x=90--+rotation.y
			,
			y=offset[1]+rotation.x
			,
			z=90---rotation.y
			}
			wieldEnt:set_attach(player, "", bonePos, bRotate)
			
		end
	end
	
	if not (wield_redo.systemd and minetestd.services.wield_redo) then --Don't redefine this when reloaded by minetest_systemd.
		wield_redo.hack = false 
		minetest.register_on_joinplayer(function(player)
			if wield_redo.hack then return end
			essence_of_all_life = getmetatable(player)
			local old_set_bone_position = essence_of_all_life.set_bone_position 
			essence_of_all_life.set_bone_position = function(self, bone, position, rotation)
				local r = old_set_bone_position(self, bone, position, rotation)
				if self:is_player() then 
					wield_redo.do_satanic_stuff(self, bone, rotation)
				end
				return r
			end
			wield_redo.hack = true
		end)
	end
	--error("Playeranim is currently incompatible with wield_redo. Sorry. If you have a solution (or if you managed to make mine work), let me know!")
end

if not wield_redo.systemd then -- no minetest_systemd support, use default init
	wield_redo.timer = 0
	minetest.register_globalstep(function(dtime)
		if wield_redo.timer < 0.25 then
			wield_redo.timer = wield_redo.timer + dtime
			return
		end
		for _,player in pairs(minetest.get_connected_players()) do
			wield_redo.update(player)
		end
		wield_redo.timer = 0
	end)
end



if not (wield_redo.systemd and minetestd.services.wield_redo) then -- Do once at true init, in case of reload

	minetest.register_entity("wield_redo:item", {
		visual = "wielditem",
		visual_size = {x=0.30, y=0.30},
		collisionbox = {0},
		physical = false,
		textures = {"wield_redo:nothing"},
		static_save = false,
		wielder = "",
		on_step = function(self, dtime)
			local parent = self.object:get_attach("parent")
			if not (parent and parent:is_player() and wield_redo.player_items[parent:get_player_name()] == self.object) then
				self.object:remove()
			end
		end
	})
	minetest.register_on_leaveplayer(function(player)
		if wield_redo.player_items[player:get_player_name()] then
			wield_redo.player_items[player:get_player_name()]:remove() 
		end
		wield_redo.player_items[player:get_player_name()] = nil
	end)
	minetest.register_craftitem("wield_redo:nothing", {
		inventory_image="default_wood.png^[colorize:#0000:255", --Drawtype: please don't.
		groups={not_in_creative_inventory=1}
	})

end


if wield_redo.systemd then
	if not minetestd.services.wield_redo then -- Do once if minetest_systemd is present
		minetestd.register_service("wield_redo", {
			start = function()
				if minetestd.services.wield_redo.initialized then
					dofile(minetest.get_modpath("wield_redo").."/init.lua") 
				end
				minetestd.services.wield_redo.enabled = true
				return true
			end,
			stop = function()
				minetestd.playerctl.steps["wield_redo"] = nil
				minetestd.services.wield_redo.enabled = false
				wield_redo.players = {} -- Entities will remove themselves, effectively disabling the mod.
			end,
		
		})
	end
	minetestd.playerctl.register_playerstep("wield_redo", { -- Safe. Overwrites if reloaded
		func = wield_redo.update,
		save = false,
		interval = 0.25
	})
end
return
