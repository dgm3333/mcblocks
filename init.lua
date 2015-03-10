-- MCBlocks version 0.5

-- Version 1: Still outstanding:-
-- TODO:
-- NB currently doors aren't working, and rotation of many blocks is incorrect
-- Working Doors, Gates, Fence
-- Double-height plants and tallgrass
-- Mushrooms
-- Correct node registration to give blocks 'usual' properties (eg diggable, flammable, etc)
-- utilise 3D models: /assets/minecraft/models, and 3D textures /assets/minecraft/textures/entity
-- Special Block Functions (doors, chests, enchanting table, crafting table/workbench, furnace, anvil, cake, signs, ladders, rails)
-- Fix glitchy water and lava (which flows more widely the minecraft equivalents and currently varies between block types
-- Growing Crops

-- Version 2 plans:
-- Functioning Redstone
-- Import most/all entities (eg mobs)

mcblocks = {}

local flattenTexturePack = function()
	local curModPath = minetest.get_modpath('mcblocks')
	local texPath = curModPath.. "/textures/"
    local assetsPath = curModPath.. "/assets/"
	local blockPath = curModPath.. "/assets/minecraft/textures/blocks/"
	local entityPath = curModPath.. "/assets/minecraft/textures/entity/"
	local itemPath = curModPath.. "/assets/minecraft/textures/items/"
	local paintPath = curModPath.. "/assets/minecraft/textures/painting/"

	local p = io.popen('find "'..blockPath..'" -type f')  --Open directory look for files
	for file in p:lines() do                         --Loop through all files
--		print(file)
--		print(string.gsub(file,blockPath,texPath..'mcB'))
		os.rename(file, string.gsub(file,blockPath,texPath..'mcB'))
	end
    local p = io.popen('find "'..entityPath..'" -type f')  --Open directory look for files
    for file in p:lines() do                         --Loop through all files
        os.rename(file, string.gsub(file,entityPath,texPath..'mcE'))
    end
    local p = io.popen('find "'..entityPath..'chest/" -type f')  --Open directory look for files
    for file in p:lines() do                         --Loop through all files
        os.rename(file, string.gsub(file,entityPath..'chest/',texPath..'mcECh'))
    end
    local p = io.popen('find "'..entityPath..'creeper/" -type f')  --Open directory look for files
    for file in p:lines() do                         --Loop through all files
        os.rename(file, string.gsub(file,entityPath..'creeper/',texPath..'mcECr'))
    end
    local p = io.popen('find "'..entityPath..'zombie/" -type f')  --Open directory look for files
    for file in p:lines() do                         --Loop through all files
        os.rename(file, string.gsub(file,entityPath..'zombie/',texPath..'mcEZo'))
    end
    local p = io.popen('find "'..entityPath..'skeleton/" -type f')  --Open directory look for files
    for file in p:lines() do                         --Loop through all files
        os.rename(file, string.gsub(file,entityPath..'skeleton/',texPath..'mcESk'))
    end
	local p = io.popen('find "'..itemPath..'" -type f')  --Open directory look for files
	for file in p:lines() do                         --Loop through all files
		os.rename(file, string.gsub(file,itemPath,texPath..'mcI'))
	end
	local p = io.popen('find "'..paintPath..'" -type f')  --Open directory look for files
	for file in p:lines() do                         --Loop through all files
		os.rename(file, string.gsub(file,paintPath,texPath..'mcP'))
	end
	os.remove(assetsPath)      -- sadly this doesn't seem to work (possibly as I can't be bothered recursively deleting the directories and files
	os.execute("rm -rf "..assetsPath)      -- this works with linux at least
end
flattenTexturePack()


function mcblocks.register_plant(subname, images)
	minetest.register_node("mcblocks:"..subname, {
		drawtype = "plantlike",
		tiles = images,
		paramtype = "light",
		walkable = true,
		selection_box = {type = "fixed",fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3},},
		groups = {snappy=3,flammable=2,plant=1,not_in_creative_inventory=1,growing=1},
		sounds = default.node_sound_leaves_defaults(),
	})
end

function mcblocks.register_leaves(subname, images)
    minetest.register_node("mcblocks:"..subname, {
        description = "Leaves",
        drawtype = "allfaces_optional",
        waving = 1,
        visual_scale = 1.3,
        tiles = {"default_leaves.png"},
        paramtype = "light",
        is_ground_content = false,
        groups = {snappy=3, leafdecay=0, flammable=2, leaves=1},
        sounds = default.node_sound_leaves_defaults(),

        after_place_node = default.after_place_leaves,
    })
    minetest.register_node("mcblocks:"..subname.."_NoDecay", {
        description = "Leaves",
        drawtype = "allfaces_optional",
        waving = 1,
        visual_scale = 1.3,
        tiles = {"default_leaves.png"},
        paramtype = "light",
        is_ground_content = false,
        groups = {snappy=3, flammable=2, leaves=1},
        sounds = default.node_sound_leaves_defaults(),

        after_place_node = default.after_place_leaves,
    })
end

--at the moment this is just a single plant
function mcblocks.register_doubleplant(subname, images)
	mcblocks.register_plant(subname, images)
end

--at the moment this is just a single plant
function mcblocks.register_crop(subname, images)
	mcblocks.register_plant(subname, images)
end

function mcblocks.register_item(subname, images)
	mcblocks.register_plant(subname, images)
end


--Stairs
function mcblocks.register_stair_slab(subname, images, groups, sounds)
    local nbVertices = ""
    if not (subname:find("slab") == nil) then
        if subname:sub(-3) == "USD" then
            nbVertices = {-0.5, 0.5, -0.5, 0.5, 0, 0.5}           -- Upside Down Slab
        else
            nbVertices = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
        end
    else
        if subname:sub(-3) == "USD" then
            nbVertices = {{-0.5, 0.5, -0.5, 0.5,  0,   0.5},        -- Upside Down Staircase
                          {-0.5, 0,    0,   0.5, -0.5, 0.5},}
        else
            nbVertices = {{-0.5, -0.5, -0.5, 0.5, 0,   0.5},      -- {x1, y1, z1, x2, y2, z2}
                          {-0.5,  0,    0,   0.5, 0.5, 0.5},}
        end
    end
--    print("Registering Node: "..subname)
    minetest.register_node(subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = images,
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
        groups = groups,
        sounds = sounds,
        node_box = { type = "fixed",  fixed = nbVertices, },
    })
end



function mcblocks.register_stair(subname, images, sounds)
    subname = "mcblocks:stair_"..subname
	if sounds == 'w' then
        mcblocks.register_stair_slab(subname, images, {snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3}, default.node_sound_wood_defaults())
        mcblocks.register_stair_slab(subname.."_USD", images, {snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3}, default.node_sound_wood_defaults())
	else
        mcblocks.register_stair_slab(subname, images, {cracky=3}, default.node_sound_stone_defaults())
        mcblocks.register_stair_slab(subname.."_USD", images, {cracky=3}, default.node_sound_stone_defaults())
	end
end

function mcblocks.register_slab(subname, images, sounds)
    subname = "mcblocks:slab_"..subname
    if sounds == 'w' then
        mcblocks.register_stair_slab(subname, images, {snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3}, default.node_sound_wood_defaults())
        mcblocks.register_stair_slab(subname.."_USD", images, {snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3}, default.node_sound_wood_defaults())
    else
        mcblocks.register_stair_slab(subname, images, {cracky=3}, default.node_sound_stone_defaults())
        mcblocks.register_stair_slab(subname.."_USD", images, {cracky=3}, default.node_sound_stone_defaults())
    end
end

function mcblocks.register_bed(subname, images)
	-- I'm not sure how to rotate the side textures
	minetest.register_node("mcblocks:"..subname, {
		description = subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
--		groups = groups,
--		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
	})
end

function mcblocks.register_rail(subname, images, power)
	-- This uses minetest logic for rails, not minecraft, so needs an edit
	minetest.register_node("mcblocks:"..subname, {
		description = subname,
		drawtype = "raillike",
--		tiles = {"carts_rail_pwr.png", "carts_rail_curved_pwr.png", "carts_rail_t_junction_pwr.png", "carts_rail_crossing_pwr.png"},
		tiles = images,
--		inventory_image = "carts_rail_pwr.png",
--		wield_image = "carts_rail_pwr.png",
		paramtype = "light",
		is_ground_content = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			-- but how to specify the dimensions for curved and sideways rails?
			fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
		},
		groups = {bendy=2,snappy=1,dig_immediate=2,attached_node=1,rail=1,connect_to_raillike=1},

		after_place_node = function(pos, placer, itemstack)
			if not mesecon then
				minetest.env:get_meta(pos):set_string("cart_acceleration", "0.5")
			end
		end,

		mesecons = {
			effector = {
				action_on = function(pos, node)
					minetest.env:get_meta(pos):set_string("cart_acceleration", "0.5")
				end,

				action_off = function(pos, node)
					minetest.env:get_meta(pos):set_string("cart_acceleration", "0")
				end,
			},
		},
	})
end


-- This has to be improved the stained glass is not the correct colour
function mcblocks.register_glass(subname, images)
	minetest.register_node("mcblocks:"..subname, {
		description = subname,
		drawtype = "glasslike_framed_optional",
		tiles = images,
		paramtype = "light",
		use_texture_alpha = true,		-- enable semi-transparency
        alpha = 160,
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {cracky=3,oddly_breakable_by_hand=3},
		sounds = default.node_sound_glass_defaults(),
	})
end


local function punchDoor(pos)
    local meta = minetest.env:get_meta(pos)
    local node = minetest.env:get_node(pos)
    local nodeName = node.name:sub(1,-3)
    local doorState = node.name:sub(-2)
    print(nodeName)
    if doorState == "BC" then
        minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."BO", param1=node.param1, param2=node.param2})
    elseif doorState == "TC" then
        minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."TO", param1=node.param1, param2=node.param2})
    elseif doorState == "BO" then
        minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."BC", param1=node.param1, param2=node.param2})
    elseif doorState == "BC" then
        minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."BO", param1=node.param1, param2=node.param2})
    end
end

function mcblocks.register_door_state(subname, imageTB, imageSide, doorState)
    local dS, tiles, inventory_image, boundBox, node_box, selection_box, drop
    local nodeName = "mcblocks:"..subname.."_"..doorState
    if doorState == "BC" or doorState == "TC" then
        if doorState == "BC" then dS=1 else dS=-1 end
        tiles = {imageTB,imageTB,imageSide,imageSide,imageSide,imageSide,}
        inventory_image = imageTB
        boundBox = {dS*0.5, dS*0.5, dS*0.5, dS*-0.5, dS*0.4, dS*-0.5}
        node_box = {type="fixed", fixed = boundBox}
        selection_box = {type="fixed", fixed = boundBox}
        drop = nodeName
    else
        tiles = {imageSide,imageSide,imageSide,imageSide,imageTB,imageTB,}
        boundBox = {-0.5, -0.5, -0.5, -0.5, 0.5, -0.3}
        node_box = {type="fixed", fixed=boundBox}
        selection_box = {type ="fixed", fixed=boundBox}
    end

    print("Registering Node: "..nodeName)
    print(tiles)
    minetest.register_node(nodeName, {
        description = subname,
        drawtype = "nodebox",
        paramtype = "light",
        paramtype2 = "facedir",
        groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
        sounds = default.node_sound_wood_defaults(),
        tiles = tiles, inventory_image = inventory_image, node_box = node_box, selection_box = selection_box, drop = drop,
        on_rightclick = function(pos, node, clicker)
            punchTrapdoor(pos)
        end,
    })
end

--mcblocks.register_door("Wooden_Door_Bottom_Closed", "mcBdoor_wood_lower.png")       --type=Door"64"
--mcblocks.register_door("Wooden_Door_Bottom_Open", "mcBdoor_wood_lower.png")       --type=Door"64"
--mcblocks.register_door("Wooden_Door_Top_HingeRight", "mcBdoor_wood_upper.png")       --type=Door"64"
--mcblocks.register_door("Wooden_Door_Top_HingeLeft", "mcBdoor_wood_upper.png")       --type=Door"64"

function mcblocks.register_door_basic(subname, imageTB, imageSide)
    local dS, tiles, inventory_image, boundBox, node_box, selection_box, drop
    local nodeName = "mcblocks:"..subname
    tiles = {imageSide,imageSide,imageSide,imageSide,imageTB,imageTB,}
    boundBox = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.3}
    node_box = {type="fixed", fixed=boundBox}
    selection_box = {type ="fixed", fixed=boundBox}

    print("Registering Node: "..nodeName)
    print(tiles)
    minetest.register_node(nodeName, {
        description = subname,
        drawtype = "nodebox",
        paramtype = "light",
        paramtype2 = "facedir",
        groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
        sounds = default.node_sound_wood_defaults(),
        tiles = tiles, inventory_image = inventory_image, node_box = node_box, selection_box = selection_box, drop = drop,
        on_rightclick = function(pos, node, clicker)
            punchDoor(pos)
        end,
    })
end


function mcblocks.register_door(subname, imageFB, imageSide)
    mcblocks.register_door_basic(subname, imageFB, imageSide)
--    mcblocks.register_door_state(subname, imageFB, imageSide, "BO")
--    mcblocks.register_door_state(subname, imageFB, imageSide, "TC")
--    mcblocks.register_door_state(subname, imageFB, imageSide, "TO")
--    mcblocks.register_door_state(subname, imageFB, imageSide, "BC")
--    mcblocks.register_door_state(subname, imageFB, imageSide, "BO")
--    mcblocks.register_door_state(subname, imageFB, imageSide, "TC")
--    mcblocks.register_door_state(subname, imageFB, imageSide, "TO")
end


local function punchTrapdoor(pos)
    local meta = minetest.env:get_meta(pos)
    local node = minetest.env:get_node(pos)
    local nodeName = node.name:sub(1,-3)
    local doorState = node.name:sub(-2)
    print(nodeName)
    if doorState == "BC" then
        minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."BO", param1=node.param1, param2=node.param2})
    elseif doorState == "TC" then
        minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."TO", param1=node.param1, param2=node.param2})
    elseif doorState == "BO" then
        minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."BC", param1=node.param1, param2=node.param2})
    elseif doorState == "BC" then
        minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
        minetest.env:set_node(pos, {name=nodeName.."BO", param1=node.param1, param2=node.param2})
    end
end

function mcblocks.register_trapdoor_state(subname, imageTB, imageSide, doorState)
    local dS, tiles, inventory_image, boundBox, node_box, selection_box, drop
    local nodeName = "mcblocks:"..subname.."_"..doorState
    if doorState == "BC" or doorState == "TC" then
        if doorState == "BC" then dS=1 else dS=-1 end
        tiles = {imageTB,imageTB,imageSide,imageSide,imageSide,imageSide,}
        inventory_image = imageTB
        boundBox = {dS*0.5, dS*0.5, dS*0.5, dS*-0.5, dS*0.4, dS*-0.5}
        node_box = {type="fixed", fixed = boundBox}
        selection_box = {type="fixed", fixed = boundBox}
        drop = nodeName
    else
        tiles = {imageSide,imageSide,imageSide,imageSide,imageTB,imageTB,}
        boundBox = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
        node_box = {type="fixed", fixed=boundBox}
        selection_box = {type ="fixed", fixed=boundBox}
    end

    print("Registering Node: "..nodeName)
    print(tiles)
    minetest.register_node(nodeName, {
        description = subname,
        drawtype = "nodebox",
        paramtype = "light",
        paramtype2 = "facedir",
        groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
        sounds = default.node_sound_wood_defaults(),
        tiles = tiles, inventory_image = inventory_image, node_box = node_box, selection_box = selection_box, drop = drop,
        on_rightclick = function(pos, node, clicker)
            punchTrapdoor(pos)
        end,
    })
end

function mcblocks.register_trapdoor(subname, imageTB, imageSide)
    mcblocks.register_trapdoor_state(subname, imageTB, imageSide, "BC")
    mcblocks.register_trapdoor_state(subname, imageTB, imageSide, "BO")
    mcblocks.register_trapdoor_state(subname, imageTB, imageSide, "TC")
    mcblocks.register_trapdoor_state(subname, imageTB, imageSide, "TO")
end


function mcblocks.register_button(subname, images)
    mcblocks.register_button_core(subname.."_Active", images)
    mcblocks.register_button_core(subname.."_Inactive", images)
