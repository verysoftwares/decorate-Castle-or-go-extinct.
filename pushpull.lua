--[[ main game mechanic! ]]--


-- push/pull force happens at ppos towards dx,dy. here's what to do:
    function shiftall(ppos,dx,dy)
        local nxtlayer=REG.lastoccupy
        -- hurry up previous shift that might be ongoing.
            flux:finishall()
        
        local context={}

        context.disco={}           -- for discoveries that emerge and happen after action
        context.poststop={}        -- consequences that require a successful push/pull first
        context.poststop.arg={}    -- persistent arguments for a closure which bends scopes too much
        context.posttween={arg={}} -- like poststop but even after animations finish
        context.dx=dx; context.dy=dy
        context.tween_t= 0.5       -- heavier objects increase animation length
        
        REG.lastoccupy=nxtlayer
        context.shapes={shiftshape(ppos,dx,dy)}

        if context.shapes[1].layer==decos     then promise(context,'decopushpull')    end
        if context.shapes[1].layer==mysteries then promise(context,'mysterypushpull') end
                            
        if love.update==pushmode and context.shapes[1].layer==blocks then promise(context,'push') end
        if love.update==pullmode and context.shapes[1].layer==blocks then promise(context,'pull') end
        predict('mysteries')


        -- logic of recursive shapes (1st compile of 2 possible)
            compile(context)
        

        -- interrupt
            local merging=false
            local stopping=false

            for i,c in ipairs(context) do
                if c.merge then 
                    merging=true; 
                
                    me=blocks[c.pos]; them=blocks[c.mergetgt]

                    ins(me.click,c.mergetgt)
                    if dx==1 then ins(me,'r') end; if dx==-1 then ins(me,'l') end; if dy==-1 then ins(me,'u') end; if dy==1 then ins(me,'d') end 
                    ins(them.click,c.pos)
                    if dx==1 then ins(them,'l') end; if dx==-1 then ins(them,'r') end; if dy==-1 then ins(them,'d') end; if dy==1 then ins(them,'u') end 

                    spawn_particles(c.pos,dx,dy)
                end
            end
            if merging then 
                assure('merge')
                return
            end

            for i,c in ipairs(context) do
                if c.stop then stopping=true 
                    blocks[c.pos].flash=1 
                end
            end
            if stopping then 
                assure('block->block')
                return 
            end

        -- final possible interrupt:
        -- does adjusting the lion prevent the move from happening?
        -- we compare to a   f u t u r e   v i r t u a l   state of blocks.
            if context.lionadjust then 
                local fvblocks= {}
                for i,c in ipairs(context) do if c.layer==blocks then local cx,cy= strpos(c.pos); ins(fvblocks,{fvpos=wrappos2(cx+context.dx,cy+context.dy),pos=c.pos}) end end
                -- we also need the unmoving ones from current state:
                for k,b in pairs(blocks) do if not findf(context,function(v) return v.layer==blocks and v.pos==k end) then ins(fvblocks,{fvpos=k,pos=k}) end end
                
                for i,fv in ipairs(fvblocks) do
                    local fvx,fvy= strpos(fv.fvpos)
                    local cla= context.lionadjust
                    if AABB(cla.x,cla.y,48-4,48-3, fvx*48,fvy*48,48,48) then
                        blocks[fv.pos].flash=1
                        stopping=true
                    end
                end 
            end
            if stopping then
                assure('lionway')
                return
            end

        -- 2nd compile phase for results which depend on poststop actions.
        -- skips past already compiled shapes.
            for i,f in ipairs(context.poststop) do f(i) end
            compile(context)

        -- and now to actually shift everything.
        -- compilation shapes have no meaning now, 
        -- we just handle the flat context.
            build(context)

        -- incoming discoveries start recording a 
        -- reference animation for the idea screen.
            for i,dis in ipairs(context.disco) do
                predict(dis)
            end

        if context.lionadjust then
            local gx,gy= 0,0
            if (context.dx>0) then gx=-48+(lion.x%48) end
            if (context.dx<0) then gx=48
                if lion.x%48>4 then gx=gx-(48-lion.x%48) end
            end
            if (context.dy>0) then gy=-48+(lion.y%48) end
            if (context.dy<0) then gy=48
                if lion.y%48>3 then gy=gy-(48-lion.y%48) end
            end
            lion.xx=gx; if context.dx<0 then lion.xx=lion.xx+4 end; flux:to(lion,context.tween_t,{xx=0})
            lion.xy=gy; if context.dy<0 then lion.xy=lion.xy+3 end; flux:to(lion,context.tween_t,{xy=0})
            lion.x=context.lionadjust.x; lion.y=context.lionadjust.y
        end
        
    end

