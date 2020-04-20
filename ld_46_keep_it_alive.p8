pico-8 cartridge // http://www.pico-8.com
version 21
__lua__
-- ludum dare 46
-- keep it alive

rows = {}
bw=10 --board width
bh=15 --board height
c={x=4,y=4} -- board top corner
f={} -- falling piece
last=0
counter=0
test=1
playing=true
level=1
score=1
fs=2--fire strength
go_msg=""
pause=false

--map the spawn chances (out of 10)
mp={1,1,2,3,2,2,2,1,3}

function _init()
 init_rows()
 spawn_f()
 fs=2
 score=1
 level=1
 
 reset_time()
end

function reset_time()
 last=time()
 counter=0
end

function _update()
 if(fs<=0)then
  go_msg="the fire has died"
  game_over()
 end

 if(not playing)then
  gameover_u()
 elseif(pause)then
  if(btnp(4))then
   pause=false
  else
   
  end
 else
	 counter=time()-last
	
	 if (check_l_col()) then
	  lock_f()
	 end
	 
	 local nfx=f.x
	 local nfy=f.y
 
	 if (btnp(0)) then
	  nfx = f.x - 1
	 end
	 
	 if (btnp(1)) then
	  nfx= f.x + 1
	 end
	 
	 if (btnp(2)) then
	  spin()
	 end
	 
	 if (btnp(3)) then
	  nfy=f.y+1
	 elseif (counter > 1-(level/10)+.2) then
	  nfy=f.y+1
	  reset_time()
	 else
	 end
	 
	 if (btnp(4))then
	  pause=true
	 end
 
	 if (nfx<0) then
	  nfx = f.x
	 end
	 
	 if (nfx>(bw-2)) then
	  nfx = f.x
	 end
 
	 if (nfy>bh-2) then
	  nfy = f.y
	  lock_f()
	 elseif (not check_n_f(nfx,nfy)) then
	  f.x = nfx
	  f.y = nfy
	 else
	  
	 end
	 
	 process_rows()
	 collapse_rows()
	 update_level()
 end
end

function _draw()
	cls(1)
	
	color(7)
	
	map(0,0,5,3,bw+6,bh+8)
	spr(109,-3,bh*8+3)
	spr(124,bw*8+36,53,1,1,
	 flr(last)%3==0
	)

 rect(c.x-1,c.y-1,(c.x)+(bw*8),(c.y)+(bh*8))
		
	for i=0,bw do
	 for j=0,bh do
   spr(rows[i][j].s,c.x+(i*8),c.y+(j*8))
  end
	end
	
	draw_f()
	
	color(0)
	
	print("level "..
	 level,c.x+2+(bw*8)+4,c.y
	)
	
	print("score:",c.x+2+(bw*8)+4,c.y+8)
	print("score:",c.x+2+(bw*8)+4,c.y+8)
	print(score.."00",c.x+2+(bw*8)+4,c.y+16)
	
	print("fire size",c.x+2+(bw*8)+4,c.y+24)
	print(fs,c.x+2+(bw*8)+4,c.y+32)
	
	print("pause: x/z",c.x+(bw*8)+3,c.y+42,7)	
	
	color(7)
	line(c.x,(c.y+(3*8)),c.x+(bw*8),(c.y+(3*8)))
		
	if(not playing)then
	 xm=28
	 ym=48
	 spr(64,xm,ym,10,1)
	 spr(80,xm,ym+8,10,2)
	 spr(80,xm,ym+24,10,2)
	 spr(64,xm,ym+40,10,1)
	 print(go_msg,xm+6,ym+12,0)
	 print("game over",xm+20,ym+24,0)
	 print("press x/z to play",xm+8,ym+32)
	end
	
	if(pause)then
	 draw_info()
	end
end


-->8
function game_over()
 playing=false
end

function spin()
 local fta=f.a
 local ftb=f.b
 local ftc=f.c
 local ftd=f.d
 f.a=ftc
 f.b=fta
 f.c=ftd
 f.d=ftb
