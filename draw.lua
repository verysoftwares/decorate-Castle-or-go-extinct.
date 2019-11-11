--[[ drawing functionalities. ]]--
--[[ further includes draw-anim.lua and draw-utility.lua. ]]--


-- i find that love.draw always gets a bit complex,
-- so it's good to keep it as an overview of flow
-- and implement functions for each step.

-- in this game's case there are few enough layers that
-- such steps correspond nicely to layers.
-- in a more complex game i tend to have all entities
-- in the same table and sort by a layer number variable.

        

-- main draw function, assigned to love.draw. see state.lua.
-- can draw a virtual world coming from an online source, too.
    function castledraw(_canvas,_blocks,_decos,_mysteries,_lion)
        _blocks,_decos,_mysteries,_lion= _blocks or blocks,_decos or decos,_mysteries or mysteries,_lion or lion

        if _canvas then lg.setCanvas(_canvas)
        else lg.setCanvas(photo_canvas) end
            bgdraw()        
                mysterydraw(_mysteries)
                decodraw(_decos)
                liondraw(_lion)
                blockdraw(_blocks)

        if _canvas then return end

        if not paused_animation() then record_animation() end

        lg.setCanvas()
            fg(1,1,1,1)
                lg.draw(photo_canvas,random(-camera.shake,camera.shake),random(-camera.shake,camera.shake))
                interfacedraw()
    end