function compile(context)
    for i,shape in ipairs(context.shapes) do
        
        if shape.checked then goto skip end
        for i2,pos in ipairs(shape) do
            -- include if not already included in context
                if not findf(context,function(v) return v.pos==pos and v.layer==shape.layer end) then
                    ins(context,{pos=pos,layer=shape.layer})
                else 
                    shape.checked=true 
               end
        end
        if shape.checked then goto skip end
        
        if shape.layer==blocks then context.crushing=true end
        for i2=#shape,1,-1 do
            pos=shape[i2]
            -- just get the shape, we will loop the logic
            local px,py= strpos(pos)
            local nxt = wrappos2(px+context.dx,py+context.dy)
            local nxtlayer;
            
            if occupied(nxt) then
                nxtlayer=REG.lastoccupy
                if findf(context,function(v) return v.pos==nxt and v.layer==nxtlayer end) then
                    -- however. there is a case where a formation
                    -- looping over itself still includes unprocessed mysteries below blocks,
                    -- and they would get skipped. so let's explicitly handle that.
                    -- discovered by borb in our playtesting sesh.

                    -- this quickfix might add redundant mystery sequences to context.shapes,
                    -- but it doesn't break the flat context's logic, 
                    -- it's just a few extra shapes to loop over.
                        if shape.layer==decos and blocks[nxt] and mysteries[nxt] then 
                            local mysseq= mystery_sequence(nxt,context.dx,context.dy)
                            mysseq.layer= mysteries
                            mysseq.underneath= true     -- to suppress a discovery which could be confusing
                            ins(context.shapes,mysseq)
                        end
                     goto continue
                end

                -- block->block: stop or merge
                -- deco->block: ok, except crush if was knocked by an earlier block
                -- mystery->block: no interaction
                    if nxtlayer==blocks then
                        if shape.layer==blocks then promise(context,'block->block') end
                        if shape.layer==decos then promise(context,'deco->block') end
                        if shape.layer==mysteries and not shape.underneath then promise(context,'mystery<->block') end

                        if shape.layer==blocks then 
                            local attr='stop'
                            if blocks[pos].tex==1 or nxtlayer[nxt].tex==1 or 
                               blocks[pos].tex==2 or nxtlayer[nxt].tex==2 then
                                attr='merge'
                            end
                            for i3,c in ipairs(context) do
                            if c.pos==pos and c.layer==shape.layer then
                                context[i3][attr]=true
                                context[i3].mergetgt=nxt
                                break   -- there's only one of this block
                            end
                            end
                        elseif shape.layer==decos then
                            -- even if blocks have been checked,
                            -- that doesn't mean the mysteries underneath have.
                            -- we don't want decos to overlap mysteries ever.
                                if mysteries[nxt] then 
                                    local mysseq= mystery_sequence(nxt,context.dx,context.dy)
                                    mysseq.layer= mysteries
                                    mysseq.underneath= true     -- to suppress a discovery which could be confusing
                                    ins(context.shapes,mysseq)
                                end

                            if context.crushing then
                                rem(shape,i2)
                                promise(context,'crush')
                                ins(context.poststop, function(i) crush(context.poststop.arg[i],decos,context) end) 
                                ins(context.poststop.arg, pos)
                            else
                                if shape.layer[pos].id==12 then
                                    promise(context,'wallcrush')
                                    ins(context.poststop, function(i) crush(context.poststop.arg[i],blocks,context) end)
                                    ins(context.poststop.arg, nxt)
                                elseif shape.layer[pos].id==14 or shape.layer[pos].id==20 then
                                    predict('paintjob'); predict('paintsame')
                                    ins(context.posttween, function(i) local cpa=context.posttween.arg[i]; paint_formation(cpa[1],cpa[2],cpa[3]) end)
                                    local nx,ny= strpos(nxt)
                                    local arg={}
                                    ins(arg, wrappos2(nx+context.dx,ny+context.dy))
                                    if     shape.layer[pos].id==14 then ins(arg,'red')
                                    elseif shape.layer[pos].id==20 then ins(arg,'magenta') end
                                    ins(arg,nxtlayer)
                                    ins(context.posttween.arg,arg)

                                    ins(context.shapes, shiftshape(nxt,context.dx,context.dy))
                                else
                                    ins(context.shapes, shiftshape(nxt,context.dx,context.dy))
                                end
                            end
                        end

                -- block->deco: ok
                -- deco->deco: ok
                -- mystery->deco: ok
                    elseif nxtlayer==decos then
                        if shape.layer==blocks then promise(context,'block->deco') end
                        if shape.layer==decos then promise(context,'deco->deco') end
                        if shape.layer==mysteries then promise(context,'mystery->deco') end

                        if shape.layer==decos then 
                            if shape.layer[pos].id==14 or shape.layer[pos].id==20 then
                                local nx,ny= strpos(nxt)
                                local arg={}
                                local nnp=wrappos2(nx+context.dx,ny+context.dy)
                                ins(arg, nnp)

                                if nxtlayer[nxt].id==14 or nxtlayer[nxt].id==20 then 
                                    predict('paintpaint')   --                                             v      might've been crushed..
                                    ins(context.posttween, function(i) local cpa=context.posttween.arg[i]; if not decos[cpa[1]] then return end; if not (decos[cpa[1]].id==cpa[2].id) then discover('paintpaint') end; decos[cpa[1]].id=cpa[2].id; decos[cpa[1]].img=cpa[2].img end)
                                    ins(arg, shape.layer[pos])
                                else
                                    predict('paintdeco')
                                    ins(context.posttween, function(i) local cpa=context.posttween.arg[i]; paint_formation(cpa[1],cpa[2],cpa[3]) end)
                                    if     shape.layer[pos].id==14 then ins(arg,'red')
                                    elseif shape.layer[pos].id==20 then ins(arg,'magenta') end
                                    ins(arg, nxtlayer)
                                end

                                ins(context.posttween.arg,arg)
                            end                                    
                        end

                        ins(context.shapes, shiftshape(nxt,context.dx,context.dy))

                -- block->mystery: no interaction
                -- deco->mystery: ok
                -- mystery->mystery: shiftshape already accounted for 
                    elseif nxtlayer==mysteries then
                        if shape.layer==blocks and not shape.underneath then promise(context,'mystery<->block') end
                        if shape.layer==decos then promise(context,'deco->mystery') end
                        if shape.layer==mysteries then promise(context,'mystery->mystery') end

                        if shape.layer==decos then
                            ins(context.shapes, shiftshape(nxt,context.dx,context.dy))
                        end
                    end

            end

            ::continue::
            
            if shape.layer==blocks and ((not nxtlayer) or nxtlayer==mysteries or nxtlayer==decos) then    
                if not context.lionadjust then
                    local wx,wy= strpos(nxt)
                    
                    if AABB(lion.x,lion.y,48-4,48-3, wx*48,wy*48,48,48) 
                    or AABB(lion.x,lion.y-6*48,48-4,48-3, wx*48,wy*48,48,48)
                    or AABB(lion.x-6*48,lion.y,48-4,48-3, wx*48,wy*48,48,48) then
                        
                        wx,wy= strpos(wrappos2(wx+context.dx,wy+context.dy))
                        context.lionadjust={x=lion.x,y=lion.y}
                        local cla= context.lionadjust
                        if not (context.dx==0) then cla.x=wx*48 
                        if context.dx>0 then cla.x=cla.x+4 end
                        end
                        if not (context.dy==0) then cla.y=wy*48
                        if context.dy>0 then cla.y=cla.y+3 end
                        end

                    end
                end
            end
            
            
        end
        shape.checked=true
        ::skip::
    end
