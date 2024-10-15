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
	hitboxes = {}
	make_player()
	bombpool = {}
	explosions = {}
	arrowpool = {}
	particlesystems = {}
	particles = {}
	npc1 = make_npc(1,0,70,35,1,1)
	npc2 = make_npc(0,0,8,16,0,1)
	//music(0)
	
	--testing
	
end

// routine updates every frame
// using designed update funcs.
function _update()
	update_player()
	foreach(bombpool,update_bomb)
	foreach(explosions,update_explosion)
	foreach(arrowpool,update_arrow)
	update_npc(npc1)
	update_npc(npc2)
	foreach(particlesystems, update_partsys)
	foreach(particles, update_particle)
	foreach(hitboxes, update_hitbox)
end



// routine updates every frame
// using designed update funcs.
function _draw()
	cls(1)
	bomb_animation()
	draw_map()
	draw_player()
	foreach(arrowpool,draw_arrow)
	foreach(bombpool,draw_bomb)
	draw_npc(npc1)
	draw_npc(npc2)
	
	foreach(particles, draw_particle)
	
	// debug menu setup for
	// debugging info within game
// debug:
	--[[print("x: ")
	print(player.mapposx)
	print("y: ")
	print(player.mapposy)--]]
	print("player.itempool")
	print(player.itempool)
	print("bombs")
	print(player.resources.bombs)
	print("keys")
	print(player.resources.keys)
	print("arrows")
	print(player.resources.arrows)
	
	local topx, topy = map_cell(player.hb.left-1,player.hb.top-1)		
	print(topx)
	print(topy)
	local botx, boty = map_cell(player.hb.left-1,player.hb.bot+1)
	print(botx)
	print(boty)
	
	foreach(hitboxes, draw_hitbox)


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
	player = {}
	//player stats
	player.x =104
	player.y =104
	player.dx =0
	player.dy =0
	player.mapposx = 0
	player.mapposy = 0
 player.sprite = 2
 player.face = 3
 player.interaction = false
 // player items
 player.itempool = {}
  player.itempool.bow = {42, 0}
 	player.itempool.raft = {43, 0} 
 player.resources = {}
 	player.resources.bombs = 0
 	player.resources.keys = 0
 	player.resources.arrows = 0

	
	--player hurtbox, tag = 0 
 player.hb = add_hitbox(0, 4,4, 6,6, -1, player)

end

// move player
//
// move player is self explanatory
// the function uses our collions
// function (bottom of this tab)
// to restrict movement against
// walls and objects with the
// flag #0.

function move_player()
 //debug
	//print(collisions(player.x, player.y))
	player.sprite = 2
	// player change in distance 
	player.dx = 0
	player.dy = 0

	// runs check on left movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	
	if(btn(0) and not mapcollisions(player.hb).l) then
		player.dx =-1
		player.x += player.dx
		--player.face = 0
	end
	
	// runs check on right movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	if(btn(1) and not mapcollisions(player.hb).r) then
		player.dx =1
		player.x += player.dx
		--player.face = 1
	end
	
	// runs check on up movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	if(btn(2) and not mapcollisions(player.hb).t) then
		player.dy =-1
		player.y += player.dy
		--player.face = 2
	end
	
	// runs check on down movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	if(btn(3) and not mapcollisions(player.hb).b) then
		player.dy =1
		player.y += player.dy
		--player.face = 3
	end
end

// update player
//
// update player does a variety
// of things, including use items,
// update map position, and move
// the player when called

function update_player()
	
	--process input, update world pos
	// called from above
	move_player()
	
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
	

	

	
	--update mappos
	player.mapposx, player.mapposy = map_pos(player.x,player.y)	


 	// check for if bomb has been placed
