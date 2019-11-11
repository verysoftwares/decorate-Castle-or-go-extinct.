--[[ recording and replaying animations. ]]--


anime = {}
anime_maxrec=48+12
function record_animation()
    -- there are quite a lot of predictions going on,
    -- so let's eliminate duplicate frames.
    -- this change from inside to outside the loop (*)
    -- implies eliminating empty frames, as well.
        local c=0; for dis,rec in pairs(anime) do if rec.t<anime_maxrec then c=c+1; break end end
        if c==0 then return end
        local todays_canvas= lg.newCanvas(sw,sh)
        lg.setCanvas(todays_canvas)
        lg.draw(photo_canvas,0,0)

    -- (*) this one
    for dis,rec in pairs(anime) do
        if rec.t<anime_maxrec then
            ins(rec,todays_canvas)
            rec.t=rec.t+1
            if rec.assure and rec.t==30 then discover(rec.assure) end
            
            if rec.t==anime_maxrec then

                -- if the potential discovery has not materialized yet,
                -- we throw away the footage.

                -- there could be a case where a discovery is on its way,
                -- and we would miss the footage for it, but
                -- that one's covered by interrupts in pushpull.lua. (*)

                -- yet another case where you pause the game to prolong discovery,
                -- but let's just disable recording while paused, 
                -- it's not fun to look at an animation with duplicate frames anyway.

                -- (*) ok you could interrupt indefinitely with rapid pushpulls but that's a weird flex so we don't worry. finish the game already

                    if not disco[dis] then anime[dis]=nil end 
            end
        end
    end
end

function replay_animation(dis)
    local out= anime[dis][anime[dis].i]
    cycle(anime[dis])
    return out
end

function paused_animation()
    return love.update==shiftctrl or love.update==pullmode or love.update==pushmode -- and others which change love.draw to not animate anyway so we don't worry.
end