end

function build(context)
    -- clear out everything first. 
        for i,c in ipairs(context) do
            c.old=c.layer[c.pos]
           -- mysterious mysteries..
                local cx,cy=strpos(c.pos)
                if c.old == nil then return end
                c.old.x=c.old.x or cx*48; c.old.y=c.old.y or cy*48

            if c.layer==decos and c.layer[c.pos].id==12 then
                context.tween_t= 0.8
                camera.shake=3
            end

            c.layer[c.pos]=nil
        end

    predict('sofa'); predict('plant'); predict('shelf')

    for i,c in ipairs(context) do
        local cx,cy=strpos(c.pos)
        local new=wrappos2(cx+context.dx,cy+context.dy)

        -- regular old push/pull.
            if not REG.lastwrap then 
                c.layer[new]=c.old
                -- update connections
                    if not (c.layer==mysteries) then
                    for j,v in ipairs(c.old.click) do
                        local jx,jy=strpos(v)
                        c.old.click[j]=wrappos2(jx+context.dx,jy+context.dy)
                    end
                    end
                flux:to(c.layer[new], context.tween_t, {x=cx*48+context.dx*48, y=cy*48+context.dy*48})
                    :oncomplete(function() for i,d in ipairs(context.disco) do discover(d) end 
                                           for i,f in ipairs(context.posttween) do f(i) end
                                           camera.shake=0
                                           uncover(mysteries) end)

        -- wraparound, some extra logic tied to this.
            else
            -- wrapping & transmute
                if c.layer==mysteries then predict('paintred'); predict('paintmag') end
                promise(context,'wraparound')

                -- old goes off-screen.
                    local oobx,ooby=cx+context.dx,cy+context.dy
                    local oob=posstr(oobx,ooby)
                    c.layer[oob]=c.old
                    flux:to(c.layer[oob], context.tween_t, {x=oobx*48, y=ooby*48})
                        :oncomplete(function() c.layer[oob]=nil
                                               uncover(mysteries) end)

                -- new comes from the opposite off-screen.
                    local newx,newy=strpos(new)
                    c.layer[new]=deepcopy(c.old)
                    -- update connections
                        if not (c.layer==mysteries) then
                        for j,v in ipairs(c.layer[new].click) do
                            local jx,jy=strpos(v)
                            c.layer[new].click[j]=wrappos2(jx+context.dx,jy+context.dy)
                        end
                        end
                    c.layer[new].x=(newx-context.dx)*48; c.layer[new].y=(newy-context.dy)*48
                    if c.layer==mysteries then c.layer[new].wrap=love.update end
                    flux:to(c.layer[new], context.tween_t, {x=newx*48, y=newy*48})
                        :oncomplete(function(o) for i,d in ipairs(context.disco) do discover(d) end
                                                for i,f in ipairs(context.posttween) do f(i) end
                                                camera.shake=0
                                                uncover(mysteries)
                                                o.wrap=nil end)
            end 
    end
