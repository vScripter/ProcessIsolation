<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.75
	 Created on:   	1/14/2015 8:52 AM
	 Created by:   	Kevin Kirkpatrick
	 Organization: 	
	 Filename:     	ProcessIsolation.psm1
	-------------------------------------------------------------------------
	 Module Name: ProcessIsolation
	===========================================================================
	
#>

function Get-ProcessServices {
	<#
	.SYNOPSIS
		This function will return all of the services associated with the process instance/s based on the process name you provide
	.DESCRIPTION
		This function uses tasklist.exe to return service-to-process (image) associations for the means of toubleshooting.
	
		A common example of this would be if you were troubleshooting a performance issue related to a service process running underneath one of the svchost.exe
		processes.
	
		You can use this function to identify what you want to isolate and then use the Set-ServiceIsolation function to actually set isolation.
	.PARAMETER ComputerName
		Name of computer you wish to run the command against.
	.PARAMETER ProcessName
		Name of process
	.INPUTS
		System.String
	.OUTPUTS
		PSCustomObject
	.EXAMPLE
		Get-ProcessServices -ComputerName localhost -ProcessName svchost.exe -Verbose | Format-Table -AutoSize

ComputerName ProcessName ProcessID Services                                                                                                                            
------------ ----------- --------- --------                                                                                                                            
localhost    svchost.exe 664       DcomLaunch,PlugPlay,Power                                                                                                           
localhost    svchost.exe 1108      RpcEptMapper,RpcSs                                                                                                                  
localhost    svchost.exe 1204      AudioSrv,Dhcp,eventlog,HomeGroupProvider,lmhosts,wscsvc                                                                             
localhost    svchost.exe 1288      AudioEndpointBuilder,CscService,hidserv,Netman,PcaSvc,TabletInputService,TrkWks,UmRdpService,UxSms,Wlansvc,wudfsvc                  
localhost    svchost.exe 1312      EventSystem,fdPHost,FontCache,netprofm,nsi,W32Time,WdiServiceHost,WinHttpAutoProxySvc                                               
localhost    svchost.exe 1352      AeLookupSvc,BITS,Browser,CertPropSvc,EapHost,IKEEXT,iphlpsvc,LanmanServer,ProfSvc,Schedule,SENS,SessionEnv,ShellHWDetection
localhost    svchost.exe 1564      gpsvc                                                                                                                               
localhost    svchost.exe 1968      CryptSvc,Dnscache,LanmanWorkstation,NlaSvc,TermService,WinRM                                                                        
localhost    svchost.exe 2104      BFE,DPS,MpsSvc                                                                                                                      
localhost    svchost.exe 2372      bthserv                                                                                                                             
localhost    svchost.exe 2524      FDResPub,SSDPSRV,TBS,upnphost                                                                                                       
localhost    svchost.exe 3316      RemoteRegistry                                                                                                                      
localhost    svchost.exe 4940      PolicyAgent                                                                                                                         
localhost    svchost.exe 9460      stisvc                                                                                                                              
localhost    svchost.exe 13704     wuauserv
	.NOTES
	
		#TAG:PUBLIC
		
			GitHub: https://github.com/vN3rd
			Twitter: @vN3rd
			Email: kevin@vmotioned.com
			Blog: www.vMotioned.com
	
	[-------------------------------------DISCLAIMER-------------------------------------]
	 All script are provided as-is with no implicit
	 warranty or support. It's always considered a best practice
	 to test scripts in a DEV/TEST environment, before running them
	 in production. In other words, I will not be held accountable
	 if one of my scripts is responsible for an RGE (Resume Generating Event).
	 If you have questions or issues, please reach out/report them on
	 my GitHub page. Thanks for your support!
	[-------------------------------------DISCLAIMER-------------------------------------]
	
	.LINK
		https://github.com/vN3rd

	#>
	
	[cmdletbinding(PositionalBinding = $true)]
	param (
		[parameter(Mandatory = $false,
				   Position = 0,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $false,
				   HelpMessage = 'Name of computer to query')]
		[alias('CN')]
		[System.String]$ComputerName = 'localhost',
	
		[parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $false,
				   HelpMessage = 'Name of process (ex: svchost.exe')]
		[alias('Name', 'PN')]
		[System.String]$ProcessName		
	)
	
	BEGIN {
		$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
		$finalResults = @()
		
	} # end BEGIN block
	
	PROCESS {
		$taskListQuery = $null
		$p = $null
		
		if (-not ($processName -like '*.exe')) {
			$ProcessName = $ProcessName + '.exe'
		} # end if
		
		Write-Verbose -Message 'Gathering service associations'
		$imageName = @{ name = 'ImageName'; Expression = { $_.'Image Name' } }
		
		$taskListQuery = tasklist.exe /S $ComputerName /SVC /FI "IMAGENAME eq $processName" /FO CSV |
		ConvertFrom-Csv |
		Select-Object $imageName, PID, Services
		
		foreach ($p in $taskListQuery) {
			$objTaskList = @()
			
			$objTaskList = [PSCustomObject] @{
				ComputerName = $ComputerName
				ProcessName = $p.ImageName
				ProcessID = $p.PID
				Services = $p.Services
			} # end $objTaskList
			
			$finalResults += $objTaskList
		} # end foreach $p
		
	} # end PROCESS block
	
	END {
		
		$finalResults
		
	} # end END block
} # end function Get-ProcessServices

