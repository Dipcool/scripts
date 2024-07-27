local effil 			= require("effil")
local encoding          = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local Version = '1.1'

function main()
    while not isSampAvailable() do wait(0) end
	
    checkupdate()

    while true do
        wait(0)
    


    end
end

function asyncHttpRequest(method, url, args, resolve, reject)
	local request_thread = effil.thread(function (method, url, args)
	   local requests = require 'requests'
	   local result, response = pcall(requests.request, method, url, args)
	   if result then
		  response.json, response.xml = nil, nil
		  return true, response
	   else
		  return false, response
	   end
	end)(method, url, args)
	-- Если запрос без функций обработки ответа и ошибок.
	if not resolve then resolve = function() end end
	if not reject then reject = function() end end
	-- Проверка выполнения потока
	lua_thread.create(function()
	   local runner = request_thread
	   while true do
		  local status, err = runner:status()
		  if not err then
			 if status == 'completed' then
				local result, response = runner:get()
				if result then
				   resolve(response)
				else
				   reject(response)
				end
				return
			 elseif status == 'canceled' then
				return reject(status)
			 end
		  else
			 return reject(err)
		  end
		  wait(0)
	   end
	end)
end

function checkupdate()
    asyncHttpRequest('GET', 'https://raw.githubusercontent.com/Dipcool/scripts/main/AutoBusBot_version.json', nil, function(response)
		local decodejs, repository = pcall(decodeJson, u8:decode(response.text))
		if decodejs and repository then
			if repository.CurrentVersion ~= Version then
				sampAddChatMessage("Обновление требуется", -1)

				if repository.updateurl ~= nil then
					local dlstatus = require('moonloader').download_status
					downloadUrlToFile(repository.updateurl, thisScript().path, function(id3, status, p13, p23)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							sampAddChatMessage('Обновление завершено!', -1)
							goupdatestatus = true
							lua_thread.create(function() wait(1000) thisScript():reload() end)
						end
						if status == dlstatus.STATUSEX_ENDDOWNLOAD then
							if goupdatestatus == nil then
								sampAddChatMessage('Обновление прошло неудачно. Запускаю устаревшую версию..', -1)
							end
						end
					end)
				end

			else
				sampAddChatMessage("Обновление не требуется", -1)
			end
		else
			sampAddChatMessage("Проверка обновлений не удалась. Невалидный JSON", -1)
		end
    end, 
    function(err) 
        sampAddChatMessage('Возникла ошибка', -1)
    end)	
end