end

function mcblocks.register_button_core(subname, images)
    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = {images,},
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
--      groups = groups,
--      sounds = sounds,
        node_box = {
            type = "fixed",
            fixed = {-0.2, -0.1, 0.5, 0.2, 0.1, 0.4},
        },
    })
end

function mcblocks.register_lever(subname, images)
    mcblocks.register_lever_core(subname.."_Active", images)
    mcblocks.register_lever_core(subname.."_Inactive", images)
end

function mcblocks.register_lever_core(subname, images)
    if subname:sub(-8) == "_Inactive" then
        nbVertices = {{-0.1, -0.2, 0.5, 0.1, 0.2, 0.4},       -- base
                     {-0.05, -0.1, 0.4, 0.05, -0.15, 0.2}}       -- lever
    else
        nbVertices = {{-0.1, -0.2, 0.5, 0.1, 0.2, 0.4},       -- base
                     {-0.05, 0.1, 0.4, 0.05, 0.15, 0.2}}       -- lever
    end

    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = {images,},
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
--      groups = groups,
--      sounds = sounds,
        node_box = {
            type = "fixed",
            fixed = nbVertices,
        },
    })
end

--Vertices = {x1, y1, z1, x2, y2, z2,}
--nametexture(all faces)top,bottom,side/left,right,front,back,interior,baseblock typeid#idName
-- minetest.register_node("mcblocks:DummyNode", {tiles ={"up.png","mcBdown.png","mcBleft.png","mcBright.png","mcBfront.png","mcBback.png",},})
minetest.register_node("mcblocks:Stone", {tiles = {"mcBstone.png",},})		--type=Solid"1:0""stone"
minetest.register_node("mcblocks:Granite", {tiles = {"mcBstone_granite.png",},})		--type=Solid"1:1""stone"
minetest.register_node("mcblocks:Polished_Granite", {tiles = {"mcBstone_granite_smooth.png",},})		--type=Solid"1:2""stone"
minetest.register_node("mcblocks:Diorite", {tiles = {"mcBstone_diorite.png",},})		--type=Solid"1:3""stone"
minetest.register_node("mcblocks:Polished_Diorite", {tiles = {"mcBstone_diorite_smooth.png",},})		--type=Solid"1:4""stone"
minetest.register_node("mcblocks:Andesite", {tiles = {"mcBstone_andesite.png",},})		--type=Solid"1:5""stone"
minetest.register_node("mcblocks:Polished_Andesite", {tiles = {"mcBstone_andesite_smooth.png",},})		--type=Solid"1:6""stone"
minetest.register_node("mcblocks:Grass", {tiles = {"mcBdirt.png","mcBgrass_top.png","mcBdirt.png","mcBdirt.png","mcBdirt.png","mcBdirt.png","mcBdirt.png",},})		--type=Grass"2""grass"betterGrass="none"dirtSide="grass_side.png"grassSide="grass_side_overlay.png"snowSide="grass_side_snowed.png"
minetest.register_node("mcblocks:Dirt", {tiles = {"mcBdirt.png",},})		--type=Solid"3:0""dirt"
minetest.register_node("mcblocks:Coarse_Dirt", {tiles = {"mcBcoarse_dirt.png",},})		--type=Solid"3:1""dirt"
minetest.register_node("mcblocks:Podzol", {tiles = {"mcBdirt_podzol_top.png","mcBdirt_podzol_top.png","mcBdirt_podzol_side.png","mcBdirt_podzol_side.png","mcBdirt_podzol_side.png","mcBdirt_podzol_side.png",},})		--type=Solid"3:2""dirt"
minetest.register_node("mcblocks:Cobblestone", {tiles = {"mcBcobblestone.png",},})		--type=Solid"4""cobblestone"
minetest.register_node("mcblocks:Oak_Wooden_Plank", {tiles = {"mcBplanks_oak.png",},})		--type=Solid"5:0""planks"
minetest.register_node("mcblocks:Spruce_Wooden_Plank", {tiles = {"mcBplanks_spruce.png",},})		--type=Solid"5:1""planks"
minetest.register_node("mcblocks:Birch_Wooden_Plank", {tiles = {"mcBplanks_birch.png",},})		--type=Solid"5:2""planks"
minetest.register_node("mcblocks:Jungle_Wooden_Plank", {tiles = {"mcBplanks_jungle.png",},})		--type=Solid"5:3""planks"
minetest.register_node("mcblocks:Acacia_Wooden_Plank", {tiles = {"mcBplanks_acacia.png",},})		--type=Solid"5:4""planks"
minetest.register_node("mcblocks:Dark_Oak_Wooden_Plank", {tiles = {"mcBplanks_big_oak.png",},})		--type=Solid"5:5""planks"
mcblocks.register_plant("Oak_Sapling", {"mcBsapling_oak.png"})		--type=Plant"6:0"
mcblocks.register_plant("Spruce_Sapling", {"mcBsapling_spruce.png"})		--type=Plant"6:1"
mcblocks.register_plant("Birch_Sapling", {"mcBsapling_birch.png"})		--type=Plant"6:2"
mcblocks.register_plant("Jungle_Sapling", {"mcBsapling_jungle.png"})		--type=Plant"6:3"
mcblocks.register_plant("Acacia_Sapling", {"mcBsapling_acacia.png"})		--type=Plant"6:4"
mcblocks.register_plant("Dark_Oak_Sapling", {"mcBsapling_roofed_oak.png"})		--type=Plant"6:5"

minetest.register_node("mcblocks:Bedrock", {tiles = {"mcBbedrock.png",},})		--type=Solid"7""bedrock"


--minetest.register_node("mcblocks:Water_Flowing", {tiles = {"mcBwater_flow.png",},alpha = 160,})             --type=Water"8""flowing_water"
--minetest.register_node("mcblocks:Water", {tiles = {"mcBwater_still.png",},alpha = 160,})              --type=Water"9""water"

--if 1==0 then
minetest.register_node("mcblocks:Water", {
    description = "Still Water",
    inventory_image = minetest.inventorycube("mcBwater_still.png"),
    drawtype = "liquid",
    tiles = {
        {
            name = "mcBwater_still.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
        },
    },
    special_tiles = {
        -- New-style water source material (mostly unused)
        {
            name = "mcBwater_still.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
            backface_culling = true,
        },
    },
    alpha = 160,
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = "",
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "mcblocks:Water_Flowing",
    liquid_alternative_source = "mcblocks:Water",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=100, g=100, b=200},
    groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("mcblocks:Water_Flowing", {
    description = "Flowing Water",
    inventory_image = minetest.inventorycube("mcBwater_flow.png"),
    drawtype = "flowingliquid",
    tiles = {"default_water.png"},
    special_tiles = {
        {
            name = "mcBwater_flow.png",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 0.8,
            },
        },
        {
            name = "mcBwater_flow.png",
            backface_culling = true,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 0.8,
            },
        },
    },
    alpha = 160,
    paramtype = "light",
    paramtype2 = "flowingliquid",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = "",
    drowning = 1,
    liquidtype = "flowing",
    liquid_alternative_flowing = "mcBwater_flow",
    liquid_alternative_source = "mcBwater_flow",
    liquid_viscosity = 1,
    post_effect_color = {a=64, r=100, g=100, b=200},
    groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})
--end
--minetest.register_node("mcblocks:Lava_Flowing", {tiles = {"mcBlava_flow.png",},})             --type=Solid"10""flowing_lava"
--minetest.register_node("mcblocks:Lava", {tiles = {"mcBlava_still.png",},})               --type=Solid"11""lava"


minetest.register_node("mcblocks:Lava", {
    description = "Still Lava",
    inventory_image = minetest.inventorycube("mcBlava_still.png"),
    drawtype = "liquid",
    tiles = {
        {
            name = "mcBlava_still.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 3.0,
            },
        },
    },
    special_tiles = {
        -- New-style lava source material (mostly unused)
        {
            name = "mcBlava_still.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 3.0,
            },
            backface_culling = false,
        },
    },
    paramtype = "light",
    light_source = default.LIGHT_MAX - 1,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = "",
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "mcblocks:Lava_Flowing",
    liquid_alternative_source = "mcblocks:Lava",
    liquid_viscosity = 7,
    liquid_renewable = false,
    damage_per_second = 4 * 2,
    post_effect_color = {a=192, r=255, g=64, b=0},
    groups = {lava=3, liquid=2, hot=3, igniter=1},
})

minetest.register_node("mcblocks:Lava_Flowing", {
    description = "Flowing Lava",
    inventory_image = minetest.inventorycube("mcBlava_flow.png"),
    drawtype = "flowingliquid",
    tiles = {"mcBlava_flow.png"},
    special_tiles = {
        {
            name = "mcBlava_flow.png",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 3.3,
            },
        },
        {
            name = "mcBlava_flow.png",
            backface_culling = true,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 3.3,
            },
        },
    },
    paramtype = "light",
    paramtype2 = "flowingliquid",
    light_source = default.LIGHT_MAX - 1,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = "",
    drowning = 1,
    liquidtype = "flowing",
    liquid_alternative_flowing = "mcblocks:Lava_Flowing",
    liquid_alternative_source = "mcblocks:Lava",
    liquid_viscosity = 7,
    liquid_renewable = false,
    damage_per_second = 4 * 2,
    post_effect_color = {a=192, r=255, g=64, b=0},
    groups = {lava=3, liquid=2, hot=3, igniter=1, not_in_creative_inventory=1},
})



if 1==0 then
    minetest.register_node("mcblocks:Water", {				--type=Water"8""flowing_water"
    	description = "Flowing Water",
    	inventory_image = minetest.inventorycube("mcBwater_flow.png"),
    	drawtype = "flowingliquid",
    	tiles = {"mcBwater_flow.png"},
    	alpha = 160,
    	paramtype = "light",
    	paramtype2 = "flowingliquid",
    	walkable = false,
    	pointable = false,
    	diggable = false,
    	buildable_to = true,
    	drop = "",
    	drowning = 1,
    	liquidtype = "flowing",
    	liquid_alternative_flowing = "mcblocks:Water",
    	liquid_alternative_source = "mcblocks:Water_Still",
    	liquid_viscosity = 1,
    	post_effect_color = {a=64, r=100, g=100, b=200},
    	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
    })

    minetest.register_node("mcblocks:Water_Still", {				--type=Water"9""water"
    	description = "Water Still",
    	inventory_image = minetest.inventorycube("mcBwater_still.png"),
    	drawtype = "liquid",
    	tiles = {"mcBwater_still.png"},
    	alpha = 160,
    	paramtype = "light",
    	walkable = false,
    	pointable = false,
    	diggable = false,
    	buildable_to = true,
    	drop = "",
    	drowning = 1,
    	liquidtype = "source",
    	liquid_alternative_flowing = "mcblocks:Water",
    	liquid_alternative_source = "mcblocks:Water_Still",
    	liquid_viscosity = 1,
    	post_effect_color = {a=64, r=100, g=100, b=200},
    	groups = {water=3, liquid=3, puts_out_fire=1},
    })


    minetest.register_node("mcblocks:Lava", {				--type=Solid"10""flowing_lava"
    	description = "Flowing Lava",
    	inventory_image = minetest.inventorycube("mcBlava_flow.png"),
    	drawtype = "flowingliquid",
    	tiles = {"mcBlava_flow.png"},
    	paramtype = "light",
    	paramtype2 = "flowingliquid",
    	light_source = 14,
    	walkable = false,
    	pointable = false,
    	diggable = false,
    	buildable_to = true,
    	drop = "",
    	drowning = 1,
    	liquidtype = "flowing",
    	liquid_alternative_flowing = "mcblocks:Lava",
    	liquid_alternative_source = "mcblocks:Lava_Still",
    	liquid_viscosity = 7,
    	liquid_renewable = false,
    --	damage_per_second = 4 * 2,
    --	post_effect_color = {a=192, r=255, g=64, b=0},
    --	groups = {lava=3, liquid=2, hot=3, igniter=1, not_in_creative_inventory=1},
    })

    minetest.register_node("mcblocks:Lava_Still", {				--type=Solid"11""lava"
    	description = "Lava_Still",
    	inventory_image = minetest.inventorycube("mcBlava_still.png"),
    	drawtype = "liquid",
    	tiles = {"mcBlava_still.png"},
    	paramtype = "light",
    	light_source = 14,
    	walkable = false,
    	pointable = false,
    	diggable = false,
    	buildable_to = true,
    	drop = "",
    	drowning = 1,
    	liquidtype = "source",
    	liquid_alternative_flowing = "mcblocks:Lava",
    	liquid_alternative_source = "mcblocks:Lava_Still",
    	liquid_viscosity = 7,
    	liquid_renewable = false,
    --	damage_per_second = 4 * 2,
    --	post_effect_color = {a=192, r=255, g=64, b=0},
    --	groups = {lava=3, liquid=2, hot=3, igniter=1},
    })
end

minetest.register_node("mcblocks:Sand", {tiles = {"mcBsand.png",},})		--type=Solid"12:0""sand"
minetest.register_node("mcblocks:Red_Sand", {tiles = {"mcBred_sand.png",},})		--type=Solid"12:1""sand"
minetest.register_node("mcblocks:Gravel", {tiles = {"mcBgravel.png",},})		--type=Solid"13""gravel"
minetest.register_node("mcblocks:Gold_Ore", {tiles = {"mcBgold_ore.png",},})		--type=Solid"14""gold_ore"
minetest.register_node("mcblocks:Iron_Ore", {tiles = {"mcBiron_ore.png",},})		--type=Solid"15""iron_ore"
minetest.register_node("mcblocks:Coal_Ore", {tiles = {"mcBcoal_ore.png",},})		--type=Solid"16""coal_ore"
minetest.register_node("mcblocks:Oak_Wood", {tiles = {"mcBlog_oak_top.png","mcBlog_oak_top.png","mcBlog_oak.png","mcBlog_oak.png","mcBlog_oak.png","mcBlog_oak.png",},})		--type=Log"17:0""log"
minetest.register_node("mcblocks:Spruce_Wood", {tiles = {"mcBlog_spruce_top.png","mcBlog_spruce_top.png","mcBlog_spruce.png","mcBlog_spruce.png","mcBlog_spruce.png","mcBlog_spruce.png",},})		--type=Log"17:1""log"
minetest.register_node("mcblocks:Birch_Wood", {tiles = {"mcBlog_birch_top.png","mcBlog_birch_top.png","mcBlog_birch.png","mcBlog_birch.png","mcBlog_birch.png","mcBlog_birch.png",},})		--type=Log"17:2""log"
minetest.register_node("mcblocks:Jungle_Wood", {tiles = {"mcBlog_jungle_top.png","mcBlog_jungle_top.png","mcBlog_jungle.png","mcBlog_jungle.png","mcBlog_jungle.png","mcBlog_jungle.png",},})		--type=Log"17:3""log"
minetest.register_node("mcblocks:Oak_Wood_EastWest", {tiles = {"mcBlog_oak_top.png","mcBlog_oak_top.png","mcBlog_oak.png","mcBlog_oak.png","mcBlog_oak.png","mcBlog_oak.png",},})		--type=Log"17:4""log"
minetest.register_node("mcblocks:Spruce_Wood_EastWest", {tiles = {"mcBlog_spruce_top.png","mcBlog_spruce_top.png","mcBlog_spruce.png","mcBlog_spruce.png","mcBlog_spruce.png","mcBlog_spruce.png",},})		--type=Log"17:5""log"
minetest.register_node("mcblocks:Birch_Wood_EastWest", {tiles = {"mcBlog_birch_top.png","mcBlog_birch_top.png","mcBlog_birch.png","mcBlog_birch.png","mcBlog_birch.png","mcBlog_birch.png",},})		--type=Log"17:6""log"
minetest.register_node("mcblocks:Jungle_Wood_EastWest", {tiles = {"mcBlog_jungle_top.png","mcBlog_jungle_top.png","mcBlog_jungle.png","mcBlog_jungle.png","mcBlog_jungle.png","mcBlog_jungle.png",},})		--type=Log"17:7""log"
minetest.register_node("mcblocks:Oak_Wood_NorthSouth", {tiles = {"mcBlog_oak_top.png","mcBlog_oak_top.png","mcBlog_oak.png","mcBlog_oak.png","mcBlog_oak.png","mcBlog_oak.png",},})		--type=Log"17:8""log"
minetest.register_node("mcblocks:Spruce_Wood_NorthSouth", {tiles = {"mcBlog_spruce_top.png","mcBlog_spruce_top.png","mcBlog_spruce.png","mcBlog_spruce.png","mcBlog_spruce.png","mcBlog_spruce.png",},})		--type=Log"17:9""log"
minetest.register_node("mcblocks:Birch_Wood_NorthSouth", {tiles = {"mcBlog_birch_top.png","mcBlog_birch_top.png","mcBlog_birch.png","mcBlog_birch.png","mcBlog_birch.png","mcBlog_birch.png",},})		--type=Log"17:10""log"
minetest.register_node("mcblocks:Jungle_Wood_NorthSouth", {tiles = {"mcBlog_jungle_top.png","mcBlog_jungle_top.png","mcBlog_jungle.png","mcBlog_jungle.png","mcBlog_jungle.png","mcBlog_jungle.png",},})		--type=Log"17:11""log"
mcblocks.register_leaves("Oak_Leaves", {"mcBleaves_oak.png",})		--type=Leaves"18:0"
mcblocks.register_leaves("Spruce_Leaves", {"mcBleaves_spruce.png",})		--type=Leaves"18:1"
mcblocks.register_leaves("Birch_Leaves", {"mcBleaves_birch.png",})		--type=Leaves"18:2"
mcblocks.register_leaves("Jungle_Leaves", {"mcBleaves_jungle.png",})		--type=Leaves"18:3"
minetest.register_node("mcblocks:Sponge", {tiles = {"mcBsponge.png",},})		--type=Solid"19:0""sponge"
minetest.register_node("mcblocks:Wet_Sponge", {tiles = {"mcBsponge_wet.png",},})		--type=Solid"19:1""sponge"
mcblocks.register_glass("Glass", {"mcBglass.png",})		--type=Glass"20"
minetest.register_node("mcblocks:Lapis_Lazuli_Ore", {tiles = {"mcBlapis_ore.png",},})		--type=Solid"21"
minetest.register_node("mcblocks:Lapis_Lazuli_Block", {tiles = {"mcBlapis_block.png",},})		--type=Solid"22"
minetest.register_node("mcblocks:Dispenser", {tiles = {"mcBfurnace_top.png","mcBfurnace_top.png","mcBfurnace_side.png","mcBfurnace_side.png","mcBdispenser_front_horizontal.png","mcBfurnace_side.png",},})		--type=Dispenser"23"topBottom="dispenser_front_vertical.png"
minetest.register_node("mcblocks:Sandstone", {tiles = {"mcBsandstone_top.png","mcBsandstone_bottom.png","mcBsandstone_normal.png","mcBsandstone_normal.png","mcBsandstone_normal.png","mcBsandstone_normal.png",},})		--type=Solid"24:0"
minetest.register_node("mcblocks:Chiseled_Sandstone", {tiles = {"mcBsandstone_top.png","mcBsandstone_top.png","mcBsandstone_carved.png","mcBsandstone_carved.png","mcBsandstone_carved.png","mcBsandstone_carved.png",},})		--type=Solid"24:1"
minetest.register_node("mcblocks:Smooth_Sandstone", {tiles = {"mcBsandstone_top.png","mcBsandstone_top.png","mcBsandstone_smooth.png","mcBsandstone_smooth.png","mcBsandstone_smooth.png","mcBsandstone_smooth.png",},})		--type=Solid"24:2"
minetest.register_node("mcblocks:Note_Block", {tiles = {"mcBnoteblock.png",},})		--type=Solid"25"