end

--add the piece to rows
function lock_f()
 rows[f.x][f.y]=set_cell(f.a)
 rows[f.x+1][f.y]=set_cell(f.b)
 rows[f.x][f.y+1]=set_cell(f.c)
 rows[f.x+1][f.y+1]=set_cell(f.d)
 
 --if the piece is above the 
 --line, game over
 if(f.y<2)then
  go_msg="fire is too large"
  game_over()
 end
 
 spawn_f()
end

--helper to create a cell
function set_cell(s)
 t=s
 
 return {
  t=t,
  s=s,
  bst=time(),
  fc=time()
 }  
end

--spawn a new falling piece
function spawn_f()
 f={
  x=(bw/2)-1,y=1,
  a=mp[flr(rnd(9))+1],
  b=mp[flr(rnd(9))+1],
  c=mp[flr(rnd(9))+1],
  d=mp[flr(rnd(9))+1]
 }
end

--process all cells on the 
--board
function process_rows()
 fs=0
 for i=0,bw do
  for j=0,bh do
   if(not near_fire(i,j))then
    rows[i][j].fc=time()
   end
   
   --process fire
   if(rows[i][j].t==5) then
    local tl=time()
     -rows[i][j].bst
    if(rows[i][j].bm)then
     tl=tl+rows[i][j].bm
    end
    if (tl>12) then
     rows[i][j] = {
      t=0,s=0,bst=time()
     }
    elseif(tl<2)then
     rows[i][j].s=18
    elseif(tl<4)then
     rows[i][j].s=19
    elseif(tl<6)then
     rows[i][j].s=20
    else
     rows[i][j].s=21
    end
    
    if(rows[i][j-1].t==3)then
     rows[i][j]=set_cell(3)
     score=score+1
    end
   --process water
   elseif(rows[i][j].t==3)then
    local tl=time()
     -rows[i][j].bst
    if (tl>3) then
     rows[i][j] = {
      t=0,s=0,bst=time()
     }
    elseif(tl<1)then
     rows[i][j].s=33
    elseif(tl<2)then
     rows[i][j].s=34
    else
     rows[i][j].s=35
    end
   --process logs
   elseif(rows[i][j].t==1)then
    if(time()-rows[i][j].fc>3)
    then
     rows[i][j].t=5
     rows[i][j].s=17
     rows[i][j].bm=0
     score=score+5
    end
   elseif(rows[i][j].t==2)then
    if(time()-rows[i][j].fc>2)
    then
     rows[i][j].t=5
     rows[i][j].s=20
     rows[i][j].bm=3
     score=score+3
    end
   end
   
   if(rows[i][j].t==5)then
    fs+=1
   end
  end
 end   
end

--collapse any blank cells
function collapse_rows()
 for i=bw-1,0,-1 do
  for j=bh-1,0,-1 do
   if(j!=0 and rows[i][j].t==0)then
    if(rows[i][j-1].t!=0)then
     rows[i][j].s=rows[i][j-1].s
     rows[i][j].t=rows[i][j-1].t
     rows[i][j].fc=rows[i][j-1].fc
     rows[i][j].bst=rows[i][j-1].bst
     rows[i][j-1]=set_cell(0)
    end
   end
  end
 end
end
-->8
--set up the starting fire
function init_fire()
 ft={
  t=5,s=17,bst=time(),fc=time()
 }
 fw={
  t=2,s=2,bst=time(),fc=time()
 }
 fl={
  t=1,s=1,bst=time(),fc=time()
 }
 
 rows[bw/2][bh-1]=ft
 rows[bw/2-1][bh-1]=ft
 rows[bw/2+1][bh-1]=fw
 rows[bw/2-2][bh-1]=fw
 rows[bw/2][bh-2]=fw
 rows[bw/2-1][bh-2]=fw
 rows[bw/2+2][bh-2]=fl
 rows[bw/2-3][bh-2]=fl
 rows[bw/2+1][bh-2]=fl
 rows[bw/2-2][bh-2]=fl
 rows[bw/2][bh-3]=fl
 rows[bw/2-1][bh-3]=fl
