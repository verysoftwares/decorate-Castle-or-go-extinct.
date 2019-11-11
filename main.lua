--[[ welcome to the main.lua file! ]]--


-- you wanna see how my game works. that's pretty cool, 
-- this curiosity will get you far in game development. 
-- a bit scary to me, though, that people read my code. 
-- thus, i organized things so they're easy to look at. 
-- coding is like tending to a garden, don't you think? 

-- t. verysoftwares 






-- btw, all the code in this project is designed for a monospace font.
-- all my careful formatting explodes if you use a variable-width one.


-- layers of the game objects to interact with. 
    blocks = {}
    decos = {}
    mysteries = {}

-- time in frames. 
    t = 0

-- let's include all the .lua files that make up the game's behaviour. 

    require('utility')        -- common utilities. 
    require('pushpull')       -- main mechanic! 
    flux=require('flux/flux') -- rxi's in-between animation helper, 
                              -- with some of my changes. 
    require('alias')          -- global shorthands. 
    require('space')          -- handling positions. 
    require('connect')        -- adjacency of blocks/decos/mysteries. 
    require('discover')       -- discovery database. spoilers! 
    require('deco')           -- decoration database. spoilers! 
    require('initial')        -- starting room design. 
    require('lion')           -- lion as a game entity. 
    require('state')          -- managing love.update changes. 
    require('draw')           -- love.draw and image processing. 
    require('online')         -- Castle's multiplayer features.



-- good intentions, but i ended up hardcoding 48 everywhere. 
-- i figured early on that 48x48 is not subject to change. 
    grid = 48

-- friendly intro message that adds context.
    print(fmt('_-* decorate Castle or go extinct. *-_\n\n      public build 1 (Halloween)\n       game made with LÖVE %d.%d\n       by verysoftwares in 2019\n\n~Å_Å~                            ~Å_Å~\n=\'a\'=  arrows and Shift to play  =\'-\'=', love.getVersion()))