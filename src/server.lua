local arquivo

if (fileExists('src/update.cfg')) then
    arquivo = fileOpen('src/update.cfg')
else
    arquivo = fileCreate('src/update.cfg')
end
local versionText = fileRead(arquivo, fileGetSize(arquivo))
fileClose(arquivo)

addEventHandler('onResourceStart', getResourceRootElement(getThisResource()),
    function()
        verifyUpdate()
    end
)

local _fetchRemote = fetchRemote
function fetchRemote(...)
  	if hasObjectPermissionTo(getThisResource(), "function.fetchRemote", true) then
  		  return _fetchRemote(...)
  	else
  		  outputDebugString('SQH Update: '..getResourceName(getThisResource()).." requer a permissão 'function.fetchRemote' para receber atualizações.", 2)
  	end
  	return false
end

local versionAtual = tonumber(versionText) or 0
function verifyUpdate()
    fetchRemote('https://raw.githubusercontent.com/JoohnWiick/testeSource/main/src/update.cfg?token=AQMGGOTYQFHFGEMWOWBBHDK7TWRYI',
        function(value, err)
            outputDebugString('SQH Update: O resource foi conectado com sucesso em nosso banco de atualizações! ')
            if (err == 0) then
                newVersion = tonumber(value)
                print('SQH Update: Versão atual '..getResourceName(getThisResource())..': '..versionAtual)
                if (newVersion > versionAtual) then
                    outputDebugString('SQH Update: Você está usando uma versão antiga desse resource')
                    outputDebugString('SQH Update: Para atualizar, utilize /updateRes')
                elseif (newVersion == versionAtual) then
                    outputDebugString('SQH Update: Seu resource está na ultima versão ')
                elseif (versionAtual > newVersion) then
                    outputDebugString('SQH Update: Detectamos um problema com seu resource, sua versão está errada!')
                    outputDebugString('SQH Update: Vá no arquivo src/update.cfg e substitua '..versionAtual.. ' por '..newVersion)
                    outputDebugString('SQH Update: Ou abra um ticket em nossa loja e peça suporte!')
                end
            end
        end
    )
end

addCommandHandler('updateRes',
    function(executer, _)
        if (isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(executer)), aclGetGroup('Admin')) or isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(executer)), aclGetGroup('Console'))) then
            if (newVersion > versionAtual) then
                startUpdate()
            else
                outputDebugString('SQH Update: Nenhuma atualização encontrada.')
            end
        else
            outputDebugString('SQH Update: O jogador '..getPlayerName(executer)..' tentou fazer uma atualização no resource '..getResourceName(getThisResource()))
        end
    end
)

function getFilesInResourceFolder(path, res)
    if (triggerServerEvent) then error('The @getFilesInResourceFolder function should only be used on server-side', 2) end

    if not (type(path) == 'string') then
        error("@getFilesInResourceFolder argument #1. Expected a 'string', got '"..type(path).."'", 2)
    end

    if not (tostring(path):find('/$')) then
        error("@getFilesInResourceFolder argument #1. The path must contain '/' at the end to make sure it is a directory.", 2)
    end

    res = (res == nil) and getThisResource() or res
    if not (type(res) == 'userdata' and getUserdataType(res) == 'resource-data') then
        error("@getFilesInResourceFolder argument #2. Expected a 'resource-data', got '"..(type(res) == 'userdata' and getUserdataType(res) or tostring(res)).."' (type: "..type(res)..")", 2)
    end

    local files = {}
    local files_onlyname = {}
    local thisResource = res == getThisResource() and res or false
    local charsTypes = '%.%_%w%d%|%\%<%>%:%(%)%&%;%#%?%*'
    local resourceName = getResourceName(res)
    local Meta = xmlLoadFile(':'..resourceName ..'/meta.xml')
    if not Meta then error("(@getFilesInResourceFolder) Could not get the 'meta.xml' for the resource '"..resourceName.."'", 2) end
    for _, nod in ipairs(xmlNodeGetChildren(Meta)) do
        local srcAttribute = xmlNodeGetAttribute(nod, 'src')
        if (srcAttribute) then
            local onlyFileName = tostring(srcAttribute:match('/(['..charsTypes..']+%.['..charsTypes..']+)') or srcAttribute)
            local theFile = fileOpen(thisResource and srcAttribute or ':'..resourceName..'/'..srcAttribute)
            if theFile then
                local filePath = fileGetPath(theFile)
                filePath = filePath:gsub('/['..charsTypes..']+%.['..charsTypes..']+', '/'):gsub(':'..resourceName..'/', '')
                if (filePath == tostring(path)) then
                    table.insert(files, srcAttribute)
                    table.insert(files_onlyname, onlyFileName)
                end
                fileClose(theFile)
            else
                outputDebugString("(@getFilesInResourceFolder) Could not check file '"..onlyFileName.."' from resource '"..nomeResource.."'", 2)
            end
        end
    end
    xmlUnloadFile(Meta)
    return #files > 0 and files or false, #files_onlyname > 0 and files_onlyname or false
end

resources = getFilesInResourceFolder('src/', getThisResource())

function startUpdate()
    outputDebugString('SQH Update: Seu resource está sendo atualizado, aguarde!')
    for _,resource in pairs(resources) do
        print(resource)
        setTimer(function()
            fetchRemote('https://raw.githubusercontent.com/JoohnWiick/testeSource/main/'..resource,
                function(value, err)
                    if (err == 0) then
                        if (fileExists(resource)) then
                            fileDelete(resource)
                        end
                        data = fileCreate(resource)
                        fileWrite(data, value)
                        fileClose(data)
                    end
                end
            )
        end, 1000, 1)
    end
    outputDebugString('SQH Update: Atualização concluída com sucesso, seu resource está na última versão')
    outputDebugString('SQH Update: Reinicie o resource para aplicar as atualizações.')
end
