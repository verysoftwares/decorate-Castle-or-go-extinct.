--[[ multiplayer features. ]]--


-- the motivation of this game is to share photos of customized rooms.


-- define the global game session,
-- containing player info.
    session = {}
    function refresh_session()
        network.async(function()
            local me = castle.user.getMe()
            if me then
                session.id = me.userId
                session.player = me.username
                session.avatar = me.photoUrl
            else 
                -- ghost for unlogged players
                session.id = 'anonymous'
                session.player = 'anonymous'
                -- missing avatar is just drawn as a dark square. 
            end
        end)
    end

-- uploads screenshot data for in-game sharing.
-- update submit_session.i after every online call for progress bar.
    submit_session = nil -- when this is defined we are currently storing, and can't store another.
    function screenshot_store()
        submit_session = {i=0,imax=10}
        network.async(function()
            local count = castle.storage.getGlobal('count')
            count = count or 0  -- won't be nil after i'm done testing
            submit_session.i = submit_session.i + 1

            -- update count asap to minimize race conditions
            castle.storage.setGlobal('count', count+1)
            submit_session.i = submit_session.i + 1

            castle.storage.setGlobal(fmt('%d',count+1), session.id)
            submit_session.i = submit_session.i + 1

            castle.storage.setGlobal(fmt('%d-player',count+1), session.player)
            submit_session.i = submit_session.i + 1

            castle.storage.setGlobal(fmt('%d-avatar',count+1), session.avatar)
            submit_session.i = submit_session.i + 1

            -- then comes the heavy lifting.
            castle.storage.setGlobal(fmt('%d-blocks',count+1), sanitize(blocks))
            submit_session.i = submit_session.i + 1

            castle.storage.setGlobal(fmt('%d-decos',count+1), sanitize(decos))
            submit_session.i = submit_session.i + 1

            castle.storage.setGlobal(fmt('%d-mysteries',count+1), mysteries)
            submit_session.i = submit_session.i + 1

            castle.storage.setGlobal(fmt('%d-lion',count+1), lion)
            submit_session.i = submit_session.i + 1

            local photodisco = deepcopy(disco_order)
            photodisco.i=nil
            castle.storage.setGlobal(fmt('%d-disco',count+1), photodisco)
            submit_session.i = submit_session.i + 1

            submit_session = nil

            screenshot_restore(count+1)
        end)
    end

-- inverse of submission.
-- get data to render in 'photodraw' (draw.lua)
    photo_session = nil     -- defined on 'photomode' onset (state.lua)
    function screenshot_restore(from)
        photo_session = {i=0,imax=9}
        network.async(function()
            local chosen;
            if not from then
                local count = castle.storage.getGlobal('count')
                count = count or 0  -- won't be nil after i'm done testing
                if count==0 then print('öjakg nothing in storage') return end
                
                chosen = random(count)
            else
                chosen = from
            end
            photo_session.i = photo_session.i + 1

            photo_session.id = castle.storage.getGlobal(fmt('%d',chosen))
            photo_session.i = photo_session.i + 1

            photo_session.player = castle.storage.getGlobal(fmt('%d-player',chosen))
            photo_session.i = photo_session.i + 1

            -- this can safely be nil for unlogged players
            photo_session.avatar = castle.storage.getGlobal(fmt('%d-avatar',chosen))
            if photo_session.avatar then photo_session.img = lg.newImage(photo_session.avatar) end
            photo_session.i = photo_session.i + 1

            -- then comes the heavy lifting.
            photo_session.blocks = unsanitize(castle.storage.getGlobal(fmt('%d-blocks',chosen)))
            photo_session.i = photo_session.i + 1

            photo_session.decos = unsanitize(castle.storage.getGlobal(fmt('%d-decos',chosen)))
            photo_session.i = photo_session.i + 1

            photo_session.mysteries = castle.storage.getGlobal(fmt('%d-mysteries',chosen))
            photo_session.i = photo_session.i + 1

            photo_session.lion = castle.storage.getGlobal(fmt('%d-lion',chosen))
            photo_session.i = photo_session.i + 1

            photo_session.disco = castle.storage.getGlobal(fmt('%d-disco',chosen))
            photo_session.i = photo_session.i + 1
        end)
    end


-- sends a screenshot as a Castle post.
    function screenshot_castle()
        network.async(function()
            local media,message;
            if 1 then
                media = photo_canvas:newImageData()
                message = 'I\'ve decorated Castle.'
            else end
            castle.post.create({
                message = message,
                media   = media,
            })  
        end)
    end

-- Lua CJSON is very particular about tables which mix numbered and string keys,
-- so we'll clear out the numbered ones before sending to storage.
-- of course, this function also makes a deep copy and returns it.
    function sanitize(layer)
        local out = deepcopy(layer)

        for k,v in pairs(out) do
            v.store={}
            for i=1,#v do
                ins(v.store,v[i])
                v[i]=nil
            end
        end

        return out
    end

    function unsanitize(layer)
        local out = deepcopy(layer)

        for k,v in pairs(out) do
            for i=1,#v.store do
                v[i]=v.store[i]
            end
            v.store=nil
        end

        return out
    end


refresh_session()

