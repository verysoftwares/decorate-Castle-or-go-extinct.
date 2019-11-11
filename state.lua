--[[ game state handling. ]]--


-- remember that love.update is a variable like any other, 
-- you can assign functions to it at runtime. 
-- this kind of thinking helps compartmentalize program flow. 
-- also, comparing love.update==state1 is just comparing addresses that stay constant. 
-- you could encapsulate state changes and comparisons into setter/getter functions, 
-- but i don't like turning a simple variable assignment into another black box. 


-- initial state with platforming controls.
    function freectrl(dt)

        -- i don't give flux the real dt here because i believe
        -- physics and animations should act in a deterministic way
        -- from one frame to the next.
            flux:update(1/60)

        t = t + 1
        
        -- this comes from lion.lua.
        -- again, note how there's no dt given to it.
            platforming()
        -- just flex the arrow keys' state so they aren't already active in the menu.
            press('up');press('down');press('left');press('right')

        -- we can only go to the menu state from here.
            if (tapped('rshift') or tapped('lshift')) then
                intro_read=true
                love.update=shiftctrl
                -- this one is a little weird, it's like a separate
                -- rolling time for animations while otherwise paused.
                    lion.shifting=t
            else    lion.shifting=nil end
    end

-- Shift menu state. or tap.
    function shiftctrl(dt)
        lion.shifting = lion.shifting + 1

        if tapped('up') then love.update=pushmode; return end
        if tapped('down') then love.update=pullmode; return end
        if #disco_order>0 and tapped('left') then 
            love.update=ideamode; love.draw=ideadraw
            t_shift = t
            -- skip to first unread for convenience
                for i,v in ipairs(disco_order) do
                    if disco[v].unread then disco_order.i=i; break end 
                end
            return
        end

        if (disco['push'] and not disco['push'].unread) and 
           (disco['pull'] and not disco['pull'].unread) then
                if tapped('right') then 
                    love.update=photomode; love.draw=photodraw
                    photo_session=nil; t_shift = t return
                end
        end

        -- you can always leave a state by pressing Shift. or tapping
            if tapped('rshift') or tapped('lshift') then
                love.update=freectrl
            end
    end

-- chosen to push.
    function pushmode(dt)
        lion.shifting = lion.shifting + 1

        if tapped('rshift') or tapped('lshift') then
            love.update=freectrl
            return
        end

        -- if any directional key is pressed, push towards that direction.
            for i,dir in ipairs(cardinal) do
                if tapped(dir.key) then
                    local ppos=wrappos2(lion.cx/48 +dir.dx, lion.cy/48 +dir.dy)
                    if occupied(ppos) then
                        shiftall(ppos, dir.dx,dir.dy)
                        love.update=freectrl
                        return
                    end
                end
            end
    end

-- chosen to pull.
    function pullmode(dt)
        lion.shifting = lion.shifting + 1

        if tapped('rshift') or tapped('lshift') then
            love.update=freectrl
            return
        end

        -- if any directional key is pressed, pull away from that direction.
            for i,dir in ipairs(cardinal) do
                if tapped(dir.key) then
                    local ppos=wrappos2(lion.cx/48 -dir.dx, lion.cy/48 -dir.dy)
                    if occupied(ppos) then
                        shiftall(ppos, dir.dx,dir.dy)
                        love.update=freectrl
                        return
                    end
                end
            end

    end

-- reading thru lightbulb notifications.
-- covers the screen, so we change love.draw on state onset and offset.
    function ideamode(dt)
        t = t + 1

        disco[disco_order[disco_order.i]].unread=false
        if tapped('left') then cycle(disco_order,-1) end
        if tapped('right') then cycle(disco_order,1) end
        disco[disco_order[disco_order.i]].unread=false
        
        if tapped('rshift') or tapped('lshift') then
            love.update=freectrl
            love.draw=castledraw
            t = t_shift
        end
    end

-- browsing and submitting photos. covers the screen.
    function photomode(dt)
        t = t + 1

        if tapped('up') and not session_busy() then 
            love.update = sendconfirm
            photo_session = nil
            return
        end
        if (tapped('down')) and not session_busy() then 
            screenshot_restore() 
        end

        if (tapped('rshift') or tapped('lshift')) and not session_busy() then
            love.update=freectrl
            love.draw=castledraw
            photo_session = nil
            t = t_shift
        end
    end

    -- Send this for everyone to see?
    -- Yes           No
        function sendconfirm(dt)
            t = t + 1
            if tapped('left') then 
                screenshot_store() 
                love.update=submitconfirm
            end
            if tapped('right') then love.update=photomode end
        end

    -- Make a post on Castle, as well?
    -- Yes           No
        function submitconfirm(dt)
            t = t + 1
            if tapped('left') then 
                screenshot_castle() 
                love.update=photomode 
            end
            if tapped('right') then love.update=photomode end
        end

    function session_busy()
        if not session.player then return true end
        if submit_session then return true end
        if photo_session and photo_session.i<photo_session.imax then return true end
        return false
    end


-- i would love to have this at the top of the file for clarity, 
-- but 'freectrl' isn't defined at that point yet. 
    love.update=freectrl