mcblocks.register_bed("Bed_Head", {"mcBbed_head_top.png","","mcBbed_head_end.png","","mcBbed_head_side.png","mcBbed_head_side.png",})      --type=Bed"26"
mcblocks.register_bed("Bed_Foot", {"mcBbed_feet_top.png","","","mcBbed_feet_end.png","mcBbed_feet_side.png","mcBbed_feet_side.png",})      --type=Bed"26"

mcblocks.register_rail("Powered_rails", {"mcBrail_detector.png","mcBrail_detector.png","mcBrail_detector.png","mcBrail_detector.png"}, "P")      --type=MinecartTracks"27:0-5"
mcblocks.register_rail("Powered_rails_powered", {"mcBrail_detector_powered.png","mcBrail_detector_powered.png","mcBrail_detector_powered.png","mcBrail_detector_powered.png"}, "P")      --type=MinecartTracks"27:8-11"
mcblocks.register_rail("Detector_rails", {"mcBrail_detector.png","mcBrail_detector.png","mcBrail_detector.png","mcBrail_detector.png"}, "D")      --type=MinecartTracks"28:0-5"
mcblocks.register_rail("Detector_rails_powered", {"mcBrail_detector_powered.png","mcBrail_detector_powered.png","mcBrail_detector_powered.png","mcBrail_detector_powered.png"}, "D")      --type=MinecartTracks"28:8-11"

-- see below (@ ID 33) for piston code

mcblocks.register_plant("Cobweb", {"mcBweb.png"})		--type=Plant"30"
mcblocks.register_plant("TallGrass_Shrub", {"mcBdeadbush.png"})     --type=TallGrass"31:0"
mcblocks.register_plant("TallGrass", {"mcBtallgrass.png"})     --type=TallGrass"31:1"
mcblocks.register_plant("TallGrass_Fern", {"mcBfern.png"})     --type=TallGrass"31:2"
mcblocks.register_plant("Dead_Shrub", {"mcBdeadbush.png"})		--type=Plant"32"




function mcblocks.register_piston(subname)
    local topImg, nbVertices

    bottomImg = "mcBpiston_bottom.png"
    if not (subname:find("Sticky") == nil) then
        topImg = "mcBpiston_top_sticky.png"
    else
        topImg = "mcBpiston_top_normal.png"
    end

    if not (subname:find("Out") == nil) then
        topImg = "mcBpiston_inner.png"
        nbVertices = {{-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},       -- base
                     {-0.15, 0.25, -0.15, 0.15, 0.5, 0.15}}    -- shaft
    elseif not (subname:find("Retracted") == nil) then
        nbVertices = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}       -- retracted
    elseif not (subname:find("Head") == nil) then
        bottomImg = "mcBpiston_inner.png"
        nbVertices = {{-0.15, -0.5, -0.15, 0.15, 0.25, 0.15},    -- shaft
                     {-0.5, 0.25, -0.5, 0.5, 0.5, 0.5}}       -- plate
    end



    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = {topImg,bottomImg,"mcBpiston_side.png","mcBpiston_side.png","mcBpiston_side.png","mcBpiston_side.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
--      groups = groups,
--      sounds = sounds,
        node_box = {
            type = "fixed",
            fixed = nbVertices
        },
    })
end

mcblocks.register_piston("Sticky_Piston_Retracted")        --type=PistonBase"29"pistonFace="mcBpiston_inner.png"
mcblocks.register_piston("Sticky_Piston_Out")        --type=PistonBase"29"pistonFace="mcBpiston_inner.png"

mcblocks.register_piston("Piston_Retracted")     --type=PistonBase"33"
mcblocks.register_piston("Piston_Out")
mcblocks.register_piston("Piston_Head")
mcblocks.register_piston("Piston_Head_Sticky")

---- Various wool colours --
minetest.register_node("mcblocks:White_wool", {tiles = {"mcBwool_colored_white.png",},})		--type=Solid"35:0"
minetest.register_node("mcblocks:Orange_wool", {tiles = {"mcBwool_colored_orange.png",},})		--type=Solid"35:1"
minetest.register_node("mcblocks:Magenta_wool", {tiles = {"mcBwool_colored_magenta.png",},})		--type=Solid"35:2"
minetest.register_node("mcblocks:Light_Blue_wool", {tiles = {"mcBwool_colored_light_blue.png",},})		--type=Solid"35:3"
minetest.register_node("mcblocks:Yellow_wool", {tiles = {"mcBwool_colored_yellow.png",},})		--type=Solid"35:4"
minetest.register_node("mcblocks:Lime_wool", {tiles = {"mcBwool_colored_lime.png",},})		--type=Solid"35:5"
minetest.register_node("mcblocks:Pink_wool", {tiles = {"mcBwool_colored_pink.png",},})		--type=Solid"35:6"
minetest.register_node("mcblocks:Gray_wool", {tiles = {"mcBwool_colored_gray.png",},})		--type=Solid"35:7"
minetest.register_node("mcblocks:Silver_wool", {tiles = {"mcBwool_colored_silver.png",},})		--type=Solid"35:8"
minetest.register_node("mcblocks:Cyan_wool", {tiles = {"mcBwool_colored_cyan.png",},})		--type=Solid"35:9"
minetest.register_node("mcblocks:Purple_wool", {tiles = {"mcBwool_colored_purple.png",},})		--type=Solid"35:10"
minetest.register_node("mcblocks:Blue_wool", {tiles = {"mcBwool_colored_blue.png",},})		--type=Solid"35:11"
minetest.register_node("mcblocks:Brown_wool", {tiles = {"mcBwool_colored_brown.png",},})		--type=Solid"35:12"
minetest.register_node("mcblocks:Green_wool", {tiles = {"mcBwool_colored_green.png",},})		--type=Solid"35:13"
minetest.register_node("mcblocks:Red_wool", {tiles = {"mcBwool_colored_red.png",},})		--type=Solid"35:14"
minetest.register_node("mcblocks:Black_wool", {tiles = {"mcBwool_colored_black.png",},})		--type=Solid"35:15"

minetest.register_node("mcblocks:Piston_Moving", {tiles = {"mcblocks.png"},})			---- id 36 block moved by piston

---- Small flowers --
mcblocks.register_plant("Dandelion", {"mcBflower_dandelion.png"})		--type=Plant"37"
mcblocks.register_plant("Poppy", {"mcBflower_rose.png"})			--type=Plant"38:0"
mcblocks.register_plant("Blue", {"mcBflower_blue_orchid.png"})		--type=Plant"38:1"
mcblocks.register_plant("Allium", {"mcBflower_allium.png"})		--type=Plant"38:2"
mcblocks.register_plant("Azure_Bluet", {"mcBflower_houstonia.png"})	--type=Plant"38:3"
mcblocks.register_plant("Red_Tulip", {"mcBflower_tulip_red.png"})		--type=Plant"38:4"
mcblocks.register_plant("Orange_Tulip", {"mcBflower_tulip_orange.png"})	--type=Plant"38:5"
mcblocks.register_plant("White_Tulip", {"mcBflower_tulip_white.png"})	--type=Plant"38:6"
mcblocks.register_plant("Pink_Tulip", {"mcBflower_tulip_pink.png"})	--type=Plant"38:7"
mcblocks.register_plant("Oxeye_Daisy", {"mcBflower_oxeye_daisy.png"})	--type=Plant"38:8"
mcblocks.register_plant("Brown_Mushroom", {"mcBmushroom_brown.png"})	--type=Plant"39"
mcblocks.register_plant("Red_Mushroom", {"mcBmushroom_red.png"})		--type=Plant"40"

minetest.register_node("mcblocks:Gold_Block", {tiles = {"mcBgold_block.png",},})		--type=Solid"41"
minetest.register_node("mcblocks:Iron_Block", {tiles = {"mcBiron_block.png",},})		--type=Solid"42"
minetest.register_node("mcblocks:Stone_Double_Slab", {tiles = {"mcBstone_slab_top.png","mcBstone_slab_top.png","mcBstone_slab_side.png","mcBstone_slab_side.png","mcBstone_slab_side.png","mcBstone_slab_side.png",},})		--type=Solid"43:0"
minetest.register_node("mcblocks:Sandstone_Double_Slab", {tiles = {"mcBsandstone_top.png","mcBsandstone_top.png","mcBsandstone_normal.png","mcBsandstone_normal.png","mcBsandstone_normal.png","mcBsandstone_normal.png",},})		--type=Solid"43:1"
minetest.register_node("mcblocks:Wooden_Double_Slab", {tiles = {"mcBplanks_oak.png",},})		--type=Solid"43:2"
minetest.register_node("mcblocks:Cobblestone_Double_Slab", {tiles = {"mcBcobblestone.png",},})		--type=Solid"43:3"
minetest.register_node("mcblocks:Brick_Double_Slab", {tiles = {"mcBbrick.png",},})		--type=Solid"43:4"
minetest.register_node("mcblocks:Stone_Brick_Double_Slab", {tiles = {"mcBstonebrick.png",},})		--type=Solid"43:5"
minetest.register_node("mcblocks:Nether_Brick_Double_Slab", {tiles = {"mcBnether_brick.png",},})		--type=Solid"43:6"
minetest.register_node("mcblocks:Quartz_Double_Slab", {tiles = {"mcBquartz_block_top.png",},})		--type=Solid"43:7"

--Half height 'slabs'
--minetest.register_node("mcblocks:Stone_Slab", {tiles = {"mcBstone_slab_top.png","mcBstone_slab_top.png","mcBstone_slab_side.png","mcBstone_slab_side.png","mcBstone_slab_side.png","mcBstone_slab_side.png",},})		--type=Slab"44:0"
mcblocks.register_slab("Stone", {"mcBstone_slab_side.png"}, "")		--type=Slab"44:0"
--minetest.register_node("mcblocks:Sandstone_Slab", {tiles = {"mcBsandstone_top.png","mcBsandstone_top.png","mcBsandstone_normal.png","mcBsandstone_normal.png","mcBsandstone_normal.png","mcBsandstone_normal.png",},})		--type=Slab"44:1"
mcblocks.register_slab("Sandstone", {"mcBsandstone_normal.png"}, "")	--type=Slab"44:1"
mcblocks.register_slab("Wooden", {"mcBplanks_oak.png"}, "w")		--type=Slab"44:2"
mcblocks.register_slab("Cobblestone", {"mcBcobblestone.png"}, "")		--type=Slab"44:3"
mcblocks.register_slab("Brick", {"mcBbrick.png"}, "")			--type=Slab"44:4"
mcblocks.register_slab("Stone_Brick", {"mcBstonebrick.png"}, "")		--type=Slab"44:5"
mcblocks.register_slab("Nether_Brick", {"mcBnether_brick.png"}, "")	--type=Slab"44:6"
mcblocks.register_slab("Quartz", {"mcBquartz_block_top.png"}, "")		--type=Slab"44:7"

minetest.register_node("mcblocks:Brick", {tiles = {"mcBbrick.png",},})		--type=Solid"45"
minetest.register_node("mcblocks:TNT", {tiles = {"mcBtnt_top.png","mcBtnt_top.png","mcBtnt_side.png","mcBtnt_side.png","mcBtnt_side.png","mcBtnt_side.png",},})		--type=Solid"46"
minetest.register_node("mcblocks:Bookshelf", {tiles = {"mcBplanks_oak.png","mcBplanks_oak.png","mcBbookshelf.png","mcBbookshelf.png","mcBbookshelf.png","mcBbookshelf.png",},})		--type=Solid"47"
minetest.register_node("mcblocks:Mossy_Cobblestone", {tiles = {"mcBcobblestone_mossy.png",},})		--type=Solid"48"
minetest.register_node("mcblocks:Obsidian", {tiles = {"mcBobsidian.png",},})		--type=Solid"49"
minetest.register_node("mcblocks:Torch", {           --type=Torch"50"
    description = "Torch",
    drawtype = "torchlike",
    tiles = {{
        name="mcBtorch_on.png",
        animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
    }},
    inventory_image = "mcBtorch_on.png",
    light_source = 14,
    drop = '',
    walkable = false,
    buildable_to = true,
})


minetest.register_node("mcblocks:Fire", {			--type=Fire"51"
	description = "Fire",
	drawtype = "firelike",
	tiles = {{
		name="mcBfire_layer_0.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
	}},
	inventory_image = "mcBfire_layer_0.png",
	light_source = 14,
	drop = '',
	walkable = false,
	buildable_to = true,
})

minetest.register_node("mcblocks:Mob_Spawner", {tiles = {"mcBmob_spawner.png",},})		--type=Solid"52"
mcblocks.register_stair("Oak_Wooden", {"mcBplanks_oak.png"}, "w")		--type=Stairs"53"

minetest.register_node("mcblocks:Chest", {tiles = {"mcEChnormal.png"},})		--type=Chest"54"


function mcblocks.register_Redstone_Wire(subname, images)
    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.49, -0.5, 0.5, -0.49, 0.5},
        },
        paramtype = "light",
        paramtype2 = "facedir",
        tiles = {images,images,"","","","",},
    })
