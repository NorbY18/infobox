local screen = {}
screen.x, screen.y = guiGetScreenSize()
local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}


local itypes = {
    error = "files/error.png",
    info = "files/info.png",
    success = "files/success.png",
    warning = "files/warning.png",
    ban = "files/ban.png",
};

local e = exports.et_core;

local font = dxCreateFont("files/font.ttf", 12)

local sound = false;

local messages = {}

local infobox = {}
infobox.w = 200
infobox.h = 33
infobox.y = 10
infobox.x = screen.x/2 - infobox.w/2


function addInfoBox(message,itype)
    local id = #messages+1
    table.insert(messages,id,{
        id = id,
        message = message,
        itype = itype,
        x = infobox.x,
        y = infobox.y,
        w = infobox.h,
        h = infobox.h,
        dWidth = infobox.h + dxGetTextWidth(message,1,font) + 10,
        opacity = 0,
        animState = false,
        })

    createAnimation(0,1,4,300,function(animation) messages[id].opacity = animation end,function()
        createAnimation(infobox.h,messages[id].dWidth,4,300,function(animation) messages[id].w = animation end,function()
            setTimer(function()
                createAnimation(messages[id].dWidth,infobox.h,4,300,function(animation) messages[id].w = animation end,function()
                    createAnimation(1,0,4,300,function(animation) messages[id].opacity = animation end,function()
                        messages[id] = nil
                    end)
                end)
            end,8000,1)
        end)
    end)

    if not (isElement(sound)) then 
        sound = playSound("files/sound.mp3")
        sound:setVolume(3)
    else 
        stopSound(sound)
        sound = playSound("files/sound.mp3")
        sound:setVolume(3)
    end 
end
addEvent("addInfoBox", true)
addEventHandler("addInfoBox", root, addInfoBox)

function renderInfoBox()
    local i = 0
    for _,v in pairs(messages) do
        v.x = screen.x/2 - v.w/2

        dxDrawRectangle(v.x - 2, v.y + i*v.h + i*10 - 2, v.w + 10, v.h + 4, tocolor(20, 20, 20, 255*v.opacity), true)
        dxDrawRectangle(v.x, v.y + i*v.h + i*10, v.w + 6, v.h, tocolor(30, 30, 30, 255*v.opacity), true)
        
        dxDrawRectangle(v.x - 2, v.y + i*v.h + i*10 - 2 + v.h + 2, v.w + 10, 2, tocolor(94, 132, 175, 255*v.opacity), true)

        dxDrawImage(v.x + v.h/2 - (v.h - 3)/2, v.y + i*v.h + i*10 + v.h/2 - (v.h - 2)/2, 30.5, 30, itypes[v.itype], 0, 0, 0, tocolor(255,255,255,180*v.opacity), true)

        dxDrawText(v.message,
            v.x + v.h + 5,
            v.y + i*v.h + i*10 + v.h/2 - dxGetFontHeight(1,font)/2,
            v.x+v.w,
            v.y + i*v.h + i*10 +v.h,
            tocolor(200, 200, 200, 255*v.opacity),1,font,"left","top", true, false, true)

        i = i + 1
    end
end
addEventHandler("onClientRender", root, renderInfoBox)

function table.find(t, v)
    for k, a in ipairs(t) do
        if a == v then
            return k
        end
    end
    return false
end

function createAnimation(f, t, easing, duration, onChange, onEnd)
    assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
    assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
    assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
    assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
    assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount(), onChange = onChange, onEnd = onEnd})
    return #anims
end

function destroyAnimation(a)
    if anims[a] then
        table.remove(anims, a)
    end
end

addEventHandler("onClientRender", root, 
    function()
        local now = getTickCount()
        for k,v in ipairs(anims) do
            v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
            if now >= v.start+v.duration then
                if type(v.onEnd) == "function" then
                    v.onEnd()
                end
                table.remove(anims, k)
            end
        end
    end
);