local screenX, screenY = guiGetScreenSize() 
local x, y = (screenX/1920), (screenY/1080)

function drawRect()
    dxDrawRectangle(x*100, y*300, x*100, y*200)
end
addEventHandler('onClientRender', root, drawRect)
