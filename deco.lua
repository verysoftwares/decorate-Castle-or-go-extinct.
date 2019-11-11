--[[ decoration database. ]]--


--TIC-style indexing
    canon = {
        [0]={0,0,1,2,tag='bush2'},
        [7]={1,1,2,1,tag='sofa1'},
        [12]={0,2,2,2,tag='shelf1'},
        [14]={2,2,1,1,tag='paint1'},
        [20]={2,3,1,1,tag='paint2'},
    }

function newdeco(id,dpos)
    if not canon[id] then print(fmt('yritettiin luua %d, ei oo %d.', id,id)); return end

    local dx,dy= strpos(dpos)
    if id==0 then
        decos[dpos]={}
        decos[dpos].x=dx*48
        decos[dpos].y=dy*48
        decos[dpos].id=id
        decos[dpos].img='bush2-1'
        decos[dpos].click={wrappos2(dx,dy+1)}
        decos[wrappos2(dx,dy+1)]={}
        decos[wrappos2(dx,dy+1)].x=dx*48
        decos[wrappos2(dx,dy+1)].y=((dy+1)%6)*48
        decos[wrappos2(dx,dy+1)].id=id
        decos[wrappos2(dx,dy+1)].img='bush2-2'
        decos[wrappos2(dx,dy+1)].click={dpos}
    elseif id==7 then
        decos[dpos]={}
        decos[dpos].x=dx*48
        decos[dpos].y=dy*48
        decos[dpos].id=id
        decos[dpos].img='sofa1-1'
        decos[dpos].click={wrappos2(dx+1,dy)}
        decos[wrappos2(dx+1,dy)]={}
        decos[wrappos2(dx+1,dy)].x=((dx+1)%6)*48
        decos[wrappos2(dx+1,dy)].y=dy*48
        decos[wrappos2(dx+1,dy)].id=id
        decos[wrappos2(dx+1,dy)].img='sofa1-2'
        decos[wrappos2(dx+1,dy)].click={dpos}
    elseif id==12 then
        decos[dpos]={}
        decos[dpos].x=dx*48
        decos[dpos].y=dy*48
        decos[dpos].id=id
        decos[dpos].img='shelf1-1'
        decos[dpos].click={wrappos2(dx+1,dy),wrappos2(dx,dy+1)}
        decos[wrappos2(dx+1,dy)]={}
        decos[wrappos2(dx+1,dy)].x=((dx+1)%6)*48
        decos[wrappos2(dx+1,dy)].y=dy*48
        decos[wrappos2(dx+1,dy)].id=id
        decos[wrappos2(dx+1,dy)].img='shelf1-2'
        decos[wrappos2(dx+1,dy)].click={dpos,wrappos2(dx+1,dy+1)}
        decos[wrappos2(dx,dy+1)]={}
        decos[wrappos2(dx,dy+1)].x=dx*48
        decos[wrappos2(dx,dy+1)].y=((dy+1)%6)*48
        decos[wrappos2(dx,dy+1)].id=id
        decos[wrappos2(dx,dy+1)].img='shelf1-3'
        decos[wrappos2(dx,dy+1)].click={dpos,wrappos2(dx+1,dy+1)}
        decos[wrappos2(dx+1,dy+1)]={}
        decos[wrappos2(dx+1,dy+1)].x=((dx+1)%6)*48
        decos[wrappos2(dx+1,dy+1)].y=((dy+1)%6)*48
        decos[wrappos2(dx+1,dy+1)].id=id
        decos[wrappos2(dx+1,dy+1)].img='shelf1-4'
        decos[wrappos2(dx+1,dy+1)].click={wrappos2(dx+1,dy),wrappos2(dx,dy+1)}
    elseif id==14 then
        decos[dpos]={}
        decos[dpos].x=dx*48
        decos[dpos].y=dy*48
        decos[dpos].id=id
        decos[dpos].img='paint1-1'
        decos[dpos].click={}
    elseif id==20 then
        decos[dpos]={}
        decos[dpos].x=dx*48
        decos[dpos].y=dy*48
        decos[dpos].id=id
        decos[dpos].img='paint2-1'
        decos[dpos].click={}
    end
end

