-- Block namespace
local BLOCK_NAMESPACE = 'FTPClient_FC.Put'
local nameOfModule = 'CSK_FTPClient'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function put(handle, data1, data2, data3, data4)

  local dataType1 = Container.get(handle, 'DataType1')
  local dataType2 = Container.get(handle, 'DataType2')
  local dataType3 = Container.get(handle, 'DataType3')
  local dataType4 = Container.get(handle, 'DataType4')
  local autoName1 = Container.get(handle, 'AutoName1')
  local autoName2 = Container.get(handle, 'AutoName2')
  local autoName3 = Container.get(handle, 'AutoName3')
  local autoName4 = Container.get(handle, 'AutoName4')

  if data1 then
    CSK_FTPClient.addRegistration(data1, dataType1, autoName1)
  end
  if data2 then
    CSK_FTPClient.addRegistration(data2, dataType2, autoName2)
  end
  if data3 then
    CSK_FTPClient.addRegistration(data3, dataType3, autoName3)
  end
  if data4 then
    CSK_FTPClient.addRegistration(data4, dataType4, autoName4)
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.put', put)

--*************************************************************
--*************************************************************

local function create(dataType1, dataType2, dataType3, dataType4, autoName1, autoName2, autoName3, autoName4)
  if autoName1 == nil then
    autoName1 = true
  end
  if autoName2 == nil then
    autoName2 = true
  end
  if autoName3 == nil then
    autoName3 = true
  end
  if autoName4 == nil then
    autoName4 = true
  end

  if nil ~= instanceTable['Solo'] then
    _G.logger:warning(nameOfModule .. ": Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable['Solo'] = 'Solo'

    local dataTypes = { dataPos1=dataType1, dataPos2=dataType2, dataPos3=dataType3, dataPos4=dataType4 }
    local autoNames = { dataPos1=autoName1, dataPos2=autoName2, dataPos3=autoName3, dataPos4=autoName4 }

    for key, value in pairs(dataTypes) do
      local pos = string.sub(key, #key, #key)
      if value == '' then
        Container.add(handle, 'DataType' .. pos, 'DATA')
      else
        Container.add(handle, 'DataType' .. pos, value)
      end
    end
    for key, value in pairs(autoNames) do
      local pos = string.sub(key, #key, #key)
        Container.add(handle, 'AutoName' .. pos, value)
    end
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)