-- if ( btnp(5) then	
-- 	readinfo(player.face) end
	player.interaction = false
	if ( btnp(5)) then
		interact(player.face)
		if ( player.interaction==false	 and player.resources.bombs>0 ) then
	 	player.resources.bombs -= 1
			add_bomb(player.mapposx,player.mapposy,player.x%128, player.y%128)
 	end
 end
 //sword
	if(btnp(4)) then
		sword()
	end
	
	if (btnp(0,1) and player.itempool.bow[2] == 1 and player.resources.arrows > 0)  then
		add_arrow(player.mapposx,player.mapposy,player.x%128,player.y%128)
		player.resources.arrows -= 1
	end
end

// draw player
//
// draws player

function draw_player()
	if player.face == 6 then
		player.sprite = 2
	elseif player.face == 1 then
		player.sprite = 35
	elseif player.face == 7 then
		player.sprite = 37
	elseif player.face == 5 then
		player.sprite = 38	
	elseif player.face == 2 then
		player.sprite = 34
	elseif player.face == 0 then
		player.sprite = 36
	elseif player.face == 3 then
	 player.sprite = 33
	else
	 player.sprite = 32
	end	
	spr(player.sprite, player.x%128, player.y%128)
end

// draw map
//
// draws map

function draw_map()

	map(player.mapposx * 16,player.mapposy * 16,0,0,16,16)

end




function sword()
		//sword visuals	
		if player.face == 1 then
			add_partsys(player.x -2,player.y -4, 0,1, 4, 4, 2,0, 1,.5, .25)
		elseif player.face == 6 then
			add_partsys(player.x +10,player.y +12, 0,1, 4, 4, -2,0, 1,.5, .25)
		elseif player.face == 4 then
			add_partsys(player.x +12,player.y -2, 1,0, 4, 4, 0,2, .5,1, 0.25)
		elseif player.face == 3 then
			add_partsys(player.x -4,player.y +10, 1,0, 4, 4, 0,-2, .5,1, 0.25)
		elseif player.face == 2 then
			add_partsys(player.x +4,player.y -6, .5,.5, 4, 4, 2,2, .5,.5, 0.25)
		elseif player.face == 5 then
			add_partsys(player.x +4,player.y +14, .5,.5, 4, 4, -2,-2, .5,.5, 0.25)
		elseif player.face == 0 then
			add_partsys(player.x -6,player.y +4, .5,.5, 4, 4, 2,-2, .5,.5, 0.25)
		elseif player.face == 7 then
			add_partsys(player.x +14,player.y +4, .5,.5, 4, 4, -2,2, .5,.5, 0.25)
		end
		
		//add sword hitbox here!!!!
		

end
-->8
-- npcs
// tab 2 contains information
// about drawing npcs, their 
// movement, and drawing them
//
// make npc
//
// this function generates a npc
// upon call in init, and provides
// npc info

function make_npc(mapposx,mapposy,xpos,ypos,dx,dy)
	local npc = {}
		npc.x = xpos + mapposx*128 --x world space
		npc.y = ypos + mapposy*128 --y world space
		npc.dx = dx
		npc.dy = dy
		npc.mapposx = mapposx
		npc.mapposy = mapposy

		npc.sprite =10
	
	return npc
end


// update npc
//
// updates npc movement based on
// collisions and map position

function update_npc(npc)
	
	
	if npc.dx < 0 and collisions(npc).l then
		npc.dx = -npc.dx
	end
	
	if npc.dx > 0 and collisions(npc).r then
		npc.dx = -npc.dx
	end
	
	if npc.dy < 0 and collisions(npc).t then
		npc.dy = -npc.dy
	end
	
	if npc.dy > 0 and collisions(npc).b then
		npc.dy = -npc.dy
	end
	
	
	if npc.x%8 ==0 and npc.y%8 ==0 then
		
		if collisions(npc).tl and npc.dy <0 and npc.dx <0 then
			npc.dy = -npc.dy
			npc.dx = -npc.dx
		end
		
		if collisions(npc).tr and npc.dy <0 and npc.dx >0 then
			npc.dy = -npc.dy
			npc.dx = -npc.dx
		end
		
		if collisions(npc).bl and npc.dy >0 and npc.dx <0 then
			npc.dy = -npc.dy
			npc.dx = -npc.dx
		end

		if collisions(npc).br and npc.dy >0 and npc.dx >0 then
			npc.dy = -npc.dy
			npc.dx = -npc.dx
		end
	end

	npc.x += npc.dx
	npc.y += npc.dy
	
	
	--update mappos	
	npc.mapposx, npc.mapposy = map_pos(npc.x,npc.y)
	
end

// draw npc
//
// draws npc

function draw_npc(npc)
		if (player.mapposx == npc.mapposx and player.mapposy == npc.mapposy) then
				--spr(3, npc.x, npc.y)
				spr(npc.sprite, npc.x%128, npc.y%128)
		end

end


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
	local bomb = {}
	
	--left
	if (player.face == 0 or player.face ==3 or player.face ==5) then
		bomb.x = xpos + mapposx*128 - 8 // world space
	--right
 elseif (player.face ==2 or player.face ==4 or player.face ==7) then
	 bomb.x = xpos + mapposx*128 + 8 // world space
	else
		bomb.x = xpos + mapposx*128
	end
	
	--up 
 if (player.face ==0 or player.face ==1 or player.face ==2) then
		bomb.y = ypos + mapposy*128 - 8 // world space
	--down
	elseif (player.face ==5 or player.face ==6 or player.face ==7) then
		bomb.y = ypos + mapposy*128 + 8 // world space
	else
		bomb.y = ypos + mapposy*128
	end
	
	bomb.timer = 100
	bomb.sprite = 18
	bomb.mapposx = mapposx
	bomb.mapposy = mapposy
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
	 del(bombpool,bomb)
	 
	 add_hitbox(1, bomb.x+4,bomb.y+4, 24,24, 3)
	 
 	local explosion = {}
 		explosion.x = bomb.x
 		explosion.y = bomb.y
 		add(explosions, explosion)
	else
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
	local ycell = yest(explosion.y/8)
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

		else
		 sfx(7)
			mset(pair.xcell, pair.ycell,20)
	 end
	end
	del(pair)
end
-->8
-- enemy

-->8
--chests

// code here contains all
// small chest functionality,
// although we may add in large
// chests as well
function openchest(face)
 if face == 0 then
 	update_chest(xest(player.x/8),yest(player.y/8),-1,-1)
 elseif face == 1 then
  update_chest(xest(player.x/8),yest(player.y/8),0,-1)
 elseif face == 2 then
 	update_chest(xest(player.x/8),yest(player.y/8),1,-1)
	elseif face == 3 then
		update_chest(xest(player.x/8),yest(player.y/8),-1,0)
	elseif face == 4 then
	 update_chest(xest(player.x/8),yest(player.y/8),1,0)
	elseif face == 5 then
	 update_chest(xest(player.x/8),yest(player.y/8),-1,1)
	elseif face == 6 then
	 update_chest(xest(player.x/8),yest(player.y/8),0,1)
	else
	 update_chest(xest(player.x/8),yest(player.y/8),1,1)
	end
end

function update_chest(xtemp,ytemp,xpm,ypm)
	local contentflag = false
	local loopflag = false
 contentflag = fget(mget((xtemp+xpm),(ytemp+ypm)), 5)
 if ( contentflag == true) then
  for i=1,4 do
  	loopflag = fget(mget((xtemp+xpm),(ytemp+ypm)), i)
  	if (loopflag == true and i == 1 ) then
  		player.resources.bombs += 5
  		player.interaction = true
  		sfx(8)
  		mset((xtemp+xpm),(ytemp+ypm),24)
  	elseif (loopflag == true and i== 2 ) then
  		player.resources.keys += 1
  		player.interaction = true
  	 sfx(8)
  		mset((xtemp+xpm),(ytemp+ypm),24)
  	elseif (loopflag == true and i==3 ) then
  		player.resources.arrows += 20
  		player.interaction = true
  		sfx(8)
  		mset((xtemp+xpm),(ytemp+ypm),24)
  	elseif (loopflag == true and i== 4 ) then
  		player.interaction = true
  		// player.keys += 1
  		//	mset((player.x/8),(player.y/8-1),24)
  	end
  end
 end
end
-->8
--locked doors
// faces are 1, 4,5, 7
// run check on keys, sprite
function opendoor(face)
	if face == 1 then
		update_door(xest(player.x/8),yest(player.y/8),0,-1)
	elseif face == 3 then
		update_door(xest(player.x/8),yest(player.y/8),-1,0)
	elseif face == 4 then
		update_door(xest(player.x/8),yest(player.y/8),1,0)
	elseif face == 6 then
		update_door(xest(player.x/8),yest(player.y/8),0,1)
	end
end

function update_door(xtemp,ytemp,xpm, ypm)
 local contentflag = false
 contentflag = fget(mget((xtemp+xpm),(ytemp+ypm)), 2)
		if (contentflag == true and player.keys > 0) then
				player.interaction = true
			 player.keys -= 1
			 sfx(9)
  		mset((xtemp+xpm),(ytemp+ypm),0)
		end
end
-->8
--sword physics
function swordswing(face)
	
end	
-->8
--optimizations and development functions
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

function yest(y)
 return flr(y+0.5)
end

function bomb_animation()
	if (sget(22,8) == 8) then
		sset(22,8,6)
	else
		sset(22,8,8)
	end
end



// collisions
//
// reads map collions around an object
// for all 8 surrounding map cells,
// returns cell information

function mapcollisions(hb)
	--sam finish this!!!!
	
	--find all mapcells
	--containing/touching hb:
	---get tl and tr mapcell,
	
	---for loops from tl to tr cell
	---to check collisions,
	
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
	local tlx, tly = map_cell(hb.left-1,hb.top-1)		
	local trx, try = map_cell(hb.right+1,hb.top-1)
	local blx, bly = map_cell(hb.left-1,hb.bot+1)
	local brx, bry = map_cell(hb.right+1,hb.bot+1)
	
	
	
	
	return cols
end

function collisions(obj)
 // local table collisions
	local cols = {}
	//list of collisions
	cols.tl = false
	cols.t = false
	cols.tr = false
	cols.l = false
	cols.r = false
	cols.bl = false
	cols.b = false
	cols.br = false
	
	--horizontal
	if(obj.x%8 == 0) then
		--left collision
		cols.tl =fget(mget((obj.x/8)-1, (obj.y-obj.y%8)/8), 0)	
	 cols.bl =fget(mget((obj.x/8)-1, (obj.y+8-obj.y%8)/8), 0)
	 
	 if cols.tl or cols.bl then
	 	cols.l = true
	 end
	 
	 --right collision
	 cols.tr =fget(mget((obj.x/8)+1, (obj.y-obj.y%8)/8), 0)	
	 cols.br =fget(mget((obj.x/8)+1, (obj.y+8-obj.y%8)/8), 0)
	 
	 if cols.tr or cols.br then
	 	cols.r = true
	 end
	end
	
	--vertical
	if(obj.y%8 ==0) then
		--top collisions
		cols.tl =fget(mget(((obj.x-obj.x%8)/8),(obj.y/8)-1),0)
		cols.tr =fget(mget(((obj.x+8-obj.x%8)/8),(obj.y/8)-1),0)
		
		if cols.tl or cols.tr then
			cols.t = true
		end
		
		--bottom collisions
		cols.bl =fget(mget(((obj.x-obj.x%8)/8),(obj.y/8)+1),0)
		cols.br =fget(mget(((obj.x+8-obj.x%8)/8),(obj.y/8)+1),0)
		
		if cols.bl or cols.br then
			cols.b = true
		end
	end
	
	--centered h+v
	if(obj.x%8 == 0 and obj.y%8 ==0) then
		cols.tl =fget(mget((obj.x/8)-1, (obj.y/8)-1), 0)
		cols.tr =fget(mget((obj.x/8)+1, (obj.y/8)-1), 0)
		cols.bl =fget(mget((obj.x/8)-1, (obj.y/8)+1), 0)
		cols.br = fget(mget((obj.x/8)+1, (obj.y/8)+1), 0)
		
		cols.l =fget(mget((obj.x/8)-1, obj.y/8), 0)
		cols.r =fget(mget((obj.x/8)+1, obj.y/8), 0)
		cols.t =fget(mget(obj.x/8, (obj.y/8)-1), 0)
		cols.b =fget(mget(obj.x/8, (obj.y/8)+1), 0)
	end
	
	
	return cols
end


function add_hitbox(tag, x,y, xlen,ylen, duration, parent)
	hitbox = {}
	
	hitbox.tag = tag
	hitbox.x = x
	hitbox.y = y
	hitbox.xlen = xlen
	hitbox.ylen = ylen

	--coordinates of the hb edges
	hitbox.left = hitbox.x-(.5*hitbox.xlen)	
	hitbox.right = hitbox.x+(.5*hitbox.xlen)	
	hitbox.top = hitbox.y-(.5*hitbox.ylen)
	hitbox.bot = hitbox.y+(.5*hitbox.ylen)
	
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
	elseif hb.parent == nil then
		del(hitboxes, hb)
	end
	
	--update mappos
	hb.mapposx, hb.mapposy = map_pos(hb.x,hb.y)
	if hb.parent != nil then
		hb.mapposx = hb.parent.mapposx
		hb.mapposy = hb.parent.mapposy
		
		hb.x = hb.xoff+hb.parent.x
 	hb.y = hb.yoff+hb.parent.y
		
		--coordinates of the hb edges
		hb.left = hb.x-(.5*hb.xlen)	
		hb.right = hb.x+(.5*hb.xlen)	
		hb.top = hb.y-(.5*hb.ylen)
		hb.bot = hb.y+(.5*hb.ylen)
	end
	
	
	--add oncollision function here!!!
	
	
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




function interact(face)
	local itemtable = {42, 43}
	local xpm, ypm
	local faces = {1,3,4,6}
	openchest(face)
	opendoor(face)
	//npcfuncwhendone(face)
	
	pickup_item(face)	
end

--returns the map cell containing x,y
function map_cell(x,y)
	local mapx = (x-(x%8))/8
	local mapy = (y-(y%8))/8
	
	return mapx, mapy
end

--returns the map screen containing x,y
function map_pos(x,y)
	local mapx, mapy = map_cell(x,y)
	
	local mapposx = (mapx-(mapx%16)) / 16
	local mapposy = (mapy-(mapy%16)) / 16
	return mapposx, mapposy
end

function pickup_item(face) 
	local xpm, ypm
	local faces = {
 [1] = {0,-1},
	[3] = {-1,0},
	[4] = {1,0},
	[6] = {0,1}
	}
	for k, v in pairs(faces) do
		if face == k then
		  p_i_recieve(v[1],v[2])
		end
	end
end

function p_i_recieve(xpm,ypm)
 local temp = mget(xest(player.x/0+xpm),yest(player.y/0+ypm))
	for k,v in pairs(player.itempool) do
		if temp == v[1] then
		 player.interaction = true
	 	v[2] += 1
	 	mset(xest(player.x/8+xpm),yest(player.y/8+ypm),0)
		end
	end
end
-->8
--arrows and bow
// this tab contains code for
// the arrows utilized in bow
// combat. if a "combat" tab
// is formalized later, this 
// code will be moved there.


function add_arrow(mapposx,mapposy,xpos,ypos)
	local arrow = {}
	--left
	if (player.face == 0 or player.face ==3 or player.face ==5) then
		arrow.x = xpos + mapposx*128 - 8 // world space
		arrow.dx = -1.0
	--right
 elseif (player.face ==2 or player.face ==4 or player.face ==7) then
	 arrow.x = xpos + mapposx*128 + 8 // world space
		arrow.dx = 1.0
	else
		arrow.x = xpos + mapposx*128
		arrow.dx = 0
	end
	
	--up 
 if (player.face ==0 or player.face ==1 or player.face ==2) then
		arrow.y = ypos + mapposy*128 - 8 // world space
		arrow.dy = -1.0
	--down
	elseif (player.face ==5 or player.face ==6 or player.face ==7) then
		arrow.y = ypos + mapposy*128 + 8 // world space
		arrow.dy = 1.0
	else
		arrow.y = ypos + mapposy*128
		arrow.dy = 0
	end
	
	arrow.timer = 40
	
	if ((arrow.dx == 0) or (arrow.dy == 0)) then
		if arrow.dx == 0 then
			arrow.sprite = 39
		else
			arrow.sprite = 41
		end
	else 
	 arrow.sprite = 40
	end
	
	arrow.mapposx = mapposx
	arrow.mapposy = mapposy
	
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
	
	add(arrowpool, arrow)
end


function update_arrow(arrow)
	if ( collisions(arrow).r or collisions(arrow).l) then
	 arrow.dx = 0 
	end
	if ( collisions(arrow).t or collisions(arrow).b) then
		arrow.dy = 0
	end
	if	arrow.sprite == 40 then
	 if (collisions(arrow).tr or collisions(arrow).tl 
	or collisions(arrow).bl or collisions(arrow).br) then
		arrow.dx = 0
		arrow.dy = 0
		end
	end
	
	if (arrow.timer == 0 or (arrow.dx ==0 and arrow.dy == 0)) then 
	 sfx(10)
	 del(arrowpool,arrow)
	else
	 arrow.x += arrow.dx
		arrow.y += arrow.dy
		arrow.timer -= 1
	end
	--update mappos
	arrow.mapposx, arrow.mapposy = map_pos(arrow.x, arrow.y)
end

function draw_arrow(arrow)
	if (player.mapposx == arrow.mapposx and player.mapposy == arrow.mapposy) then
		spr(arrow.sprite,arrow.x%128,arrow.y%128,1.0,1.0,arrow.flipx,arrow.flipy)
 end
end
__gfx__
00000000111111110000000011111111222222222ff7f22222ff2222222fff22222222222222222200000000222222222222222222222222222222222ff7f222
000000001111cc11000cc00011111111222222222f7ff22222ff22222222fff22222222222222222000880002ff222222f62222222ffff22222222222ffff6f2
00700700111ccc1100cccc00111111112ff2222222ffff2f222ff222222ff7f2222222ffff22222200888800222f7ff2226fff222fffcff22222fff222ff6ff2
00077000111c1cc1007cc70011111111ffffffff2222ffff222ff222ffff7f2222222f7ffef222220078870022ff67f222ffffe2ff6feff222fffff222ffff22
0007700011cc11c10c1cc1c011111111f22fffff22222fff222ff222ff7ff2222222fff2ffff22220808808022f7cf2222fefff2ffeffff222fcff2222f6f222
0070070011c111c10ccccc4011111111222ff222222222ff222ff22222f222222222f7f22f7622220888888022f7f22222fffff22fffff222ffef222222fef22
0000000011ccccc100c0044011111111222222222222222222ff2222222222222222ff222f6ff2220080080022ff2222222fff22222222222fcff2222222ff22
000000001111111100c00c001111111122222222222222222ff7f22222222222222f7f222ffff222008008002222222222222ff22222222222ff222222222222
2222222200022220000007800000000016111116cccccccc2ff7f222222222220000000000000000000000000000000000000000454444544544445445444454
2222222200222200000070000000000061c16161cccccc6c2f7ff222222222220000000005455450054554500545545005455450555555555555555555555555
222222ff00c2c200000770000000000016116c11cc6ccc7622ffff2f22fffff20444444045455454454554544545545445455454454444544566665445444454
fff22f7f03fff230005555000000000011c116c1cc76ccc7f22fefff2ffffeff50000005555aa555555aa555555aa555555aa5555555aa254566665445444454
f77ffff203333330051111500000000061111111cc676cccf6ff2fff2ffef6ff400aa004444aa444444aa444444aa444444aa4444544aa244566665445444454
2ffff7f20f3333f005111150000000001116c161ccc67cccfff222ff2ffcfff25445544554455445544554455445544554455445454444544566665445444454
222fff220f5555f00511115000000000611111116ccccccc6f22222222ffff225445544554455445544554455445544554455445555555555555555555555555
222f7f2200500500005555000000000016c61161c6cccccc22222222222222225445544554455445544554455445544554455445454444544544445445444454
00000000000000000000000000000000000000000000000000000000000040000000000000000000005440000747647000000000000000000000000000000000
000cc000000cc000000cc000000cc000000cc000000cc000000cc000000444000440000000000000007004000404404000000000000000000000000000000000
00cccc0000cccc0000ccdc0000cdcc0000ccdc0000cccc0000cccc000000f00004f0000004000077007000400645547000000000000000000000000000000000
0cc7cc7007cc7cc000ccdc7000cdcc0007ccdc00007cc700007cc7000000f000000f000044fffff0007000900404404000000000000000000000000000000000
0cc1cc1001cc1cc00ccdcc100cdcccc001cdccc00c1cc1c00c1cc1c00000f0000000f00004000077007000400404404000000000000000000000000000000000
0ccccc400cccc4c00ccdccc00cdcccc004cdccc00ccccc400ccccc400000f00000000f7000000000007000400745546000000000000000000000000000000000
00cc044000c0c40000c0cc0004c00c0004cc0c0000c00c4000c004400007f700000007f700000000007004000404404000000000000000000000000000000000
00c00c0000c00c0000c00c0000c00c0000c00c000c00c000000c00c0000707000000007000000000005440000647747000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
60303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030304040404030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303060
50404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404070
__gff__
0003000001010101010100010101010101000000000101010123252931050101000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0804040404040404100404040404041010040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040409
0603030303030303060303030301010606030303030303030303030303030303030303030303040403030303030304040404040404030303030303030303030303030303030303030303030303030304040303030303030303030303030303030303030303030303030303030303030303030303030304040403030303030306
0603030119030303062a01030301030606010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303010303050409030303030606031a03080903030303010101010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06030103030303030303050d0303030606030804070f03030301030303030103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030301030301030303030516040703030303030103030303030301030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0504040903030303030308040903030303030303030303030103030303030301030303030303030303030303030d03030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0b0c0c0504090303080407080703030303030303030303030103030303030301030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0c0b080404070303050404070303030303030303030303030103030303030301030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0804070303030303030303010101030810040d03030303030301030303030103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030103030303030303030301010606030303030303030303010101010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030101030303030303030303010507030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0619030301030303030303030303030103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030103010303030303030303010103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603010103030303030303030303010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0504090101080404040404090101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0804070303050404040404070303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
060303030303030303030303030303030303030308040d031704040903030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303031f1e1f1e1f030303030303030303060101010101010603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06031a0303031f0319031f030303030303030303060101010101010f03030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06031a0303031f0303031f0303030303030303030f0101010101010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06031a0303031f1e1d1e1f030303030303030303030101011b01010e03030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06031a03030303030303030303030303030303030e0101010101010603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06031a0303030303030303030303030303030303060101010101010603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06030303031d03031d03031d03030303030303030504040d0317040703030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
__sfx__
611000001f0201f0201f0201f0201f0201f0201f0201f0201d0201d0201d0201d0201d0201d0201d0201d020210201f020210201f020210202102021020210201f0201f0201f0201f0201f0201f0251f0251f025
611000001d0201d0201d0201d0201d0201d0201d0201d0201b0201b0201b0201b0201b0201b0201b0201b0201f0201f0201d0201f020220202202022020220201d0201d0251d0201d0201d0251d0251d0251d025
011000100704513015136251362507045130151362513015070451300013000130001362511015136251101507000000001460016600070000000014600166000700000000070001460014600146001460000000
011000100504511015116251362505045130151362511015050450000000000000001362511015136251101500000000000000000000000000000000000000000000000000000000000000000000000000000000
611000001f0201f0201f0201f0201f0201f0201f0201f0201d0201d0201d0201d0201d0201d0251d0251d025210201f020210201f020210202302026020240202302023020230202302023020230252302523025
011000001d0201d0201d0201d0201d0201d0201d0201d0201b0201b0201b0201b0201b0201b0251b0251b0251f0201d0201b020180201d0201b02018020110212102421025210222102021025210252102521025
030700001064015640176301063017620136201761010610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
110700001364010640106301063010620106201061010610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
490c00000f645000000000000000000000000000000000001f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002d6132d615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001b6101b6101e62020633226551a0001a0001a0001a0001a0001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00024344
00 04024344
00 01034344
02 05034344

