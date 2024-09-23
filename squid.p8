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
	make_player()
	bombpool = {}
	explosions = {}
	particlesystems = {}
	particles = {}
	npc1 = make_npc(1,0,80,48,1,1)
	npc2 = make_npc(0,0,8,16,0,1)


end

// routine updates every frame
// using designed update funcs.
function _update()
	update_player()
	foreach(bombpool,update_bomb)
	foreach(explosions,update_explosion)
	update_npc(npc1)
	update_npc(npc2)

end

// routine updates every frame
// using designed update funcs.
function _draw()
	cls()

	draw_map()
	draw_player()
	foreach(bombpool,draw_bomb)
	draw_npc(npc1)
	draw_npc(npc2)
	
	// debug menu setup for
	// debugging info within game
	--[[ debug:
	print("x: ")
	print(player.mapposx)
	print("y: ")
	print(player.mapposy)
	--]]	
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
	player.mapposx =0
	player.mapposy =0
 player.sprite =2
 // player items
 player.bombs = 5
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
	
	// player change in distance 
	player.dx = 0
	player.dy = 0

	// runs check on left movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	
	if(btn(0) and not collisions(player).l) then
		player.dx =-1
		player.x += player.dx
	end
	
	// runs check on right movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	if(btn(1) and not collisions(player).r) then
		player.dx =1
		player.x += player.dx
	end
	
	// runs check on up movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	if(btn(2) and not collisions(player).t) then
		player.dy =-1
		player.y += player.dy
	end
	
	// runs check on down movement
	// here, if the collisons and
	// btn press are both true,
	// the player can move
	if(btn(3) and not collisions(player).b) then
		player.dy =1
		player.y += player.dy
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
	
	--update mappos	
	local mapx = (player.x-(player.x%8))/8
	local mapy = (player.y-(player.y%8))/8
	player.mapposx = (mapx-(mapx%16)) / 16
	player.mapposy = (mapy-(mapy%16)) / 16
 	// check for if bomb has been placed
	if ( btnp(5) and player.bombs>0 ) then
	 player.bombs -= 1
		add_bomb(player.mapposx,player.mapposy,player.x%128, player.y%128,100,18)
 end
end

// draw player
//
// draws player

function draw_player()

	spr(player.sprite, player.x%128, player.y%128)

end

// draw map
//
// draws map

function draw_map()

	map(player.mapposx * 16,player.mapposy * 16,0,0,16,16)

end


// collisions
//
// reads collions around an object
// for all 8 surrounding cells,
// returns cell information

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
	if(obj.x%8 ==0) then
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
		npc.x =xpos + mapposx*128 --x world space
		npc.y =ypos + mapposy*128 --y world space
		npc.dx =dx
		npc.dy =dy
		npc.mapposx =mapposx
		npc.mapposy =mapposy

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
	local mapx = (npc.x-(npc.x%8))/8
	local mapy = (npc.y-(npc.y%8))/8
	npc.mapposx = (mapx-(mapx%16)) / 16
	npc.mapposy = (mapy-(mapy%16)) / 16
	
	
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

--creates a particle system
function add_partsys(x,y,xrange,yrange, sduration,pduration, anglemin,anglemax, speed,srange, freq, parent)
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
	--range of particle movement
	--0-360
 partsys.anglemin = anglemin
 partsys.anglemax =anglemax
 --speed of particles
 partsys.speed =speed
 --range of speed variation:
 --speed +- srange
 partsys.srange =srange
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
	--not sure if this is needed...
	if partsys.parent != nil then
		partsys.x = partsys.parent.x
		partsys.y = partsys.parent.y
	end
	
	--spawn particle
	if partsys.sduration % partsys.freq == 0 then
		add_particle(partsys.x-partsys.xrange + rnd(partsys.xrange*2), partsys.y-partsys.yrange + rnd(partsys.yrange*2), partsys.pduration, partsys.anglemin + rnd(partsys.anglemax-partsys.anglemin), partsys.speed-partsys.srange + rnd(partsys.srange*2))
	end
	
	--track sys lifetime
	partsys.sduration -= 1
	if partsys.sduration < 0 then
		del(particlesystems,partsys)
	end
end

