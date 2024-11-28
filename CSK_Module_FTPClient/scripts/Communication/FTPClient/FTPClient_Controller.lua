---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the ftpClient_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_FTPClient'

-- Timer to update UI via events after page was loaded
local tmrFTPClient = Timer.create()
tmrFTPClient:setExpirationTime(300)
tmrFTPClient:setPeriodic(false)

-- Reference to global handle
local ftpClient_Model

-- ************************ UI Events Start ********************************

Script.serveEvent('CSK_FTPClient.OnNewStatusModuleVersion', 'FTPClient_OnNewStatusModuleVersion')
Script.serveEvent('CSK_FTPClient.OnNewStatusCSKStyle', 'FTPClient_OnNewStatusCSKStyle')
Script.serveEvent('CSK_FTPClient.OnNewStatusModuleIsActive', 'FTPClient_OnNewStatusModuleIsActive')

Script.serveEvent("CSK_FTPClient.OnNewServerIP", "FTPClient_OnNewServerIP")
Script.serveEvent("CSK_FTPClient.OnNewPort", "FTPClient_OnNewPort")
Script.serveEvent("CSK_FTPClient.OnNewStatusConnected", "FTPClient_OnNewStatusConnected")
Script.serveEvent("CSK_FTPClient.OnNewUsername", "FTPClient_OnNewUsername")
Script.serveEvent("CSK_FTPClient.OnNewPassword", "FTPClient_OnNewPassword")
Script.serveEvent("CSK_FTPClient.OnNewPassiveModeStatus", "FTPClient_OnNewPassiveModeStatus")
Script.serveEvent('CSK_FTPClient.OnNewStatusAsyncMode', 'FTPClient_OnNewStatusAsyncMode')
Script.serveEvent('CSK_FTPClient.OnNewStatusVerboseMode', 'FTPClient_OnNewStatusVerboseMode')

Script.serveEvent("CSK_FTPClient.OnNewIPCheck", "FTPClient_OnNewIPCheck")

Script.serveEvent('CSK_FTPClient.OnNewStatusRegisteredEventName', 'FTPClient_OnNewStatusRegisteredEventName')
Script.serveEvent('CSK_FTPClient.OnNewStatusDataType', 'FTPClient_OnNewStatusDataType')
Script.serveEvent('CSK_FTPClient.OnNewStatusAutoFilename', 'FTPClient_OnNewStatusAutoFilename')

Script.serveEvent('CSK_FTPClient.OnNewStatusRegistrationList', 'FTPClient_OnNewStatusRegistrationList')

