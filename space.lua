--[[ handling positions of the game space. ]]--


-- you give this the numbers 0 and 1, it will return a string '0,1'.
-- table keys use this format consistently. 
    function posstr(x,y)
        return fmt('%d,%d',x,y)
    end

-- you give this the string '0,1', it will return 0 and 1. 
    function strpos(pos)
        local delim=string.find(pos,',')
        local x=sub(pos,1,delim-1)
        local y=sub(pos,delim+1)
        --important tonumber calls
        --Lua will handle a string+number addition until it doesn't
        return tonumber(x),tonumber(y)
    end

-- wraps positions around a 6x6 space, so 0,-1 becomes '0,5'.
-- pushes/pulls happen in increments of 1 tile, so i haven't expanded this to take positions beyond -6 into account.
-- side effect of setting REGisters so you know whether a wrap happened.
    function wrappos2(px,py)
        REG.lastwrap=false
        if px<0 then px=px+6; REG.lastwrap=true end; if px>=6 then px=px-6; REG.lastwrap=true end
        if py<0 then py=py+6; REG.lastwrap=true end; if py>=6 then py=py-6; REG.lastwrap=true end
        return posstr(px,py)
    end

-- is there a push/pull object at ppos.
    function occupied(ppos)
        local out;
        out = blocks[ppos]; if out then REG.lastoccupy=blocks; return out end 
        out = decos[ppos]; if out then REG.lastoccupy=decos; return out end 
        out = mysteries[ppos]; if out then REG.lastoccupy=mysteries; return out end 
        return nil
    end

cardinal = {
    {key='left',  dx=-1, dy= 0, dir='l', opposite='r'},
    {key='right', dx= 1, dy= 0, dir='r', opposite='l'},
    {key='up',    dx= 0, dy=-1, dir='u', opposite='d'},
    {key='down',  dx= 0, dy= 1, dir='d', opposite='u'},
}