end

mcblocks.register_Redstone_Wire("Redstone_Wire", "mcBredstone_dust_cross.png")
mcblocks.register_Redstone_Wire("Redstone_Wire_offJunction", "mcBredstone_dust_cross.png")
mcblocks.register_Redstone_Wire("Redstone_Wire_onJunction", "mcBredstone_dust_cross.png")
mcblocks.register_Redstone_Wire("Redstone_Wire_offLine", "mcBredstone_dust_line.png")
mcblocks.register_Redstone_Wire("Redstone_Wire_onLine", "mcBredstone_dust_line.png")

minetest.register_node("mcblocks:Diamond_Ore", {tiles = {"mcBdiamond_ore.png",},})		--type=Solid"56"
minetest.register_node("mcblocks:Diamond_Block", {tiles = {"mcBdiamond_block.png",},})		--type=Solid"57"
minetest.register_node("mcblocks:Workbench", {tiles = {"mcBcrafting_table_top.png","mcBcrafting_table_top.png","mcBcrafting_table_side.png","mcBcrafting_table_side.png","mcBcrafting_table_front.png","mcBcrafting_table_side.png",},})		--type=Workbench"58"
mcblocks.register_crop("Wheat0", {"mcBwheat_stage_0.png"})		--type= Crops"59"
mcblocks.register_crop("Wheat1", {"mcBwheat_stage_1.png"})		--type= Crops"59"
mcblocks.register_crop("Wheat2", {"mcBwheat_stage_2.png"})		--type= Crops"59"
mcblocks.register_crop("Wheat3", {"mcBwheat_stage_3.png"})		--type= Crops"59"
mcblocks.register_crop("Wheat4", {"mcBwheat_stage_4.png"})		--type= Crops"59"
mcblocks.register_crop("Wheat5", {"mcBwheat_stage_5.png"})		--type= Crops"59"
mcblocks.register_crop("Wheat6", {"mcBwheat_stage_6.png"})		--type= Crops"59"
mcblocks.register_crop("Wheat7", {"mcBwheat_stage_7.png"})		--type= Crops"59"

minetest.register_node("mcblocks:Farmland_Dry", {tiles = {"mcBfarmland_dry.png","mcBfarmland_dry.png","mcBdirt.png","mcBdirt.png","mcBdirt.png","mcBdirt.png",},})		--type=Soil"60"
minetest.register_node("mcblocks:Farmland_Wet", {tiles = {"mcBfarmland_wet.png","mcBfarmland_wet.png","mcBdirt.png","mcBdirt.png","mcBdirt.png","mcBdirt.png",},})		--type=Soil"60"

minetest.register_node("mcblocks:Furnace", {tiles = {"mcBfurnace_top.png","mcBfurnace_top.png","mcBfurnace_side.png","mcBfurnace_side.png","mcBfurnace_front_off.png","mcBfurnace_side.png",},})		--type=Furnace"61"
minetest.register_node("mcblocks:Furnace_Smelting", {tiles = {"mcBfurnace_top.png","mcBfurnace_top.png","mcBfurnace_side.png","mcBfurnace_side.png","mcBfurnace_front_on.png","mcBfurnace_side.png",},})		--type=Furnace"62"
minetest.register_node("mcblocks:Sign_Standing", {tiles = {"mcBplanks_oak.png",},})		--type=Sign"63"

mcblocks.register_door("Wooden_Door_Bottom_Closed", "mcBdoor_wood_lower.png", "mcBplanks_spruce.png")       --type=Door"64"
mcblocks.register_door("Wooden_Door_Bottom_Open", "mcBdoor_wood_lower.png", "mcBplanks_spruce.png")       --type=Door"64"
mcblocks.register_door("Wooden_Door_Top_HingeRight", "mcBdoor_wood_upper.png", "mcBplanks_spruce.png")       --type=Door"64"
mcblocks.register_door("Wooden_Door_Top_HingeLeft", "mcBdoor_wood_upper.png", "mcBplanks_spruce.png")       --type=Door"64"


-- Unfortunately default doesn't expose it's method with a function, so it's copied here...
minetest.register_node("mcblocks:Ladder", {		--type=Ladder"65"
	description = "Ladder",
	drawtype = "signlike",
	tiles = {"mcBladder.png",},
	inventory_image = "mcBladder.png",
	wield_image = "mcBladder.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy=2,oddly_breakable_by_hand=3,flammable=2},
	legacy_wallmounted = true,
	sounds = default.node_sound_wood_defaults(),
})


mcblocks.register_rail("Rail", {"mcBrail_normal.png","mcBrail_normal.png","mcBrail_normal_turned.png","mcBrail_normal.png"}, "")      --type=MinecartTracks"66"
mcblocks.register_stair("Cobblestone", {"mcBcobblestone.png"}, "w")		--type=Stairs"67"

minetest.register_node("mcblocks:Wall_Sign", {tiles = {"mcBplanks_oak.png",},})		--type=Sign"68"
mcblocks.register_lever("Lever", "mcBcobblestone.png")       --type=Lever"69"lever="lever.png"base="mcBcobblestone.png"

mcblocks.register_door("Iron_Door", "mcBdoor_iron_lower.png", "mcBiron_block.png")       --type=Door"71"
mcblocks.register_door("Iron_Door_Bottom_Closed", "mcBdoor_iron_lower.png", "mcBiron_block.png")       --type=Door"71"
mcblocks.register_door("Iron_Door_Bottom_Open", "mcBdoor_iron_lower.png", "mcBiron_block.png")       --type=Door"71"
mcblocks.register_door("Iron_Door_Top_HingeRight", "mcBdoor_iron_upper.png", "mcBiron_block.png")       --type=Door"71"
mcblocks.register_door("Iron_Door_Top_HingeLeft", "mcBdoor_iron_upper.png", "mcBiron_block.png")       --type=Door"71"



function mcblocks.register_pressurePlate(subname, image)
    -- NB wooden pressure plates can be triggered by having items dropped on them, whereas stone plates require a player or mob so stand on them
    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = {image,},
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
--      groups = groups,
--      sounds = sounds,
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.49, -0.5, 0.5, -0.39, 0.5},
        },
    })
end

mcblocks.register_pressurePlate("Stone_Pressure_Plate", "mcBstone.png")       --type=PressurePlate"70"
mcblocks.register_pressurePlate("Wooden_Pressure_Plate", "mcBplanks_oak.png")     --type=PressurePlate"72"


minetest.register_node("mcblocks:Redstone_Ore", {tiles = {"mcBredstone_ore.png",},})		--type=Solid"73"
minetest.register_node("mcblocks:Redstone_Ore_Glowing", {tiles = {"mcBredstone_ore.png",},})		--type=Solid"74"
minetest.register_node("mcblocks:Redstone_Torch_Off", {drawtype = "torchlike", paramtype = "light", tiles = {"mcBredstone_torch_off.png",},})		--type=Torch"75"
minetest.register_node("mcblocks:Redstone_Torch_On", {           --type=Torch"76"
    description = "Torch",
    drawtype = "torchlike",
    tiles = {{
        name="mcBredstone_torch_on.png",
        animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
    }},
    inventory_image = "mcBredstone_torch_on.png",
    light_source = 14,
    drop = '',
    walkable = false,
    buildable_to = true,
})

mcblocks.register_button("Stone_Button", "mcBstone.png")       --type=Button"77"

minetest.register_node("mcblocks:Snow", {tiles = {"mcBsnow.png",},})		--type=Snow"78"
minetest.register_node("mcblocks:Ice", {tiles = {"mcBice.png",},})		--type=Ice"79"
minetest.register_node("mcblocks:Snow_Block", {tiles = {"mcBsnow.png",},})		--type=Solid"80"
minetest.register_node("mcblocks:Cactus", {tiles = {"mcBcactus_top.png","mcBcactus_top.png","mcBcactus_side.png","mcBcactus_side.png","mcBcactus_side.png","mcBcactus_side.png",},})		--type=Cactus"81"
minetest.register_node("mcblocks:Clay_Block", {tiles = {"mcBclay.png",},})		--type=Solid"82"
mcblocks.register_plant("SugarCane_Block", {"mcBreeds.png"})		--type=Plant"83"
minetest.register_node("mcblocks:Jukebox", {tiles = {"mcBjukebox_top.png","mcBjukebox_top.png","mcBjukebox_side.png","mcBjukebox_side.png","mcBjukebox_side.png","mcBjukebox_side.png",},})		--type=Solid"84"


minetest.register_node("mcblocks:Oak_Fence", {tiles = {"mcBplanks_oak.png",},})		--type=Fence"85"


minetest.register_node("mcblocks:Pumpkin", {tiles = {"mcBpumpkin_top.png","mcBpumpkin_top.png","mcBpumpkin_side.png","mcBpumpkin_side.png","mcBpumpkin_face_off.png","mcBpumpkin_side.png",},})		--type=Pumpkin"86"
minetest.register_node("mcblocks:Netherrack", {tiles = {"mcBnetherrack.png",},})		--type=Solid"87"
minetest.register_node("mcblocks:SoulSand", {tiles = {"mcBsoul_sand.png",},})		--type=Solid"88"
minetest.register_node("mcblocks:Glowstone", {      		--type=Solid"89"
    description = "Glowstone",
    drawtype = "nodelike",
    tiles = {"mcBglowstone_top.png","mcBglowstone_top.png","mcBglowstone.png","mcBglowstone.png","mcBglowstone.png","mcBglowstone.png",},
    inventory_image = "mcBglowstone.png",
    light_source = 14,
    drop = '',
    walkable = false,
    buildable_to = true,
})


