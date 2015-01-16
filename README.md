<a name="Title">
# Process Isolation Module

This module consists of 3 functions that can be used to find and isolate service processes, mainly for troubleshooting.

|Navigation|
|-----------------|
|[Installation](#Installation)|
|[Functions](#Functions)|
|[Links](#Links)|

<a name="Installation">
## Installation
[***Back to top***](#Title)

1. Clone, Fork or download the .zip of the master source code
  * To download, you can copy/paste this into a PowerShell console, and it will download the module into your ~\Downloads directory.
  ```powershell
(New-Object System.Net.WebClient).DownloadFile("https://github.com/vN3rd/ProcessIsolation/archive/master.zip","$ENV:USERPROFILE\Downloads\ProcessIsolation.zip")
```

2. If you download the source:
  * Un-Block the .zip before un-zipping
  * Un-zip the source code

3. Move the 'ProcessIsolation' directory into a valid PSModulePath directory
  * You can run the following, in PowerShell, to list valid directories:
  ```powershell
  ($ENV:PSModulePath).split(';')
  ```
  * Open PowerShell and run:
  ```powershell
  Import-Module ProcessIsolation
  ```
  * Note: You may need to adjust your ExecutionPolicy


<a name="Functions">
## Functions
* [**Get-ProcessServices**](#Get-ProcessServices)
* [**Get-ServiceType**](#Get-ServiceType)
* [**Set-ServiceType**](#Set-ServiceType)

<a name="Get-ProcessServices">
#### Get-ProcessServices
[***Back to top***](#Title)

At it's core, this function executes:
```
tasklist.exe /S $computer /SVC /FI "IMAGENAME eq $processName" /FO CSV
```

Which is then sent to ConvertFrom-CSV

This function supports pipeline input, **however**, be very careful gathering information on a process name that may be running multiple instances.

```
C:\> Get-ProcessServices -ProcessName svchost.exe -Verbose | ft -a

VERBOSE: Gathering service associations on localhost


ComputerName ProcessName ProcessID Services
------------ ----------- --------- --------
localhost    svchost.exe 664       DcomLaunch,PlugPlay,Power
localhost    svchost.exe 1108      RpcEptMapper,RpcSs
localhost    svchost.exe 1204      AudioSrv,Dhcp,eventlog,lmhosts,wscsvc
localhost    svchost.exe 1288      AudioEndpointBuilder,CscService,hidserv,Netman,PcaSvc,TabletInputService,TrkWks,UmRdpService,UxSms,Wlansvc,wudfsvc
localhost    svchost.exe 1312      EventSystem,fdPHost,FontCache,netprofm,nsi,W32Time,WdiServiceHost,WinHttpAutoProxySvc
localhost    svchost.exe 1352      BITS,Browser,CertPropSvc,EapHost,IKEEXT,iphlpsvc,LanmanServer,ProfSvc,Schedule,SENS,SessionEnv,ShellHWDetection,Themes,Winmgmt,wuauserv
localhost    svchost.exe 1564      gpsvc
localhost    svchost.exe 1968      CryptSvc,Dnscache,LanmanWorkstation,NlaSvc,TermService,WinRM
localhost    svchost.exe 2104      BFE,DPS,MpsSvc
localhost    svchost.exe 2372      bthserv
localhost    svchost.exe 2524      FDResPub,SSDPSRV,TBS,upnphost
localhost    svchost.exe 3316      RemoteRegistry
localhost    svchost.exe 4940      PolicyAgent
localhost    svchost.exe 9460      stisvc
```

<a name="Get-ServiceType">
#### Get-ServiceType
[***Back to top***](#Title)

This function uses WMI to gather detail about the service type (Shared/Own) on a designated computer/s. It also accepts pipeline input.

```
C:\> Get-ServiceType -ServiceName wuauserv -Verbose| ft -a

VERBOSE: Checking 'wuauserv' service type on localhost


ComputerName ServiceName ServiceDescription ServiceStatus ServiceType
------------ ----------- ------------------ ------------- -----------
localhost    wuauserv    Windows Update           Running Shared
```

<a name="Set-ServiceType">
#### Set-ServiceType
[***Back to top***](#Title)

This function uses WMI to actually set the desired service type to either 'Shared' or 'Own'.

Since this can potentially produce undesired activity, this function fully supports -WhatIf and -Confirm.

This function supports pipeline input.

```
C:\> Set-ServiceType -ComputerName localhost -ServiceName wuauserv -IsolationType Own -RestartService -Verbose -Confirm:$false

VERBOSE: Setting isolation to 'Own' for the 'wuauserv' service on localhost
VERBOSE: Getting return code
VERBOSE: SUCCESS: Service Type Change - The request was accepted.
VERBOSE: Performing the operation "Restart-Service" on target "Windows Update (wuauserv)".
VERBOSE: Checking 'wuauserv' service type on localhost


ComputerName       : localhost
ServiceName        : wuauserv
ServiceDescription : Windows Update
ServiceStatus      : Running
ServiceType        : Own
```

<a name="Links">
## Links
* [MSDN win32_service 'Change' method](http://msdn.microsoft.com/en-us/library/aa384901(v=vs.85).aspx)
