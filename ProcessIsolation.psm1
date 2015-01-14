<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.75
	 Created on:   	1/14/2015 8:52 AM
	 Created by:   	Kevin Kirkpatrick
	 Organization: 	
	 Filename:     	SvchostManager.psm1
	-------------------------------------------------------------------------
	 Module Name: SvchostManager
	===========================================================================

	This module was written to make it easier/faster to isolate svchost.exe child processes.
	It's a wrapper for for native 'SC' commands
	
#>

function Get-ProcessServices {
	<#
	- WMI 'Change' method: http://msdn.microsoft.com/en-us/library/aa384901(v=vs.85).aspx
	- Update this to use WMI and include options for remoting
	- include output codes and messages
	#>
	
	[cmdletbinding()]
	param ()
	
	BEGIN {
		$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
		
		Write-Verbose -Message 'Checking for PowerShell ISE'
		if (-not (Test-Path -LiteralPath "$env:windir\system32\windowspowershell\v1.0\powershell_ises.exe" -Type Leaf)) {
			Write-Warning -Message 'The PowerShell ISE does not appear to be installed and is required. Please install and run again'
			Write-Warning -Message 'Exiting script'
			Exit
		} # end if
		
	} # end BEGIN block
	
	PROCESS {
		
		Write-Verbose -Message 'Gathering active processes'
		try {
			Write-Verbose -Message 'Select process...'
			$processQuery = Get-Process | Select-Object -Unique | Sort-Object ProcessName | Out-GridView -OutputMode Single
		} catch {
			Write-Warning -Message "Error gathering processes. $_"
			Write-Warning -Message 'Exiting script'
			Exit
		} # end try/catch
		
		$processName = $processQuery.ProcessName + '.exe'
		
		Write-Verbose -Message 'Gathering associations and children'
		tasklist.exe /SVC /FI "IMAGENAME eq $processName"
		
	} # end PROCESS block
	
	END {
		Write-Verbose -Message 'Done'
	} # end END block
} # end function


function Set-ProcessIsolationType {
	[cmdletbinding()]
	param (
	)
	
	BEGIN {
		#
	} # end BEGIN block
	
	PROCESS {
		#
	} # end PROCESS block
	
	END {
		#
	} # end END block
	
} # end function