minetest.register_node("mcblocks:Portal", {tiles = {{name="mcBportal.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},}},light_source = 8,})		--type=Portal"90"

minetest.register_node("mcblocks:JackOLantern_On", {tiles = {"mcBpumpkin_top.png","mcBpumpkin_top.png","mcBpumpkin_side.png","mcBpumpkin_side.png","mcBpumpkin_face_on.png","mcBpumpkin_side.png",},})		--type=Pumpkin"91"
minetest.register_node("mcblocks:JackOLantern_Off", {tiles = {"mcBpumpkin_top.png","mcBpumpkin_top.png","mcBpumpkin_side.png","mcBpumpkin_side.png","mcBpumpkin_face_off.png","mcBpumpkin_side.png",},})
minetest.register_node("mcblocks:Cake", {tiles = {"mcBcake_top.png","mcBcake_top.png","mcBcake_side.png","mcBcake_side.png","mcBcake_side.png","mcBcake_side.png",},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
})		--interior="cake_inner.png"type=Cake"92"


function mcblocks.register_Redstone_Repeater(subname, TopImage, BaseImage, TorchImage)
    --TODO: add torches as switches
    if not (subname:find("Repeater") == nil) then
        nbVertices = {{-0.05, -0.4, 0.35, 0.05, -0.2, 0.25},         -- fixed torch
                      {-0.05, -0.4, -0.15, 0.05, -0.2, -0.05},       -- mobile torch
                      {-0.5,  -0.5, -0.5,   0.5, -0.4,  0.5 }}       -- base
    else
        nbVertices = {{-0.225, -0.4, -0.3, -0.125, -0.2, -0.2},         -- base torch1
                      { 0.125, -0.4, -0.3,  0.225, -0.2, -0.2},       -- base torch2
                      {-0.05, -0.3, 0.25, 0.05, -0.2, 0.35},       -- output torch2
                      {-0.5,  -0.5, -0.5,   0.5, -0.4,  0.5 }}       -- base
    end

    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = {TopImage, BaseImage, BaseImage, BaseImage, BaseImage, BaseImage,},
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
--      groups = groups,
--      sounds = sounds,
        node_box = {
            type = "fixed",
            fixed = nbVertices,
        },
    })
end

mcblocks.register_Redstone_Repeater("Redstone_Repeater_Off", "mcBrepeater_off.png","mcBstone_slab_top.png","mcBredstone_torch_off.png")		--type=RedstoneRepeater"93"
mcblocks.register_Redstone_Repeater("Redstone_Repeater_On",  "mcBrepeater_on.png", "mcBstone_slab_top.png","mcBredstone_torch_on.png")		--type=RedstoneRepeater"94"
mcblocks.register_Redstone_Repeater("Redstone_Comparator_Off", "mcBcomparator_off.png","mcBstone_slab_top.png","mcBredstone_torch_off.png")       --type=RedstoneRepeater"149"
mcblocks.register_Redstone_Repeater("Redstone_Comparator_On", "mcBcomparator_on.png","mcBstone_slab_top.png","mcBredstone_torch_on.png")       --type=RedstoneRepeater"149"


mcblocks.register_glass("White_Stained_Glass", {"mcBglass_white.png"})		--type=Glass"95:0"
mcblocks.register_glass("Orange_Stained_Glass", {"mcBglass_orange.png"})		--type=Glass"95:1"
mcblocks.register_glass("Magenta_Stained_Glass", {"mcBglass_magenta.png"})		--type=Glass"95:2"
mcblocks.register_glass("Light_Blue_Stained_Glass", {"mcBglass_light_blue.png"})		--type=Glass"95:3"
mcblocks.register_glass("Yellow_Stained_Glass", {"mcBglass_yellow.png"})		--type=Glass"95:4"
mcblocks.register_glass("Lime_Stained_Glass", {"mcBglass_lime.png"})		--type=Glass"95:5"
mcblocks.register_glass("Pink_Stained_Glass", {"mcBglass_pink.png"})		--type=Glass"95:6"
mcblocks.register_glass("Gray_Stained_Glass", {"mcBglass_gray.png"})		--type=Glass"95:7"
mcblocks.register_glass("Silver_Stained_Glass", {"mcBglass_silver.png"})		--type=Glass"95:8"
mcblocks.register_glass("Cyan_Stained_Glass", {"mcBglass_cyan.png"})		--type=Glass"95:9"
mcblocks.register_glass("Purple_Stained_Glass", {"mcBglass_purple.png"})		--type=Glass"95:10"
mcblocks.register_glass("Blue_Stained_Glass", {"mcBglass_blue.png"})		--type=Glass"95:11"
mcblocks.register_glass("Brown_Stained_Glass", {"mcBglass_brown.png"})		--type=Glass"95:12"
mcblocks.register_glass("Green_Stained_Glass", {"mcBglass_green.png"})		--type=Glass"95:13"
mcblocks.register_glass("Red_Stained_Glass", {"mcBglass_red.png"})		--type=Glass"95:14"
mcblocks.register_glass("Black_Stained_Glass", {"mcBglass_black.png"})		--type=Glass"95:15"
mcblocks.register_trapdoor("Trapdoor", "mcBtrapdoor.png", "mcBplanks_spruce.png")		--type=Trapdoor"96"

minetest.register_node("mcblocks:Hidden_Silverfish_Stone", {tiles = {"mcBstone.png",},})		--type=DataSolid"97"
minetest.register_node("mcblocks:Hidden_Silverfish_Cobblestone", {tiles = {"mcBcobblestone.png",},})	--type=DataSolid"97"
minetest.register_node("mcblocks:Hidden_Silverfish_StoneBrick", {tiles = {"mcBstonebrick.png",},})		--type=DataSolid"97"
minetest.register_node("mcblocks:Hidden_Silverfish_MossyStoneBrick", {tiles = {"mcBstonebrick_mossy.png",},})	--type=DataSolid"97"
minetest.register_node("mcblocks:Hidden_Silverfish_CrackedStone", {tiles = {"mcBstonebrick_cracked.png",},})	--type=DataSolid"97"
minetest.register_node("mcblocks:Hidden_Silverfish_ChiseledStone", {tiles = {"mcBstonebrick_carved.png",},})	--type=DataSolid"97"

minetest.register_node("mcblocks:Stone_Brick", {tiles = {"mcBstonebrick.png",},})		--type=DataSolid"98"
minetest.register_node("mcblocks:Mossy_Stone_Brick", {tiles = {"mcBstonebrick_mossy.png",},})	--type=DataSolid"98"
minetest.register_node("mcblocks:Cracked_Stone_Brick", {tiles = {"mcBstonebrick_cracked.png",},})	--type=DataSolid"98"
minetest.register_node("mcblocks:Chiseled_Stone_Brick", {tiles = {"mcBstonebrick_carved.png",},})	--type=DataSolid"98"


minetest.register_node("mcblocks:Huge_Brown_Mushroom_cap", {tiles = {"mcBmushroom_block_skin_brown.png"},})        --type=HugeMushroom"99"
minetest.register_node("mcblocks:Huge_Brown_Mushroom_pores", {tiles = {"mcBmushroom_block_inside.png"},})
minetest.register_node("mcblocks:Huge_Brown_Mushroom_stem", {tiles = {"mcBmushroom_block_skin_stem.png"},})
minetest.register_node("mcblocks:Huge_Red_Mushroom_cap", {tiles = {"mcBmushroom_block_skin_red.png"},})        --type=HugeMushroom"100"
minetest.register_node("mcblocks:Huge_Red_Mushroom_pores", {tiles = {"mcBmushroom_block_inside.png"},})
minetest.register_node("mcblocks:Huge_Red_Mushroom_stem", {tiles = {"mcBmushroom_block_skin_stem.png"},})


minetest.register_node("mcblocks:Iron_Bars", {drawtype = "allfaces_optional",tiles = {"mcBiron_bars.png",},})		--type=GlassPane"101"
mcblocks.register_glass("Glass_Pane", {"mcBglass.png",})		--type=GlassPane"102"
minetest.register_node("mcblocks:Melon", {tiles = {"mcBmelon_top.png","mcBmelon_top.png","mcBmelon_side.png","mcBmelon_side.png","mcBmelon_side.png","mcBmelon_side.png",},})		--type=Solid"103"

mcblocks.register_plant("Pumpkin_Stem0", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem1", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem2", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem3", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem4", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem5", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem6", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem7", {"mcBpumpkin_stem_disconnected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Pumpkin_Stem_Bent", {"mcBpumpkin_stem_connected.png",})        --type=FruitStem"104"fruitId="86"
mcblocks.register_plant("Melon_Stem0", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem1", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem2", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem3", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem4", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem5", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem6", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem7", {"mcBmelon_stem_disconnected.png",})      --type=FruitStem"105"fruitId="103"
mcblocks.register_plant("Melon_Stem_Bent", {"mcBmelon_stem_connected.png",})      --type=FruitStem"105"fruitId="103"

-- This uses the default ladder code. Ultimately could be remade to follow the vines rules (spreading etc)
minetest.register_node("mcblocks:Vines", {     --type=Vines"106"
    description = "Vines",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.49, -0.5, 0.5, -0.49, 0.5},
    },
    paramtype = "light",
    paramtype2 = "facedir",
    tiles = {"mcBvine.png","mcBvine.png","","","","",},
    inventory_image = "mcBvine.png",
    wield_image = "mcBvine.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    walkable = true,
    climbable = true,
    is_ground_content = false,
    groups = {choppy=2,oddly_breakable_by_hand=3,flammable=2},
    sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("mcblocks:Oak_Fence_Gate", {tiles = {"mcBplanks_oak.png",},})		--type=FenceGate"107"
mcblocks.register_stair("Brick", {"mcBbrick.png"}, "")		--type=Stairs"108"
mcblocks.register_stair("Stone_Brick", {"mcBstonebrick.png"}, "")		--type=Stairs"109"
minetest.register_node("mcblocks:Mycelium", {tiles = {"mcBmycelium_top.png","mcBmycelium_top.png","mcBmycelium_side.png","mcBmycelium_side.png","mcBmycelium_side.png","mcBmycelium_side.png",},})		--type=Solid"110"
minetest.register_node("mcblocks:Lily_Pad", {       --type=Lilly"111"
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.49, -0.5, 0.5, -0.49, 0.5},
    },
    paramtype = "light",
    paramtype2 = "facedir",
    tiles = {"mcBwaterlily.png","mcBwaterlily.png","","","","",},
})


minetest.register_node("mcblocks:Nether_Brick", {tiles = {"mcBnether_brick.png",},})		--type=Solid"112"
minetest.register_node("mcblocks:Nether_Brick_Fence", {tiles = {"mcBnether_brick.png",},})		--type=Fence"113"
mcblocks.register_stair("Nether_Brick", {"mcBnether_brick.png"}, "")	--type=Stairs"114"


mcblocks.register_crop("Nether_Wart0", {"mcBnether_wart_stage_0.png"})		--type=NetherWart"115"
mcblocks.register_crop("Nether_Wart1", {"mcBnether_wart_stage_0.png"})		--type=NetherWart"115"
mcblocks.register_crop("Nether_Wart2", {"mcBnether_wart_stage_1.png"})		--type=NetherWart"115"

minetest.register_node("mcblocks:Enchantment_Table", {      --type=EnchantmentTable"116"book="entity_enchanting_table_book.png"
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
    },
    tiles ={{name="mcBenchanting_table_top.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBenchanting_table_top.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBenchanting_table_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBenchanting_table_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBenchanting_table_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBenchanting_table_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            },
    light_source = 8,
})

minetest.register_node("mcblocks:Brewing_Stand", {                  --base="brewing_stand_base.png"type=BrewingStand"117"
    tiles = {{name="mcBbrewing_stand.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},}},
    light_source = 8,
})

minetest.register_node("mcblocks:Cauldron", {tiles = {"mcBcauldron_top.png","mcBcauldron_inner.png","mcBcauldron_side.png","mcBcauldron_side.png","mcBcauldron_side.png","mcBcauldron_side.png",},})		--type=Cauldron"118"water="water_still.png"
minetest.register_node("mcblocks:EnderPortal", {tiles = {"mcEend_portal.png",},})		--type=EnderPortal"119"
minetest.register_node("mcblocks:End_Portal_Frame", {		--type=EnderPortalFrame"120"mcBendframe_eye.png"
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
    },
    tiles ={{name="mcBendframe_top.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBendframe_top.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBendframe_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBendframe_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBendframe_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            {name="mcBendframe_side.png",animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},},
            },
    light_source = 8,
})



minetest.register_node("mcblocks:End_Stone", {tiles = {"mcBend_stone.png",},})		--type=Solid"121"
minetest.register_node("mcblocks:Dragon_Egg", {tiles = {"mcBdragon_egg.png",},})		--type=DragonEgg"122"
minetest.register_node("mcblocks:Redstone_Lamp_off", {tiles = {"mcBredstone_lamp_off.png",},})		--type=Solid"123"
minetest.register_node("mcblocks:Redstone_Lamp_on", {       --type=Solid"124"
    description = "Redstone Lamp",
    drawtype = "nodelike",
    tiles = {"mcBredstone_lamp_on.png",},
    inventory_image = "mcBredstone_lamp_on.png",
    light_source = 14,
    drop = '',
    walkable = false,
    buildable_to = true,
})

minetest.register_node("mcblocks:Oak_Wood_Double_Slab", {tiles = {"mcBplanks_oak.png",},})		--type=Solid"125:0"
minetest.register_node("mcblocks:Spruce_Wood_Double_Slab", {tiles = {"mcBplanks_spruce.png",},})		--type=Solid"125:1"
minetest.register_node("mcblocks:Birch_Wood_Double_Slab", {tiles = {"mcBplanks_birch.png",},})		--type=Solid"125:2"
minetest.register_node("mcblocks:Jungle_Wood_Double_Slab", {tiles = {"mcBplanks_jungle.png",},})		--type=Solid"125:3"
minetest.register_node("mcblocks:Acacia_Wood_Double_Slab", {tiles = {"mcBplanks_acacia.png",},})		--type=Solid"125:4"
minetest.register_node("mcblocks:Dark_Oak_Wood_Double_Slab", {tiles = {"mcBplanks_big_oak.png",},})		--type=Solid"125:5"

--Slabs
mcblocks.register_slab("Oak_Wood", {"mcBplanks_oak.png"}, "w")			--type=Slab"126:0"
mcblocks.register_slab("Spruce_Wood", {"mcBplanks_spruce.png"}, "w")			--type=Slab"126:1"
mcblocks.register_slab("Birch_Wood", {"mcBplanks_birch.png"}, "w")			--type=Slab"126:2"
mcblocks.register_slab("Jungle_Wood", {"mcBplanks_jungle.png"}, "w")			--type=Slab"126:3"
mcblocks.register_slab("Acacia_Wood", {"mcBplanks_acacia.png"}, "w")			--type=Slab"126:4"
mcblocks.register_slab("Dark_Oak_Wood", {"mcBplanks_big_oak.png"}, "w")			--type=Slab"126:5"

mcblocks.register_crop("Cocoa_Pod0", {"mcBcocoa_stage_0.png"})		--type=CocoaPod"127"
mcblocks.register_crop("Cocoa_Pod1", {"mcBcocoa_stage_1.png"})		--type=CocoaPod"127"
mcblocks.register_crop("Cocoa_Pod2", {"mcBcocoa_stage_2.png"})		--type=CocoaPod"127"

mcblocks.register_stair("Sandstone", {"mcBsandstone_normal.png"}, "")		--type=Stairs"128"

minetest.register_node("mcblocks:Emerald_Ore", {tiles = {"mcBemerald_ore.png",},})		--type=Solid"129"
minetest.register_node("mcblocks:Ender_Chest", {tiles = {"mcEChender.png"},})		--type=Chest"130"
minetest.register_node("mcblocks:Tripwire_Hook", {drawtype = "plantlike", tiles = {"mcBtrip_wire_source.png",},})		--type=TripwireHook"131"texture2="trip_wire_source.png"tripwire="trip_wire.png""planks_oak.png"
minetest.register_node("mcblocks:Tripwire", {drawtype = "signlike", tiles = {"mcBtrip_wire.png",},})		--type=Tripwire"132"
minetest.register_node("mcblocks:Emerald_Block", {tiles = {"mcBemerald_block.png",},})		--type=Solid"133"
mcblocks.register_stair("Spruce_Wooden", {"mcBplanks_spruce.png"}, "w")		--type=Stairs"134"
mcblocks.register_stair("Birch_Wooden", {"mcBplanks_birch.png"}, "w")		--type=Stairs"135"
mcblocks.register_stair("Jungle_Wooden", {"mcBplanks_jungle.png"}, "w")		--type=Stairs"136"

minetest.register_node("mcblocks:Command_Block", {tiles = {"mcBcommand_block.png",},})		--type=Solid"137"
minetest.register_node("mcblocks:Beacon", {         --type=Beacon"138"glass="glass.png"beacon="beacon.png"obsidian="obsidian.png"beam="entity_beacon_beam.png"
    description = "Beacon",
    drawtype = "nodebox",
    tiles = {"mcBbeacon.png",},
    inventory_image = "mcBbeacon.png",
    node_box = {
        type = "fixed",
        fixed = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
    },
    light_source = 14,
    drop = '',
    walkable = false,
    buildable_to = true,
})

minetest.register_node("mcblocks:Cobblestone_Wall", {tiles = {"mcBcobblestone.png",},})		--type=Wall"139"
minetest.register_node("mcblocks:Mossy_Cobblestone_Wall", {tiles = {"mcBcobblestone_mossy.png",},})		--type=Wall"139:1"
mcblocks.register_plant("Flower_Pot", {"mcBflower_pot.png",})		--type=FlowerPot"140:0"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Rose", {"mcBflower_pot.png",})		--type=FlowerPot"140:1"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Yellow_Flower", {"mcBflower_pot.png",})		--type=FlowerPot"140:2"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Oak_Sapling", {"mcBflower_pot.png",})		--type=FlowerPot"140:3"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Spruce_Sapling", {"mcBflower_pot.png",})		--type=FlowerPot"140:4"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Birch_Sapling", {"mcBflower_pot.png",})		--type=FlowerPot"140:5"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Jungle_Sapling", {"mcBflower_pot.png",})		--type=FlowerPot"140:6"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Red_Mushroom", {"mcBflower_pot.png",})		--type=FlowerPot"140:7"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Brown_Mushroom", {"mcBflower_pot.png",})		--type=FlowerPot"140:8"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Cactus", {"mcBflower_pot.png",})		--type=FlowerPot"140:9"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Dead_Bush", {"mcBflower_pot.png",})		--type=FlowerPot"140:10"dirt="dirt.png"
mcblocks.register_plant("Flower_Pot_Fern", {"mcBflower_pot.png",})		--type=FlowerPot"140:11"dirt="dirt.png"
mcblocks.register_crop("Carrots0", {"mcBcarrots_stage_0.png"})		--type= Crops"141"
mcblocks.register_crop("Carrots1", {"mcBcarrots_stage_0.png"})		--type= Crops"141"
mcblocks.register_crop("Carrots2", {"mcBcarrots_stage_1.png"})		--type= Crops"141"
mcblocks.register_crop("Carrots3", {"mcBcarrots_stage_1.png"})		--type= Crops"141"
mcblocks.register_crop("Carrots4", {"mcBcarrots_stage_2.png"})		--type= Crops"141"
mcblocks.register_crop("Carrots5", {"mcBcarrots_stage_2.png"})		--type= Crops"141"
mcblocks.register_crop("Carrots6", {"mcBcarrots_stage_2.png"})		--type= Crops"141"
mcblocks.register_crop("Carrots7", {"mcBcarrots_stage_3.png"})		--type= Crops"141"

mcblocks.register_crop("Potatoes0", {"mcBpotatoes_stage_0.png"})		--type= Crops"142"
mcblocks.register_crop("Potatoes1", {"mcBpotatoes_stage_0.png"})		--type= Crops"142"
mcblocks.register_crop("Potatoes2", {"mcBpotatoes_stage_1.png"})		--type= Crops"142"
mcblocks.register_crop("Potatoes3", {"mcBpotatoes_stage_1.png"})		--type= Crops"142"
mcblocks.register_crop("Potatoes4", {"mcBpotatoes_stage_2.png"})		--type= Crops"142"
mcblocks.register_crop("Potatoes5", {"mcBpotatoes_stage_2.png"})		--type= Crops"142"
mcblocks.register_crop("Potatoes6", {"mcBpotatoes_stage_2.png"})		--type= Crops"142"
mcblocks.register_crop("Potatoes7", {"mcBpotatoes_stage_3.png"})		--type= Crops"142"

mcblocks.register_button("Wooden_Button", "mcBplanks_oak.png")       --type=Button"143"

minetest.register_node("mcblocks:Head_Block", {tiles = {"mcESkskeleton.png"},})          --type=Skull"144"
minetest.register_node("mcblocks:Head_Block_Skeleton", {tiles = {"mcESkskeleton.png"},})     --type=Skull"144"
minetest.register_node("mcblocks:Head_Block_Wither", {tiles = {"mcESkwither_skeleton.png"},})       --type=Skull"144"
minetest.register_node("mcblocks:Head_Block_Zombie", {tiles = {"mcEZozombie.png"},})       --type=Skull"144"
minetest.register_node("mcblocks:Head_Block_Steve", {tiles = {"mcEsteve.png"},})        --type=Skull"144"
minetest.register_node("mcblocks:Head_Block_Creeper", {tiles = {"mcESkcreeper.png"},})      --type=Skull"144"


function mcblocks.register_anvil(subname, imageTB)                 --base="anvil_base.png"type=Anvil"145"
    local imageSide = "mcBanvil_base.png"
    local images = {imageTB,imageTB,imageSide,imageSide,imageSide,imageSide,}

    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = images,
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
--      groups = groups,
--      sounds = sounds,
        node_box = {
            type = "fixed",
            fixed = {{-0.3, 0.25,-0.5, 0.3, 0.5, 0.5},      -- {x1, y1, z1, x2, y2, z2}
                     {-0.2,-0.2, -0.3, 0.2, 0.25,0.3},
                     {-0.3,-0.3, -0.4, 0.3,-0.2, 0.4},
                     {-0.5,-0.5, -0.5, 0.5,-0.3, 0.5},
            },
        },
    })
end

mcblocks.register_anvil("Anvil0", "mcBanvil_top_damaged_0.png")
mcblocks.register_anvil("Anvil1", "mcBanvil_top_damaged_1.png")
mcblocks.register_anvil("Anvil2", "mcBanvil_top_damaged_2.png")

minetest.register_node("mcblocks:Trapped_Chest", {tiles = {"mcEChtrapped.png"},})		--type=Chest"146"
minetest.register_node("mcblocks:Gold_Pressure_Plate", {tiles = {"mcBgold_block.png",},})		--type=PressurePlate"147"
minetest.register_node("mcblocks:Iron_Pressure_Plate", {tiles = {"mcBiron_block.png",},})		--type=PressurePlate"148"

