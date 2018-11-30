wield_redo = {}
wield_redo.player_items = {}
wield_redo.handed = "Arm_Right" -- Unsupported, may implement later if this becomes more standard to the point where widely used animation mods are implementing it.
wield_redo.toolRotate = {
	["default:shovel_wood"] = 90,
	["default:axe_wood"] = 0,
	["default:sword_wood"] = -10,
	["default:pick_wood"] = 0,
	["farming:hoe_wood"] = 0,
	
	["default:shovel_stone"] = 90,
	["default:axe_stone"] = 0,
	["default:sword_stone"] = -10,
	["default:pick_stone"] = 0,
	["farming:hoe_stone"] = 0,
	
	["default:shovel_steel"] = 90,
	["default:axe_steel"] = 0,
	["default:sword_steel"] = -10,
	["default:pick_steel"] = 0,
	["farming:hoe_steel"] = 0,
	
	["default:shovel_bronze"] = 90,
	["default:axe_bronze"] = 0,
	["default:sword_bronze"] = -10,
	["default:pick_bronze"] = 0,
	["farming:hoe_bronze"] = 0,
	
	["default:shovel_mese"] = 90,
	["default:axe_mese"] = 0,
	["default:sword_mese"] = -10,
	["default:pick_mese"] = 0,
	["farming:hoe_mese"] = 0,
	
	["default:shovel_diamond"] = 90,
	["default:axe_diamond"] = 0,
	["default:sword_diamond"] = -10,
	["default:pick_diamond"] = 0,
	["farming:hoe_diamond"] = 0,
	
	["screwdriver:screwdriver"] = 77,
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
				local yRotation = ((
					wield_redo.toolRotate[itemname] or
					wield_redo.toolRotate[
						minetest.get_modpath("minetest_systemd") and 
						minetestd.utils.check_item_match(itemname, wield_redo.toolRotate)
					]
					) or 35
				)
				
				wield_redo.player_items[name]:set_attach(player, wield_redo.handed, {x=-0.5,y=3.6,z=2.5}, {x=90,y=yRotation,z=-90}) 
				--Update this sometimes, as it tends to glitch out. 
				--(Seriously, set_attach needs a SERIOUS overhaul. It's been a thorn in my side when making better_nametags, hanggliders, and now, this).
			end
		else
			wield_ent:set_properties({textures = {"wield_redo:nothing"}})
		end
	else
		wield_redo.player_items[name] = minetest.add_entity(player:get_pos(), "wield_redo:item")
		wield_redo.player_items[name]:set_properties({textures = {"wield_redo:nothing"}})
		wield_redo.player_items[name]:set_attach(player, wield_redo.handed, {x=-0.5,y=3.6,z=2.5}, {x=90,y=0,z=-90})
	end
	
end



if minetest.get_modpath("playeranim") then -- A hack for a hack, and a bone for a bone
	--[[
	wield_redo.do_satanic_stuff = function(player)
		local wieldEnt = wield_redo.player_items[player:get_player_name()]
		if wieldEnt then
			local bonePos, bRotate = player:get_bone_position(wield_redo.handed)
			bonePos.y = bonePos.y - 1
			bonePos.z = bonePos.z + 1.5
			bonePos.x = bonePos.x + math.sin(bRotate.x)*3.5 + math.
		
			wieldEnt:set_attach(player, "", bonePos, bRotate)
		end
	end
	
	if not (minetestd and minetestd.services.wield_redo) then --Minetest_systemd 
		wield_redo.hack = false 
		minetest.register_on_joinplayer(function(player)
			if wield_redo.hack then return end
			essence_of_all_life = getmetatable(player)
			local old_set_bone_position = essence_of_all_life.set_bone_position 
			essence_of_all_life.set_bone_position = function(self, bone, position, rotation)
				local r = old_set_bone_position(self, bone, position, rotation)
				if self:is_player() then 
					wield_redo.do_satanic_stuff(self)
				end
				return r
			end
			wield_redo.hack = true
		end)
	end]]
	error("Playeranim is currently incompatible with wield_redo. Sorry. If you have a solution (or if you managed to make mine work), let me know!")
end

if not minetestd then -- no minetest_systemd support, use default init
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



if not (minetestd and minetestd.services.wield_redo) then -- Do once at init, in case of reload

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


if minetestd then
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
	minetestd.playerctl.register_playerstep("wield_redo", {
		func = wield_redo.update,
		save = false,
		interval = 0.25
	})
end
return