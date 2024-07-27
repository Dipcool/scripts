local effil 			= require("effil")
local encoding          = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local Version = '1.0'

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
	-- ���� ������ ��� ������� ��������� ������ � ������.
	if not resolve then resolve = function() end end
	if not reject then reject = function() end end
	-- �������� ���������� ������
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

--[[function checkupdate()
    asyncHttpRequest('GET', 'https://raw.githubusercontent.com/Dipcool/scripts/main/AutoBusBot_version.json', nil, function(response)
		local decodejs, repository = pcall(decodeJson, u8:decode(response.text))
		if decodejs and repository then
			if repository.CurrentVersion ~= Version then
				sampAddChatMessage("���������� ���������", -1)

				if repository.updateurl ~= nil then
					local dlstatus = require('moonloader').download_status
					downloadUrlToFile(repository.updateurl, thisScript().path, function(id3, status, p13, p23)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							sampAddChatMessage('���������� ���������!', -1)
							goupdatestatus = true
							lua_thread.create(function() wait(1000) thisScript():reload() end)
						end
						if status == dlstatus.STATUSEX_ENDDOWNLOAD then
							if goupdatestatus == nil then
								sampAddChatMessage('���������� ������ ��������. �������� ���������� ������..', -1)
							end
						end
					end)
				end

			else
				sampAddChatMessage("���������� �� ���������", -1)
			end
		else
			sampAddChatMessage("�������� ���������� �� �������. ���������� JSON", -1)
		end
    end, 
    function(err) 
        sampAddChatMessage('�������� ������', -1)
    end)	
end]]

-->> �������� � ���.
local function msg(text)
	sampAddChatMessage("[{6A5ACD}BusBot by xMercy{FFFFFF}] | " ..text, -1)
end


function checkupdate()
    asyncHttpRequest('GET', 'https://raw.githubusercontent.com/Dipcool/scripts/main/AutoBusBot_version.json', nil, function(response)
		local decodejs, repository = pcall(decodeJson, u8:decode(response.text))
		if decodejs and repository then
			if repository.CurrentVersion ~= Version then
				msg("������ ��������� ����������...")

				if repository.updateurl ~= nil then
					local dlstatus = require('moonloader').download_status
					downloadUrlToFile(repository.updateurl, thisScript().path, function(id3, status, p13, p23)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							msg('�������� ���������� ������ �������!')
							UpdateStatus = true
							lua_thread.create(function() wait(1000) thisScript():reload() end)
						end
						if status == dlstatus.STATUSEX_ENDDOWNLOAD then
							if UpdateStatus == nil then
								msg('���������� ������ ��������. �������� ���������� ������..')
							end
						end
					end)
				end

			else
				msg("���������� ������� �� ���������!")
			end
		else
			msg("�������� ���������� �� �������. ���������� JSON.")
		end
    end, 
    function(err) 
        msg('�� ������ ���������� ���������� � ��������.')
    end)	
end