-- for redstone comparator see code at location #93

function mcblocks.register_lightSensor(subname, imageTop, imageSide)
    -- NB wooden pressure plates can be triggered by having items dropped on them, whereas stone plates require a player or mob so stand on them
    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = {imageTop,imageTop,imageSide,imageSide,imageSide,imageSide},
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = true,
--      groups = groups,
--      sounds = sounds,
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.49, -0.5, 0.5, -0.19, 0.5},
        },
    })
end

mcblocks.register_lightSensor("Daylight_Sensor", "mcBdaylight_detector_top.png", "mcBdaylight_detector_side.png") --type=DaylightSensor"151"
mcblocks.register_lightSensor("Inverted_Daylight_Sensor", "mcBdaylight_detector_inverted_top.png","mcBdaylight_detector_side.png")      --type=DaylightSensor"178"



minetest.register_node("mcblocks:Redstone_Block", {tiles = {"mcBredstone_block.png",},})		--type=Solid"152"
minetest.register_node("mcblocks:Nether_Quartz_Ore", {tiles = {"mcBquartz_ore.png",},})		--type=Solid"153"
minetest.register_node("mcblocks:Hopper", {tiles = {"mcBhopper_top.png","mcBhopper_top.png","mcBhopper_outside.png","mcBhopper_outside.png","mcBhopper_outside.png","mcBhopper_outside.png",},})		--type=Hopper"154"inside="hopper_inside.png"
minetest.register_node("mcblocks:Quartz_Block", {tiles = {"mcBquartz_block_top.png","mcBquartz_block_bottom.png","mcBquartz_block_side.png","mcBquartz_block_side.png","mcBquartz_block_side.png","mcBquartz_block_side.png",},})		--type=Solid"155:0"
minetest.register_node("mcblocks:Chiseled_Quartz_Block", {tiles = {"mcBquartz_block_chiseled_top.png","mcBquartz_block_chiseled_top.png","mcBquartz_block_chiseled.png","mcBquartz_block_chiseled.png","mcBquartz_block_chiseled.png","mcBquartz_block_chiseled.png",},})		--type=Solid"155:1"
minetest.register_node("mcblocks:Quartz_Pillar", {tiles = {"mcBquartz_block_lines_top.png","mcBquartz_block_lines_top.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png",},})		--type=Solid"155:2"
minetest.register_node("mcblocks:Quartz_Pillar_NorthSouth", {tiles = {"mcBquartz_block_lines_top.png","mcBquartz_block_lines_top.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png",},})		--type=Log"155:3"
minetest.register_node("mcblocks:Quartz_Pillar_EastWest", {tiles = {"mcBquartz_block_lines_top.png","mcBquartz_block_lines_top.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png","mcBquartz_block_lines.png",},})		--type=Log"155:4"
mcblocks.register_stair("Quartz", {"mcBquartz_block_top.png"}, "")		--type=Stairs"156"

mcblocks.register_rail("Activator_rails", {"mcBrail_activator.png","mcBrail_activator.png","mcBrail_activator.png","mcBrail_activator.png"}, "A")      --type=MinecartTracks"157:0-5"
mcblocks.register_rail("Activator_rails_powered", {"mcBrail_activator_powered.png","mcBrail_activator_powered.png","mcBrail_activator_powered.png","mcBrail_activator_powered.png"}, "A")      --type=MinecartTracks"157:8-11"

minetest.register_node("mcblocks:Dropper", {tiles = {"mcBfurnace_top.png","mcBfurnace_top.png","mcBfurnace_side.png","mcBfurnace_side.png","mcBdropper_front_horizontal.png","mcBfurnace_side.png",},})		--type=Dispenser"158"topBottom="dropper_front_vertical.png"
---- Various stained clay colours --
minetest.register_node("mcblocks:White_Stained_Clay", {tiles = {"mcBhardened_clay_stained_white.png",},})		--type=Solid"159:0"
minetest.register_node("mcblocks:Orange_Stained_Clay", {tiles = {"mcBhardened_clay_stained_orange.png",},})		--type=Solid"159:1"
minetest.register_node("mcblocks:Magenta_Stained_Clay", {tiles = {"mcBhardened_clay_stained_magenta.png",},})		--type=Solid"159:2"
minetest.register_node("mcblocks:Light_Blue_Stained_Clay", {tiles = {"mcBhardened_clay_stained_light_blue.png",},})		--type=Solid"159:3"
minetest.register_node("mcblocks:Yellow_Stained_Clay", {tiles = {"mcBhardened_clay_stained_yellow.png",},})		--type=Solid"159:4"
minetest.register_node("mcblocks:Lime_Stained_Clay", {tiles = {"mcBhardened_clay_stained_lime.png",},})		--type=Solid"159:5"
minetest.register_node("mcblocks:Pink_Stained_Clay", {tiles = {"mcBhardened_clay_stained_pink.png",},})		--type=Solid"159:6"
minetest.register_node("mcblocks:Gray_Stained_Clay", {tiles = {"mcBhardened_clay_stained_gray.png",},})		--type=Solid"159:7"
minetest.register_node("mcblocks:Silver_Stained_Clay", {tiles = {"mcBhardened_clay_stained_silver.png",},})		--type=Solid"159:8"
minetest.register_node("mcblocks:Cyan_Stained_Clay", {tiles = {"mcBhardened_clay_stained_cyan.png",},})		--type=Solid"159:9"
minetest.register_node("mcblocks:Purple_Stained_Clay", {tiles = {"mcBhardened_clay_stained_purple.png",},})		--type=Solid"159:10"
minetest.register_node("mcblocks:Blue_Stained_Clay", {tiles = {"mcBhardened_clay_stained_blue.png",},})		--type=Solid"159:11"
minetest.register_node("mcblocks:Brown_Stained_Clay", {tiles = {"mcBhardened_clay_stained_brown.png",},})		--type=Solid"159:12"
minetest.register_node("mcblocks:Green_Stained_Clay", {tiles = {"mcBhardened_clay_stained_green.png",},})		--type=Solid"159:13"
minetest.register_node("mcblocks:Red_Stained_Clay", {tiles = {"mcBhardened_clay_stained_red.png",},})		--type=Solid"159:14"
minetest.register_node("mcblocks:Black_Stained_Clay", {tiles = {"mcBhardened_clay_stained_black.png",},})		--type=Solid"159:15"
mcblocks.register_glass("White_Stained_Glass_Pane", {"mcBglass_white.png",})		--type=GlassPane"160:0"
mcblocks.register_glass("Orange_Stained_Glass_Pane", {"mcBglass_orange.png",})		--type=GlassPane"160:1"
mcblocks.register_glass("Magenta_Stained_Glass_Pane", {"mcBglass_magenta.png",})		--type=GlassPane"160:2"
mcblocks.register_glass("Light_Blue_Stained_Glass_Pane", {"mcBglass_light_blue.png",})		--type=GlassPane"160:3"
mcblocks.register_glass("Yellow_Stained_Glass_Pane", {"mcBglass_yellow.png",})		--type=GlassPane"160:4"
mcblocks.register_glass("Lime_Stained_Glass_Pane", {"mcBglass_lime.png",})		--type=GlassPane"160:5"
mcblocks.register_glass("Pink_Stained_Glass_Pane", {"mcBglass_pink.png",})		--type=GlassPane"160:6"
mcblocks.register_glass("Gray_Stained_Glass_Pane", {"mcBglass_gray.png",})		--type=GlassPane"160:7"
mcblocks.register_glass("Light_Gray_Stained_Glass_Pane", {"mcBglass_silver.png",})		--type=GlassPane"160:8"
mcblocks.register_glass("Cyan_Stained_Glass_Pane", {"mcBglass_cyan.png",})		--type=GlassPane"160:9"
mcblocks.register_glass("Purple_Stained_Glass_Pane", {"mcBglass_purple.png",})		--type=GlassPane"160:10"
mcblocks.register_glass("Blue_Stained_Glass_Pane", {"mcBglass_blue.png",})		--type=GlassPane"160:11"
mcblocks.register_glass("Brown_Stained_Glass_Pane", {"mcBglass_brown.png",})		--type=GlassPane"160:12"
mcblocks.register_glass("Green_Stained_Glass_Pane", {"mcBglass_green.png",})		--type=GlassPane"160:13"
mcblocks.register_glass("Red_Stained_Glass_Pane", {"mcBglass_red.png",})		--type=GlassPane"160:14"
mcblocks.register_glass("Black_Stained_Glass_Pane", {"mcBglass_black.png",})		--type=GlassPane"160:15"
mcblocks.register_leaves("Acacia_Leaves", {"mcBleaves_acacia.png",})		--type=Leaves"161:0"
mcblocks.register_leaves("Dark_Oak_Leaves", {"mcBleaves_big_oak.png",})		--type=Leaves"161:1"
minetest.register_node("mcblocks:Acacia_Wood", {tiles = {"mcBlog_acacia_top.png","mcBlog_acacia_top.png","mcBlog_acacia.png","mcBlog_acacia.png","mcBlog_acacia.png","mcBlog_acacia.png",},})		--type=Log"162:0"
minetest.register_node("mcblocks:Dark_Oak_Wood", {tiles = {"mcBlog_big_oak_top.png","mcBlog_big_oak_top.png","mcBlog_big_oak.png","mcBlog_big_oak.png","mcBlog_big_oak.png","mcBlog_big_oak.png",},})		--type=Log"162:1"
minetest.register_node("mcblocks:Acacia_Wood_EastWest", {tiles = {"mcBlog_acacia_top.png","mcBlog_acacia_top.png","mcBlog_acacia.png","mcBlog_acacia.png","mcBlog_acacia.png","mcBlog_acacia.png",},})		--type=Log"162:4"
minetest.register_node("mcblocks:Dark_Oak_Wood_EastWest", {tiles = {"mcBlog_big_oak_top.png","mcBlog_big_oak_top.png","mcBlog_big_oak.png","mcBlog_big_oak.png","mcBlog_big_oak.png","mcBlog_big_oak.png",},})		--type=Log"162:5"
minetest.register_node("mcblocks:Acacia_Wood_NorthSouth", {tiles = {"mcBlog_acacia_top.png","mcBlog_acacia_top.png","mcBlog_acacia.png","mcBlog_acacia.png","mcBlog_acacia.png","mcBlog_acacia.png",},})		--type=Log"162:8"
minetest.register_node("mcblocks:Dark_Oak_Wood_NorthSouth", {tiles = {"mcBlog_big_oak_top.png","mcBlog_big_oak_top.png","mcBlog_big_oak.png","mcBlog_big_oak.png","mcBlog_big_oak.png","mcBlog_big_oak.png",},})		--type=Log"162:9"
mcblocks.register_stair("Acacia_Wooden", {"mcBplanks_acacia.png"}, "w")		--type=Stairs"163"
mcblocks.register_stair("Dark_Oak_Wooden", {"mcBplanks_big_oak.png"}, "w")		--type=Stairs"164"
mcblocks.register_glass("Slime_Block", {"mcBslime.png",})		--type=Glass"165""slime"
mcblocks.register_plant("Barrier", {"mcIbarrier.png"})		--type=Plant"166"
mcblocks.register_trapdoor("Iron_Trapdoor", "mcBiron_trapdoor.png", "mcBiron_block.png")       --type=Trapdoor"167"

minetest.register_node("mcblocks:Prismarine", {tiles = {"mcBprismarine_rough.png",},})		--type=Solid"168:0""prismarine"
minetest.register_node("mcblocks:Prismarine_Bricks", {tiles = {"mcBprismarine_bricks.png",},})		--type=Solid"168:1""prismarine"
minetest.register_node("mcblocks:Dark_Prismarine", {tiles = {"mcBprismarine_dark.png",},})		--type=Solid"168:2""prismarine"
minetest.register_node("mcblocks:Sea_Lantern", {tiles = {"mcBsea_lantern.png",},})		--type=Solid"169""sea_lantern"
minetest.register_node("mcblocks:Hay_Block", {tiles = {"mcBhay_block_top.png","mcBhay_block_top.png","mcBhay_block_side.png","mcBhay_block_side.png","mcBhay_block_side.png","mcBhay_block_side.png",},})		--type=Log"170:0"
minetest.register_node("mcblocks:Hay_Block_NorthSouth", {tiles = {"mcBhay_block_top.png","mcBhay_block_top.png","mcBhay_block_side.png","mcBhay_block_side.png","mcBhay_block_side.png","mcBhay_block_side.png",},})		--type=Log"170:8"
minetest.register_node("mcblocks:Hay_Block_EastWest", {tiles = {"mcBhay_block_top.png","mcBhay_block_top.png","mcBhay_block_side.png","mcBhay_block_side.png","mcBhay_block_side.png","mcBhay_block_side.png",},})		--type=Log"170:4"

function mcblocks.register_carpet(subname, images)
    minetest.register_node("mcblocks:"..subname, {
        description = subname,
        drawtype = "nodebox",
        tiles = {images},
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = {
            type = "fixed",
            fixed = {{-0.5, -0.5,-0.5, 0.5, -0.4, 0.5},},      -- {x1, y1, z1, x2, y2, z2}
        },
    })
end

mcblocks.register_carpet("White_Carpet","mcBwool_colored_white.png")		--type=Carpet"171:0"
mcblocks.register_carpet("Orange_Carpet","mcBwool_colored_orange.png")		--type=Carpet"171:1"
mcblocks.register_carpet("Magenta_Carpet","mcBwool_colored_magenta.png")		--type=Carpet"171:2"
mcblocks.register_carpet("Light_Blue_Carpet","mcBwool_colored_light_blue.png")		--type=Carpet"171:3"
mcblocks.register_carpet("Yellow_Carpet","mcBwool_colored_yellow.png")		--type=Carpet"171:4"
mcblocks.register_carpet("Lime_Carpet","mcBwool_colored_lime.png")		--type=Carpet"171:5"
mcblocks.register_carpet("Pink_Carpet","mcBwool_colored_pink.png")		--type=Carpet"171:6"
mcblocks.register_carpet("Gray_Carpet","mcBwool_colored_gray.png")		--type=Carpet"171:7"
mcblocks.register_carpet("Silver_Carpet","mcBwool_colored_silver.png")		--type=Carpet"171:8"
mcblocks.register_carpet("Cyan_Carpet","mcBwool_colored_cyan.png")		--type=Carpet"171:9"
mcblocks.register_carpet("Purple_Carpet","mcBwool_colored_purple.png")		--type=Carpet"171:10"
mcblocks.register_carpet("Blue_Carpet","mcBwool_colored_blue.png")		--type=Carpet"171:11"
mcblocks.register_carpet("Brown_Carpet","mcBwool_colored_brown.png")		--type=Carpet"171:12"
mcblocks.register_carpet("Green_Carpet","mcBwool_colored_green.png")		--type=Carpet"171:13"
mcblocks.register_carpet("Red_Carpet","mcBwool_colored_red.png")		--type=Carpet"171:14"
mcblocks.register_carpet("Black_Carpet","mcBwool_colored_black.png")		--type=Carpet"171:15"
minetest.register_node("mcblocks:Hardened_Clay",{tiles = {"mcBhardened_clay.png",},})		--type=Solid"172"
minetest.register_node("mcblocks:Coal_Block", {tiles = {"mcBcoal_block.png",},})		--type=Solid"173"
minetest.register_node("mcblocks:Packed_Ice", {tiles = {"mcBice_packed.png",},})		--type=Solid"174"

--DoubleTall Plants???
mcblocks.register_doubleplant("Sunflower", {"mcBdouble_plant_sunflower_front.png","mcBdouble_plant_sunflower_bottom.png",})		--type=Plant"175:0"
mcblocks.register_doubleplant("Lilac", {"mcBdouble_plant_syringa_top.png","mcBdouble_plant_syringa_bottom.png",})		--type=Plant"175:1"
mcblocks.register_doubleplant("Double_Tall_Grass", {"mcBdouble_plant_grass_top.png","mcBdouble_plant_grass_bottom.png",})	--type=Plant"175:2"
mcblocks.register_doubleplant("Large_Fern", {"mcBdouble_plant_fern_top.png","mcBdouble_plant_fern_bottom.png",})		--type=Plant"175:3"
mcblocks.register_doubleplant("Rose_Bush", {"mcBdouble_plant_rose_top.png","mcBdouble_plant_rose_bottom.png",})		--type=Plant"175:4"
mcblocks.register_doubleplant("Peony", {"mcBdouble_plant_paeonia_top.png","mcBdouble_plant_paeonia_bottom.png",})		--type=Plant"175:5"