end

function init_rows()
 for i=0,bw do
  rows[i]={}
  for j=0,bh do
   rows[i][j]={
    t=0,s=0,bst=time(),fc=time()
   }
  end
 end
 
 init_fire()
end
-->8
--check side collisions
function check_s_col()
 if(rows[f.x-1][f.y].t != 0)then
  return true 
 end
 
 if(rows[f.x+3][f.y].t != 0)then
  return true
 end
 
 return false
end

--check lower collisions
function check_l_col()
 if(rows[f.x][f.y+2].t != 0)then
  return true
 end
 
 if(rows[f.x+1][f.y+2].t != 0)then
  return true
 end
 
 return false
end

--check if a piece is next 
--to a fire
function near_fire(i,j)
 if(rows[i][j].t==0)then
  return false
 end

 --above
 if(j!=0 and rows[i][j-1].t==5)then
  return true
 end
 
 --right
 if(rows[i+1][j].t==5)then
  return true
 end
 
 --below
 if(rows[i][j+1].t==5)then
  return true
 end
 
 --left
 if(i!=0 and rows[i-1][j].t==5)then
  return true
 end
 
 return false
end

--check the new pos of f
function check_n_f(nfx,nfy)
 if(rows[nfx][nfy].t != 0)then
  return true
 end
 
 if(rows[nfx+1][nfy].t != 0)then
  return true
 end
 
 if(rows[nfx][nfy+1].t != 0)then
  return true
 end
 
 if(rows[nfx+1][nfy+1].t != 0)then
  return true
 end
 
 return false
end
-->8
--draw the falling piece
function draw_f()
 spr(f.a,(c.x)+(f.x*8),(c.y)+f.y*8)
 spr(f.b,(c.x)+(f.x+1)*8,(c.y)+f.y*8)
 spr(f.c,(c.x)+f.x*8,(c.y)+(f.y+1)*8)
 spr(f.d,(c.x)+(f.x+1)*8,(c.y)+(f.y+1)*8)
end

function draw_info()
 map(17,0,12,24,13,12)
 rectfill(21,39,30,48,1)
 spr(1,22,40)
 color(0)
 print("ignites slow",34,40)
 print("burns long",34,46)
 print("500",88,40)
 print("pts",88,46)
 
 rectfill(21,39+16,30,48+16,1)
 spr(2,22,40+16)
 color(0)
 print("ignites fast",34,40+16)
 print("burns short",34,46+16)
 print("300",88,40+16)
 print("pts",88,46+16)
 
 rectfill(21,39+32,30,48+32,1)
 spr(3,22,40+32)
 color(0)
 print("extinguishes",34,40+32)
 print("fire",34,46+32)
 print("100",88,40+32)
 print("pts",88,46+32)
 
 rectfill(21,39+48,30,48+48,1)
 spr(5,22,40+48)
 color(0)
 print("keep it alive",34,40+48)
 print("100",88,40+48)
 print("pts",88,46+48)
 
 print("press x/z to continue",22,40+64)
end

--gameover update function
function gameover_u()
 if (btnp(4)) then
  playing=true
  _init()
 end
end
-->8
function update_level()
 if(level<10)then
  if((level*10)<last)then
   level+=1
  end
 end
