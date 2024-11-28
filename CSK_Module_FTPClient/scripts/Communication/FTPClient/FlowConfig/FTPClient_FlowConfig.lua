--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Communication.FTPClient.FlowConfig.FTPClient_Put')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if ftpClient_Model.parameters.flowConfigPriority then
      CSK_FTPClient.clearFlowConfigRelevantConfiguration()
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)