minetest.register_node("mcblocks:Standing_Banner", {tiles = {"mcEbanner_base.png",},})		--type=Banner"176"
minetest.register_node("mcblocks:Wall_Banner", {tiles = {"mcEbanner_base.png",},})		--type=Banner"177"

-- for mcblocks:Inverted_Daylight_Sensor see code at position #151

minetest.register_node("mcblocks:Red_Sandstone", {tiles = {"mcBred_sandstone_top.png","mcBred_sandstone_bottom.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png",},})		--type=Solid"179:0""red_sandstone"
minetest.register_node("mcblocks:Chiseled_Red_Sandstone", {tiles = {"mcBred_sandstone_top.png","mcBred_sandstone_top.png","mcBred_sandstone_carved.png","mcBred_sandstone_carved.png","mcBred_sandstone_carved.png","mcBred_sandstone_carved.png",},})		--type=Solid"179:1""red_sandstone"
minetest.register_node("mcblocks:Smooth_Red_Sandstone", {tiles = {"mcBred_sandstone_top.png","mcBred_sandstone_top.png","mcBred_sandstone_smooth.png","mcBred_sandstone_smooth.png","mcBred_sandstone_smooth.png","mcBred_sandstone_smooth.png",},})		--type=Solid"179:2""red_sandstone"
mcblocks.register_stair("Red_Sandstone", {"mcBred_sandstone_normal.png"}, "")		--type=Stairs"180"

minetest.register_node("mcblocks:Red_Sandstone_Double_Slab", {tiles = {"mcBred_sandstone_top.png","mcBred_sandstone_top.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png",},})		--type=Solid"181""double_stone_slab2"
mcblocks.register_slab("Red_Sandstone", {"mcBred_sandstone_top.png","mcBred_sandstone_top.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png","mcBred_sandstone_normal.png",}, "")			--type=Slab"182"

minetest.register_node("mcblocks:Spruce_Fence_Gate", {tiles = {"mcBplanks_spruce.png",},})		--type=FenceGate"183"
minetest.register_node("mcblocks:Birch_Fence_Gate", {tiles = {"mcBplanks_birch.png",},})		--type=FenceGate"184"
minetest.register_node("mcblocks:Jungle_Fence_Gate", {tiles = {"mcBplanks_jungle.png",},})		--type=FenceGate"185"
minetest.register_node("mcblocks:Dark_Oak_Fence_Gate", {tiles = {"mcBplanks_big_oak.png",},})		--type=FenceGate"186"
minetest.register_node("mcblocks:Acacia_Fence_Gate", {tiles = {"mcBplanks_acacia.png",},})		--type=FenceGate"187"
minetest.register_node("mcblocks:Spruce_Fence", {tiles = {"mcBplanks_spruce.png",},})		--type=Fence"188"
minetest.register_node("mcblocks:Birch_Fence", {tiles = {"mcBplanks_birch.png",},})		--type=Fence"189"
minetest.register_node("mcblocks:Jungle_Fence", {tiles = {"mcBplanks_jungle.png",},})		--type=Fence"190"
minetest.register_node("mcblocks:Dark_Oak_Fence", {tiles = {"mcBplanks_big_oak.png",},})		--type=Fence"191"
minetest.register_node("mcblocks:Acacia_Fence", {tiles = {"mcBplanks_acacia.png",},})		--type=Fence"192"
minetest.register_node("mcblocks:Spruce_Door", {tiles = {"mcBdoor_spruce_upper.png","mcBdoor_spruce_lower.png",},})		--type=Door"193""spruce_door"
minetest.register_node("mcblocks:Birch_Door", {tiles = {"mcBdoor_birch_upper.png","mcBdoor_birch_lower.png",},})		--type=Door"194""birch_door"
minetest.register_node("mcblocks:Jungle_Door", {tiles = {"mcBdoor_jungle_upper.png","mcBdoor_jungle_lower.png",},})		--type=Door"195""jungle_door"
minetest.register_node("mcblocks:Acacia_Door", {tiles = {"mcBdoor_acacia_upper.png","mcBdoor_acacia_lower.png",},})		--type=Door"196""acacia_door"
minetest.register_node("mcblocks:Dark_Oak_Door", {tiles = {"mcBdoor_dark_oak_upper.png","mcBdoor_dark_oak_lower.png",},})		--type=Door"197""dark_oak_door"
minetest.register_node("mcblocks:Paintings", {tiles = {"mcPpaintings_kristoffer_zetterstrand.png",},})		--type=Painting"1"
minetest.register_node("mcblocks:ItemFrame", {tiles = {"mcBmap_map_background.png"},})		--type=ItemFrame"2"background="itemframe_background.png"border="planks_birch.png"map="map_map_background.png"



