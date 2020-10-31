local screenX, screenY = guiGetScreenSize()
local x, y = (screenX/1920), (screenY/1080)

-- Código para teste do github

function dxDraw()
     dxDrawRectangle(x*100, y*100, x*15, y*30)
end
addEventHandler('onClientRender', root, dxDraw)