--creates a single particle
--from particle system
function add_particle(x,y, duration, angle, speed)
	part = {}
	--sam finish this!!!!!!
	

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

function add_bomb(mapposx,mapposy,xpos,ypos,timer,sprite)
	local bomb = {}
	bomb.x = xpos + mapposx*128 // world space
	bomb.y = ypos + mapposy*128 + 8 // world space
	bomb.timer = timer
	bomb.sprite = sprite
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
	 bomb.sprite = 0
	 del(bombpool,bomb)
 	local explosion = {}
 		explosion.x = bomb.x
 		explosion.y = bomb.y
 		add(explosions, explosion)
	else
  bomb.timer -= 1
 end
 
 	--update mappos	
	local mapx = (bomb.x-(bomb.x%8))/8
	local mapy = (bomb.y-(bomb.y%8))/8
	bomb.mapposx = (mapx-(mapx%16)) / 16
	bomb.mapposy = (mapy-(mapy%16)) / 16
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
	local xcell = (explosion.x/8)
	local ycell = (explosion.y/8)
	if (xcell - flr(xcell) > 0.5) then
		xcell = ceil(xcell)
	else
	 xcell = flr(xcell)
	end	
	if (ycell - flr(ycell) > 0.5) then
	 ycell = ceil(ycell)
	else
	 ycell = flr(ycell)
	end
	
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
end

function explode_tile(pair)
	if fget(mget(pair.xcell,pair.ycell),1) then
		mset(pair.xcell, pair.ycell,20)
	end
end
__gfx__
00000000111111110000000011111111222222222ff7f22222ff2222222fff22222222222222222200000000222222222222222222222222222222222ff7f222
000000001111cc11000cc00011111111222222222f7ff22222ff22222222fff22222222222222222000880002ff222222f62222222ffff22222222222ffff6f2
00700700111ccc1100cccc00111111112ff2222222ffff2f222ff222222ff7f2222222ffff22222200888800222f7ff2226fff222fffcff22222fff222ff6ff2
00077000111c1cc1007cc70011111111ffffffff2222ffff222ff222ffff7f2222222f7ffef222220078870022ff67f222ffffe2ff6feff222fffff222ffff22
0007700011cc11c10c0cc0c011111111f22fffff22222fff222ff222ff7ff2222222fff2ffff22220808808022f7cf2222fefff2ffeffff222fcff2222f6f222
0070070011c111c10cccccc011111111222ff222222222ff222ff22222f222222222f7f22f7622220888888022f7f22222fffff22fffff222ffef222222fef22
0000000011ccccc100c00c0011111111222222222222222222ff2222222222222222ff222f6ff2220080080022ff2222222fff22222222222fcff2222222ff22
000000001111111100c00c001111111122222222222222222ff7f22222222222222f7f222ffff222008008002222222222222ff22222222222ff222222222222
22222222000222200000078000000760161111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222200222200000070000000700061c161610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222222ff00c2c200000770000007700016116c110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff22f7f03fff230005555000055550011c116c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f77ffff2033333300511115005111150611111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2ffff7f20f3333f005111150051111501116c1610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222fff220f5555f00511115000511500611111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222f7f2200500500005555000005500016c611610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0003000001010101010100010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0804040404040404100404040404040904040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040409
0603030303030303060303030301010606030303030303030303030303030303030303030303040403030303030304040404040404030303030303030303030303030303030303030303030303030304040303030303030303030303030303030303030303030303030303030303030303030303030304040403030303030306
0603030103030303060301030301030606030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303010303050409030303030606030303080903030303010101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
06030103030303030303050d0303030606030404070f03030304030303010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030301030303030303030f04040403030303030103030303030103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0504040903030303030308040903030303030303030303030103030303030103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0b0c0c0504090303080407080703030303030303030303030103030303030103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0c0b080404070303050404070303030303030303030303030103030303030103030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0804070303030303030303030303030e04040403030303030301030303010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030606030303030000000303010101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030606030303030000000303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0504040303040404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0604040303040404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030301030303010303030303030303030303030303040404030404040403030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030103030303030303030303030303030303040303030303030403030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030103030303030303030303030303030303030303040303030303030403030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303010303030303030303030303030303030303030303030403030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303040303030303030403030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303040303030303030403030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303040404040304040403030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
0603030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030306
