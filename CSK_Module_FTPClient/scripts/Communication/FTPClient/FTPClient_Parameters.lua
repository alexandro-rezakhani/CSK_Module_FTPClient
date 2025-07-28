---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local ftpClientParameters = {}

  ftpClientParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  ftpClientParameters.serverIP = '192.168.0.201' -- IP of FTP server
  ftpClientParameters.imageName = 'unknown' -- Use to give a name for the image to send
  ftpClientParameters.isConnected = false -- Status if FTP connection should be established
  ftpClientParameters.mode = 'FTP' -- FTP / SFTP -- Mode of FTP connection
  if ftpClientParameters.mode == 'SFTP' then
    if _G.availableAPIs.specific == true then
      ftpClient_Model.ftpClient:setSecurityProtocol('SFTP')
    end
    ftpClientParameters.port = 22 -- FTP = 21 / SFTP = 22 -- FTP port to use
  else
    ftpClientParameters.port = 21 -- FTP = 21 / SFTP = 22
  end

  ftpClientParameters.user = 'unknown' -- FTP user
  ftpClientParameters.password = 'pass'-- FTP password for user
  ftpClientParameters.passiveMode = true -- FTP passive mode
  ftpClientParameters.asyncMode = false -- asyncMode
  ftpClientParameters.verboseMode = false -- verbose Mode of FTP connection

  ftpClientParameters.registeredEvents = {} -- Events to listen for incoming data to store on FTP server
  -- Sample of data content of entries within the "registeredEvents"
  -- ftpClientParameters.registeredEvents[id].eventName -- Name of event
  -- ftpClientParameters.registeredEvents[id].dataType -- Type of data to save
  -- ftpClientParameters.registeredEvents[id].autoFilename -- Status if filename should be created by timestamp

  return ftpClientParameters
end
functions.getParameters = getParameters

return functions