-- special draw function for ideamode where the logic is different.
    function ideadraw()
        lg.setCanvas()
            bg(0.8,0.8,0.8,1)
            fg(112/255,105/255,49/255,1)
            rect('fill',sw/2-sw/4-2,12-2,sw/2+4,sh/2+4)
            fg(0.8,0.8,0.8,1)
            rect('fill',sw/2-sw/4,12,sw/2,sh/2)
            
            fg(1,1,1,1)
            
            -- an animation might not have finished recording if a player
            -- quickly swaps here, it'll just continue recording once you return.
                local dis= disco_order[disco_order.i]
                lg.draw(replay_animation(dis),sw/2-sw/4,12,0,0.5,0.5)

            text3d('Shift to return.',sw/2,sh-24-6,t)
            if #disco_order>1 then
            sine3d('<',sw/2-sw/4-12,12+sh/4-12,t)
            sine3d('>',sw/2+sw/4+12,12+sh/4-12,t)
            end

            fg(112/255,105/255,49/255,1)
            rect('fill',12-2,12-2+12+sh/2+12,48+4,48+4)
            fg(0.8,0.8,0.8,1)
            rect('fill',12,12+12+sh/2+12,48,48)
            fg(1,1,1,1)
            lg.draw(images.lion, round(12+24),round(12+12+sh/2+12),0,-1,1,24,0)
            
            -- the lion speaks.
            -- sometimes game code be like this.
            lg.setFont(lionfont)
                fg(211/255,254/255,218/255,1)
                local msg=lionsay()
                local tw=lionfont:getWidth(msg)
                local tx=12+48+2+12
                local ty=12+12+sh/2+12
                local wrapped=false
                for i=1,#msg do
                    local char=sub(msg,i,i)
                    lg.print(char,tx,ty)
                    tx=tx+lionfont:getWidth(char)
                    if char==' ' then
                        local nextsp=string.find(msg,' ',i+1) or #msg
                        local nextwd=sub(msg,i+1,nextsp)
                        if tx+lionfont:getWidth(nextwd)>sw-12 then
                            tx=12+48+2+12; ty=ty+16
                            if ty>12+48+2+12+sh/2+12 then wrapped=true end
                            if ty>=sh then ty=-2 end
                            if wrapped then tx=12 end
                        end
                    end
                end
                lg.print(fmt('%d of %d',disco_order.i,#disco_order),12,12+48+2+6+12+sh/2+12-2)

    end

-- special draw function for photomode 
-- where the logic is differently different.
    function photodraw()
        lg.setCanvas()
            bg(0.8,0.8,0.8,1)
            fg(112/255,105/255,49/255,1)
            rect('fill',sw/2-sw/4-2,12-2,sw/2+4,sh/2+4)
            fg(0.8,0.8,0.8,1)
            rect('fill',sw/2-sw/4,12,sw/2,sh/2)
            
            if (not photo_session and not submit_session) or love.update==sendconfirm then
                fg(1,1,1,1)
                lg.draw(photo_canvas,sw/2-sw/4,12,0,0.5,0.5)
            end

            if love.update==sendconfirm then
                text3d('Send this for',sw/2,12+sw/2+12,t)
                text3d('everyone to see?',sw/2,12+sw/2+12+20,t)
                sine3d('<Yes',12+16*2-8+2,sh-24-12,t)
                sine3d('>No',sw-16-8-8+2,sh-24-12,t)
                
            elseif love.update==submitconfirm and not session_busy() then
                text3d('Done! Make a post on',sw/2,12+sw/2+12+20+4,t)
                text3d('Castle, as well?',sw/2,12+sw/2+12+20+20+4,t)
                sine3d('<Yes',12+16*2-8+2,sh-24-12,t)
                sine3d('>No',sw-16-8-8+2,sh-24-12,t)

            elseif not session_busy() then
                sine3d('^Send',12+16*2,sh-80-12,t)
                sine3d('vReceive',sw-16*4,sh-80-12,t)
                text3d('Shift to return.',sw/2,sh-24-6,t)
            end
            
            -- in photomode, a state table is being formed from network.async calls.
            -- here we just draw what's there, visualizing a progress bar.

            if submit_session then
                if submit_session.i<submit_session.imax then
                    fg(0.9,0.9,0.9)
                    rect('fill',0,12+sh/4-24+12,sw,24)
                    fg(0.5,0.6,0.8)
                    rect('fill',4,12+sh/4-24+4+12,(sw-8)*(submit_session.i/(submit_session.imax-1)),24-8)
                end
            end
            if photo_session then 
                if not photo_session.canvas then
                    photo_session.canvas = lg.newCanvas(sw,sh)
                end
                if photo_session.i<photo_session.imax then
                    fg(0.9,0.9,0.9)
                    rect('fill',0,12+sh/4-24+12,sw,24)
                    fg(0.6,0.8,0.5)
                    rect('fill',4,12+sh/4-24+4+12,(sw-8)*(photo_session.i/(photo_session.imax-1)),24-8)
                end
                if photo_session.i==photo_session.imax then
                    castledraw(photo_session.canvas,photo_session.blocks,photo_session.decos,photo_session.mysteries,photo_session.lion)
                end

                if photo_session.i==photo_session.imax then
                    lg.setCanvas()
                        lg.draw(photo_session.canvas,sw/2-sw/4,12,0,0.5,0.5)

                        lg.setFont(lionfont)
                        fg(211/255,254/255,218/255,1)
                        local msg=fmt('by %s ',photo_session.player)
                        local tw=lionfont:getWidth(msg)
                        local tx=0
                        for i=1,#msg do
                            lg.print(sub(msg,i,i),sw/2-round(tw/2)+tx-12,12+sh/2+6+sin(i+t*0.04)*3+3)
                            tx=tx+lionfont:getWidth(sub(msg,i,i))
                            if i==#msg then
                                if not photo_session.img then
                                    if photo_session.avatar then
                                        --photo_session.img=lg.newImage(photo_session.avatar)
                                    else
                                        photo_session.img=lg.newCanvas(24,24)
                                        lg.setCanvas(photo_session.img)
                                            bg(112/255,105/255,49/255,1)
                                        lg.setCanvas()
                                    end
                                end
                                fg(1,1,1,1)
                                lg.draw(photo_session.img,sw/2-round(tw/2)+tx-12,12+sh/2+6+sin(i+t*0.04)*3+3,0,24/photo_session.img:getWidth(),24/photo_session.img:getHeight())
                            end
                        end

                        lg.setFont(descfont)
                        local ideas= #photo_session.disco
                        local new_ideas=0
                        for i,tag in ipairs(photo_session.disco) do if not disco[tag] or (disco[tag] and disco[tag].unread) then new_ideas=new_ideas+1 end end
                        msg=fmt('using %d ideas (%d new to you)',ideas,new_ideas)
                        tw=descfont:getWidth(msg)
                        fg(112/255,105/255,49/255,1)
                        local rw=math.max(tw+2,sw/2+4)
                        rect('fill',sw/2-rw/2,0,rw,12-2)
                        fg(0.8,0.8,0.8,1)
                        lg.print(msg,sw/2-tw/2,0-3)--12+sh/2+6+3+3+2)
                end
            end

    end


love.draw = castledraw


-- set things up to be pixel-perfect.
-- (they won't entirely be.. when scaled. i wonder what Castle's doing with the pipeline.)
-- (apparently you can fix things by integer-rounding every drawn position, so i've done that.)
    lg.setDefaultFilter('nearest') -- nearest is dearest.

require('draw-utility')
require('draw-anim')

camera={x=0,y=0,shake=0}


-- everything sans interface that we can send as a screenshot,
-- and record for playback in ideamode.
    photo_canvas = lg.newCanvas(sw,sh)

    particles = {}

-- graphical resources.
    
    -- font by Florian Contreras:
        threed =  lg.newFont('3D-Thirteen-Pixel-Fonts.ttf',32) 
        threed2 = lg.newFont('3D-Thirteen-Pixel-Fonts.ttf',32*2)
    -- font by Zacchary Dempsey-Plante:
        lionfont = lg.newFont('Pixellari.ttf',16) 
    -- font by Yusuke Kamiyamane:
        descfont = lg.newFont('pf_easta_seven.ttf',8)
    
    lg.setFont(threed)


-- now for the implementation of what's referenced in castledraw.

    -- turn the spritesheets into actual canvases that will be drawn.
        create_images()


    -- clear & draw background.
        function bgdraw()
            -- cute, apparently here's where i started from :D
                --local y_offset = 8 * math.sin(t * 0.3)
                --lg.print('Edit main.lua to get started!', 400, 300 + y_offset)
                --lg.print('Press Cmd/Ctrl + R to reload.', 400, 316 + y_offset)
            -- unnecessary visual considering nobody will see this
                bg(0.5,0.5+sin(t*0.03)*0.2,0.5+sin((t+90)*0.03)*0.2,1)

            -- i thought the stripes would be placeholder,
            -- but people said the colours look nice,
            -- and i've designed the sprites around their contrast..
                for y=0,sh,48 do
                    fg(0.7+sin(y*0.01+t*0.03)*0.2,0.7+sin(y*0.01+t*0.03)*0.2,0.6,1)
                    rect('fill',0,y,sw,48)
                end
        end

    -- mysteries, just question marks currently.
        function mysterydraw(mysteries)
            fg(1,1,1,1)
            for k,m in pairs(mysteries) do
                -- m.x and m.y may be subject to tweening.
                local kx,ky=strpos(k)
                -- last processing step is in love.draw,
                -- mysteries are mysterious in that way.
                    m.x=m.x or kx*48; m.y=m.y or ky*48
                    local mx,my= round(m.x),round(m.y)

                if m.tex=='?' then lg.draw(images.qmark,mx,my)
                else print(fmt('mystery at %d,%d with no texture somehow',mx,my)) end
            end
        end

    -- decoration sprites.
        function decodraw(decos)
            fg(1,1,1,1)
            for k,d in pairs(decos) do
                -- d.x and d.y may be subject to tweening.
                local dx,dy= round(d.x),round(d.y)
                if d.id==12 then
                    if d.tex then lg.draw(images[fmt('%s-%d',d.img,d.tex)],dx,dy)
                    else          lg.draw(images[d.img],dx,dy)                    end
                else
                    if d.tex==1 then recolor:send('r',213.0/255.0); recolor:send('g',110.0/255.0); recolor:send('b',112.0/255.0); 
                        shade(recolor) end
                    if d.tex==2 then recolor:send('r',240.0/255.0); recolor:send('g',205.0/255.0); recolor:send('b',254.0/255.0); 
                        shade(recolor) 
                    end
                        lg.draw(images[d.img],dx,dy)
                    shade()
                end
            end
        end

    -- lion entity.
        function liondraw(lion)
            -- highlight current active tile.
                fg(0.7,0.3,0.3,0.5+sin(t*0.1)*0.3)
                rect('fill',lion.cx,lion.cy,48,48)

            -- circle placeholder asdfa        
                --fg(0.94,0.84+sin(t*0.05)*0.1,0.94,1)
                --lg.circle('fill',lion.x+24,lion.y+24,24-4+sin(t*0.05)*4)

            -- lion in the Castle.
                fg(1,1,1,1)
                local flip=-1; if lion.dx<0 then flip=1 end
                local xx,xy=lion.xx or 0, lion.xy or 0

                for dx=-1,1 do for dy=-1,1 do

                    -- draw him, flipped if necessary.
                    -- i think once animations come in, 
                    -- i'll just change an image associated with the lion entity,
                    -- so that there's no animation logic in love.draw.
                        lg.draw(images.lion, round(lion.x+6*dx*48+24-2+xx),round(lion.y+6*dy*48-3+xy),0, flip,1,24,0)

                end end

        end

    -- walls with their connections.
    -- wall formations could be cached as their own canvases,
    -- but since they are so dynamic, it would be a hassle.
    -- and it would break this 'one tile at a time' thinking.
        function blockdraw(blocks)
            for k,b in pairs(blocks) do
                -- b.x and b.y may be subject to tweening.
                local bx,by= round(b.x),round(b.y)

                fg(1,1,1,1)

                -- if a known mystery is beneath then highlight this.
                    if mysteries[k] and mysteries[k].known and not flux:active() then fg(240/255, 205/255-sin((t/2)%80*pi/80)*0.3, 254/255, 1) end

                -- if a push/pull is prevented there's a visual highlight 
                -- in the walls that caused this.                                    
                    if b.flash then b.flash=b.flash+1; if b.flash>80 then b.flash=nil end end
                    if b.flash then fg(1-0.2, 1-sin(b.flash*pi/80)*0.7, 1-sin(b.flash*pi/80)*0.7, 1) end
                
                -- rendering connected walls from spritesheet.
                -- have fun.
                    if not find(b,'u') then 
                        if not find(b,'l') then lg.draw(images.brick11,b.x,by) 
                        else lg.draw(images.brick9,bx,by) end
                        if not find(b,'r') then lg.draw(images.brick12,bx+24,by) 
                        else lg.draw(images.brick9,bx+24,by) end
                    else
                        lg.draw(images.brick9,bx,by) 
                        lg.draw(images.brick9,bx+24,by)               
                    end
                    if not find(b,'d') then 
                        if not find(b,'l') then lg.draw(images.brick14,bx,by+24) 
                        else lg.draw(images.brick9,bx,by+24) end
                        if not find(b,'r') then lg.draw(images.brick13,bx+24,by+24) 
                        else lg.draw(images.brick9,bx+24,by+24) end
                    else
                        lg.draw(images.brick9,bx,by+24)
                        lg.draw(images.brick9,bx+24,by+24)               
                    end

                    lg.draw(images[fmt('tex%d',b.tex+1)],bx,by) 
                    
                    if not find(b,'u') then 
                        if not find(b,'l') then lg.draw(images.brick8,bx,by) 
                        else lg.draw(images.brick1,bx,by) end
                        if not find(b,'r') then lg.draw(images.brick2,bx+24,by) 
                        else lg.draw(images.brick1,bx+24,by) end
                        if find(b,'l') and find(b,'d') then lg.draw(images.brick17,bx,by+24) end
                        if find(b,'r') and find(b,'d') then lg.draw(images.brick16,bx+24,by+24) end
                    else
                        -- alt shading
                            if not find(b,'l') then lg.draw(images.brick15,bx,by) 
                        else lg.draw(images.brick18,bx,by) end
                        if not find(b,'r') then lg.draw(images.brick3,bx+24,by) 
                        else lg.draw(images.brick19,bx+24,by) end
                    end
                    if not find(b,'d') then 
                        if not find(b,'l') then lg.draw(images.brick6,bx,by+24) 
                        else lg.draw(images.brick5,bx,by+24) end
                        if not find(b,'r') then lg.draw(images.brick4,bx+24,by+24) 
                        else lg.draw(images.brick5,bx+24,by+24) end
                        if find(b,'r') and find(b,'u') then lg.draw(images.brick19,bx+24,by) end
                        if find(b,'l') and find(b,'u') then lg.draw(images.brick18,bx,by) end 
                    else
                        if not find(b,'l') then lg.draw(images.brick7,bx,by+24) 
                        else lg.draw(images.brick17,bx,by+24) end
                        if not find(b,'r') then lg.draw(images.brick3,bx+24,by+24) 
                        else lg.draw(images.brick16,bx+24,by+24) end                
                    end
                    
            end

            -- particles are created by blocks merging,
            -- and we want them to be visible in photo_canvas
            -- (while being the next layer above blocks)
            -- so let's process them here.
                fg(1,1,1,1)
                for i=#particles,1,-1 do
                    local p= particles[i]

                    if (t+i)%16>=8 then
                        lg.draw(p.img,p.x-12,p.y-12)
                    end

                    p.x=p.x+p.dx; p.y=p.y+p.dy
                    p.dy=p.dy+0.2
                    if p.dy>=8 then rem(particles,i) end
                end
        end

    -- everything to do with the interface.
    -- note that lion.shifting from state.lua is used
    -- for timing here, it's a bit odd i admit.
        function interfacedraw()
            -- lightbulbs.
            -- this draw step used to be associated with the lion,
            -- but i realized that since lightbulbs behave like part of the interface,
            -- i should admit they are part of the interface.
                local xx,xy=lion.xx or 0, lion.xy or 0
                for dx=-1,1 do for dy=-1,1 do
                    local tc=0
                    for i,tag in ipairs(disco_order) do
                        if disco[tag].unread then
                            lg.draw(images.bulb,round(lion.x+6*dx*48+xx),round(lion.y+6*dy*48-3-48*(tc+1)+xy))
                            tc=tc+1
                        end
                        -- but only 5 tops.
                            if tc>=5 then break end
                    end

                end end

            if not intro_read then
            for dx=-1,1 do for dy=-1,1 do
            sine3d('Arrows and Shift!',lion.x+24+xx+dx*6*48,lion.y-12+xy+dy*6*48-2-4,t)
            end end
            end

            -- Shift (or tap) state.
                if love.update==shiftctrl then
                    for dx=-1,1 do for dy=-1,1 do
                    sine3d('^Push',lion.x+24+xx+dx*6*48,lion.y-12+xy+dy*6*48-2-4,lion.shifting)
                    sine3d('vPull',lion.x+24+xx+dx*6*48,lion.y+24+12+xy+dy*6*48-2,lion.shifting)
                    if #disco_order>0 then
                    sine3d('<Idea',lion.x+24-64+xx+dx*6*48,lion.y+12+xy+dy*6*48-2,lion.shifting)
                    end

                    if (disco['push'] and not disco['push'].unread) and 
                       (disco['pull'] and not disco['pull'].unread) then
                        sine3d('>Snap',lion.x+24+64+xx+dx*6*48,lion.y+12+xy+dy*6*48-2,lion.shifting)
                    end
                    end end
                end

            -- push and pull states.
            -- these are annoying because font prints don't line up
            -- and you end up adjusting them with eyeballed pixel offsets.
            -- i'll make proper arrow sprites that look less blocky anyway.
                if love.update==pushmode then
                    lg.setFont(threed2)
                    fg(0.34,0.24+sin(lion.shifting*0.05)*0.1,0.34,1)
                        local ppos=wrappos2(lion.cx/48+1,lion.cy/48)
                        local ox,oy;
                        local oc=0;
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('>',ox*48+4+lion.shifting%16,oy*48-8) end
                        ppos=wrappos2(lion.cx/48-1,lion.cy/48)
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('<',ox*48-4+8+8+6-lion.shifting%16,oy*48-8) end
                        ppos=wrappos2(lion.cx/48,lion.cy/48+1)
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('v',ox*48+8,oy*48+4-8-6-2+lion.shifting%16) end
                        ppos=wrappos2(lion.cx/48,lion.cy/48-1)
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('^',ox*48+8,oy*48+8+8-lion.shifting%16) end
                    lg.setFont(threed)
                    if oc==0 then 
                        for dx=-1,1 do for dy=-1,1 do
                        sine3d('Shift to return.',lion.x+24+dx*48*6,lion.y+24-12+dy*48*6,lion.shifting) 
                        end end
                    end
                end
                if love.update==pullmode then
                    lg.setFont(threed2)
                    fg(0.34,0.24+sin(lion.shifting*0.05)*0.1,0.34,1)
                        local ppos=wrappos2(lion.cx/48+1,lion.cy/48)
                        local ox,oy;
                        local oc=0;
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('<',ox*48-4+8+lion.shifting%16,oy*48-8) end
                        ppos=wrappos2(lion.cx/48-1,lion.cy/48)
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('>',ox*48+4+8+8-2-lion.shifting%16,oy*48-8) end
                        ppos=wrappos2(lion.cx/48,lion.cy/48+1)
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('^',ox*48+8,oy*48-4+lion.shifting%16) end
                        ppos=wrappos2(lion.cx/48,lion.cy/48-1)
                        if occupied(ppos) then oc=oc+1; ox,oy=strpos(ppos); lg.print('v',ox*48+8,oy*48+2-lion.shifting%16) end
                    lg.setFont(threed)
                    if oc==0 then 
                        for dx=-1,1 do for dy=-1,1 do
                        sine3d('Shift to return.',lion.x+24+dx*48*6,lion.y+24-12+dy*48*6,lion.shifting) 
                        end end
                    end
                end

        end