end

-- there is a natural language synergy here:
-- a promise is made in a context, and if that context
-- is changed, then the promise is broken. </3
    function promise(context,dis) ins(context.disco,dis) end
-- a prediction needs no context,
-- you're just thinking this discovery might happen.
-- (usually related to mystery formations which are resolved after tweens)
    function predict(dis) if not disco[dis] and (not anime[dis] or (anime[dis] and anime[dis].t>0 and anime[dis].t<anime_maxrec)) then anime[dis]={i=1,t=0} end end
-- set in motion, unpreventable but interrupts can delay.
-- animation handles discovery at tween interval.    
    function assure(dis) predict(dis); anime[dis].assure=dis end


function shiftshape(ppos,dx,dy)
    local shape;
    local origin_layer=REG.lastoccupy
    if origin_layer==mysteries then shape= mystery_sequence(ppos,dx,dy)
    else shape= formation(ppos,origin_layer) end
    shape.layer=origin_layer
    return shape
end

-- crush deco/block and leave a mystery behind.
    function crush(pos,layer,context)
        disconnect(pos,layer)
        
        for ci=#context,1,-1 do
            if context[ci].pos==pos and context[ci].layer==layer then
                rem(context,ci)
                break
            end
        end
        if mysteries[pos] then 
            -- energy was not conserved
            if mysteries[pos].known then
                promise(context,'energyconserve') 
            end
        end
        mysteries[pos]={tex='?',known=true}
        local mysseq= mystery_sequence(pos,context.dx,context.dy)
        mysseq.layer= mysteries
        ins(context.shapes,mysseq)
    end

    