--[[ utilities for drawing/image handling. ]]--


function sine3d(msg,lx,ly,timing)
    text3d(msg,lx,ly,timing, function(i,timing) return sin(i+timing*0.06)*6 end)
end

function text3d(msg,lx,ly,timing,offy)
    offy= offy or function() return 0 end
    lg.setFont(threed)
    local tw=threed:getWidth(msg)+#msg-1
    local tx=0
    for i=1,string.len(msg) do
        local char = sub(msg,i,i)
        fg(0.44+sin(i+timing*0.06)*0.2, 0.34+sin(i+timing*0.05)*0.2, 0.34,1)
        lg.print(char, round(lx-tw/2+tx), round(ly+offy(i,timing)))
        tx = tx+threed:getWidth(char)+1
    end
end


local SPRSHEET = lg.newImage('SPRSHEET.png')
local PLRSHEET = lg.newImage('PLRSHEET.png')

function create_images()
    if images then return end

    images={}
    -- umm this isn't actually so easy, there's
    -- going to be non-rectangle-shaped decos..
        for k,v in pairs(canon) do
            local c=1
            for y=1,v[4] do for x=1,v[3] do
            images[fmt('%s-%d',v.tag,c)]= stamp(v[1]+x-1,v[2]+y-1,1,1)
            c=c+1
            end end
        end
        images['shelf1-1-1']=stamp(0,4,1,1)
        images['shelf1-2-1']=stamp(1,4,1,1)
        images['shelf1-3-1']=stamp(0,5,1,1)
        images['shelf1-4-1']=stamp(1,5,1,1)
        images['shelf1-1-2']=stamp(2,4,1,1)
        images['shelf1-2-2']=stamp(3,4,1,1)
        images['shelf1-3-2']=stamp(2,5,1,1)
        images['shelf1-4-2']=stamp(3,5,1,1)

    -- wall graphic pieces
        -- clockwise starting from top. (see SPRSHEET.png)
            images.brick1=stamphalf(8,3,1,1)
            images.brick2=stamphalf(6,3,1,1)
            images.brick3=stamphalf(9,3,1,1)
            images.brick4=stamphalf(7,3,1,1)
            images.brick5=stamphalf(9,2,1,1)
            images.brick6=stamphalf(7,2,1,1)
            images.brick7=stamphalf(8,2,1,1)
            -- alt shading
                images.brick15=stamphalf(8,8,1,1)
            images.brick8=stamphalf(6,2,1,1)
        images.brick9=stamphalf(4*2,2*2,1,1)
        images.brick10=stamp(4,2,1,1)
        -- corners
            images.brick11=stamphalf(6,4,1,1)
            images.brick12=stamphalf(6,5,1,1)
            images.brick13=stamphalf(7,5,1,1)
            images.brick14=stamphalf(7,4,1,1)
            -- inner corners
                images.brick16=stamphalf(8,6,1,1)
                images.brick17=stamphalf(9,6,1,1)
                images.brick18=stamphalf(9,7,1,1)
                images.brick19=stamphalf(8,7,1,1)
        images.tex1=stamp(5,1,1,1)
        images.tex2=stamp(5,2,1,1)
        images.tex3=stamp(5,3,1,1)


    images.qmark=stamp(1,0,1,1)
    
    images.lion=stamp(0,1,1,1,PLRSHEET)
    images.bulb=stamp(2,2,1,1,PLRSHEET)

    images.flash1=stamphalf(10,10,1,1)
    images.flash2=stamphalf(11,10,1,1)

end

-- sub-functions used in the above.
    -- generate 48x48 canvases from a larger spritesheet.
        function stamp(x,y,w,h,sheet)
            sheet=sheet or SPRSHEET
            local nc= lg.newCanvas(w*48,h*48)
            nc:renderTo(function()
                bg(0,0,0,0)
                lg.draw(sheet,-x*48,-y*48)
            end)
            return nc
        end

    -- same with 24x24 canvases.
    -- this could be just a variety of 'stamp' with different arguments,
    -- but having a different function name makes 
    -- already tricky definitions a bit clearer.
        function stamphalf(x,y,w,h,sheet)
            sheet=sheet or SPRSHEET
            local nc= lg.newCanvas(w*24,h*24)
            nc:renderTo(function()
                bg(0,0,0,0)
                lg.draw(sheet,-x*24,-y*24)
            end)
            return nc
        end

function spawn_particles(pos,dx,dy)
    local px,py= strpos(pos)
    px= px*48 +24; py=py*48 +24
    for i=1,50 do
        local p= {}
        ins(particles,p)

        if not (dx==0) then
            -- horizontal edge
            p.x= px+dx*24
            p.y= py+random(49)-24-1
        end
        if not (dy==0) then
            -- vertical edge
            p.y= py+dy*24
            p.x= px+random(49)-24-1
        end

        -- between -1.5 and 1.5 with increased precision
            p.dx=((random(49)-1)/24.0-1)*1.5
        -- between -4.5 and -2.5 with increased precision
            p.dy=((random(49)-1)/24.0-1)-3.5

        local img=2
        if random(64)-1<16 then img=1 end

        p.img= images[fmt('flash%d',img)]
    end
end

-- remaps alt colours for certain decos. 
    recolor = lg.newShader([[
        extern number r,g,b;
        vec4 effect( vec4 cl, Image tex, vec2 tc, vec2 sc )
        {
            vec4 texcolor = Texel(tex, tc);
            if (texcolor.r==116.0/255.0 && texcolor.g==207.0/255.0 && texcolor.b==129.0/255.0) {
                return vec4(r,g,b,1);
            }
            return texcolor;
        }
    ]])

-- jhfaafs unused
-- when Castle is scaled, screen coordinate based pixel shaders change.
-- i didn't bother with it, this made me compromise on effects i tend to use.
    liquid = lg.newShader([[
        extern number t;
        vec4 effect( vec4 cl, Image tex, vec2 tc, vec2 sc )
        {
            //vec4 texcolor = Texel(tex, tc);
            //return vec4(0.8-sc.x*0.02, 0.9-sc.y*0.02, 1.0-t*0.01, 0.6); 
            return vec4(cl.r+sin((sc.x+sc.y)*0.2+t*0.02)*0.2,cl.g,cl.b,cl.a);
            //return texcolor * color;
        }
    ]])

