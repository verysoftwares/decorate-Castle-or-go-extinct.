--[[ discovery database. ]]--


-- i've decided to keep data about lightbulbs unattached to lion entity. 


-- keeps track of current discoveries.
    disco = {}          -- for tag info access
    disco_order = {i=1} -- for order of tags found

-- called from various places within code when necessary. 
    function discover(tag)
        if not disco[tag] then
            ins(disco_order, tag)
            disco[tag]={unread=true}
        end
    end

-- output string you can print on screen about a discovery.
    function lionsay()
        return disco_db[disco_order[disco_order.i]].reflection
    end

function disco_status()
    return pairslength(disco), pairslength(disco_db)
end

function moment_of_discovery()
    local out = lg.newCanvas(sw,sh)
    out:renderTo(function()
        fg(1,1,1,1)
        lg.draw(photo_canvas,0,0)
    end)
    return out
end

--[[


















                        ~Å_Å~
                        ='-'= spoilers ahead.


















--]]

-- all of the discoveries to be made as of this version.
-- character reflection.. in future: connections to other tags 
    disco_db = {
        ['pushpull']={reflection='Delete me just like you would the others. ik ki tf ft fk tk it if ll ff tt ii __ lf lt li il tl fl hey! listen.'},
        ['pull']={reflection='So this is how you pull!'},
        ['push']={reflection='..And this is how you push.'},
        ['wraparound']={reflection='What! The tiles wrap around.'},
        ['mysteries']={reflection='I wonder what that question mark does.'},
        ['plant']={reflection='Aha! So 2 stacked question marks create a plant.'},
        ['sofa']={reflection='Ooh, 2 neighbouring question marks make a sofa.'},
        ['shelf']={reflection='A 2-by-2 pattern is for a bookshelf. It emanates an aura of wisdom.'},
        ['crush']={reflection='Oi, that decoration got crushed between walls, turning into [?] tiles.'},
        ['wallcrush']={reflection='The bookshelf is so heavy, it crushes walls on its path.'},
        ['paintred']={reflection='I pushed a [?] tile around the edge, and got red paint.'},
        ['paintmag']={reflection='I pulled a [?] tile around the edge, and got magenta paint.'},
        ['paintjob']={reflection='Knocking back walls with a paint can gives them a nice colour.'},
        ['paintdeco']={reflection='Decorations can be painted, for sure.'},
        ['paintpaint']={reflection='Even paint cans can be painted!'},
        ['merge']={reflection='Painted walls can merge like that!'},
        ['lionwrap']={reflection='Ohh I can go around the edges!'},
        ['block->block']={reflection='This way is blocked.'},
        ['mystery<->block']={reflection='[?] tiles slide under walls, makes sense since I found them that way.'},
        ['block->deco']={reflection='Walls can shift decorations just fine.'},
        ['deco->deco']={reflection='A decoration can shift another just fine.'},
        ['mystery->deco']={reflection='A [?] tile can shift a decoration just fine.'},
        ['deco->block']={reflection='A decoration can shift walls just fine.'},
        ['deco->mystery']={reflection='A decoration can shift a [?] tile just fine.'},
        ['mystery->mystery']={reflection='A [?] tile can shift another just fine.'},
        ['lionway']={reflection='I\'m in the way, I\'d get squished!'},
        ['mysteryknown']={reflection='I\'ll remember known [?] tile locations for you.'},
        ['decopushpull']={reflection='Decorations can also be pushed and pulled.'},
        ['mysterypushpull']={reflection='So [?] tiles can also be pushed and pulled.'},
        ['energyconserve']={reflection='Energy was not conserved. Crushing that block spawned a [?] tile on another, replacing it, so there was a net loss of [?] tiles. You see, the way this works, during compilation we can\'t nudge [?] tiles from the spawned one\'s path. Even if we could, there is still the problem that if you already had 6 moving tiles in a row, where would the 7th go? So it\'s one of those hard game design problems.'},
        ['paintsame']={reflection='I think paint only changes adjacent colours, not all in the wall. I may need to rethink this..'},
    }

