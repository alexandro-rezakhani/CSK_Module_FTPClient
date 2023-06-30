---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the FTPClient_Model definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_FTPClient'

local ftpClient_Model = {}

-- Check if CSK_UserManagement module can be used
ftpClient_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
ftpClient_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
ftpClient_Model.parametersName = 'CSK_FTPClient_Parameter' -- name of parameter dataset to be used for this module
ftpClient_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the FTPClient_Model interface and give access
-- to the FTPClient_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setFTPClient_Model_Handle = require('Communication/FTPClient/FTPClient_Controller')
setFTPClient_Model_Handle(ftpClient_Model)

ftpClient_Model.helperFuncs = require('Communication/FTPClient/helper/funcs')

-- Create a FTP client instance
ftpClient_Model.ftpClient = FTPClient.create() -- FTP client to use for FTP connection
ftpClient_Model.counter = 1 -- Internal counter, e.g. used to count sent data and use it for naming
ftpClient_Model.formatter = Image.Format.JPEG.create() -- Formatter instance (JPG per default)

-- Function to be processed asynchronously if 'asyncMode' is used
ftpClient_Model.async = Engine.AsyncFunction.create()
ftpClient_Model.async:setFunction("FTPClient.put", ftpClient_Model.ftpClient)

-- Parameters to be saved permanently if wanted
ftpClient_Model.parameters = {}
ftpClient_Model.parameters.serverIP = '192.168.0.201' -- IP of FTP server
ftpClient_Model.parameters.imageName = 'unknown' -- Use to give a name for the image to send
ftpClient_Model.parameters.isConnected = false -- Status if FTP connection should be established
ftpClient_Model.parameters.mode = 'FTP' -- FTP / SFTP -- Mode of FTP connection
if ftpClient_Model.parameters.mode == 'SFTP' then
  ftpClient_Model.ftpClient:setSecurityProtocol('SFTP')
  ftpClient_Model.parameters.port = 22 -- FTP = 21 / SFTP = 22 -- FTP port to use
else
  ftpClient_Model.parameters.port = 21 -- FTP = 21 / SFTP = 22
end

ftpClient_Model.parameters.user = 'unknown' -- FTP user
ftpClient_Model.parameters.password = 'pass'-- FTP password for user
ftpClient_Model.parameters.passiveMode = true -- FTP passive mode
ftpClient_Model.parameters.asyncMode = false -- asyncMode
ftpClient_Model.parameters.verboseMode = false -- verbose Mode of FTP connection

-- For future usage
--ftpClient_Model.parameters.registeredEvents = {} -- Events to listen for incoming data to store on FTP server

-- Sample of data content of entries within the "registeredEvents"
--[[
local tempInfo = {}
tempInfo.eventName = nil -- Name of the event to register on, e.g. 'CSK_ImagePlayer.OnNewImage'
tempInfo.contentType = nil
tempInfo.contentType = nil
table.insert(ftpClient_Model.parameters.registeredEvents, tempInfo)
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Checking of the asynchronous FTP transfer process
---@param futureHandle Engine.AsyncFunction.Future The future object identifying the function call
local function checkDataTransfer(futureHandle)

  local suc = futureHandle:isFailed()
  if suc then
    _G.logger:info(nameOfModule .. ": FTP put OK.")
  else
    _G.logger:warning(nameOfModule .. ": FTP put error.")
  end
end
Engine.AsyncFunction.register(ftpClient_Model.async, "OnFinished", checkDataTransfer)

local function sendData(data, filename)
  if ftpClient_Model.ftpClient:isConnected() then
    _G.logger:info(nameOfModule .. ": Try to send data")

    if ftpClient_Model.parameters.asyncMode then --> Asynchronous image transfer
      ftpClient_Model.async:launch(filename, data)

    else --> Non asynchronous image transfer
      local suc = ftpClient_Model.ftpClient:put(filename, data)

      if suc then
        _G.logger:info(nameOfModule .. ": FTP put OK.")
      else
        _G.logger:warning(nameOfModule .. ": FTP put error.")
      end
    end

  else
    _G.logger:warning(nameOfModule .. ": No FTP connection.")
  end
  if type(data) == "userdata" then
    Script.releaseObject(data)
  end
end
Script.serveFunction("CSK_FTPClient.sendData", sendData)
ftpClient_Model.sendData = sendData

local function sendImage(img, filename)
  if ftpClient_Model.ftpClient:isConnected() then
    _G.logger:info(nameOfModule .. ": Try to send image")
    local compImg = ftpClient_Model.formatter:encode(img)

    if ftpClient_Model.parameters.asyncMode then --> Asynchronous image transfer
      if filename then
        ftpClient_Model.async:launch(filename .. '.jpg', compImg)
      elseif ftpClient_Model.parameters.imageName == "unknown" then
        ftpClient_Model.async:launch(ftpClient_Model.parameters.imageName .. 'image' .. tostring(ftpClient_Model.counter) .. '.jpg', compImg)
        ftpClient_Model.counter = ftpClient_Model.counter + 1
      else
        ftpClient_Model.async:launch(ftpClient_Model.parameters.imageName .. '.jpg', compImg)
      end

    else --> Non asynchronous image transfer
      local suc = false
      if filename then
        suc = ftpClient_Model.ftpClient:put(filename .. '.jpg', compImg)
      elseif ftpClient_Model.parameters.imageName == "unknown" then
        suc = ftpClient_Model.ftpClient:put(ftpClient_Model.parameters.imageName .. 'image' .. tostring(ftpClient_Model.counter) .. '.jpg', compImg)
        if suc then
          ftpClient_Model.counter = ftpClient_Model.counter + 1
        end
      else
        suc = ftpClient_Model.ftpClient:put(ftpClient_Model.parameters.imageName .. '.jpg', compImg)
      end
      if suc then
        _G.logger:info(nameOfModule .. ": FTP put OK.")
      else
        _G.logger:warning(nameOfModule .. ": FTP put error.")
      end
    end

  else
    _G.logger:warning(nameOfModule .. ": No FTP connection.")
  end
  Script.releaseObject(img)
end
Script.serveFunction("CSK_FTPClient.sendImage", sendImage)
ftpClient_Model.sendImage = sendImage

return ftpClient_Model