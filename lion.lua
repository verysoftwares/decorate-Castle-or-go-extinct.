--[[ lion entity definitions. ]]--


-- there he is.
-- his hitbox is a bit smaller than the 48x48 sprite,
-- so there's some offsets sprinkled around code.
-- cx and cy are always snapped to the 48x48 grid.
    lion={x=48*3+2,y=48*3+3,dx=0,dy=0}
    lion.cx=(lion.x+22)-(lion.x+22)%48
    lion.cy=(lion.y+21)-(lion.y+21)%48

function platforming()
    if press('right') then 
        if lion.dx<0 then lion.dx=0 end
        lion.dx=lion.dx+0.2 
    end
    if press('left') then 
        if lion.dx>0 then lion.dx=0 end
        lion.dx=lion.dx-0.2 
        if press('right') then lion.dx=0 end
    end
    -- yeah you can jump in the air but
    -- then it's just a tiny jump that carries you further horizontally.
    -- this is by no means a precision platformer so it's ok.
        if tapped('up') and not lion.jumping then 
            lion.dy=lion.dy-5.2 
            lion.jumping=true 
        end

    lion.dy=lion.dy+0.2; if lion.dy>260 then lion.dy=260 end

    -- sometimes game code be like this.
        
        -- i like to separate x/y axes for collision detection,
        -- this eliminates a category of corner cases.
        -- i also check whether we are already inside a wall,
        -- not just about to collide with it (the x+dx pattern).
        -- it makes a philosophical difference to me that
        -- correction happens after a collision, not beforehand.
        
        -- the fancy bit going on is that i do this
        -- virtual positioning thing with wraparounds in mind.
        -- otherwise it's just standard collision logic, i think
        -- there are enough good resources for teaching that.
        
            if lion.x+48-4>sw and not anime['lionwrap'] then assure('lionwrap') end
            if lion.x<0       and not anime['lionwrap'] then assure('lionwrap') end
            
            lion.x=lion.x+lion.dx
            lion.dx=lion.dx*0.94
            lion.cx=(lion.x+22)-(lion.x+22)%48

            if lion.cx/48<0  then lion.x=lion.x+6*48 end
            if lion.cx/48>=6 then lion.x=lion.x-6*48 end
            
            for k,v in pairs(blocks) do
                local vx,vy=strpos(k)
                for wx=-1,1 do for wy=-1,1 do
                if abs(lion.x-(vx+wx*6)*48)<96 and abs(lion.y-(vy+wy*6)*48)<96 and 
                   AABB(lion.x,lion.y,48-4,48-3, (vx+wx*6)*48,(vy+wy*6)*48,48,48) then
                    if lion.dx>=0 then lion.x=(vx+wx*6)*48-(48-4); lion.dx=-0.000000001 
                    else lion.x=(vx+wx*6)*48+48; lion.dx=0 end
                    break
                end
                end end
            end

            if lion.y+48-3>sh and not anime['lionwrap'] then assure('lionwrap') end
            if lion.y<0       and not anime['lionwrap'] then assure('lionwrap') end
            
            lion.y=lion.y+lion.dy
            lion.cy=(lion.y+21)-(lion.y+21)%48
            
            if lion.cy/48>=6 then lion.y=lion.y-6*48 end
            if lion.cy/48<0  then lion.y=lion.y+6*48; assure('lionwrap') end

            for k,v in pairs(blocks) do
                local vx,vy=strpos(k)
                for wx=-1,1 do for wy=-1,1 do
                if abs(lion.x-(vx+wx*6)*48)<96 and abs(lion.y-(vy+wy*6)*48)<96 and 
                   AABB(lion.x,lion.y,48-4,48-3, (vx+wx*6)*48,(vy+wy*6)*48,48,48) then
                    if lion.dy>=0 then lion.jumping=false; lion.y=(vy+wy*6)*48-(48-3); lion.dy=0 
                    else lion.y=(vy+wy*6)*48+48 end
                    break
                end
                end end
            end

    lion.cx=(lion.x+22)-(lion.x+22)%48
    lion.cy=(lion.y+21)-(lion.y+21)%48

end