--These are all items (items have values above 255)
mcblocks.register_item("IronShovel", {"mcIiron_shovel.png"})		--type=Item"256"D
mcblocks.register_item("IronPickaxe", {"mcIiron_pickaxe.png"})		--type=Item"257"D
mcblocks.register_item("IronAxe", {"mcIiron_axe.png"})		--type=Item"258"D
mcblocks.register_item("FlintandSteel", {"mcIflint_and_steel.png"})		--type=Item"259"D
mcblocks.register_item("Apple", {"mcIapple.png"})		--type=Item"260"
mcblocks.register_item("Bow0", {"mcIbow_pulling_0.png"})		--type=Item"261"D
mcblocks.register_item("Bow1", {"mcIbow_pulling_1.png"})		--type=Item"261"D
mcblocks.register_item("Bow2", {"mcIbow_pulling_2.png"})		--type=Item"261"D
mcblocks.register_item("Bow_Standby", {"mcIbow_standby.png"})		--type=Item"261"D
mcblocks.register_item("Arrow", {"mcIarrow.png"})		--type=Item"262"
mcblocks.register_item("Coal", {"mcIcoal.png"})		--type=Item"263"B
--Charcoal
mcblocks.register_item("Diamond", {"mcIdiamond.png"})		--type=Item"264"
mcblocks.register_item("IronIngot", {"mcIiron_ingot.png"})		--type=Item"265"
mcblocks.register_item("GoldIngot", {"mcIgold_ingot.png"})		--type=Item"266"
mcblocks.register_item("IronSword", {"mcIiron_sword.png"})		--type=Item"267"D
mcblocks.register_item("WoodenSword", {"mcIwood_sword.png"})		--type=Item"268"D
mcblocks.register_item("WoodenShovel", {"mcIwood_shovel.png"})		--type=Item"269"D
mcblocks.register_item("WoodenPickaxe", {"mcIwood_pickaxe.png"})		--type=Item"270"D
mcblocks.register_item("WoodenAxe", {"mcIwood_axe.png"})		--type=Item"271"D
mcblocks.register_item("StoneSword", {"mcIstone_sword.png"})		--type=Item"272"D
mcblocks.register_item("StoneShovel", {"mcIstone_shovel.png"})		--type=Item"273"D
mcblocks.register_item("StonePickaxe", {"mcIstone_pickaxe.png"})		--type=Item"274"D
mcblocks.register_item("StoneAxe", {"mcIstone_axe.png"})		--type=Item"275"D
mcblocks.register_item("DiamondSword", {"mcIdiamond_sword.png"})		--type=Item"276"D
mcblocks.register_item("DiamondShovel", {"mcIdiamond_shovel.png"})		--type=Item"277"D
mcblocks.register_item("DiamondPickaxe", {"mcIdiamond_pickaxe.png"})		--type=Item"278"D
mcblocks.register_item("DiamondAxe", {"mcIdiamond_axe.png"})		--type=Item"279"D
mcblocks.register_item("Stick", {"mcIstick.png"})		--type=Item"280"
mcblocks.register_item("Bowl", {"mcIbowl.png"})		--type=Item"281"
mcblocks.register_item("MushroomStew", {"mcImushroom_stew.png"})		--type=Item"282"
mcblocks.register_item("GoldSword", {"mcIgold_sword.png"})		--type=Item"283"D
mcblocks.register_item("GoldShovel", {"mcIgold_shovel.png"})		--type=Item"284"D
mcblocks.register_item("GoldPickaxe", {"mcIgold_pickaxe.png"})		--type=Item"285"D
mcblocks.register_item("GoldAxe", {"mcIgold_axe.png"})		--type=Item"286"D
mcblocks.register_item("String", {"mcIstring.png"})		--type=Item"287"
mcblocks.register_item("Feather", {"mcIfeather.png"})		--type=Item"288"
mcblocks.register_item("Gunpowder", {"mcIgunpowder.png"})		--type=Item"289"
mcblocks.register_item("WoodenHoe", {"mcIwood_hoe.png"})		--type=Item"290"D
mcblocks.register_item("StoneHoe", {"mcIstone_hoe.png"})		--type=Item"291"D
mcblocks.register_item("IronHoe", {"mcIiron_hoe.png"})		--type=Item"292"D
mcblocks.register_item("DiamondHoe", {"mcIdiamond_hoe.png"})		--type=Item"293"D
mcblocks.register_item("GoldHoe", {"mcIgold_hoe.png"})		--type=Item"294"D
mcblocks.register_item("WheatSeeds", {"mcIseeds_wheat.png"})		--type=Item"295"
mcblocks.register_item("Wheat", {"mcIwheat.png"})		--type=Item"296"
mcblocks.register_item("Bread", {"mcIbread.png"})		--type=Item"297"
mcblocks.register_item("LeatherHelmet", {"mcIleather_helmet.png"})		--type=Item"298"D
mcblocks.register_item("LeatherChestplate", {"mcIleather_chestplate.png"})		--type=Item"299"D
mcblocks.register_item("LeatherLeggings", {"mcIleather_leggings.png"})		--type=Item"300"D
mcblocks.register_item("LeatherBoots", {"mcIleather_boots.png"})		--type=Item"301"D
mcblocks.register_item("ChainmailHelmet", {"mcIchainmail_helmet.png"})		--type=Item"302"D
mcblocks.register_item("ChainmailChestplate", {"mcIchainmail_chestplate.png"})		--type=Item"303"D
mcblocks.register_item("ChainmailLeggings", {"mcIchainmail_leggings.png"})		--type=Item"304"D
mcblocks.register_item("ChainmailBoots", {"mcIchainmail_boots.png"})		--type=Item"305"D
mcblocks.register_item("IronHelmet", {"mcIiron_helmet.png"})		--type=Item"306"D
mcblocks.register_item("IronChestplate", {"mcIiron_chestplate.png"})		--type=Item"307"D
mcblocks.register_item("IronLeggings", {"mcIiron_leggings.png"})		--type=Item"308"D
mcblocks.register_item("IronBoots", {"mcIiron_boots.png"})		--type=Item"309"D
mcblocks.register_item("DiamondHelmet", {"mcIdiamond_helmet.png"})		--type=Item"310"D
mcblocks.register_item("DiamondChestplate", {"mcIdiamond_chestplate.png"})		--type=Item"311"D
mcblocks.register_item("DiamondLeggings", {"mcIdiamond_leggings.png"})		--type=Item"312"D
mcblocks.register_item("DiamondBoots", {"mcIdiamond_boots.png"})		--type=Item"313"D
mcblocks.register_item("GoldHelmet", {"mcIgold_helmet.png"})		--type=Item"314"D
mcblocks.register_item("GoldChestplate", {"mcIgold_chestplate.png"})		--type=Item"315"D
mcblocks.register_item("GoldLeggings", {"mcIgold_leggings.png"})		--type=Item"316"D
mcblocks.register_item("GoldBoots", {"mcIgold_boots.png"})		--type=Item"317"D
mcblocks.register_item("Flint", {"mcIflint.png"})		--type=Item"318"
mcblocks.register_item("RawPorkchop", {"mcIporkchop_raw.png"})		--type=Item"319"
mcblocks.register_item("CookedPorkchop", {"mcIporkchop_cooked.png"})		--type=Item"320"
mcblocks.register_item("Painting", {"mcIpainting.png"})		--type=Item"321"
mcblocks.register_item("GoldenApple", {"mcIapple_golden.png"})		--type=Item"322"B
--EnchantedGoldenApple
mcblocks.register_item("Sign", {"mcIsign.png"})		--type=Item"323"
mcblocks.register_item("WoodenDoor_Acacia", {"mcIdoor_acacia.png"})		--type=Item"324"
mcblocks.register_item("WoodenDoor_Birch", {"mcIdoor_birch.png"})		--type=Item"324"
mcblocks.register_item("WoodenDoor_DarkOak", {"mcIdoor_dark_oak.png"})		--type=Item"324"
mcblocks.register_item("WoodenDoor_Jungle", {"mcIdoor_jungle.png"})		--type=Item"324"
mcblocks.register_item("WoodenDoor_Spruce", {"mcIdoor_spruce.png"})		--type=Item"324"
mcblocks.register_item("IronDoor", {"mcIdoor_iron.png"})		--type=Item"324"
mcblocks.register_item("WoodenDoor", {"mcIdoor_wood.png"})		--type=Item"324"
mcblocks.register_item("Bucket", {"mcIbucket_empty.png"})		--type=Item"325"
mcblocks.register_item("BucketWater", {"mcIbucket_water.png"})		--type=Item"326"
mcblocks.register_item("BucketLava", {"mcIbucket_lava.png"})		--type=Item"327"
mcblocks.register_item("Minecart", {"mcIminecart_normal.png"})		--type=Item"328"
mcblocks.register_item("Saddle", {"mcIsaddle.png"})		--type=Item"329"
mcblocks.register_item("IronDoor", {"mcIdoor_iron.png"})		--type=Item"330"
mcblocks.register_item("RedstoneDust", {"mcIredstone_dust.png"})		--type=Item"331"
mcblocks.register_item("Snowball", {"mcIsnowball.png"})		--type=Item"332"
mcblocks.register_item("Boat", {"mcIboat.png"})		--type=Item"333"
mcblocks.register_item("Leather", {"mcIleather.png"})		--type=Item"334"
mcblocks.register_item("BucketMilk", {"mcIbucket_milk.png"})		--type=Item"335"
mcblocks.register_item("ClayBrick", {"mcIbrick.png"})		--type=Item"336"
mcblocks.register_item("ClayBall", {"mcIclay_ball.png"})		--type=Item"337"
mcblocks.register_item("Reeds", {"mcIreeds.png"})		--type=Item"338"
mcblocks.register_item("Paper", {"mcIpaper.png"})		--type=Item"339"
mcblocks.register_item("Book", {"mcIbook_normal.png"})		--type=Item"340"
mcblocks.register_item("SlimeBall", {"mcIslimeball.png"})		--type=Item"341"
mcblocks.register_item("MinecartChest", {"mcIminecart_chest.png"})		--type=Item"342"
mcblocks.register_item("MinecartFurnace", {"mcIminecart_furnace.png"})		--type=Item"343"
mcblocks.register_item("Egg", {"mcIegg.png"})		--type=Item"344"
mcblocks.register_item("Compass", {"mcIcompass.png"})		--type=Item"345"
mcblocks.register_item("FishingRod", {"mcIfishing_rod_cast.png"})		--type=Item"346"D
mcblocks.register_item("FishingRodUncast", {"mcIfishing_rod_uncast.png"})		--type=Item"346"D
mcblocks.register_item("Clock", {"mcIclock.png"})		--type=Item"347"
mcblocks.register_item("GlowstoneDust", {"mcIglowstone_dust.png"})		--type=Item"348"
mcblocks.register_item("RawClownfish", {"mcIfish_clownfish_raw.png"})		--type=Item"349" B
mcblocks.register_item("CookedCod", {"mcIfish_cod_cooked.png"})		--type=Item"349" B
mcblocks.register_item("RawCod", {"mcIfish_cod_raw.png"})		--type=Item"349" B
mcblocks.register_item("CookedFish", {"mcIfish_cooked.png"})		--type=Item"349" B
mcblocks.register_item("RawPufferfish", {"mcIfish_pufferfish_raw.png"})		--type=Item"349" B
mcblocks.register_item("CookedSalmon", {"mcIfish_salmon_cooked.png"})		--type=Item"349" B
mcblocks.register_item("RawSalmon", {"mcIfish_salmon_raw.png"})		--type=Item"349" B
mcblocks.register_item("RawFish", {"mcIfish_raw.png"})		--type=Item"349"B
mcblocks.register_item("InkSack", {"mcIfish_cooked.png"})		--type=Item"350" B
mcblocks.register_item("dye_powder_black", {"mcIdye_powder_black.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_blue", {"mcIdye_powder_blue.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_brown", {"mcIdye_powder_brown.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_cyan", {"mcIdye_powder_cyan.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_gray", {"mcIdye_powder_gray.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_green", {"mcIdye_powder_green.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_light_blue", {"mcIdye_powder_light_blue.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_lime", {"mcIdye_powder_lime.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_magenta", {"mcIdye_powder_magenta.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_orange", {"mcIdye_powder_orange.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_pink", {"mcIdye_powder_pink.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_purple", {"mcIdye_powder_purple.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_red", {"mcIdye_powder_red.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_silver", {"mcIdye_powder_silver.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_white", {"mcIdye_powder_white.png"})		--type=Item"351" B
mcblocks.register_item("dye_powder_yellow", {"mcIdye_powder_yellow.png"})		--type=Item"351" B
mcblocks.register_item("Bone", {"mcIbone.png"})		--type=Item"352"
mcblocks.register_item("Sugar", {"mcIsugar.png"})		--type=Item"353"
mcblocks.register_item("Cake", {"mcIcake.png"})		--type=Item"354"
mcblocks.register_item("Bed", {"mcIbed.png"})		--type=Item"355"
mcblocks.register_item("RedstoneRepeater", {"mcIrepeater.png"})		--type=Item"356"
mcblocks.register_item("Cookie", {"mcIcookie.png"})		--type=Item"357"//this id is wrong
mcblocks.register_item("Map", {"mcImap_filled.png"})		--type=Item"358"B
mcblocks.register_item("Shears", {"mcIshears.png"})		--type=Item"359"D
mcblocks.register_item("Melon_Slice", {"mcImelon.png"})		--type=Item"360"
mcblocks.register_item("PumpkinSeeds", {"mcIseeds_pumpkin.png"})		--type=Item"361"
mcblocks.register_item("MelonSeeds", {"mcIseeds_melon.png"})		--type=Item"362"
mcblocks.register_item("RawBeef", {"mcIbeef_raw.png"})		--type=Item"363"
mcblocks.register_item("CookedBeef", {"mcIbeef_cooked.png"})		--type=Item"364"
mcblocks.register_item("RawChicken", {"mcIchicken_raw.png"})		--type=Item"365"
mcblocks.register_item("CookedChicken", {"mcIchicken_cooked.png"})		--type=Item"366"
mcblocks.register_item("RottenFlesh", {"mcIrotten_flesh.png"})		--type=Item"367"
mcblocks.register_item("EnderPearl", {"mcIender_pearl.png"})		--type=Item"368"
mcblocks.register_item("BlazeRod", {"mcIblaze_rod.png"})		--type=Item"369"
mcblocks.register_item("GhastTear", {"mcIghast_tear.png"})		--type=Item"370"
mcblocks.register_item("GoldNugget", {"mcIgold_nugget.png"})		--type=Item"371"
mcblocks.register_item("NetherWartSeeds", {"mcInether_wart.png"})		--type=Item"372"
mcblocks.register_item("potion_overlay", {"mcIpotion_overlay.png"})		--type=Item"373"
mcblocks.register_item("potion_bottle_drinkable", {"mcIpotion_bottle_drinkable.png"})		--type=Item"373"B
mcblocks.register_item("potion_bottle_splash", {"mcIpotion_bottle_splash.png"})		--type=Item"373"
mcblocks.register_item("potion_bottle_empty", {"mcIpotion_bottle_empty.png"})		--type=Item"373"
mcblocks.register_item("GlassBottle", {"mcIglass_bottle.png"})		--type=Item"374"
mcblocks.register_item("SpiderEye", {"mcIspider_eye.png"})		--type=Item"375"
mcblocks.register_item("FermentedSpiderEye", {"mcIspider_eye_fermented.png"})		--type=Item"376"
mcblocks.register_item("BlazePowder", {"mcIblaze_powder.png"})		--type=Item"377"
mcblocks.register_item("MagmaCream", {"mcImagma_cream.png"})		--type=Item"378"
mcblocks.register_item("BrewingStand", {"mcIbrewing_stand.png"})		--type=Item"379"

mcblocks.register_item("Cauldron", {"mcIcauldron.png"})		--type=Item"380"
mcblocks.register_item("EyeofEnder", {"mcIender_eye.png"})		--type=Item"381"
mcblocks.register_item("GlisteringMelon_Slice", {"mcImelon_speckled.png"})		--type=Item"382"
mcblocks.register_item("SpawnEgg", {"mcIspawn_egg.png"})		--type=Item"383"B
mcblocks.register_item("BottleofEnchanting", {"mcIexperience_bottle.png"})		--type=Item"384"
mcblocks.register_item("FireCharge", {"mcIfireball.png"})		--type=Item"385"
mcblocks.register_item("BookandQuill", {"mcIbook_writable.png"})		--type=Item"386"
mcblocks.register_item("WrittenBook", {"mcIbook_written.png"})		--type=Item"387"
mcblocks.register_item("Emerald", {"mcIemerald.png"})		--type=Item"388"
mcblocks.register_item("ItemFrame", {"mcIitem_frame.png"})		--type=Item"389"
mcblocks.register_item("FlowerPot", {"mcIflower_pot.png"})		--type=Item"390"
mcblocks.register_item("Carrot", {"mcIcarrot.png"})		--type=Item"391"
mcblocks.register_item("Potato", {"mcIpotato.png"})		--type=Item"392"
mcblocks.register_item("BakedPotato", {"mcIpotato_baked.png"})		--type=Item"393"
mcblocks.register_item("PoisonousPotato", {"mcIpotato_poisonous.png"})		--type=Item"394"
mcblocks.register_item("EmptyMap", {"mcImap_empty.png"})		--type=Item"395"
mcblocks.register_item("FilledMap", {"mcImap_filled.png"})		--type=Item"395"
mcblocks.register_item("GoldenCarrot", {"mcIcarrot_golden.png"})		--type=Item"396"
mcblocks.register_item("SkullCreeper", {"mcIskull_creeper.png"})		--type=Item"397"B
mcblocks.register_item("SkullSkeleton", {"mcIskull_skeleton.png"})		--type=Item"397"B
mcblocks.register_item("SkullSteve", {"mcIskull_steve.png"})		--type=Item"397"B
mcblocks.register_item("SkullWither", {"mcIskull_wither.png"})		--type=Item"397"B
mcblocks.register_item("SkullZombie", {"mcIskull_zombie.png"})		--type=Item"397"B
mcblocks.register_item("CarrotonaStick", {"mcIcarrot_on_a_stick.png"})		--type=Item"398"D
mcblocks.register_item("NetherStar", {"mcInether_star.png"})		--type=Item"399"
mcblocks.register_item("PumpkinPie", {"mcIpumpkin_pie.png"})		--type=Item"400"
mcblocks.register_item("FireworkRocket", {"mcIfireworks.png"})		--type=Item"401"
mcblocks.register_item("FireworkStar", {"mcIfireworks_charge.png"})		--type=Item"402"
mcblocks.register_item("EnchantedBook", {"mcIbook_enchanted.png"})		--type=Item"403"
mcblocks.register_item("RedstoneComparator", {"mcIcomparator.png"})		--type=Item"404"
mcblocks.register_item("NetherBrick_Item", {"mcInetherbrick.png"})		--type=Item"405"
mcblocks.register_item("NetherQuartz", {"mcIquartz.png"})		--type=Item"406"
mcblocks.register_item("Minecart_TNT", {"mcIminecart_tnt.png"})		--type=Item"407"
mcblocks.register_item("Minecart_Hopper", {"mcIminecart_hopper.png"})		--type=Item"408"
mcblocks.register_item("PrismarineShard", {"mcIprismarine_shard.png"})		--type=Item"409"
mcblocks.register_item("PrismarineCrystals", {"mcIprismarine_crystals.png"})		--type=Item"410"
mcblocks.register_item("RawRabbit", {"mcIrabbit_raw.png"})		--type=Item"411"
mcblocks.register_item("CookedRabbit", {"mcIrabbit_cooked.png"})		--type=Item"412"
mcblocks.register_item("RabbitStew", {"mcIrabbit_stew.png"})		--type=Item"413"
mcblocks.register_item("RabbitsFoot", {"mcIrabbit_foot.png"})		--type=Item"414"
mcblocks.register_item("RabbitHide", {"mcIrabbit_hide.png"})		--type=Item"415"
--ArmorStand
mcblocks.register_item("IronHorseArmor", {"mcIiron_horse_armor.png"})		--type=Item"417"
mcblocks.register_item("GoldHorseArmor", {"mcIgold_horse_armor.png"})		--type=Item"418"
mcblocks.register_item("DiamondHorseArmor", {"mcIdiamond_horse_armor.png"})		--type=Item"419"
mcblocks.register_item("Lead", {"mcIlead.png"})		--type=Item"420"
mcblocks.register_item("NameTag", {"mcIname_tag.png"})		--type=Item"421"
mcblocks.register_item("Minecart_CommandBlock", {"mcIminecart_command_block.png"})		--type=Item"422"
mcblocks.register_item("RawMutton", {"mcImutton_raw.png"})		--type=Item"423"
mcblocks.register_item("CookedMutton", {"mcImutton_cooked.png"})		--type=Item"424"
--Banner_Black
--Banner_Red
--Banner_Green
--Banner_Brown
--Banner_Blue
--Banner_Purple
--Banner_Cyan
--Banner_Silver
--Banner_Gray
--Banner_Pink
--Banner_Lime
--Banner_Yellow
--Banner_LightBlue
--Banner_Magenta
--Banner_Orange
--Banner_White
mcblocks.register_item("MusicDisk_13", {"mcIrecord_13.png"})		--type=Item"2256"
mcblocks.register_item("MusicDisk_Cat", {"mcIrecord_cat.png"})		--type=Item"2257"
mcblocks.register_item("MusicDisk_Blocks", {"mcIrecord_blocks.png"})		--type=Item"2258"
mcblocks.register_item("MusicDisk_Chirp", {"mcIrecord_chirp.png"})		--type=Item"2259"
mcblocks.register_item("MusicDisk_Far", {"mcIrecord_far.png"})		--type=Item"2260"
mcblocks.register_item("MusicDisk_Mall", {"mcIrecord_mall.png"})		--type=Item"2261"
mcblocks.register_item("MusicDisk_Mellohi", {"mcIrecord_mellohi.png"})		--type=Item"2262"
mcblocks.register_item("MusicDisk_Stal", {"mcIrecord_stal.png"})		--type=Item"2263"
mcblocks.register_item("MusicDisk_Strad", {"mcIrecord_strad.png"})		--type=Item"2264"
mcblocks.register_item("MusicDisk_Ward", {"mcIrecord_ward.png"})		--type=Item"2265"
mcblocks.register_item("MusicDisk_11", {"mcIrecord_11.png"})		--type=Item"2266"
mcblocks.register_item("MusicDisk_Wait", {"mcIrecord_wait.png"})		--type=Item"2267"


--
--Id	Icon	Egg	Entity	Savegame ID	Drops
--1	Dropped item	Item
--2	Experience Orb	XPOrb
--Immobile
--8	Lead knot	LeashKnot
--9	Painting	Painting
--18	Item Frame	ItemFrame
--200	Ender Crystal	EnderCrystal
--Projectiles
--10	Shot arrow	Arrow
--11	Thrown snowball	Snowball
--12	Ghast fireball	Fireball
--13	Blaze fireball	SmallFireball
--14	Thrown Ender Pearl	ThrownEnderpearl
--15	Thrown Eye of Ender	EyeOfEnderSignal
--16	Thrown splash potion	ThrownPotion
--17	Thrown Bottle o' Enchanting	ThrownExpBottle
--19	Wither Skull	WitherSkull
--22	Firework Rocket	FireworksRocketEntity
--Blocks
--20	Primed TNT	PrimedTnt
--21	Falling block (gravel,sand, anvil,dragon egg)	FallingSand
--Vehicles
--40	Minecart with Command Block	MinecartCommandBlock
--41	Boat	Boat
--42	Minecart	MinecartRideable
--43	Minecart with Chest	MinecartChest
--44	Minecart with Furnace	MinecartFurnace
--45	Minecart with TNT	MinecartTNT
--46	Minecart with Hopper	MinecartHopper
--47	Minecart with Spawner	MinecartSpawner
--Generic
--48	-	-	Mob	Mob
--49	-	-	Monster	Monster
--Hostile mobs
--50	Creeper	Creeper
--51	Skeleton	Wither Skeleton	Skeleton
--52	Spider	Spider
--53	Giant	Giant
--54	Zombie	Zombie
--55	Slime	Slime
--56	Ghast	Ghast
--57	Zombie Pigman	PigZombie
--58	Enderman	Enderman
--59	Cave Spider	CaveSpider
--60	Silverfish	Silverfish
--61	Blaze	Blaze
--62	Magma Cube	LavaSlime
--63	Ender Dragon	EnderDragon
--64	Wither	WitherBoss
--66	Witch	Witch
--67	Endermite	Endermite
--68	Guardian	Guardian
--Passive mobs
--65	Bat	Bat
--90	Pig	Pig
--91	Sheep	Sheep
--92	Cow	Cow
--93	Chicken	Chicken
--94	Squid	Squid
--95	Wolf	Wolf
--96	Mooshroom	MushroomCow
--97	Snow Golem	SnowMan
--98	Ocelot	Ozelot
--99	Iron Golem	VillagerGolem
--100	Horse	EntityHorse
--101	Rabbit	Rabbit
--NPCs
--120	Villager	Villager
--
--


-- mcDriver
local function nextrange(x, max)
    x = x + 1
    if x > max then
        x = 0
    end
    return x
end

local ROTATE_FACE = 1
local ROTATE_AXIS = 2
local USES = 200

-- Handles rotation
local function mcDriver_handler(itemstack, user, pointed_thing, mode)
    if pointed_thing.type ~= "node" then
        return
    end

    local pos = pointed_thing.under

    if minetest.is_protected(pos, user:get_player_name()) then
        minetest.record_protection_violation(pos, user:get_player_name())
        return
    end

    local node = minetest.get_node(pos)
    local ndef = minetest.registered_nodes[node.name]
    if not ndef or not ndef.paramtype2 == "facedir" or
            (ndef.drawtype == "nodebox" and
            not ndef.node_box.type == "fixed") or
            node.param2 == nil then
        return
    end

    if ndef.can_dig and not ndef.can_dig(pos, user) then
        return
    end

    -- Set param2
    local rotationPart = node.param2 % 32 -- get first 4 bits
    local preservePart = node.param2 - rotationPart

    local meta = minetest.get_meta(pos)
    local OrigParam2 = meta:get_string("OrigParam2")
    if OrigParam2:len()<1 then
        OrigParam2 = node.param2
        meta:set_string("OrigParam2", OrigParam2);
    end

    local axisdir = math.floor(rotationPart / 4)
    local rotation = rotationPart - axisdir * 4
    if mode == ROTATE_FACE then
        rotationPart = axisdir * 4 + nextrange(rotation, 3)
    elseif mode == ROTATE_AXIS then
        rotationPart = nextrange(axisdir, 5) * 4
    end

    node.param2 = preservePart + rotationPart
    minetest.swap_node(pos, node)

    chatText = "OrigParam2:".. OrigParam2.. " param2 post:".. node.param2.. " (rot:".. rotationPart.. "pres:".. preservePart.. ")"
    minetest.chat_send_player(user:get_player_name(), chatText, false)

    if not minetest.setting_getbool("creative_mode") then
        itemstack:add_wear(65535 / (USES - 1))
    end

    return itemstack
end

minetest.register_tool("mcblocks:mcDriver", {
    description = "mcDriver (left-click rotates face, right-click rotates axis)",
    inventory_image = "screwdriver.png",
    on_use = function(itemstack, user, pointed_thing)
        mcDriver_handler(itemstack, user, pointed_thing, ROTATE_FACE)
        return itemstack
    end,
    on_place = function(itemstack, user, pointed_thing)
        mcDriver_handler(itemstack, user, pointed_thing, ROTATE_AXIS)
        return itemstack
    end,
})