function Get-ServiceType {
	<#
	.SYNOPSIS
		This function will gather service type deatil on one, or more, computers. 
	.DESCRIPTION
		This function was written to complement Set-ServiceIsolation.
	
		It will return the service type for a single service on one, or more, computers
	.PARAMETER ComputerName
		Name of computer/s
	.PARAMETER ServiceName
		Name of service
	.INPUTS
		System.String
	.EXAMPLE
		Get-ServiceType -ComputerName localhost -ServiceName wuauserv -Verbose | ft -a
	.EXAMPLE
	.NOTES
	
	
		#TAG:PUBLIC
		
			GitHub: https://github.com/vN3rd
			Twitter: @vN3rd
			Email: kevin@vmotioned.com
			Blog: www.vMotioned.com
	
	[-------------------------------------DISCLAIMER-------------------------------------]
	 All script are provided as-is with no implicit
	 warranty or support. It's always considered a best practice
	 to test scripts in a DEV/TEST environment, before running them
	 in production. In other words, I will not be held accountable
	 if one of my scripts is responsible for an RGE (Resume Generating Event).
	 If you have questions or issues, please reach out/report them on
	 my GitHub page. Thanks for your support!
	[-------------------------------------DISCLAIMER-------------------------------------]
	
	.LINK
		https://github.com/vN3rd
	
	#>
	
	[cmdletbinding()]
	param (
		[parameter(Mandatory = $true,
				   Position = 0,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $false,
				   HelpMessage = 'Enter name of computer')]
		[alias('CN')]
		[String[]]$ComputerName,
		
		[parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $false,
				   HelpMessage = 'Enter name of service')]
		[alias('Name', 'N')]
		[validatenotnullorempty()]
		[String]$ServiceName
	)
	
	BEGIN {
		
		$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
		$finalResults = @()
		
	} # end BEGIN block
	
	PROCESS {
		
		foreach ($comp in $ComputerName) {
			if (Test-Connection -ComputerName $comp -Count 1 -Quiet) {
				$objSvcCheck = @()
				$svcCheck = $null
				
				Write-Verbose -Message "Checking service type for '$serviceName' on $comp"
				$svcCheck = Get-Service -ComputerName $comp -Name $serviceName | Select-Object Name, DisplayName, Status, ServiceType
				
				$objSvcCheck = [PSCustomObject] @{
					ComputerName = $comp
					ServiceName = $svcCheck.Name
					ServiceDescription = $svcCheck.DisplayName
					ServiceStatus = $svcCheck.Status
					ServiceType = $(
					if ($svcCheck.ServiceType -eq 'Win32OwnProcess') { 'Own' }
					if ($svcCheck.ServiceType -eq 'Win32ShareProcess') { 'Shared' }
					)
				} # end $objSvcCheck
				
				$finalResults += $objSvcCheck
			} else {
				Write-Warning -Message "$Comp - unreachable by ping"
			} # end if/else
		} # end foreach
		
	} # end PROCESS blocl
	
	END {
		$finalResults
	} # end END block
} # end function Get-ServiceType

