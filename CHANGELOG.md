# Changelog
All notable changes to this project will be documented in this file.

## Release 4.0.0

### New features
- Supports FlowConfig feature to link data provider to put data to FTP server
- Provide version of module via 'OnNewStatusModuleVersion'
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function 'getParameters' to provide PersistentData parameters
- It is now possible to register to events to put received data (JPG or DATA) to the FTP server (see 'addRegistration')
- Function to 'resetModule' to default setup

### Improvements
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Changed log level of some messages from 'info' to 'fine'
- Added UI icon and browser tab information

## Release 3.0.0

### Improvements
- Renamed "Ftp" to "FTP" / "Ip" to "IP" within functions/events
- Using recursive helper functions to convert Container <-> Lua table

## Release 2.6.0

### Improvements
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

## Release 2.5.0

### Improvements
- Using internal moduleName variable to be usable in merged apps instead of _APPNAME, as this did not work with PersistentData module in merged apps.

## Release 2.4.0

### New features
- FTP VerboseMode configurable

### Improvements
- optional image name parameter within "sendImage" function
- FTP VerboseMode / AsyncTransferMode status available via UI
- Naming of UI elements and adding some mouse over info texts
- Appname added to log messages
- Minor edits, docu, added log messages

### Bugfix
- UI events notified after pageLoad after 300ms instead of 100ms to not miss

## Release 2.3.0

### Improvements
- Update of helper funcs
- Minor code edits / docu updates

### Bugfix
- Error because model tried to use "parameters" before they were created

## Release 2.2.0

### New features
- Check futureHandle in Async mode

### Improvements
- ParameterName available on UI
- Prepared for all CSK user levels: Operator, Maintenance, Service, Admin
- Changed status type of user levels from string to bool
- Renamed page folder accordingly to module name
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Updated documentation

## Release 2.1.0

### New features
- Added support for userlevels, required userlevel is Maintenance

## Release 2.0.0

### New features
- Update handling of persistent data according to CSK_PersistentData module ver. 2.0.0

## Release 1.0.0
- Initial commit