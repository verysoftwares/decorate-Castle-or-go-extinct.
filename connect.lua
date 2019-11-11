--[[ logic for adjacent objects. ]]--


function connect(blocks)
    for k,v in pairs(blocks) do
        local x,y= strpos(k)
        -- image positions for tweening
        -- and connections ('click')
            v.x=x*48
            v.y=y*48
            v.click={}
            if not v.tex then v.tex=0 end
        -- loop unaffected by above non-numeric keys
            for i,dir in ipairs(v) do
                if dir=='u' then ins(v.click, wrappos2(x,y-1)) end
                if dir=='d' then ins(v.click, wrappos2(x,y+1)) end
                if dir=='l' then ins(v.click, wrappos2(x-1,y)) end
                if dir=='r' then ins(v.click, wrappos2(x+1,y)) end
            end
    end
end

function formation(pos,layer)
    -- given a pos that's already been checked to contain a block/deco,
    -- return the positions of all blocks or decos in its formation.
    -- for mysteries, see 'mystery_sequence'.
    layer=layer or blocks
    
    local out= {}
    ins(out,pos)
    for i,unchecked in ipairs(out) do
        -- table expands as we loop thru
        for j,neighbour in ipairs(layer[unchecked].click) do
            if not find(out,neighbour) then
                ins(out,neighbour)
            end
        end
    end
    return out
end

-- disconnects a tile from its neighbours.
    function disconnect(pos,layer)
        local px,py=strpos(pos)
        for i,c in ipairs(cardinal) do
            local neighbour= wrappos2(px+c.dx,py+c.dy)
            if layer[neighbour] then
                local j;
                j=find(layer[pos].click, neighbour)
                if j then rem(layer[pos].click, j) end                
                j=find(layer[neighbour].click, pos)
                if j then rem(layer[neighbour].click, j) end

                -- for blocks
                j=find(layer[pos], c.dir)
                if j then rem(layer[pos], j) end
                j=find(layer[neighbour], c.opposite)
                if j then rem(layer[neighbour], j) end
            end
        end
        layer[pos]=nil
    end

function mystery_sequence(pos,dx,dy)
    local out={}
    ins(out,pos)
    local mx,my=strpos(pos);
    local nxt=wrappos2(mx+dx,my+dy);
    for i,m in ipairs(out) do
        if mysteries[nxt] and not find(out,nxt) then
            ins(out,nxt)
        end
        mx,my=strpos(nxt)
        nxt=wrappos2(mx+dx,my+dy)
    end
    return out
end

function uncover(mysteries)
    --called more often than connect(blocks), when world updates

    -- find the visible formations of [?] tiles
    -- and deduce what recipes need to be activated.
    -- recipes are exact in the way that
    -- an L tetrimino won't produce anything,
    -- it does not activate the two sub-recipes it seemingly contains.
        local formations= mystery_formations(mysteries)
        if #formations>0 then discover('mysteries') end

    for k,m in pairs(mysteries) do
        if not blocks[k] then
            m.known=true
        end
        if blocks[k] and m.known then
            assure('mysteryknown')
        end
    end

    for i,f in ipairs(formations) do
        -- sort so that the top-left corner is always f[1]
        -- and the order goes like
        -- 1 2 3
        --   4 5 6
            formations[i]=table.sort(f, function(a,b) 
                local ax,ay=strpos(a.pos)
                local bx,by=strpos(b.pos)
                -- quickfix for looping recipes that works until 
                -- weird shapes are added.
                if a.form.wrapped then
                if ax==0 then ax=ax+6 end; if bx==0 then bx=bx+6 end
                if ay==0 then ay=ay+6 end; if by==0 then by=by+6 end
                end
                if ay<by then return true end
                if ay==by then return ax<bx end
                return false
            end)

        if #f==1 and f[1].wrap then
            if     f[1].wrap==pushmode then newdeco(14,f[1].pos); discover('paintred')
            elseif f[1].wrap==pullmode then newdeco(20,f[1].pos); discover('paintmag') end
            
            mysteries[f[1].pos]=nil
        end
        if #f==2 then
            local f1x,f1y= strpos(f[1].pos)
            if f[2].pos==wrappos2(f1x+1,f1y) then
                newdeco(7,f[1].pos); discover('sofa')
                mysteries[f[1].pos]=nil; mysteries[f[2].pos]=nil
            elseif f[2].pos==wrappos2(f1x,f1y+1) then
                newdeco(0,f[1].pos); discover('plant')
                mysteries[f[1].pos]=nil; mysteries[f[2].pos]=nil
            end
        end
        if #f==4 then
            local f1x,f1y= strpos(f[1].pos)
            if f[2].pos==wrappos2(f1x+1,f1y) and f[3].pos==wrappos2(f1x,f1y+1) and f[4].pos==wrappos2(f1x+1,f1y+1) then
                newdeco(12,f[1].pos); discover('shelf')
                for i2=1,4 do mysteries[f[i2].pos]=nil end
            end
        end
    end
    for k,m in pairs(mysteries) do
        m.pos=nil
        m.form=nil  -- so we don't end up submitting a nested table online :p
    end
end

-- floodfill to get unique mystery formations.
-- sometimes game code be like this.
    function mystery_formations()
        local formations = {}
        for k,v in pairs(mysteries) do
            local kx,ky=strpos(k)
            if kx<0 or kx>5 or ky<0 or ky>5 then goto continue end
            if blocks[k] then goto continue end

            for k2,v2 in ipairs(formations) do
                if find(v2,v) then
                    goto continue
                end
            end

            ins(formations, {v})
            v.pos=k
            v.form=formations[#formations]

            for k2,v2 in ipairs(formations[#formations]) do
                local mx,my= strpos(v2.pos)
                for _,c in ipairs(cardinal) do
                    local pos=wrappos2(mx+c.dx,my+c.dy)

                    if mysteries[pos] and not blocks[pos] then
                        -- if it's not in any of the existing formations either
                        for k3,v3 in ipairs(formations) do
                            if find(v3,mysteries[pos]) then
                                goto skip
                            end
                        end
                        local newm= mysteries[pos]
                        ins(formations[#formations], newm)
                        newm.pos=pos
                        newm.form=formations[#formations]
                        if REG.lastwrap then newm.form.wrapped=true end
                    end
                    ::skip::
                end
            end
            ::continue::
        end

        return formations
    end

function paint_formation(pos,col,layer)
    -- might've been crushed before the calling closure activates
        if not layer[pos] then return end

    local origtex=layer[pos].tex
    if origtex==col then return end
    
    layer=layer or blocks     
    local out= {}
    ins(out,pos)
    
    for i,unchecked in ipairs(out) do
        for j,neighbour in ipairs(layer[unchecked].click) do
            if not find(out,neighbour) then
                if layer[neighbour].tex==origtex then
                    ins(out,neighbour)
                else
                    discover('paintsame')
                end
            end
        end
    end

    for i,v in ipairs(out) do
        if     col=='red'     then layer[v].tex=1
        elseif col=='magenta' then layer[v].tex=2   end
        if layer==blocks then discover('paintjob')  end
        if layer==decos  then discover('paintdeco') end
    end
end

