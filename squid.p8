pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
 -- main functions
// project squidgame
// by sam france, frank bubbico
// and lucas diloreto
//
// date created ~ sept. 2024
//
// tab 0 contains:
// - all main functions
//   (init, update, draw)


// initialize all objects and
// objectpools
function _init()
 cls()
	hitboxes = {}
	make_player()
	bombpool = {}
	explosions = {}
	arrowpool = {}
	
//	makenpc()

	particlesystems = {}
	particles = {}
	
	
 global_faces = {
	[0] = {-1,-1,-6,4,.5,.5,4,4,2,-2,.5,.5,.25},
 [1] = {0,-1,-2,-4,0,1,4,4,2,0,1,.5,.2},
 [2] = {1,-1,4,-6,.5,.5,4,4,2,2,.5,.5,.25},
	[3] = {-1,0,-4,10,1,0,4,4,0,-2,.5,1,.25},
	[4] = {1,0,12,-2,1,0,4,4,0,2,.5,1,.25},
	[5] = {-1,1,4,14,.5,.5,4,4,-2,-2,.5,.5,.25},
	[6] = {0,1,10,12,0,1,4,4,-2,0,1,.5,.25},
	[7] = {1,1,14,4,.5,.5,4,4,-2,2,.5,.5,.25} }
	
	// global inventory flags? maybe?
	global_items = {
	["bombs"] = {use = use_bomb},
	["bow"] = {use = use_bow},
	["sword"] = {use = sword}
	}
	
	music(11)
	menuitem(1,"inventory", openinv)
	menuitem(2,"save game", opensaveprompt)
end

// routine updates every frame
// using designed update funcs.
function _update()
	//get_mapdata(0,0,31,31) 
	initialmenu()
	update_player()
	foreach(bombpool,update_bomb)
	foreach(explosions,update_explosion)
	foreach(arrowpool,update_arrow)
	foreach(particlesystems, update_partsys)
	foreach(particles, update_particle)
	foreach(hitboxes, update_hitbox)
	//collisiontest2()
	--[[
	if ((player.mapposx > 1 and player.mapposx < 4) and music_var !=0) then
		music_var = 0
		music(0)
		
		elseif (player.mapposx != 2 and player.mapposx != 3 and music_var != 4) then
		music(5)
		music_var = 4
	end 
	--]]
	//mag = sqrt(player.dx^2 + player.dy^2)
end



// routine updates every frame
// using designed update funcs.
function _draw()
	cls(1)
	bomb_animation()
	draw_map()
	draw_player()
	//if (player.mapposx == 0 and player.mapposy == 0) then
	 //spr(npc.sprite, npc.x%128, npc.y%128)
	//end
	foreach(arrowpool,draw_arrow)
	foreach(bombpool,draw_bomb)

	
	foreach(particles, draw_particle)
	//print("♥♥♥",13*8,1,8)

	--[[
	print("player.itempool",1, 1, 0)
	print(player.itempool.bow[2])
	print("bombs")
	print(player.resources.bombs[1])
	print("keys")
	print(player.resources.keys[1])
	print("arrows")
	print(player.resources.arrows[1])
	print(hbtestflag)
	print(player.hb.left)
	--]]
	
	
	//foreach(hitboxes, draw_hitbox)
	
	--[[
	print(hitboxes[1].left)
	print(hitboxes[1].right)
	print(hitboxes[1].top)
	print(hitboxes[1].bot)
	print(hitboxes[2].left)
	print(hitboxes[2].right)
	print(hitboxes[2].top)
	print(hitboxes[2].bot)
	--]]
	
 //print(mag)
end
-->8
-- player info
// the collions function, and
// map info/functions
//
// make player
//
// make player generates our
// player when called in _init
// it contains a ton of info 
// that we're gonna use

function make_player()
	player = add_object(0,0,110,60)
	//player stats
	//player.x =87*8+4
	//player.y =24*8-4
	player.diag = false
	player.prev_face = 0
 player.sprite = 2
 player.face = 6
 player.interaction = false
 // player items
 player.itempool = {
  ["bow"] = {42, 0, 0},
 	["ice boots"] = {43, 0}, 
 	["satchel"] = {58, 0 },
 	["magnet"] = {17, 0},
 	["sword"] = {59, 0} }
 player.resources = {
  ["bombs"] = {0, 0},
  ["keys"] = {0},
  ["arrows"] = {0},
  ["money"] = {0} }
 player.slots = {
  [1] = "none",
  [2] = "none",
  [3] = "none"
 }
 player.working_inventory = {}
 player.slotflag = 0

	player.invis = false
	--player hurtbox, tag = 0 
 player.hb = add_hitbox(0, 4,4, 6,6, -1, player)
end

// move player
//
// move player is self explanatory
// the function uses our mapcollions
// function (tab 9)
// to restrict movement against
// walls and objects with the
// flag #0.

function move_player()
	// initialize dx, dy and diag
	player.dx = 0
	player.dy = 0
	player.diag = false
	
	// alter dx, dy based on btn input
	// check mapcollisions on hb
	if (btn(0) and not mapcollisions(player.hb).l) then
  player.dx-=1.001
	end
	if (btn(1) and not mapcollisions(player.hb).r) then
  player.dx+=1.001
	end
	if (btn(2) and not mapcollisions(player.hb).t) then
  player.dy-=1.001
	end
	if (btn(3) and not mapcollisions(player.hb).b) then
  player.dy+=1.001
	end
	
	// diagonal check
	if (player.dx*player.dy != 0) then
  // roughly normalize movement
  // values. using .75 here for
  // fluidity and smoothness.
  player.dx*=.75
  player.dy*=.75
  // set diag to true
  player.diag = true
	end
	
	// smoothness functions for
	// diagonal movement. these set
	// x and y to the center of each
	// pixel. only happens on first
	// frame of diag movement.

	if (player.diag and not (player.face != player.prev_face)) then
  player.x = flr(player.x)+0.5
  player.y = flr(player.y)+0.5
 end
 
 
 // move player by dx and dy
 // (this is why .75 is better)
	player.x+=player.dx
	player.y+=player.dy
	
	// set new previous face for
	// the next frame
 player.prev_face = player.face
	// end!
end

// update player
//
// update player does a variety
// of things, including use items,
// update map position, and move
// the player when called

function update_player()
	
	--update player face direction
	
 local prev = player.face
	
	if btn(1) then
		player.face = 5
	elseif btn(0) then
		player.face = 3
	else
		player.face = 4
	end
	
	if btn(3) then
		player.face +=3
	elseif btn(2) then
	 player.face -=3
	end
	
	if player.face == 4 then
		player.face = prev
	elseif player.face >4 then
		player.face -=1
	end
	
	--process input, update world pos
	// called from above
	move_player()
	

	
	--update mappos
	player.mapposx, player.mapposy = map_pos(player.x,player.y)	


 	// check for if bomb has been placed
