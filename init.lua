wield_redo = {}
wield_redo.player_items = {}
wield_redo.handed = "Arm_Right" -- Unsupported, may implement later if this becomes more standard to the point where widely used animation mods are implementing it.
wield_redo.systemd = minetest.get_modpath("minetest_systemd")
wield_redo.moveModelUp = 0
if tonumber(string.sub(minetest.get_version().string, 1, 1)) and tonumber(string.sub(minetest.get_version().string, 1, 1)) > 4 then
	wield_redo.moveModelUp = 10
end
wield_redo.toolOffsets = { 
	--[name, or group if minetest_systemd is present. DO NOT USE TABLES AS A KEY.] {rotation (pitch), vertical offset (higher numbers move downward)} 
	["default:shovel_wood"] = {90,0},
	["default:axe_wood"] = {-15,0},
	["default:sword_wood"] = {-15,0},
	["default:pick_wood"] = {-15,0},
	["farming:hoe_wood"] = {-15,0},
	
	["default:shovel_stone"] = {90,0},
	["default:axe_stone"] = {-15,0},
	["default:sword_stone"] = {-15,0},
	["default:pick_stone"] = {-15,0},
	["farming:hoe_stone"] = {-15,0},
	
	["default:shovel_steel"] = {90,0},
	["default:axe_steel"] = {-15,0},
	["default:sword_steel"] = {-15,0},
	["default:pick_steel"] = {-15,0},
	["farming:hoe_steel"] = {-15,0},
	
	["default:shovel_bronze"] = {90,0},
	["default:axe_bronze"] = {-15,0},
	["default:sword_bronze"] = {-15,0},
	["default:pick_bronze"] = {-15,0},
	["farming:hoe_bronze"] = {-15,0},
	
	["default:shovel_diamond"] = {90,0},
	["default:axe_diamond"] = {-15,0},
	["default:sword_diamond"] = {-15,0},
	["default:pick_diamond"] = {-15,0},
	["farming:hoe_diamond"] = {-15,0},
	
	["default:shovel_mese"] = {90,0},
	["default:axe_mese"] = {-15,0},
	["default:sword_mese"] = {-15,0},
	["default:pick_mese"] = {-15,0},
	["farming:hoe_mese"] = {-15,0},
	
	["moreores:shovel_silver"] = {90,0},
	["moreores:axe_silver"] = {-15,0},
	["moreores:sword_silver"] = {-15,0},
	["moreores:pick_silver"] = {-15,0},
	["moreores:hoe_silver"] = {-15,0},
	
	["moreores:shovel_mithril"] = {90,0},
	["moreores:axe_mithril"] = {-15,0},
	["moreores:sword_mithril"] = {-15,0},
	["moreores:pick_mithril"] = {-15,0},
	["moreores:hoe_mithril"] = {-15,0},
	
	["group:shovel"] = {90,0}, --Someday...
	["group:axe"] = {-15,0},
	["group:sword"] = {-15,0},
	["group:pickaxe"] = {-15,0},
	["group:hoe"] = {-15,0},
	
	["mobs:pick_lava"] = {-15,0},
	["mobs:net"] = {0,0},
	
	["bonemeal:bone"] = {0,0.8},
	["default:stick"] = {0,0.8},
	
	["banners:wooden_pole"] = {0,0.8},
	["banners:steel_pole"] = {0,0.8},
	
	["fancy_vend:copy_tool"] = {0,0.8},
	
	["ma_pops_furniture:hammer"] = {0,0.8},
	["xdecor:hammer"] = {0,0.8},
	
	["mesecons_torch:mesecon_torch_on"] = {45,0},
	
	["default:torch"] = {45,0},
	
	["screwdriver:screwdriver"] = {77,0},
}
wield_redo.update = function(player)
	if minetestd and not minetestd.services.wield_redo.enabled then return end
	local name = player:get_player_name()
	local wield_ent = wield_redo.player_items[name]
	local item = player:get_wielded_item()
	if ( wield_ent and wield_ent:get_attach("parent") == player) then
		if item and item:get_name() ~= "" and not item:is_empty() then
			local itemname = item:get_name()
			if wield_ent:get_properties().textures[1] ~= itemname then
				wield_ent:set_properties({textures = {itemname}})
				local offset = ((
					wield_redo.toolOffsets[itemname] or
					wield_redo.toolOffsets[
						wield_redo.systemd and 
						minetestd.utils.check_item_match(itemname, wield_redo.toolOffsets)
					]
					) or {65, 0.8}
				)
				wield_redo.player_items[name]:set_attach(player, wield_redo.handed, {x=-0.25,y=3.6+offset[2],z=2.5}, {x=90,y=offset[1],z=-90}) 
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
				wield_redo.toolOffsets[itemname] or
				wield_redo.toolOffsets[
					wield_redo.systemd and 
					minetestd.utils.check_item_match(itemname, wield_redo.toolOffsets)
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