Script.serveEvent('CSK_FTPClient.OnNewStatusFlowConfigPriority', 'FTPClient_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_FTPClient.OnNewStatusLoadParameterOnReboot", "FTPClient_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_FTPClient.OnPersistentDataModuleAvailable", "FTPClient_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_FTPClient.OnNewParameterName", "FTPClient_OnNewParameterName")
Script.serveEvent("CSK_FTPClient.OnDataLoadedOnReboot", "FTPClient_OnDataLoadedOnReboot")

Script.serveEvent("CSK_FTPClient.OnUserLevelOperatorActive", "FTPClient_OnUserLevelOperatorActive")
Script.serveEvent("CSK_FTPClient.OnUserLevelMaintenanceActive", "FTPClient_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_FTPClient.OnUserLevelServiceActive", "FTPClient_OnUserLevelServiceActive")
Script.serveEvent("CSK_FTPClient.OnUserLevelAdminActive", "FTPClient_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************
-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("FTPClient_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("FTPClient_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("FTPClient_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("FTPClient_OnUserLevelAdminActive", status)
end

--- Function to check if inserted string is a valid IP
---@param ip string IP to check
---@return boolean status Result if IP is valid
local function checkIP(ip)
  if not ip then return false end
  local a,b,c,d=ip:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
  a=tonumber(a)
  b=tonumber(b)
  c=tonumber(c)
  d=tonumber(d)
  if not a or not b or not c or not d then return false end
  if a<0 or 255<a then return false end
  if b<0 or 255<b then return false end
  if c<0 or 255<c then return false end
  if d<0 or 255<d then return false end
  return true
end

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to get access to the ftpClient_Model object
---@param handle handle Handle of ftpClient_Model object
local function setFTPClient_Model_Handle(handle)
  ftpClient_Model = handle
  if ftpClient_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if ftpClient_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("FTPClient_OnUserLevelOperatorActive", true)
    Script.notifyEvent("FTPClient_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("FTPClient_OnUserLevelServiceActive", true)
    Script.notifyEvent("FTPClient_OnUserLevelAdminActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrFTPClient()

  updateUserLevel()

  Script.notifyEvent("FTPClient_OnNewStatusModuleVersion", 'v' .. ftpClient_Model.version)
  Script.notifyEvent("FTPClient_OnNewStatusCSKStyle", ftpClient_Model.styleForUI)
  Script.notifyEvent("FTPClient_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  Script.notifyEvent('FTPClient_OnNewServerIP', ftpClient_Model.parameters.serverIP)
  Script.notifyEvent('FTPClient_OnNewPort', ftpClient_Model.parameters.port)
  Script.notifyEvent('FTPClient_OnNewUsername', ftpClient_Model.parameters.user)
  Script.notifyEvent('FTPClient_OnNewPassword', ftpClient_Model.parameters.password)
  Script.notifyEvent('FTPClient_OnNewPassiveModeStatus', ftpClient_Model.parameters.passiveMode)
  Script.notifyEvent('FTPClient_OnNewStatusAsyncMode', ftpClient_Model.parameters.asyncMode)
  Script.notifyEvent('FTPClient_OnNewStatusVerboseMode', ftpClient_Model.parameters.verboseMode)
  if _G.availableAPIs.specific == true then
    Script.notifyEvent('FTPClient_OnNewStatusConnected', ftpClient_Model.ftpClient:isConnected())
  end

  Script.notifyEvent("FTPClient_OnNewStatusRegisteredEventName", ftpClient_Model.registeredEventName)
  Script.notifyEvent("FTPClient_OnNewStatusDataType", ftpClient_Model.dataType)
  Script.notifyEvent("FTPClient_OnNewStatusAutoFilename", ftpClient_Model.autoFilename)
  Script.notifyEvent("FTPClient_OnNewStatusRegistrationList", ftpClient_Model.helperFuncs.createSpecificJsonList(ftpClient_Model.parameters.registeredEvents, ftpClient_Model.eventSelection))

  Script.notifyEvent("FTPClient_OnNewStatusFlowConfigPriority", ftpClient_Model.parameters.flowConfigPriority)
  Script.notifyEvent('FTPClient_OnNewStatusLoadParameterOnReboot', ftpClient_Model.parameterLoadOnReboot)
  Script.notifyEvent('FTPClient_OnPersistentDataModuleAvailable', ftpClient_Model.persistentModuleAvailable)
  Script.notifyEvent("FTPClient_OnNewParameterName", ftpClient_Model.parametersName)

end
Timer.register(tmrFTPClient, "OnExpired", handleOnExpiredTmrFTPClient)

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrFTPClient:start()
  return ''
end
Script.serveFunction("CSK_FTPClient.pageCalled", pageCalled)

-- ********************* UI Setting / Submit Functions Start ********************

local function connectFTPClient()
  ftpClient_Model.ftpClient:setIpAddress(ftpClient_Model.parameters.serverIP)
  ftpClient_Model.ftpClient:setPort(ftpClient_Model.parameters.port)
  ftpClient_Model.ftpClient:setPassiveMode(ftpClient_Model.parameters.passiveMode)
  ftpClient_Model.ftpClient:setVerbose(ftpClient_Model.parameters.verboseMode)

  local success = ftpClient_Model.ftpClient:connect(ftpClient_Model.parameters.user, ftpClient_Model.parameters.password)
  if success then
    _G.logger:info(nameOfModule .. ": Connected to FTP server.")
  else
    _G.logger:warning(nameOfModule .. ": Not connected to FTP server.")
  end
  Script.notifyEvent('FTPClient_OnNewStatusConnected', ftpClient_Model.ftpClient:isConnected())
  ftpClient_Model.parameters.isConnected = success
  return success
end
Script.serveFunction("CSK_FTPClient.connectFTPClient", connectFTPClient)

local function disconnectFTPClient()
  ftpClient_Model.ftpClient:disconnect()
  _G.logger:info(nameOfModule .. ": Disconnected")
  Script.notifyEvent('FTPClient_OnNewStatusConnected', ftpClient_Model.ftpClient:isConnected())
end
Script.serveFunction("CSK_FTPClient.disconnectFTPClient", disconnectFTPClient)

local function getFTPStatus()
  return ftpClient_Model.ftpClient:isConnected()
end
Script.serveFunction("CSK_FTPClient.getFTPStatus", getFTPStatus)

local function setFTPServerIP(ip)
  if checkIP(ip) == true then
    ftpClient_Model.parameters.serverIP = ip
    _G.logger:fine(nameOfModule .. ': Set FTP server IP to: ' .. ip)
    Script.notifyEvent('FTPClient_OnNewIPCheck', false)
  else
    _G.logger:warning(nameOfModule .. ': Not possible to set FTP server IP to: ' .. ip)
    Script.notifyEvent('FTPClient_OnNewIPCheck', true)
  end
end
Script.serveFunction("CSK_FTPClient.setFTPServerIP", setFTPServerIP)

local function getFTPServerIP()
  return ftpClient_Model.parameters.serverIP
end
Script.serveFunction("CSK_FTPClient.getFTPServerIP", getFTPServerIP)

local function setFTPPort(port)
  _G.logger:fine(nameOfModule .. ': Set FTP port to: ' .. tostring(port))
  ftpClient_Model.parameters.port = port
end
Script.serveFunction("CSK_FTPClient.setFTPPort", setFTPPort)

local function getFTPPort()
  return ftpClient_Model.parameters.port
end
Script.serveFunction("CSK_FTPClient.getFTPPort", getFTPPort)

local function setUsername(user)
  _G.logger:fine(nameOfModule .. ': Set username to: ' .. tostring(user))
  ftpClient_Model.parameters.user = user
end
Script.serveFunction("CSK_FTPClient.setUsername", setUsername)

local function getUsername()
  return ftpClient_Model.parameters.user
end
Script.serveFunction("CSK_FTPClient.getUsername", getUsername)

local function setPassword(password)
  _G.logger:fine(nameOfModule .. ': Set password.')
  ftpClient_Model.parameters.password = password
end
Script.serveFunction("CSK_FTPClient.setPassword", setPassword)

local function getPassword()
  return ftpClient_Model.parameters.password
end
Script.serveFunction("CSK_FTPClient.getPassword", getPassword)

local function setPassiveMode(status)
  _G.logger:fine(nameOfModule .. ': Set passive mode to: ' .. tostring(status))
  ftpClient_Model.parameters.passiveMode = status
end
Script.serveFunction("CSK_FTPClient.setPassiveMode", setPassiveMode)

local function getPassiveMode()
  return ftpClient_Model.parameters.passiveMode
end
Script.serveFunction("CSK_FTPClient.getPassiveMode", getPassiveMode)

local function setAsyncMode(status)
  _G.logger:fine(nameOfModule .. ': Set async mode to: ' .. tostring(status))
  ftpClient_Model.parameters.asyncMode = status
end
Script.serveFunction("CSK_FTPClient.setAsyncMode", setAsyncMode)

local function getAsyncMode()
  return ftpClient_Model.parameters.asyncMode
end
Script.serveFunction("CSK_FTPClient.getAsyncMode", getAsyncMode)

local function setImageName (imageName)
  _G.logger:fine(nameOfModule .. ': Set image name to: ' .. tostring(imageName))
  ftpClient_Model.parameters.imageName = imageName
end
Script.serveFunction("CSK_FTPClient.setImageName", setImageName)

local function getImageName ()
  return ftpClient_Model.parameters.imageName
end
Script.serveFunction("CSK_FTPClient.getImageName", getImageName)

local function setVerboseMode(status)
  _G.logger:fine(nameOfModule .. ': Set verbose mode to: ' .. tostring(status))
  ftpClient_Model.parameters.verboseMode = status
end
Script.serveFunction('CSK_FTPClient.setVerboseMode', setVerboseMode)

local function setRegistereEventName(name)
  _G.logger:fine(nameOfModule .. ': Set eventname to: ' .. tostring(name))
  ftpClient_Model.registeredEventName = name
end
Script.serveFunction('CSK_FTPClient.setRegistereEventName', setRegistereEventName)

local function setDataType(dataType)
  _G.logger:fine(nameOfModule .. ': Set dataType to: ' .. tostring(dataType))
  ftpClient_Model.dataType = dataType
end
Script.serveFunction('CSK_FTPClient.setDataType', setDataType)

local function setAutoFilename(status)
  _G.logger:fine(nameOfModule .. ': Set autoFilename status to: ' .. tostring(status))
  ftpClient_Model.autoFilename = status
end
Script.serveFunction('CSK_FTPClient.setAutoFilename', setAutoFilename)

local function addRegistration(eventName, dataType, autoFilename)

  if not ftpClient_Model.parameters.registeredEvents[eventName] then
    ftpClient_Model.parameters.registeredEvents[eventName] = {}
    ftpClient_Model.parameters.registeredEvents[eventName].eventName = eventName
    ftpClient_Model.parameters.registeredEvents[eventName].dataType = dataType
    ftpClient_Model.parameters.registeredEvents[eventName].autoFilename = autoFilename

    ftpClient_Model.registerEvent(eventName, dataType, autoFilename)
  else
    _G.logger:fine(nameOfModule .. ": Event already exists")
  end
  handleOnExpiredTmrFTPClient()
end
Script.serveFunction('CSK_FTPClient.addRegistration', addRegistration)

local function addRegistrationViaUI()
  addRegistration(ftpClient_Model.registeredEventName, ftpClient_Model.dataType, ftpClient_Model.autoFilename)
end
Script.serveFunction('CSK_FTPClient.addRegistrationViaUI', addRegistrationViaUI)

local function deleteRegistration(eventName)
  if ftpClient_Model.parameters.registeredEvents[eventName] then
    ftpClient_Model.deregisterEvent(eventName, ftpClient_Model.parameters.registeredEvents[eventName].dataType, ftpClient_Model.parameters.registeredEvents[eventName].autoFilename)
    ftpClient_Model.parameters.registeredEvents[eventName] = nil
  else
    _G.logger:fine(nameOfModule .. ": Registration does not exists")
  end
  handleOnExpiredTmrFTPClient()
end
Script.serveFunction('CSK_FTPClient.deleteRegistration', deleteRegistration)

local function deleteRegistrationViaUI()
  deleteRegistration(ftpClient_Model.eventSelection)
end
Script.serveFunction('CSK_FTPClient.deleteRegistrationViaUI', deleteRegistrationViaUI)

--- Function to check if selection in UIs DynamicTable can find related pattern
---@param selection string Full text of selection
---@param pattern string Pattern to search for
local function checkSelection(selection, pattern)
  if selection ~= "" then
    local _, pos = string.find(selection, pattern)
    if pos == nil then
    else
      pos = tonumber(pos)
      if pattern ~= '"selected":true' then
        local endPos = string.find(selection, '"', pos+1)
        local tempSelection = string.sub(selection, pos+1, endPos-1)
        if tempSelection ~= nil and tempSelection ~= '-' then
          return tempSelection
        end
      else
        return ''
      end
    end
  end
  return nil
end

local function setUITableSelection(selection)
  local tempSelection = checkSelection(selection, '"DTC_EventName":"')
  if tempSelection then
    local isSelected = checkSelection(selection, '"selected":true')
    if isSelected then
      _G.logger:fine(nameOfModule .. ": Selected event " .. tostring(tempSelection))
      ftpClient_Model.eventSelection = tempSelection
    else
      ftpClient_Model.eventSelection = ''
    end
    handleOnExpiredTmrFTPClient()
  end

end
Script.serveFunction('CSK_FTPClient.setUITableSelection', setUITableSelection)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_FTPClient.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  for key, value in pairs(ftpClient_Model.parameters.registeredEvents) do
    deleteRegistration(key)
  end
end
Script.serveFunction('CSK_FTPClient.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters()
  return ftpClient_Model.helperFuncs.json.encode(ftpClient_Model.parameters)
end
Script.serveFunction('CSK_FTPClient.getParameters', getParameters)

-- *****************************************************************
-- Following functions can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  ftpClient_Model.parametersName = name
  _G.logger:fine(nameOfModule .. ': Set parameter name to: ' .. tostring(name))
end
Script.serveFunction("CSK_FTPClient.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if ftpClient_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(ftpClient_Model.helperFuncs.convertTable2Container(ftpClient_Model.parameters), ftpClient_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, ftpClient_Model.parametersName, ftpClient_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send FTPClient parameters with name '" .. ftpClient_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_FTPClient.sendParameters", sendParameters)

local function loadParameters()
  if ftpClient_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(ftpClient_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      ftpClient_Model.parameters = ftpClient_Model.helperFuncs.convertContainer2Table(data)
      ftpClient_Model.deregisterAllEvents()
      ftpClient_Model.registerAllEvents()
      if ftpClient_Model.parameters.isConnected then
        CSK_FTPClient.connectFTPClient()
      end
      CSK_FTPClient.pageCalled()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_FTPClient.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  ftpClient_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("FTPClient_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_FTPClient.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  ftpClient_Model.parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("FTPClient_OnNewStatusFlowConfigPriority", ftpClient_Model.parameters.flowConfigPriority)
end
Script.serveFunction('CSK_FTPClient.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')

    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')
      ftpClient_Model.persistentModuleAvailable = false
    else

      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

      if parameterName then
        ftpClient_Model.parametersName = parameterName
        ftpClient_Model.parameterLoadOnReboot = loadOnReboot
      end

      if ftpClient_Model.parameterLoadOnReboot then
        loadParameters()
      end
      Script.notifyEvent('FTPClient_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    clearFlowConfigRelevantConfiguration()
    local connected = ftpClient_Model.ftpClient:isConnected()
    if connected then
      disconnectFTPClient()
    end
    pageCalled()
  end
end
Script.serveFunction('CSK_FTPClient.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setFTPClient_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************