-- if ( btnp(5) then	
-- 	readinfo(player.face) end
	player.interaction = false
	if ( btnp(5)) then
		interact(player.face)
		if ( player.interaction==false ) then
	  use_item_in_slot(1)
 	end
 end
 
 //sword
	if(btnp(4)) then
		use_item_in_slot(2)
		--[[
		if (player.invis == true) then
			player.invis = false
		else
			player.invis = true
		end	
		--]]
	end
	
	if (btnp(0,1) ) then
		use_item_in_slot(3)
	end
end

// draw player
//
// draws player

function draw_player()
 local table = {
 [6] = {2},
 [1] = {35},
 [7] = {37},
 [5] = {38},
 [2] = {34},
 [0] = {36}, 
 [3] = {33}, 
 [4] = {32} }
 for k,v in pairs(table) do
		if player.face == k then
		 player.sprite = v[1]
		end
	end
	if (player.invis) then
		player.sprite = 3
	end	
	
	palt(0, false)
	palt(1, true)
	spr(player.sprite, player.x%128, player.y%128)
	pal()
end

function use_item_in_slot(num)
	for k,v in pairs(global_items) do
	 if (k == player.slots[num]) then
	 	global_items[k].use()
	 end
 end
end

function use_bomb()
 if (player.resources.bombs[1]>0 ) then
  add_bomb(player.mapposx,player.mapposy,player.x%128, player.y%128)
  player.resources.bombs[1] -= 1
	end
end

function use_bow()
	if (player.itempool.bow[2] >= 1 and player.resources.arrows[1] > 0) then
	 add_arrow(player)
		player.resources.arrows[1] -= 1
	end
end	

-->8
-- npcs
--[[
function makenpc()
 npc = {}
	npc.x = 60
	npc.y = 104
	npc.mapposx = 0
	npc.mapposy = 0
	npc.sprite = 10
 npc.isalive = true
	npc.hb = add_hitbox(0,4, 4, 6,6, -1, npc)
end
--]]



-->8
-- particle effects

--particle system prefabs:
---explosion: add_partsys(x,y,1,1, 2,5, 0,0, 2,2, 0.0625)
---sword swipe: add_partsys(x,y,0,1, 4, 4, 2,0, 1,.5, 0.25)


--creates a particle system
function add_partsys(x,y,
																					xrange,
																					yrange,
																					sduration,
																					pduration,
																					dx,dy,
																					dxrange,
																					dyrange,
																					freq,
																					parent)
	local partsys = {}
	--world position of
	--particle system
	partsys.x = x
	partsys.y = y
	--range of spawn position
	--variation for particles:
	--x +- xrange, y +- yrange
	partsys.xrange = xrange
	partsys.yrange = yrange
	--time until particle system
	--despawns
	partsys.sduration = sduration
	--time until particles despawn
	partsys.pduration = pduration
	--speed / direction of particles
 partsys.dx = dx
 partsys.dy = dy
 --speed / direction range of particles
 partsys.dxrange = dxrange
 partsys.dyrange = dyrange
 --frequency of particle spawns
 --spawns every freq frames
 partsys.freq =freq
	
	--parent obj of particle system
	if parent != nil then
		partsys.parent = parent
		partsys.x = parent.x
		partsys.y = parent.y
	end
		
	add(particlesystems, partsys)
end


function update_partsys(partsys)
	--track sys lifetime
	partsys.sduration -= 1
	if partsys.sduration < 0 then
		del(particlesystems,partsys)
	end
	
	--not sure if this is needed...
	if partsys.parent != nil then
		partsys.x = partsys.parent.x
		partsys.y = partsys.parent.y
	end
	
	--spawn particle
	if partsys.freq <=1 then
		for i=0, 1/partsys.freq do
			add_particle(partsys.x-partsys.xrange + rnd(partsys.xrange*2),
															partsys.y-partsys.yrange + rnd(partsys.yrange*2),
															partsys.pduration,
															partsys.dx-partsys.dxrange + rnd(partsys.dxrange*2),
															partsys.dy-partsys.dyrange + rnd(partsys.dyrange*2))
		end
	elseif partsys.sduration % partsys.freq == 0 then
		add_particle(partsys.x-partsys.xrange + rnd(partsys.xrange*2),
															partsys.y-partsys.yrange + rnd(partsys.yrange*2),
															partsys.pduration,
															partsys.dx-partsys.dxrange + rnd(partsys.dxrange*2),
															partsys.dy-partsys.dyrange + rnd(partsys.dyrange*2))
	end
	
end

--creates a single particle
--from particle system
function add_particle(x,y, duration, dx, dy)
	part = {}
	part.x = x
	part.y = y
	part.duration = duration
	part.dx = dx
	part.dy = dy
	
	
	add(particles, part)
end

function update_particle(part)
	--update duration
	part.duration -=1
	--delete if done
	if part.duration < 0 then
		del(particles, part)
	end
	
	--update position
	part.x += part.dx
	part.y += part.dy
	
end

function draw_particle(part)
	local mapposx, mapposy = map_pos(part.x,part.y)
	if mapposx == player.mapposx and mapposy == player.mapposy then
			pset(part.x%128, part.y%128, 7)
	end
end
-->8
-- bombs
// tab 4 handles bomb functions
// and potenitally other future
// item functions
//
// add_bomb
// 
// adds a bomb upon call to 
// the bomb table (called in 
// update player) with contained
// information for further use

function add_bomb(mapposx,mapposy,xpos,ypos)
	local bomb = add_object(mapposx,mapposy,xpos,ypos)
	local input_face = player.face
	
	set_movement_from_face(bomb,input_face,0)
	
	bomb.timer = 100
	bomb.sprite = 18
	bomb.hb = add_hitbox(2,4,5,5,5,-1,bomb)
	add(bombpool,bomb)
end

// update_bomb
// 
// updated the local information
// of a given bomb until timer 
// hits 0, which triggers an
// explosion (aka bomb.sprite = 0)
function update_bomb(bomb)
	if (bomb.timer == 0) then
	 add_partsys(bomb.x+4,bomb.y+4,1,1, 2,5, 0,0, 2,2, 0.0625)
	 bomb.isalive = false
	 del(bombpool,bomb)
	 
	 //add_hitbox(1, bomb.x+4,bomb.y+4, 24,24, 3)
	 
 	local explosion = {}
 		explosion.x = bomb.x
 		explosion.y = bomb.y
 		explosion.hb = add_hitbox(1, explosion.x+4,explosion.y+4, 24,24, 3)
 		add(explosions, explosion)
	else
	 bomb.x += bomb.dx
	 bomb.y += bomb.dy
  bomb.timer -= 1
 end
 --update mappos	
	bomb.mapposx, bomb.mapposy = map_pos(bomb.x,bomb.y)
end

// draw_bomb
//
// draws a bomb when called on
// a given bomb, or stops drawing
// and removes a bomb from the
// pool when bomb.sprite == 0.

function draw_bomb(bomb)
  if (player.mapposx == bomb.mapposx and player.mapposy == bomb.mapposy) then
   spr(bomb.sprite,bomb.x%128,bomb.y%128)
  end
end


function update_explosion(explosion)
	local xcell = xest(explosion.x/8)
	local ycell = xest(explosion.y/8)
	local cells = {}
	for i =-1,1 do
	 for j = -1,1 do
	  local xtemp = i + xcell
	  local ytemp = j + ycell
	  local pair = {}
	  pair.xcell = xtemp
	  pair.ycell = ytemp
	  add(cells, pair)
	 end
	end
	foreach(cells,explode_tile)
	del(explosions,explosion)
	sfx(6)
end

function explode_tile(pair)
	if fget(mget(pair.xcell,pair.ycell),1) then
		if fget(mget(pair.xcell,pair.ycell),5) then
		 //pass
		else
		 sfx(7)
			mset(pair.xcell, pair.ycell,20)
	 end
	end
	del(pair)
end
-->8
-- levels and map

--copy mapdata string to clipboard
function get_mapdata(x,y,w,h)
	local reserve=""
	for i=0,w*h-1 do
		reserve..=num2hex(mget(x+i%w,y+i\w))
	end
	printh(reserve,"@clip")
end

--convert mapdata to memory data
function num2hex(v)
	return sub(tostr(v,true),5,6)
end

--replace mapdata with hex
function replace_mapdata(x,y,w,h,data)
	for i=1,#data,2 do
		mset(x+i\2%w,y+i\2\w,"0x"..sub(data,i,i+1))
	end
end
-->8
-- menu(inventory) code
function initialmenu()
 if (btnp(6) ) then
  closeinv(b)
  return true
 end
end

function openinv(b)
 clearmenu()
		menuitem(1,"close inventory", closeinv)
 	menuitem(2," slot 1 - "..player.slots[1], function() setslotflag(1) openslot(b) return true end )
 	menuitem(3," slot 2 - "..player.slots[2], function() setslotflag(2) openslot(b) return true end )
 	menuitem(4," slot 3 - "..player.slots[3], function() setslotflag(3) openslot(b) return true end )
  menuitem(5," stats and info "  )
 return true
end

function closeinv(b)
	clearmenu() 
	player.slotflag = 0
	menuitem(1, "inventory",openinv)
	menuitem(2, "save game", opensaveprompt)
	return true
end

function setslotflag(x)
 player.slotflag = x
 return true
end

function openslot(b)
	clearmenu()
		menuitem(1, "exit slot "..player.slotflag, openinv )
		displayitem(1)
		displayitem(2)
		displayitem(3)
		menuitem(5, "next page ->", nextslotpage)
	return true
end

function nextslotpage(b)
	clearmenu()
		menuitem(1, "exit slot "..player.slotflag, openinv )
		displayitem(4)
		displayitem(5)
		menuitem(4, "<- prev page",openslot)
	return true
end

function opensaveprompt(b)
 clearmenu() 
 	menuitem(1, "are you sure you")
 	menuitem(2, "want to save?")
 	menuitem(3, " yes")
 	menuitem(4, " no", closeinv)
	return true
end

function clearmenu()
		menuitem(1)
		menuitem(2)
		menuitem(3)
		menuitem(4)
		menuitem(5)
	return true
end
	
function displayitem(x)
	if (x<4) then
		if (player.working_inventory[x] == nil) then
			menuitem(x+1, "empty")
		//elseif(player.working_inventory[x] == "satchel")
		
		else
			menuitem(x+1, ""..player.working_inventory[x],function() additemtoslot(x) displayitem(x) return true end)	
		end
	elseif (x>=4) then
		if (player.working_inventory[x] == nil) then
			menuitem(x-2, "empty")
		else 
			menuitem(x-2, ""..player.working_inventory[x],function() additemtoslot(x) displayitem(x) return true end)	
		end
	end
	return true
end

function additemtoslot(x)
 for i = 1,3,1 do
  if (player.slotflag == i) then
   player.slots[i] = player.working_inventory[x]
 	end
 end
end
-->8
-- player interaction functions

--[[
interactions range from opening
chests/doors to picking up items,
and the like. all code here 
utilizes the global_faces table
which has a set of parameters to
determine which map cell the 
player is directly looking at/
will interact with.
--]]

// interaction process
function interact(face)
	openchest(face)
	opendoor(face)
	pickup_item(face)	
	//npcfuncwhendone(face)
end

// code here contains all
// small chest functionality,
// although we may add in large
// chests as well
function openchest(face)
	for k,v in pairs(global_faces) do
		if face == k then
		 update_chest(xest(player.x/8),xest(player.y/8),v[1],v[2])
		end
	end
end

// this function updates the
// state of the chest and returns
// items to the player.
function update_chest(xtemp,ytemp,xpm,ypm)
	local contentflag = false
	local loopflag = false
	local loot_table = {
	["bombs"] = {1,5},
	["keys"] = {2,1},
	["arrows"] = {3,20} }
 contentflag = fget(mget((xtemp+xpm),(ytemp+ypm)), 5)
 if ( contentflag == true) then
  for k,v in pairs(loot_table) do
   loopflag = fget(mget((xtemp+xpm),(ytemp+ypm)),v[1])
  	if loopflag == true then
  		for i,j in pairs(player.resources) do
  			if (k == i) then
  			 player.interaction = true
  			 sfx(8)
  			 mset((xtemp+xpm),(ytemp+ypm),24)
  			 j[1] += v[2]
  			 if (k=="bombs") then
  			  if (not contains(player.working_inventory,"bombs")) then
  			 	 add(player.working_inventory,"bombs")
  			 	end
  			 end
  			end	
  		end
  	end	
  end
 end
end



// this code handles the opening
// of locked doors. functionality
// here removes keys from player
// per open.
function opendoor(face)
	for k,v in pairs(global_faces) do
		if face == k then
		 update_door(xest(player.x/8),xest(player.y/8),v[1],v[2])
		end
	end
end

// updates the state of the door
// and removes the players key
function update_door(xtemp,ytemp,xpm, ypm)
 local contentflag = false
 contentflag = fget(mget((xtemp+xpm),(ytemp+ypm)), 2)
		if (contentflag == true and player.resources.keys[1] > 0) then
				player.interaction = true
			 player.resources.keys[1] -= 1
			 sfx(9)
  		mset((xtemp+xpm),(ytemp+ypm),0)
		end
end

// picks up player inventory 
// items which are meant to lie
// static on the map.	can be 
// utilized post acquisition
function pickup_item(face) 
	local xpm, ypm
	for k, v in pairs(global_faces) do
		if face == k then
		 //p_i_recieve(v[1],v[2])
		 local temp = mget(xest(player.x/8+v[1]),xest(player.y/8+v[2]))
			for i,j in pairs(player.itempool) do
				if temp == j[1] then
		 		player.interaction = true
	 			j[2] += 1
		 			
	 		 if (i != "ice boots") then
	 			 if (not contains(player.working_inventory,i)) then
	 			  add(player.working_inventory,i)
	 			 end
	 			end  
	 			if (i == "bow") then
	 				j[1] = 52
	 			end
	 			
	 			mset(xest(player.x/8+v[1]),xest(player.y/8+v[2]),0)
				end
			end
		end
	end
end
-->8
-- sword physics

// sword()
// draws sword swing! 
// creates hitbox
function sword()
		for k,v in pairs(global_faces) do
			if player.face == k then
				add_partsys(player.x + v[3],player.y + v[4], v[5],v[6], v[7], v[8], v[9],v[10], v[11],v[12],v[13])
			end
		end
end
-->8
-- optimizations and development functions
// first order of biznes
// make world coordinate to
// map cell function and vice
// versa?

// make cell estimator function
// for universal cell estimation

// cook any other code opt.


// we are going to make an x,y
// estimator function for opening
// shit/the explosion function

function xest(x)
	return flr(x+0.5)
end

function bomb_animation()
	if (sget(22,8) == 8) then
		sset(22,8,6)
	else
		sset(22,8,8)
	end
end


// draw map
//
// draws map

function draw_map()

	map(player.mapposx * 16,player.mapposy * 16,0,0,16,16)

end


// collisions
//
// reads map collions around an object
// for all 8 surrounding map cells,
// returns cell information

function mapcollisions(hb)
	// local table collisions
	local cols = {}
	//list of collisions to check
	cols.tl = false
	cols.t = false
	cols.tr = false
	cols.l = false
	cols.r = false
	cols.bl = false
	cols.b = false
	cols.br = false
	
	
	--left collisions
	local topx, topy = map_cell(hb.left-1,hb.top)		
	local botx, boty = map_cell(hb.left-1,hb.bot)
	
	for y=boty, topy, -1 do
		if fget(mget(topx, y), 0) then
			cols.l = true
		end
	end
 
 --right collisions
	local topx, topy = map_cell(hb.right+1,hb.top)		
	local botx, boty = map_cell(hb.right+1,hb.bot)
	
	for y=boty, topy, -1 do
		if fget(mget(topx, y), 0) then
			cols.r = true
		end
	end
	
	--top collisions
	local leftx, lefty = map_cell(hb.left,hb.top-1)		
	local rightx, righty = map_cell(hb.right,hb.top-1)
	
	for x=rightx, leftx, -1 do
		if fget(mget(x, lefty), 0) then
			cols.t = true
		end
	end
	
	--bottom collisions
	local leftx, lefty = map_cell(hb.left,hb.bot+1)		
	local rightx, righty = map_cell(hb.right,hb.bot+1)
	
	for x=rightx, leftx, -1 do
		if fget(mget(x, lefty), 0) then
			cols.b = true
		end
	end
	 
	--diagonals
	--sam finish this!!!!!
	local tlx, tly = map_cell(hb.left-1,hb.top-1)		
	local trx, try = map_cell(hb.right+1,hb.top-1)
	local blx, bly = map_cell(hb.left-1,hb.bot+1)
	local brx, bry = map_cell(hb.right+1,hb.bot+1)
	
	
	return cols
end

function add_hitbox(tag, x,y, xlen,ylen, duration, parent)
	hitbox = {}
	
	hitbox.tag = tag
	hitbox.x = x
	hitbox.y = y
	hitbox.xlen = xlen
	hitbox.ylen = ylen

	--[[
	--coordinates of the hb edges
	hitbox.left = hitbox.x-(.5*hitbox.xlen)	
	hitbox.right = hitbox.x+(.5*hitbox.xlen)	
	hitbox.top = hitbox.y-(.5*hitbox.ylen)
	hitbox.bot = hitbox.y+(.5*hitbox.ylen)
	--]]
	
	
	--lifetime of hb
	---set duration = -1
	---for parent-based lifetime
	hitbox.duration = duration
	
	local mapx = (hitbox.x-(hitbox.x%8))/8
	local mapy = (hitbox.y-(hitbox.y%8))/8
	hitbox.mapposx = (mapx-(mapx%16)) / 16
	hitbox.mapposy = (mapy-(mapy%16)) / 16
	
	if parent != nil then
		hitbox.parent = parent
		hitbox.mapposx = parent.mapposx
		hitbox.mapposy = parent.mapposy
		
		--hb pos offset from parent x,y pos
		hitbox.xoff = x
		hitbox.yoff = y
		
 	hitbox.x = hitbox.xoff+hitbox.parent.x
 	hitbox.y = hitbox.yoff+hitbox.parent.y
	end
	
	--coordinates of the hb edges
	hitbox.left = hitbox.x-(.5*hitbox.xlen)	
	hitbox.right = hitbox.x+(.5*hitbox.xlen)	
	hitbox.top = hitbox.y-(.5*hitbox.ylen)
	hitbox.bot = hitbox.y+(.5*hitbox.ylen)
	
	add(hitboxes, hitbox)
	return hitbox
end


function update_hitbox(hb)
	--track lifetime
	--lifetime based on duration
	if hb.duration != -1 then
		hb.duration -= 1
		if hb.duration == 0 then
			del(hitboxes, hb)
		end
	--lifetime based on parent
	else
		if hb.parent.isalive == false then
		 del(hitboxes, hb)
		end
	end
		
	--update mappos
	hb.mapposx, hb.mapposy = map_pos(hb.x,hb.y)
	if hb.parent != nil then
		hb.mapposx = hb.parent.mapposx
		hb.mapposy = hb.parent.mapposy
		
		hb.x = flr(hb.xoff+hb.parent.x)
 	hb.y = flr(hb.yoff+hb.parent.y)
		
		--coordinates of the hb edges
		hb.left = hb.x-(.5*hb.xlen)	
		hb.right = hb.x+(.5*hb.xlen)	
		hb.top = hb.y-(.5*hb.ylen)
		hb.bot = hb.y+(.5*hb.ylen)
	end
	
	--add oncollision function here!!!
 for i,j in pairs(hitboxes) do
		if j != hb then
		 -- arrows
		 if (hbcollision(hb,j)) and (hb.tag == 2) then
		 	if (j.tag == 1 and j.parent != nil) then
		 	 hb.parent.dx = j.parent.dx
		 	 hb.parent.dy = j.parent.dy
		 	 if (hb.parent.timer >= j.parent.timer) then
		 	  hb.parent.timer = j.parent.timer
		 	 elseif (hb.parent.timer < j.parent.timer) then
		 	  j.parent.timer = hb.parent.timer
		 	 end
		 	end		
			end 
		end
	end	

	
end

--for debug purposes only
function draw_hitbox(hb)	
	if (player.mapposx == hb.mapposx and player.mapposy == hb.mapposy) then
		rect(hb.left%128,
							hb.top%128,
							hb.right%128,
							hb.bot%128, 8)
	end
end


--returns the map cell containing x,y
function map_cell(x,y)
	local mapx = (x-(x%8))/8
	local mapy = (y-(y%8))/8
	
	return mapx, mapy
end

function map_pos(x,y)
	local mapx = (x-(x%8))/8
	local mapy = (y-(y%8))/8
	local mapposx = (mapx-(mapx%16)) / 16
	local mapposy = (mapy-(mapy%16)) / 16
	return mapposx, mapposy
end

function contains(table, element)
  for key, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function hbcollision(updhb, othhb)
 	local c1 = updhb.top <= othhb.bot
 	local c2 = updhb.bot >= othhb.top
 	local c3 = updhb.left <= othhb.right
 	local c4 = updhb.right >= othhb.left
		if (c1 and c2 and c3 and c4) then
	 	return true
		else 
	 	return false
		end
end

function add_object(mapposx,
																				mapposy,
																				xpos,
																				ypos)
	local obj = {}
	obj.x = xpos
	obj.y = ypos
	obj.dx = 0
	obj.dy = 0
	obj.mapposx = mapposx
	obj.mapposy = mapposy
	obj.isalive = true
	return obj
end

function set_movement_from_face(object,
																																input_face,
																																speed)
	if (input_face == 0 or input_face ==3 or input_face ==5) then
		object.x += (object.mapposx*128 - 8) // world space
		object.dx = -(speed)
	--right
 elseif (input_face ==2 or input_face ==4 or input_face ==7) then
	 object.x += (object.mapposx*128 + 8) // world space
		object.dx = speed
	else
		object.x += object.mapposx*128
		object.dx = 0
	end
	
	--up 
 if (input_face ==0 or input_face ==1 or input_face ==2) then
		object.y += object.mapposy*128 - 8 // world space
		object.dy = -(speed)
	--down
	elseif (input_face ==5 or input_face ==6 or input_face ==7) then
		object.y += (object.mapposy*128 + 8) // world space
		object.dy = speed
	else
		object.y += object.mapposy*128
		object.dy = 0
	end																													
end
-->8
-- arrows and bow
// this tab contains code for
// the arrows utilized in bow
// combat. if a "combat" tab
// is formalized later, this 
// code will be moved there.


function add_arrow(parent)
	local arrow = add_object(parent.mapposx,parent.mapposy,parent.x%128,parent.y%128)
	local input_face = parent.face
	
	set_movement_from_face(arrow,input_face,2.002)
	
	arrow.timer = 40
	
	if ((arrow.dx == 0) or (arrow.dy == 0)) then
		if arrow.dx == 0 then
			arrow.sprite = 39
		else
			arrow.sprite = 41
		end
	else 
	 arrow.sprite = 40
	 arrow.x = flr(arrow.x)
  arrow.y = flr(arrow.y)
	 arrow.dx*=.75
	 arrow.dy*=.75
	end
	
	arrow.flipx = false
	arrow.flipy = false
	
	if player.face == 5 then
		arrow.flipy = true
	elseif (player.face == 7 or player.face == 6 or player.face == 4) then
		arrow.flipx = true
		arrow.flipy = true
	elseif player.face == 2 then
		arrow.flipx = true
	end
	
	if (arrow.sprite == 40) then
	 arrow.x = flr(player.x)+0.5
  arrow.y = flr(player.y)+0.5
	end
	
	arrow.hb = add_hitbox(1,4,4,4,4,-1,arrow)
	
	add(arrowpool, arrow)
end


function update_arrow(arrow)
	if	arrow.sprite == 40 then
	 if (arrow.dx ==0 or arrow.dy == 0) then
			arrow.dx = 0
			arrow.dy = 0
			arrow.timer = 0
		--[[	
	 elseif (mapcollisions(arrow.hb).tr or mapcollisions(arrow.hb).tl 
	or mapcollisions(arrow.hb).bl or mapcollisions(arrow.hb).br) then	
			arrow.dx = 0
			arrow.dy = 0
			arrow.timer = 0
			--]]
		end
	end
	
	if ( mapcollisions(arrow.hb).r or mapcollisions(arrow.hb).l) then
	 arrow.dx = 0 
	 arrow.dy = 0
	 arrow.timer = 0
	end
	if ( mapcollisions(arrow.hb).t or mapcollisions(arrow.hb).b) then
		arrow.dy = 0
		arrow.dx = 0
		arrow.timer = 0
	end

	
	--update mappos
	arrow.mapposx, arrow.mapposy = map_pos(arrow.x, arrow.y)
	
	if (arrow.timer == 0 or (arrow.dx == 0 and arrow.dy == 0) ) then 
	 sfx(10)
	 del(arrowpool,arrow)
	 arrow.isalive = false
	else
	 arrow.x += arrow.dx
		arrow.y += arrow.dy
		arrow.timer -= 1
	end
end

function draw_arrow(arrow)
	if (player.mapposx == arrow.mapposx and player.mapposy == arrow.mapposy) then
		spr(arrow.sprite,arrow.x%128,arrow.y%128,1.0,1.0,arrow.flipx,arrow.flipy)
 end
end
__gfx__
00000000000000001111111111111111222222222ff7f22222ff2222222fff22222222222222222200000000222222222222222222222222222222222ff7f222
0000000000005500111cc11111111111222222222f7ff22222ff22222222fff22222222222222222000880002ff222222f62222222ffff22222222222ffff6f2
007007000005550011cccc11111111112ff2222222ffff2f222ff222222ff7f2222222ffff22222200888800222f7ff2226fff222fffcff22222fff222ff6ff2
0007700000056550117cc71111111111ffffffff2222ffff222ff222ffff7f2222222f7ffef222220078870022ff67f222ffffe2ff6feff222fffff222ffff22
000770000055d6501c0cc0c111111111f22fffff22222fff222ff222ff7ff2222222fff2ffff22220808808022f7cf2222fefff2ffeffff222fcff2222f6f222
007007000056dd501ccccc4111111111222ff222222222ff222ff22222f222222222f7f22f7622220888888022f7f22222fffff22fffff222ffef222222fef22
000000000055555011c1144111111111222222222222222222ff2222222222222222ff222f6ff2220080080022ff2222222fff22222222222fcff2222222ff22
000000000000000011c11c111111111122222222222222222ff7f22222222222222f7f222ffff222008008002222222222222ff22222222222ff222222222222
22222222880000cc00000780fff777ff06000006cccccccc2ff7f222222222220000000000000000000000000000000000000000454444544544445445444454
22222222880000cc00007000ffffff7f60d06060cccccc6c2f7ff222222222220000000005455450054554500545545005455450555555555555555555555555
222222ffdd0000dd00077000ffdfffff06006d00cc6ccc7622ffff2f22fffff20444444045455454454554544545545445455454454444544566665445444454
fff22f7fdd0000dd00555500ffffffff00d006d0cc76ccc7f22fefff2ffffeff50000005555aa555555aa555555aa555555aa5555555aa254566665445444454
f77ffff2dd0000dd05111150ffffffff60000000cc676cccf6ff2fff2ffef6ff400aa004444aa444444aa444444aa444444aa4444544aa244566665445444454
2ffff7f2add00dda05111150ffffffff0006d060ccc67cccfff222ff2ffcfff25445544554455445544554455445544554455445454444544566665445444454
222fff220dddddd005111150ffdfffff600000006ccccccc6f22222222ffff225445544554455445544554455445544554455445555555555555555555555555
222f7f2200adda0000555500ffffffff06d60060c6cccccc22222222222222225445544554455445544554455445544554455445454444544544445445444454
11111111111111111111111111111111111111111111111111111111000040000000000000000000005440000000000000000000000000000000000055555555
111cc111111cc111111cc111111cc111111cc111111cc111111cc111000444000440000000000000007004000000000000000000000000000000000050000005
11cccc1111cccc1111ccdc1111cdcc1111ccdc1111cccc1111cccc110000f00004f00000040000770070004006400000000bb000000000000000000050000005
1cc7cc7117cc7cc111ccdc7111cdcc1117ccdc111c7cc711117cc7c10000f000000f000044fffff0007000906446000000bbbb00000bb0000000000050000005
1cc0cc0110cc0cc11ccdcc011cdcccc110cdccc11c0cc0c11c0cc0c10000f0000000f0000400007700700040644466000b7bb7b00bbbbbb0000bb00050000005
1ccccc411cccc4c11ccdccc11cdcccc114cdccc11ccccc411ccccc410000f00000000f700000000000700040644444670bbbbbb0b7bbbb7b0bbbbbb050000005
11cc144111c1c41111c1cc1114c11c1114cc1c1111cc1c4111c1c4410007f700000007f70000000000700400644c4cc70bbbbbb0bbbbbbbbb7bbbb7b50000005
11c11c1111c11c1111c11c1111c11c1111c11c1111c11c1111c11c110007070000000070000000000054400007c7c77000bbbb0000bbbb000bbbbbb050000005
f544445f00000000000000000555d55000a660000222200000022222000222200222220000e007e0000000000000006600000000000000000000000000000000
55ffff550099990000999900555d555500700600002222000022222000222200000222200e3e73700444000000000676000bb000000000000000000000000000
f444444f0975579009999990555d55550070006000272700007272000072270000027270e3333337004460000000676000bbbb00000000000000000000000000
f444444f97755779999559995555d555007000a00320f030030f0230030ff03000330f00073993700006640000067600007bb700000000000000000000000000
f444444f977557799955559955555dd50070006003333330033333300333333000f333300e39933e004e3e40906760000bbbbbb0000000000000000000000000
f444444f0975579009999990555dd55d007000600f3334f00f3334f00f3334f000f333400733333704439340099600000bbbbbb0000000000000000000000000
55ffff55009999000099990055d55555007006000f5555f00f5555f00f5555f000055500733776e000433740059000000bbbbbb0000000000000000000000000
f544445f00000000000000000d55555000a660000050050000500500005005000005050007e00000000444005009000000bbbb00000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
603030303030303030303030303030303030303030303030303030303030303080d0007140404001404040404040409030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306051510000101060000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306051000000000060000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306000000093939360000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306000000093939360000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306000000093930060000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306010000000000060000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030305040900000804070000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030308040700000504090000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306000000000000060000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
603030303030303030303030303030303030303030303030303030303030303060000000000000f0000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030301000000000000010000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030300000000000000010000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
6030303030303030303030303030303030303030303030303030303030303030e0000000000000e0000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030306000000000000060000000000000006030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030305040404090008070404040404040407030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030304040404030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
50404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404070
__label__
66626222666262626662666222226662666266626662666226622662622222222222222222222222222222222222222222222222222222222222222222222222
62626222626262626222626222222622262262226662626262626262622222222222222222222222222222222222222222222222222222222222222222222222
666262ff6662666266f266222ff2262226f266226f6266626f6262626ff22222222222ff2ff222222ff222222ff222222ff222222ff222222ff22222222222ff
62226f7f6f6fff6f6fff6f6ffffff6fff6ff6fff6f6f6fff6f6f6f6f6ffffffffff22f7ffffffffffffffffffffffffffffffffffffffffffffffffffff22f7f
62226662626f666f666f6f6ff62f666ff62f666f626f6fff662f66ff666ffffff77ffff2f22ffffff22ffffff22ffffff22ffffff22ffffff22ffffff77ffff2
2222f7f2222ff222222ff222222ff222222ff222222ff222222ff222222ff2222ffff7f2222ff222222ff222222ff222222ff222222ff222222ff2222ffff7f2
6662ff2222222222222222222222222222222222222222222222222222222222222fff22222222222222222222222222222222222222222222222222222fff22
626f7f2222222222222222222222222222222222222222222222222222222222222f7f22222222222222222222222222222222222222222222222222222f7f22
626f22221111111111111111111111111111111111111111111111111111111122ff222211111111111111111111111111111111111111111111111122ff2222
626f22221111111111111111111111111111111111111111111111111111111122ff222211111111111111111111111111111111111155111111551122ff2222
666ff22211111111111111111111111111111111111111111111111111111111222ff222111111111111111111111111111111111115551111155511222ff222
222ff22211111111111111111111111111111111111111111111111111111111222ff222111111111111111111111111111111111115655111156551222ff222
666ff66266616661166111111111111111111111111111111111111111111111222ff222111111111111111111111111111111111155d6511155d651222ff222
626f626266616161611111111111111111111111111111111111111111111111222ff222111111111111111111111111111111111156dd511156dd51222ff222
66ff62626161661166611111111111111111111111111111111111111111111122ff222211111111111111111111111111111111115555511155555122ff2222
6f676262616161611161111111111111111111111111111111111111111111112ff7f2221111111111111111111111111111111111111111111111112ff7f222
666f66226161666166111111111111111111111111111111111111111111111122ff222211544111111111111111111111111111111111111111111122ff2222
22ff22221111111111111111111155111545545111111111111111111111111122ff222211711411111155111111111111111111111155111111111122ff2222
666ff22211111111111111111115551145455454111111111111111111111111222ff222117111411115551111111111111111111115551116411111222ff222
626ff222111111111111111111156551555aa555111111111111111111111111222ff222117111911115655111111111111111111115655164461111222ff222
626ff22211111111111111111155d651444aa444111111111111111111111111222ff222117111411155d65111111111111111111155d65164446611222ff222
626ff22211111111111111111156dd5154455445111111111111111111111111222ff222117111411156dd5111111111111111111156dd5164444467222ff222
666f22221111111111111111115555515445544511111111111111111111111122ff22221171141111555551111111111111111111555551644c4cc722ff2222
2ff7f222111111111111111111111111544554451111111111111111111111112ff7f222115441111111111111111111111111111111111117c7c7712ff7f222
626f6662616116611111111111111111111111111111111111111111111111112ff7f22222222222222222221111111111111111111111111111111122ff2222
626f6222616161111111111111111111111111111111551111111111111111112f7ff22222222222222222221111111111111111111111111111111122ff2222
662f66226661666111111111111111111111111111155511111111111111111122ffff2f2ff22222ff22222211111111111111111111111111111111222ff222
626f6222116111611111111111111111111111111115655111111111111111112222fffffffffffffef2222211111111111111111111111111111111222ff222
626f6662666166111111111111111111111111111155d651111111111111111122222ffff22fffffffff222211111111111111111111111111111111222ff222
222ff222111111111111111111111111111111111156dd511111111111111111222222ff222ff2222f76222211111111111111111111111111111111222ff222
666f22221111111111111111111111111111111111555551111111111111111122222222222222222f6ff2221111111111111111111111111111111122ff2222
6f67f2221111111111111111111111111111111111111111111111111111111122222222222222222ffff222111111111111111111111111111111112ff7f222
626f22221111111111111111111111111111111111111111111111111111111111111111111111112ff7f2222222222211111111111111111111111122ff2222
626f22221111111111115511111111111111111111111111111111111111111111111111111111112f7ff22222ffff2211111111111111111111111122ff2222
666ff22211111111111555111111111111111111111111111111111111111111111111111111111122ffff2f2fffcff2111111111111111111111111222ff222
222ff2221111111111156551111111111111111111111111111111111111111111111111111111112222ffffff6feff2111111111111111111111111222ff222
666f6662666116616165d6611111111111111111111111111111111111111111111111111111111122222fffffeffff2111111111111111111111111222ff222
626f62626161616161666d5111111111111111111111111111111111111111111111111111111111222222ff2fffff22111111111111111111111111222ff222
666f6622661161616165666111111111111111111111111111111111111111111111111111111111222222222222222211111111111111111111111122ff2222
6f67626261616161666111611111111111111111111111111111111111111111111111111111111122222222222222221111111111111111111111112ff7f222
626f626261616611666166111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111112ff7f222
22ff222211111111111111111111111111111111111111111111111111115511111111111111111111115511111111111111111111111111111111112f7ff222
666ff222111111111111111111111111111111111111111111111111111555111111111111111111111555111111111111111111111111111111111122ffff2f
626ff22211111111111111111111111111111111111111111111111111156551111111111111111111156551111111111111111111111111111111112222ffff
626ff2221111111111111111111111111111111111111111111111111155d65111111111111111111155d6511111111111111111111111111111111122222fff
626ff2221111111111111111111111111111111111111111111111111156dd5111111111111111111156dd5111111111111111111111111111111111222222ff
666f2222111111111111111111111111111111111111111111111111115555511111111111111111115555511111111111111111111111111111111122222222
2ff7f222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111122222222
2ff7f222222222222222222222222222111111111111111111111111111111111111111111111111222222222222222222222222111111111111111111111111
2f7ff222222222222222222222222222111111111111111111111111111111111111111111111111222222222222222222222222111111111111111111111111
22ffff2f2ff222222ff22222ff222222111111111111111111111111111111111111111111111111222222ff2ff22222ff222222111111111111111111111111
2222fffffffffffffffffffffef2222211111111111111111111111111111111111111111111111122222f7ffffffffffef22222111111111111111111111111
22222ffff22ffffff22fffffffff22221111111111111111111111111111111111111111111111112222fff2f22fffffffff2222111111111111111111111111
222222ff222ff222222ff2222f7622221111111111111111111111111111111111111111111111112222f7f2222ff2222f762222111111111111111111111111
2222222222222222222222222f6ff2221111111111111111111111111111111111111111111111112222ff22222222222f6ff222111111111111111111111111
2222222222222222222222222ffff222111111111111111111111111111111111111111111111111222f7f22222222222ffff222111111111111111111111111
2222222222222222222222222ff7f222222222222222222211111111111111112222222222222222222fff2222222222222fff22111111111111111111111111
2ff222222f6222222f6222222f7ff2222222222222222222111111111111111122222222222222222222fff2222222222222fff2111111111111111111111111
222f7ff2226fff22226fff2222ffff2f2ff22222ff2222221111111111111111222222ff2ff22222222ff7f2222222ff222ff7f2111111111111111111111111
22ff67f222ffffe222ffffe22222fffffffffffffef22222111111111111111122222f7fffffffffffff7f2222222f7fffff7f22111111111111111111111111
22f7cf2222fefff222fefff222222ffff22fffffffff222211111111111111112222fff2f22fffffff7ff2222222fff2ff7ff222111111111111111111111111
22f7f22222fffff222fffff2222222ff222ff2222f76222211111111111111112222f7f2222ff22222f222222222f7f222f22222111111111111111111111111
22ff2222222fff22222fff2222222222222222222f6ff22211111111111111112222ff2222222222222222222222ff2222222222111111111111111111111111
2222222222222ff222222ff222222222222222222ffff2221111111111111111222f7f222222222222222222222f7f2222222222111111111111111111111111
2222222222222222222222222222222222222222222fff2211111111111111112ff7f2222222222222222222222fff2211111111111111111111111111111111
2f6222222ff222222222222222222222222222222222fff211111111111111112f7ff22222222222222222222222fff211111111111111111111111111111111
226fff22222f7ff2222222ff2ff222222ff22222222ff7f2111111111111111122ffff2f2ff222222ff22222222ff7f211111111111111111111111111111111
22ffffe222ff67f222222f7fffffffffffffffffffff7f2211111111111111112222ffffffffffffffffffffffff7f2211111111111111111111111111111111
22fefff222f7cf222222fff2f22ffffff22fffffff7ff222111111111111111122222ffff22ffffff22fffffff7ff22211111111111111111111111111111111
22fffff222f7f2222222f7f2222ff222222ff22222f222221111111111111111222222ff222ff222222ff22222f2222211111111111111111111111111111111
222fff2222ff22222222ff2222222222222222222222222211111111111111112222222222222222222222222222222211111111111111111111111111111111
22222ff222222222222f7f2222222222222222222222222211111111111111112222222222222222222222222222222211111111111111111111111111111111
2222222222222222222fff2211111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111122222222
22222222222222222222fff211111111111111111111111111111111111111111111111111111111111111111111551111115511111155111111111122222222
222222ff2ff22222222ff7f2111111111111111111111111111111111111111111111111111111111111111111155511111555111115551111111111222222ff
22222f7fffffffffffff7f2211111111111111111111111111111111111111111111111111111111111111111115655111156551111565511111111122222f7f
2222fff2f22fffffff7ff22211111111111111111111111111111111111111111111111111111111111111111155d6511155d6511155d651111111112222fff2
2222f7f2222ff22222f2222211111111111111111111111111111111111111111111111111111111111111111156dd511156dd511156dd51111111112222f7f2
2222ff2222222222222222221111111111111111111111111111111111111111111111111111111111111111115555511155555111555551111111112222ff22
222f7f222222222222222222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111222f7f22
22ff2222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111122ff2222
22ff2222111111111111111111115511111111111111111111111111111111111111111111111111111111111111111111111111111155111111551122ff2222
222ff2221111111111111111111555111111111111111111111111111111111111111111111111111111111111111111111111111115551111155511222ff222
222ff2221111111111111111111565511111111111111111111111111111111111111111111111111111111111111111111111111115655111156551222ff222
222ff22211111111111111111155d6511111111111111111111111111111111111111111111111111111111111111111111111111155d6511155d651222ff222
222ff22211111111111111111156dd511111111111111111111111111111111111111111111111111111111111111111111111111156dd511156dd51222ff222
22ff2222111111111111111111555551111111111111111111111111111111111111111111111111111111111111111111111111115555511155555122ff2222
2ff7f22211111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111112ff7f222
22ff222211111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111112ff7f222
22ff2222111111111111111111115511111155111111111111111111111111111111111111cc111111111111111111111111111111111111111155112f7ff222
222ff22211111111111111111115551111155511111111111111111111111111111111111cccc111111111111111111111111111111111111115551122ffff2f
222ff2221111111111111111111565511115655111111111111111111111111111111111cc7cc71111111111111111111111111111111111111565512222ffff
222ff22211111111111111111155d6511155d65111111111111111111111111111111111cc0cc011111111111111111111111111111111111155d65122222fff
222ff22211111111111111111156dd511156dd5111111111111111111111111111111111ccccc411111111111111111111111111111111111156dd51222222ff
22ff222211111111111111111155555111555551111111111111111111111111111111111cc14411111111111111111111111111111111111155555122222222
2ff7f22211111111111111111111111111111111111111111111111111111111111111111c11c111111111111111111111111111111111111111111122222222
22ff2222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
22ff2222154554511111111111111111111155111111111111111111111111111111111111111111111111111111111111111111111111111111111111115511
222ff222454554541111111111111111111555111111111111111111111111111111111111111111111111111111111111111111111111111111111111155511
222ff222555aa5551111111111111111111565511111111111111111111111111111111111111111111111111111111111111111111111111111111111156551
222ff222444aa44411111111111111111155d651111111111111111111111111111111111111111111111111111111111111111111111111111111111155d651
222ff2225445544511111111111111111156dd51111111111111111111111111111111111111111111111111111111111111111111111111111111111156dd51
22ff2222544554451111111111111111115555511111111111111111111111111111111111111111111111111111111111111111111111111111111111555551
2ff7f222544554451111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
22ff2222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
22ff2222111111111111111111115511111111111111551111111111111111111111111111111111111111111111111111111111111111111111551111115511
222ff222111111111111111111155511111111111115551111111111111111111111111111111111111111111111111111111111111111111115551111155511
222ff222111111111111111111156551111111111115655111111111111111111111111111111111111111111111111111111111111111111115655111156551
222ff22211111111111111111155d651111111111155d65111111111111111111111111111111111111111111111111111111111111111111155d6511155d651
222ff22211111111111111111156dd51111111111156dd5111111111111111111111111111111111111111111111111111111111111111111156dd511156dd51
22ff2222111111111111111111555551111111111155555111111111111111111111111111111111111111111111111111111111111111111155555111555551
2ff7f222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
22ff2222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
22ff2222111111111111551111115511111111111111111111111111111111111111111111111111111111111111111111111111111111111111551111111111
222ff222111111111115551111155511111111111111111111111111111111111111111111111111111111111111111111111111111111111115551111111111
222ff222111111111115655111156551111111111111111111111111111111111111111111111111111111111111111111111111111111111115655111111111
222ff222111111111155d6511155d651111111111111111111111111111111111111111111111111111111111111111111111111111111111155d65111111111
222ff222111111111156dd511156dd51111111111111111111111111111111111111111111111111111111111111111111111111111111111156dd5111111111
22ff2222111111111155555111555551111111111111111111111111111111111111111111111111111111111111111111111111111111111155555111111111
2ff7f222111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
2ff7f222222222222222222211111111111111112222222222222222222222222222222222222222222222222222222211111111111111111111111111111111
2f7ff222222222222222222211115511111155112222222222222222222222222222222222222222222222222222222211115511111155111111111111111111
22ffff2f2ff22222ff2222221115551111155511222222ff2ff222222ff222222ff222222ff222222ff22222ff22222211155511111555111111111111111111
2222fffffffffffffef22222111565511115655122222f7ffffffffffffffffffffffffffffffffffffffffffef2222211156551111565511111111111111111
22222ffff22fffffffff22221155d6511155d6512222fff2f22ffffff22ffffff22ffffff22ffffff22fffffffff22221155d6511155d6511111111111111111
222222ff222ff2222f7622221156dd511156dd512222f7f2222ff222222ff222222ff222222ff222222ff2222f7622221156dd511156dd511111111111111111
22222222222222222f6ff22211555551115555512222ff2222222222222222222222222222222222222222222f6ff22211555551115555511111111111111111
22222222222222222ffff2221111111111111111222f7f2222222222222222222222222222222222222222222ffff22211111111111111111111111111111111

__gff__
0003000001010101010100010101010101010000000101010123252931050101000000000000000000000101000000000100000901000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0804040404040404100404040404041010040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040408040404040404040404040404040409040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040409
0603030303030303060303030301010606030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030306040303030303030303030303030303030303030303030303030303030303030303030303030304040403030303030306
0603030119030303062a010303012b0606010303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000003151515030303030303030303030306030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303010303050409030303030606031a03080903030303010101010303000000000000000000000000000000000000000000000000000000000000000003151503031503030303030303030306030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603010303030303033a050d0303030606030804070f03030301030303030103000000000000000000000000000000000000000000000000000000000000000003030303150303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030301030303030303030516040703030303030103030303030301000000000000000000000000000000000000000000000000000000000000000003031515030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0504040903030303030308040903030303030303030303030103030303030301000000000000000000000000000000000000000000000000000000000000000003031515030303390303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0b0c0c0504090303080407080703030303030303030303030103030333030301000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0c0b080404070303050404070303030303030303030303030103030303030301000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
080407030303030303033b010303030810040d03030303030301030303030103000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0611030103030303030303030303010606030303030303030303010101010303000000000000000000000000000000000000000000000000000000000000000303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030101030303030000000003010507030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0619030301030303030000000003030103030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030000000003000103030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603010303030303030000000000000303030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0504090303080404040404090100030303030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0804070303050404040404070303030303030303030303030303030303030303030303000303030303030303030303030303030303030303030303030303000303030303030303030303030303030303080404040404040404040404040404090000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303061515151515000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303061515151515000000000000000000060000000000000000000000000000000003030303030303030303030303030306
060303030303030303030303030303030303030308040d0317040409030303030303031f1f1f1f1f1f1f0303030303030303030303030303030303030303030303030303030303030303030303030303061515151515000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303031f1e1f1e1f0303030303030303030601010101010106030303030303031f30303030301f0303030303030303030303030303030303030303030303030303030303030303030303030303061515151515000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303031f0319031f030303030303030303060101010101010f030303030303031f30303030301f0303030303030303030303030303030303030303030303030303030303030303030303030303061515151500000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303031f0303031f0303030303030303030f01010101010103030303030303031f30303030301f0303030303030303030303030303030303030303030303030303030303030303030303030303061515150000393939390000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303031f1e1d1e1f030303030303030303030101013401010e030303030303031f30303030301f0303030303030303030303030303030303030303030303030303030303030303030303030303060000000000393939390000000000060000000000000000000000000000000003030303030303030303030303030306
06030303030303030303030303030303030303030e01010101010106030303030303031f1f1f2f1f1f1f0303030303030303030303030303030303030303030303030303030303030303030303030303000000000000393939390000000000000000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303060101010101010603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303000000000000393939390000000000000000000000000000000000000000000003030303030303030303030303030306
060303030303030303030303030303030303031b0504040d0317040703030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060000000000000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060100000000000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060101000000000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060101000000000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060101010000000000000000000000060000000000000000000000000000000003030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303050404040404090000080404040404070000000000000000000000000000000003030303030303030303030303030306
__sfx__
490104000d0730807003070010750d0001f0001f0001d0001d0001d0001d0001d0001d0001d0001d000210001f000210001f000210002100021000210001f0001f0001f0001f0001f0001f0001f0001f00000000
150308003f6433f6303f6203361033610336151b0001b0001b0001b0001b0001b0001b0001b0001f0001f0001d0001f000220002200022000220001d0001d0001d0001d0001d0001d0001d0001d0000000000000
011800100700013000136001360007000130001360013000070001300013000130001360011000136001100007000000001460016600070000000014600166000700000000070001460014600146001460000000
011000100500011000116001360005000130001360011000050000000000000000001360011000136001100000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f0001f0001f0001f0001f0001f0001f0001f0001d0001d0001d0001d0001d0001d0001d0001d000210001f000210001f000210002300026000240002300023000230002300023000230002300023000
011000001d0001d0001d0001d0001d0001d0001d0001d0001b0001b0001b0001b0001b0001b0001b0001b0001f0001d0001b000180001d0001b00018000110002100021000210002100021000210002100021000
030700001064015640176301063017620136201761010610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
110700001364010640106301063010620106201061010610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
490c00000f655000000000000000000000000000000000001f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002d6232d625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000027610276102a6202c6332e6551a0001a0001a0001a0001a0001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011900002c624206152061314615206132061508035206152c645206452063520635206252062508615206152c623206152061320615206132061508035206152c62420615206152061508032080330803514135
9119000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c10000000181301b1301d1301f130
913200002012020120201202012020120201201b1201b1201d1201d1201d1201d1201d1201d1201b120191201b1201b1201b1201b120141201412014120141201612016120161201612011120111201112011120
4d190020080350a0350f035130351403500000070350803514000140350f0350a0350f0350000008030010300503205032050320503203035050320303205032050320303505035030350503005035080350a035
011900202c624206152062314615080432061520525206152c645206452063520635206252062508615206152c63320615206231461508023206151d525205250502520615206152061508623206000802514125
4d190020300352e0352c0352e0302c031290302703229032290352903514031140351403514035140351403111035110350c0350c0350f0350f0350a0350a0350c0350c035030350303505045050450504505045
4d190020080350a0320f0321303214035000000f0321303214035160321b0321f03420035200252002520022050310503205032050320303005030030340503003034050300a0350c0350f030140300f0350f035
011900202c6142061520613146150804320615205252061508033206252061420625206152061508615206150804320645080432c635080332062520615206150561320615206232061508613206150862314615
913200000812008122081220812008120081250a1350a1301d1311b1221d1221b1221b1201b1251d135161450812008122081220812014125161251b125201252212224122221222412222122201221d1221b122
91320000081331b6251b6151b61508133203311b6151b615051331b6251b6151b615051331d3311b6151b615081331b6251b6151b61508133203311b6151b615051331b6251b6151b615111300f1300c1300a130
9119002022135201351d135201301b1311d130181321b1321d1351d135381313813538135381353813538131351323813235135331003313235132331350a1003013233132301352e135301422e1422c14529145
91190000081331b6001b6251b6001b625203001b6251b600081331b6001b6251b615051331d3311b6251b615051331b6001b6251b6001b6251b6001b6152e10005133221001d3313a1001b625331001b6152e100
911900202013522132271322b1322c135001001b1321f1322013522132271322b1342c1352c1252c1152c1121d1311d1321d1321d1321b1301d1301b1341d1300f134111312213518135271312c130331353f135
991b00201f6101d6101a61018610186101761015610136101161010610106100e6100e6100c6100e6101061011610136111561017610186101a6101c6101d6101f61021610236102461026610286102861024610
313600002003520300000000000000000000001b035000001d03500000000000000000000000001b035190351b0321b0321b03500000140321403214035000001603516000160350000011035050000503500000
911b0020080350a0350f035130351403500000070350803514000140350f0350a0350f0350000008030010300503205032050320503203035050320303205032050320303505035030350503005035080350a035
911b0020080350a0350f0351303514035000000f0321303214035160351b0321f03220035207252072020720050310503205032050320303505032030320503203032050350a0350c0350f030140350f0350f035
611000001f0201f0201f0201f0201f0201f0201f0201f0201d0201d0201d0201d0201d0201d0201d0201d020210201f020210201f020210202102021020210201f0201f0201f0201f0201f0201f0251f0251f025
611000001f0201f0201f0201f0201f0201f0201f0201f0201d0201d0201d0201d0201d0201d0251d0251d025210201f020210201f020210202302026020240202302023020230202302023020230252302523025
611000001d0201d0201d0201d0201d0201d0201d0201d0201b0201b0201b0201b0201b0201b0201b0201b0201f0201f0201d0201f020220202202022020220201d0201d0251d0201d0201d0251d0251d0251d025
611000001d0201d0201d0201d0201d0201d0201d0201d0201b0201b0201b0201b0201b0201b0251b0251b0251f0201d0201b020180201d0201b02018020110212102421025210222102021025210252102521025
011000100704513015136251362507045130151362513015070451300013000130001362511015136251101507000000001460016600070000000014600166000700000000070001460014600146001460000000
011000100504511015116251362505045130151362511015050450000000000000001362511015136251101500000000000000000000000000000000000000000000000000000000000000000000000000000000
0118000009875139001c9001c9251c9250c8001c9251c90009875139001c925000001c925098751c9251c90009875139001c9001c9251c9250c8001c9251c90009875139001c925000001c9250c8001c9251b400
4f18000002050020000000000050020500000000000000500205000000000000005002050000000000005050070500000000000050500705000000000000505007050000000000005050070501f4001d40005053
7f1800000e0520e0520e0520e0520e0520e0520e0520e0520e0520f0520e0520f0520c0520c0550c0000b0000905209052090520905209052090520905209052090520a052090520a05207052070550700007000
1b1800001a5001a5001a5001a5001a5001a5001a5001a5001a5001b5001a5001b50018500185001a1001d1001f10018100181001d1001f10018100181001d100261352413526131271311e1351f1351b1351b135
031800001a1351b1001d100181351a1351810018100181351a1351a1351a135181301a135181351a1351d1321f13535400374001d1321f135294002b4001d1321f1351f1351f1351d1301f1351d1321f13222135
4f180000020520205202052020520205202052020520205202052030520205203052000520005503015070250905209052090520905209052090520905209052090520a052090520a05207052070550502503015
4f180000020500e0451a04500050020500e0451a0450005002050020250202500050020500000000000050500705000000000000505007050130251f025050500705000000000000505007050354353743535435
031800001a1351a1353e115181351a1353c1153e115181351a1351a1351a135181301a135181351a1351d1321f13535435374351d1321f135294352b4351d1321f1351f1351f135351303713535132371323a135
1f180000324251b4001d4003043132435184001840030435324353243532435304303243530435324353543237435354353743535432374353543537435354323743537435374353543037435294322b4322e435
1f180000264353c7152d43524335263353c7142433029330263303971529335397152633024335263352e3352b3453772526340293452b3453a73237722293402b1452b1352b125291452b3453a7323772213043
4f1800000205500055020550005502055000000005409050070550505507055050550005502050020450e00009055070520905207055090550c0551f000070540905507055090550c05507055090550505507055
2718000026132001002d132291322613224132211322413226132001002d132291322613200100291322613221132001002813224132211321f13221132241322d1352d1352b1352b135281322d1322413228132
4f1800000205500055020550005502055000000005409050070550505507055050550005502050020450e00009055070520905207055090550c0551f000070540905507055040550005509055050550705509055
2718000026332003002d332293322633200300213322433226332243322d332293322633229332293322633221332003002833224332213321f3322133224332283322433228332303322d332293322b33228333
27180000263322633226332263322633226332263322633226332273322633227332243322433524335213332133221332213322133221332213322133221332213322232221322223221f5521c5521855226553
3b1800001a5521a5521a5521a5521a5521a5521a5521a5521a5521b5521a5521b5521855218555185251555315552155521555215552155521555215552155521555216552155521655213552135551352502053
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
602000001880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 1c204344
00 1d204344
00 1e214344
02 211f4344
00 0b0c4344
01 0d0e0f44
00 0d110f44
00 170e0f44
00 11161744
00 10121344
02 10141544
01 18191a44
02 18191b44
00 22234344
00 22234344
00 22244b44
00 22242544
01 22232644
00 22232944
00 22282a44
00 22282b44
00 222c2d44
00 222e2f44
00 22243044
02 22243144