end
__gfx__
0000000004444440440000ff00000c0001111110000880000000000004444440440000ff00000000000000000000000000000000000000000000000000000000
000000002f444444544004ff0000cc0014444f4100899800000000002f444444544004ff00000000000000000000000000666000006006000066660000000000
00000000fff5555505224450000ccc0014f444410899998000000000fff555550522445000000000000000000066600000006600006006000060000000000000
00000000fff444440024450000cccc00144444418999a99800000000fff444440024450000000000000600000000600000066600006666000066660000000000
00000000fff55555004452000cccccc014444441899aa99800000000fff555550044520000000000000600000066600000666000000006600060060000000000
00000000fff4444404452240cc7ccccc14444f4189aaaa9800000000fff444440445224000000000000600000666660000006600000006000000060000000000
000000002f555555445005ffcc7ccccc14f44441089aa980000000002f555555445005ff00000000000000000000066000666600000006000006600000000000
0000000002222220450000ff0cccccc001111110008888000000000002222220450000ff00000000000000000000000000000000000000000000000000000000
00000000000880000008800000088000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008998000089980000099000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000089999800899998000999900008888000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000899999980999a9900999a990008998000009a00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000899aa998099aa990099aa990009a9900009aa90000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000089aaa99809aaa99009aaaa90009aa90000aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000089aa980089aa980089aa980000aa000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000088880000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c000000000000000000440000ff0006770000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000cc000000c00000000000544004ff0066677000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ccc000000c00000000000051144500066677000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cccc00000cc0000000c000001445000006770000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cccccc000cccc00000cc000004451000677677000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc7ccccc0c7cccc000cccc00044511406667767700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc7ccccc0c7cccc000c7cc00445005ff6667767700000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cccccc000cccc00000cc000450000ff0677677000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077670000000000000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000700767777000000000000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777666707000000000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000700007676666600000000000000000007000055555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000007770007676666600000000000070000077700055555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000700007777666700000000000000000007000055555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000777777000000070000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000076770000000000000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000
04444444444444444444444444444444444444444444444444444444444444444444444444444440000000000fffffffff0000000cccccc00000000000000000
2f4444444444444444444444444444444444444444444444444444444444444444444444444444440000000000fffffff0000000000000000000000000000000
fff5555555555555555555555555555555555555555555555555555555555555555555555555555500000000000fffffff000000000000000000000000000000
fff44444444444444444444444444444444444444444444444444444444444444444444444444444000000000fffffffff000000000000000000000000000000
fff55555555555555555555555555555555555555555555555555555555555555555555555555555000000000fffffffff000000000000000000000000000000
fff44444444444444444444444444444444444444444444444444444444444444444444444444444000000000ffffffff0000000000000000000000000000000
2f5555555555555555555555555555555555555555555555555555555555555555555555555555550000000000ffffff00000000000000000000000000000000
02222222222222222222222222222222222222222222222222222222222222222222222222222220000000000fffffffff000000000000000000000000000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff200000000044444402444444000000000cccccc4000000000
02ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff20000000002f44444442444444000000004444444400000000
002ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff200000000fff5555555255555000000005555555500000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff200000000fff4444444244444000000004444444400000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff200000000fff5555555255555000000005555555500000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff20000000000fff4444444244444000000004444444400000000
02ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff20000000002f55555552555555000000005555555500000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2000000000222222022222220000000002222222000000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2000000000004444400000000ffffffff0000000000000000
02fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff20000000000002f444400000000ffffffff0000000000000000
002fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff200000000000fff55500000000f3f3f3f30000000000000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff20000000000fff44400000000333333330000000000000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff20000000000fff55500000000333333330000000000000000
2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff200000000000fff44400000000333333330000000000000000
02fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff200000000002f555500000000333333330000000000000000
2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2000000000002222200000000333333330000000000000000
04444444444444444444444444444444444444444444444444444444444444444444444444444440000000000000000000000000000000000000000000000000
2f444444444444444444444444444444444444444444444444444444444444444444444444444444000000000000000000600600000000000000000000000000
fff5555555555555555555555555555555555555555555555555555555555555555555555555555500000000cccccc0000600600000000000000000000000000
fff4444444444444444444444444444444444444444444444444444444444444444444444444444400000000c4444c0006006000000000000000000000000000
fff5555555555555555555555555555555555555555555555555555555555555555555555555555500000000cccccccc06006000000000000000000000000000
fff4444444444444444444444444444444444444444444444444444444444444444444444444444400000000cccccc0c00600600000000000000000000000000
2f55555555555555555555555555555555555555555555555555555555555555555555555555555500000000cccccccc00600600000000000000000000000000
0222222222222222222222222222222222222222222222222222222222222222222222222222222000000000cccccc0000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121212121212121212121212
12121212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000121212121212121212121212
1212121203bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000003333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33330000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000
000003333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33330000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000000000000000000000000000000000
0000000003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000000000000000000000000000000000000000000000000000000000000000
00000000003333333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000808080808080808080000000000000808080808080808080800000008000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
340000350034000033004b515151584c00404141414141414141484848490909030303030303030303030303030303030909090909090909090909090909090921212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000
003200000000310000344b515151584c00505151515151515151586868590909032103030321210303210321030321030909090909090909090909090909090921212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000
310000330034000031004b515151584c00605151515151515151586868590909032103030321032103210321030321030909090909090909090909090909090921212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004b515151584c00605151515151515151586868590909032103030321032103210321030321030909090909090909090909090909090921212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004b515151584c00605151515151515151586868592121032103030321032103212121210321032121210202212121090909090909090921212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000605252525252525252586868592121032103030321032103030321030321032121210202212121090909090909090921212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000605252525252525252586868592121032121210321210303030321030321032121210202212121090909090909090921212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007b0000605252525252525252586868592121030303030303030303030303030303032121210202212121111111111111111121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006b4149405e0000605252525252525252586868590202030303030303030303030303030303030202020202020202020202020202020202020202020202020202020202020202212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006b494041490000506868686868686868686868590202030303030303030303030303030303030202020202020202020202020202020202020202020202020202020202020202212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006b434141490000606161616161616161616161690202030303030303030303030303030303030202020202020202020202020202020202020202020202020202020202020202212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006b4143495b0000707171717171717171717171790101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006b414940490000000000000000000000170000000000000000000000000021212121212121272121212121212127212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006b494041490000000000000000000000000000000000000000000021212121212121212121272121212121212127212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006b414141490000000000000000000000000000000000000015151515151515132121212112001321212121212127212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d00000000000000000000000000252127212624001616161600001513211224242413212121212127212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000012132121212121261c2521272122162321212121220000161700241c240029212121212721212121212c2121212c2121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121210021002121212c2121212121212122232121212121221623212721212121212121212126252121222424242321212121120013212121212c2121212c2121121513212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121210021210021212c21212121212121212121212121212121212127212121211217171717162521212122002321212121212600251b1b1b1b2c1b1b1b2c1b1b001c25212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212c2121212121212100000000000000000021212721212121272121212121272121212127212121212121220023212121212c2121212c2121221623212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212100151321210021212c2121212121212100000000000000000021120013212121272112151321272121211200132121212121212721212121212c2121212c2121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
212100002600001717000017171717171717171700000000000000000017001c001717172521260000172417171700240017171717171723212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121002122162321210021212121212121212121000000000000000000212216232121212721221623212721212122162321212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121210000212121212121212121000011000000110000212121212121212721212121212721212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121210000212121212121212121000000000000000000212121212121212217171717172321212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121000000000000000000212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121111111000000111111212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121000000000000000000212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121000000000000000000212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121000011111111110000212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121000000000000000000212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000306000c5501d5500b550100000c000225000650021500215001b5001b5001b5001b5001b5001750021500215002150021500215000e0002150021500110002150021500215000c000145000c0000c0000c000
001000001905019050190501905019050190501905019050190501905019050190501905019050190501905019050190501905019050190501905019050190501905019050190501905019050190501905019050
011000000c0500e0000e0500e00010050104031105010403100031040334403344033400334403344031040310003103041020410403100031020410403104031000310304102041040310003102041040310403
__music__
00 02424344