function Set-ServiceIsolation {
	<#
	.SYNOPSIS
		This function will set the isolation type to 'Own' or 'Shared' depending on your need
	.DESCRIPTION
		This function uses WMI to set the desired isolation type for the given service
	
		A common example of this would be if you were troubleshooting a performance issue related to a service process running underneath one of the svchost.exe
		processes, such as wuauserv (Windows Update)
	
		It requires the Get-ServiceType function, which is part of this module; Get-ServiceType is used to confirm service type in this module. You can use Get-ServiceType
		by itself to gather information about local services.
	.PARAMETER ComputerName
		Name of computer you wish to run the command against.
	.PARAMETER ServiceName
		Name of service
	.PARAMETER IsolationType
		Select the type of isolation; either 'Own' or 'Shared'
	.INPUTS
		System.String
	.OUTPUTS
		N/A
	.EXAMPLE
		Set-ServiceIsolation -ComputerName localhost -ServiceName wuauserv -IsolationType Own -Verbose
	.NOTES
	
		#TAG:PUBLIC
		
			GitHub: https://github.com/vN3rd
			Twitter: @vN3rd
			Email: kevin@vmotioned.com
			Blog: www.vMotioned.com
	
	[-------------------------------------DISCLAIMER-------------------------------------]
	 All script are provided as-is with no implicit
	 warranty or support. It's always considered a best practice
	 to test scripts in a DEV/TEST environment, before running them
	 in production. In other words, I will not be held accountable
	 if one of my scripts is responsible for an RGE (Resume Generating Event).
	 If you have questions or issues, please reach out/report them on
	 my GitHub page. Thanks for your support!
	[-------------------------------------DISCLAIMER-------------------------------------]
	
	.LINK
		https://github.com/vN3rd
	
	#>
	
	[cmdletbinding(PositionalBinding = $true)]
	param (
		[parameter(Mandatory = $false,
				   Position = 0,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $false,
				   HelpMessage = 'Enter name of computer')]
		[alias('CN')]
		[validatescript({ Test-Connection -ComputerName $_ -Count 1 -Quiet })]
		[System.String]$ComputerName = 'localhost',
	
		[parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $false,
				   HelpMessage = 'Enter name of service')]
		[alias('Name', 'N')]
		[validatenotnullorempty()]
		[System.String]$ServiceName,
		
		[parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $false,
				   ValueFromPipelineByPropertyName = $false,
				   HelpMessage = "Select Isolation type (Valid Values Are 'Own' and 'Shared'")]
		[validateset('Own', 'Shared')]
		[System.String]$IsolationType
	)
	
	BEGIN {
		$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
		
		[int]$setIsolation = $null
		
		function Get-ReturnCode {
			[cmdletbinding()]
			param ($ReturnCode)
			
			Write-Verbose -Message 'Getting return code'
			
			switch ($ReturnCode) {
				'0' { 'The request was accepted.' }
				'1' { 'The request is not supported.' }
				'2' { 'The user did not have the necessary access.' }
				'3' { 'The service cannot be stopped because other services that are running are dependent on it.' }
				'4' { 'The requested control code is not valid, or it is unacceptable to the service.' }
				'5' { 'The requested control code cannot be sent to the service because the state of the service (Win32_BaseService State property) is equal to 0, 1, or 2.' }
				'6' { 'The service has not been started.' }
				'7' { 'The service did not respond to the start request in a timely fashion.' }
				'8' { 'Unknown failure when starting the service.' }
				'9' { 'The directory path to the service executable file was not found.' }
				'10' { 'The service is already running.' }
				'11' { 'The database to add a new service is locked.' }
				'12' { 'A dependency this service relies on has been removed from the system.' }
				'13' { 'The service failed to find the service needed from a dependent service.' }
				'14' { 'The service has been disabled from the system.' }
				'15' { 'The service does not have the correct authentication to run on the system.' }
				'16' { 'This service is being removed from the system.' }
				'17' { 'The service has no execution thread.' }
				'18' { 'The service has circular dependencies when it starts.' }
				'19' { 'A service is running under the same name.' }
				'20' { 'The service name has invalid characters.' }
				'21' { 'Invalid parameters have been passed to the service.' }
				'22' { 'The account under which this service runs is either invalid or lacks the permissions to run the service.' }
				'23' { 'The service exists in the database of services available from the system.' }
				'24' { 'The service is currently paused in the system.' }
			} # end switch block
		} # end function Get-ReturnCode
		
	} # end BEGIN block
	
	PROCESS {
		
		$svcCheck = $Null
		
		switch ($IsolationType) {
			'Own' {
				$setIsolation = 16
				
				Write-Verbose -Message "Setting isolation to 'Own' for the $serviceName service"
				$invokeMethod = Get-WmiObject -ComputerName $ComputerName -Class win32_service -Filter "name='$serviceName'" |
				Invoke-WmiMethod -Name Change -ArgumentList @($null, $null, $null, $null, $null, $null, $null, $setIsolation)
				
				$invokeReturnCode = $invokeMethod.ReturnValue
				$returnCodeResult = Get-ReturnCode -ReturnCode $invokeReturnCode
				
				if ($invokeReturnCode -eq '0') {
					
					Write-Verbose -Message "Success - $returnCodeResult"
					
					$requestRestart = Read-Host -Prompt 'Would you like to try to restart the service? (Y/N) '
					
					if ($requestRestart -eq 'Y') {
						try {
							Write-Verbose -Message "Restarting $serviceName service"
							Get-Service -ComputerName $ComputerName -Name $serviceName | Restart-Service -Verbose
							
							Write-Verbose -Message "Service restart Complete. Checking $serviceName service type"
							Get-ServiceType -ComputerName $ComputerName -ServiceName $ServiceName -Verbose
						
						} catch {
							Write-Warning -Message "Error attempting service restart - $_"
						} # end try/catch
						
					} # end if
				} else {
					Write-Warning -Message "Error: Something happened during execution. Double check parameter values."
				} # end if/else
			} # end 'Own'
			
			'Shared' {
				$setIsolation = 32
				
				Write-Verbose -Message "Setting isolation to 'Shared' for the $serviceName service"
				$invokeMethod = Get-WmiObject -ComputerName $ComputerName -Class win32_service -Filter "name='$serviceName'" |
				Invoke-WmiMethod -Name Change -ArgumentList @($null, $null, $null, $null, $null, $null, $null, $setIsolation)
				
				$invokeReturnCode = $invokeMethod.ReturnValue
				$returnCodeResult = Get-ReturnCode -ReturnCode $invokeReturnCode
				
				if ($invokeReturnCode -eq '0') {
					
					Write-Verbose -Message "Success - $returnCodeResult"
					
					$requestRestart = Read-Host -Prompt 'Would you like to try to restart the service? (Y/N) '
					
					if ($requestRestart -eq 'Y') {
						try {
							Write-Verbose -Message "Restarting $serviceName service"
							Get-Service -ComputerName $ComputerName -Name $serviceName | Restart-Service -Verbose
							
							Write-Verbose -Message "Service restart Complete. Checking $serviceName service type"
							Get-ServiceType -ComputerName $ComputerName -ServiceName $ServiceName -Verbose
							
						} catch {
							Write-Warning -Message "Error attempting service restart - $_"
						} # end try/catch
						
					} # end if
				} else {
					Write-Warning -Message "Error: Something happened during execution. Double check parameter values."
				} # end if/else
			} # end 'Shared'
		} # end switch block
		
	} # end PROCESS block
	
	END {
		#
	} # end END block
	
} # end function Set-ServiceProcessIsolation

Export-ModuleMember *