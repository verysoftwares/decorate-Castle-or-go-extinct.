--[[ starting room design. ]]--


-- just to save characters.
    local b=blocks
    local p=posstr
    local u,d,l,r='u','d','l','r'

if 1 then
    --       0______________  1______________  2______________  3______________  4______________  5______________  
    --[[0]]  b[p(0,0)]={d,r}  b[p(1,0)]={l}    b[p(2,0)]={r}    b[p(3,0)]={l}    b[p(4,0)]={r}    b[p(5,0)]={d,l}
    --[[1]]  b[p(0,1)]={u}                                                                        b[p(5,1)]={u}
    --[[2]]  b[p(0,2)]={d}                                                                        b[p(5,2)]={d}
    --[[3]]  b[p(0,3)]={u}                                                                        b[p(5,3)]={u}
    --[[4]]  b[p(0,4)]={d}                                                                        b[p(5,4)]={d}
    --[[5]]  b[p(0,5)]={u,r}  b[p(1,5)]={l}    b[p(2,5)]={r}    b[p(3,5)]={l}    b[p(4,5)]={r}    b[p(5,5)]={u,l}

    -- initial discoveries.
        mysteries[posstr(0,0)]={tex='?'}
        mysteries[posstr(5,1)]={tex='?'}
        mysteries[posstr(2,0)]={tex='?'}
        mysteries[posstr(4,0)]={tex='?'}

        mysteries[posstr(1,5)]={tex='?'}
        mysteries[posstr(4,5)]={tex='?'}
end
if not 1 then
    -- debug 'savestate' 1
    blocks[posstr(1,0)]={'r',tex=2}
    blocks[posstr(2,0)]={'l','u',tex=2}
    blocks[posstr(2,5)]={'d',tex=2}

    blocks[posstr(3,0)]={'r',tex=1}
    blocks[posstr(4,0)]={'l','d',tex=1}
    blocks[posstr(4,1)]={'u',tex=1}

    blocks[posstr(2,2)]={'r',tex=1}
    blocks[posstr(3,2)]={'l',tex=1}

    blocks[posstr(4,2)]={'d',tex=0}
    blocks[posstr(4,3)]={'u',tex=0}

    blocks[posstr(0,3)]={'d',tex=0}
    blocks[posstr(0,4)]={'u',tex=0}

    blocks[posstr(1,3)]={'r',tex=1}
    blocks[posstr(2,3)]={'l',tex=1}

    blocks[posstr(3,3)]={'d',tex=0}
    blocks[posstr(3,4)]={'u','r',tex=0}
    blocks[posstr(4,4)]={'l',tex=0}

    blocks[posstr(1,4)]={'d','r',tex=2}
    blocks[posstr(2,4)]={'l',tex=2}
    blocks[posstr(1,5)]={'u',tex=2}

    newdeco(0,posstr(0,4))
    newdeco(0,posstr(5,0))
    newdeco(7,posstr(2,0))
end
if not 1 then
    -- debug 'savestate' 2
    blocks[posstr(0,0)]={'d',tex=2}
    blocks[posstr(0,1)]={'u',tex=2}

    blocks[posstr(2,1)]={'d',tex=2}
    blocks[posstr(2,2)]={'u','l',tex=2}
    blocks[posstr(1,2)]={'r',tex=2}

    blocks[posstr(3,1)]={'r',tex=1}
    blocks[posstr(4,1)]={'l','d',tex=1}
    blocks[posstr(4,2)]={'u',tex=1}

    blocks[posstr(5,0)]={'d',tex=2}
    blocks[posstr(5,1)]={'u',tex=2}

    blocks[posstr(5,2)]={'r',tex=1}
    blocks[posstr(0,2)]={'l',tex=1}

    blocks[posstr(1,3)]={'l',tex=1}
    blocks[posstr(0,3)]={'r',tex=1}

    blocks[posstr(2,3)]={'r','d',tex=2}
    blocks[posstr(3,3)]={'l',tex=2}
    blocks[posstr(2,4)]={'u',tex=2}

    blocks[posstr(3,4)]={'d',tex=1}
    blocks[posstr(3,5)]={'u','r',tex=1}
    blocks[posstr(4,5)]={'l',tex=1}

    newdeco(0,posstr(0,3))
    newdeco(0,posstr(4,3))
    newdeco(7,posstr(2,0))
end
if not 1 then
    -- additional connectivity tests to the starting room
    blocks[posstr(1,2)]={'r',tex=2}
    blocks[posstr(2,2)]={'l','d','r',tex=2}
    blocks[posstr(2,3)]={'l','u',tex=2}
    blocks[posstr(1,3)]={'r',tex=2}

    blocks[posstr(3,2)]={'d','l',tex=1}
    blocks[posstr(4,2)]={'d',tex=1}
    blocks[posstr(4,3)]={'l','u',tex=1}
    blocks[posstr(3,3)]={'r','u',tex=1}
end
if not 1 then
    -- seed design 3
    b[p(1,0)]= {d,tex=1}
    b[p(1,1)]= {u,l,r,tex=1}
    b[p(2,1)]= {l,d,tex=1}
    b[p(2,2)]= {u,d,r,tex=1}
    b[p(3,2)]= {l,tex=1}
    b[p(2,3)]= {u,l,tex=1}
    b[p(1,3)]= {l,r,tex=1}
    b[p(0,3)]= {u,r,tex=1}
    b[p(0,2)]= {u,d,tex=1}
    b[p(0,1)]= {d,r,tex=1}

    b[p(4,2)]= {d,tex=2}
    b[p(4,3)]= {l,u,r,tex=2}
    b[p(5,3)]= {l,d,tex=2}
    b[p(5,4)]= {u,d,tex=2}
    b[p(5,5)]= {u,l,tex=2}
    b[p(4,5)]= {r,l,tex=2}
    b[p(3,5)]= {r,u,tex=2}
    b[p(3,4)]= {l,u,d,tex=2}
    b[p(2,4)]= {r,tex=2}
    b[p(3,3)]= {r,d,tex=2}

    mysteries[p(1,2)]= {tex='?'}
    mysteries[p(4,4)]= {tex='?'}
    mysteries[p(0,4)]= {tex='?'}
    mysteries[p(0,5)]= {tex='?'}
    mysteries[p(1,5)]= {tex='?'}
    mysteries[p(2,5)]= {tex='?'}
end


connect(blocks)
uncover(mysteries)

