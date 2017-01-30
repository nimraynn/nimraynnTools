### nimraynnTools PowerShell Module Pack
### Module Version: 1.0
### Updated: 26/01/2017

### Function: Compare-UptimePassword
### Version: 1.1
### Updated: 26/01/2017

function Compare-UptimePassword {
    
    <#
    .Synopsis
        Compares the currently set Uptime agent password to a supplied password.
        
    .Description
        Compares the currently set Uptime agent password to a supplied password.
        A registry check is performed against key HKLM\Software\Wow6432Node\uptime software\up.time agent
        If no key is found, a registry check is performed against key HKLM\Software\uptime software\up.time agent
    
    .Parameter Password
        The password you would like to compare against
        
    .Parameter Server
        The server you would like to compare against
        
    .Example
        # Compares the currently set Uptime agent password to a supplied password.
        Compare-UptimePassword -Password ThisIsAPassword -Server ThisIsAServerName
    
    #>
    
    # Set some available parameters
    param (
	    [Parameter(Mandatory=$true)]        # Set the following parameter to be mandatory
	    [string]$Password,                  # -Password: What password do you want to set?
	
	    [Parameter(Mandatory=$true)]        # Set the following parameter to be mandatory
	    [string]$Server                     # -Server: What server are we checking?
	
    )
    
    # Set a 0 value for when we check if the Remote Registry service is stopped
    $RRServStopped = 0
    
    # Write a message to tell us what we're doing
    Write-Host "Comparing Uptime Agent password on $server ... " -NoNewLine
    
    # Start error handling
    try {
        
        # Check if the "Remote Registry" service is running
        $RRService = Get-Service -Name "Remote Registry" -ComputerName $Server -ErrorAction Stop
        
        # If the status is not "Running"...
        if ( $RRService.Status -ne "Running" ) {
            
            # Start the service
            $RRService | Set-Service -Status Running -ErrorAction Stop
            
            # Up the value of $RRServStopped to 1 so that we know we started it
            $RRServStopped = 1
            
        }
        
        # Open a registry connection to the specified server & open the HKLM hive
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Server)
        
        # Browse to the "up.time agent" key
        $regKey = $reg.OpenSubKey("SOFTWARE\\Wow6432Node\\uptime software\\up.time agent", $true)
        
        # Grab the current agent password value which sits in REG_SV "CmdsPassword"
        $CmdsPassword = $regKey.GetValue("CmdsPassword")
        
        # Check if the password is blank
        if ( $CmdsPassword -eq "" ) {
            
            # Write a yellow message to the console
            Write-Host "No password set!" -ForegroundColor Yellow -BackgroundColor Black
            
            # Kill the script
            Return
            
        # Check if otherwise the passwords match
        } elseif ( $CmdsPassword -eq $Password ) {
            
            # Write a green message to the console
            Write-Host "Password is correct!" -ForegroundColor Green
            
            # Kill the script
            Return
            
        # Lastly, we assume that the passwords don't match
        } else {
            
            # Write a red message to the console. Don't tell the user what the password actually is!
            Write-Host "Password does not match!" -ForegroundColor Red -BackgroundColor Black
            
            # Kill the script
            Return
            
        }
        
        # Check if we had to stop the "Remote Registry" service earlier
        if ( $RRServStopped -eq 1 ) {
            
            # Stop the service again as it was probably stopped for a reason
            Invoke-Command -ComputerName $Server -ScriptBlock {
                Stop-Service -Name "Remote Registry" -ErrorAction Stop
            }
            
            # Set the $RRServStopped back to 0 so we know we stopped it again
            $RRServStopped = 0
            
        }
    
    # Catch any errors    
    } catch [System.Exception] {
        
        # Check if the error message starts with "You cannot call a method"
        if ( $_ -match "You cannot call a method.*" ) {
            
            # Start error handling for a new block
            try {
                
                # Check if the "Remote Registry" service is running
                $RRService = Get-Service -Name "Remote Registry" -ComputerName $Server -ErrorAction Stop
                
                # If the status is not running...
                if ( $RRService -ne "Running" ) {
                    
                    # Start the service
                    $RRService | Set-Service -Status Running -ErrorAction Stop
                    
                    # Up the value of $RRServStopped to 1 so that we know we started it
                    $RRServStopped = 1
                    
                }
                
                # Open a registry connection to the specified server & open the HKLM hive
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Server)
                
                # Browse to the "up.time agent" key
                $regKey = $reg.OpenSubKey("SOFTWARE\\uptime software\\up.time agent", $true)
                
                # Grab the current agent password value which sits in REG_SV "CmdsPassword"
                $CmdsPassword = $regKey.GetValue("CmdsPassword")
                
                # Check if the password is blank
                if ( $CmdsPassword -eq "" ) {
                    
                    # Write a yellow message to the console
                    Write-Host "No password set!" -ForegroundColor Yellow -BackgroundColor Black
                    
                    # Kill the script
                    Return
                
                # Check if otherwise the passwords match    
                } elseif ( $CmdsPassword -eq $Password ) {
                    
                    # Write a green message to the console
                    Write-Host "Password is correct!" -ForegroundColor Green
                    
                    # Kill the script
                    Return
                
                # Lastly, we assume that the passwords don't match    
                } else {
                    
                    # Write a red message to the console. Don't tell the user what the password actually is!
                    Write-Host "Password does not match!" -ForegroundColor Red -BackgroundColor Black
                    
                    # Kill the script
                    Return
                    
                }
                
                # Check if we had to stop the "Remote Registry" service earlier
                if ( $RRServStopped -eq 1 ) {
                    
                    # Stop the service again as it was probably stopped for a reason
                    Invoke-Command -ComputerName $Server -ScriptBlock {
                        Stop-Service -Name "Remote Registry" -ErrorAction Stop
                    }
                    
                    # Set the $RRServStopped back to 0 so we know we stopped it again
                    $RRServStopped = 0
                    
                }
            
            # Catch any errors                     
            } catch [System.Exception] {
                
                # Write the error to the console
                Write-Host "Error! $_" -ForegroundColor Red -BackgroundColor Black
                
            }
        
        # Otherwise, we don't know what this error is    
        } else {
            
            # Write the error to the console
            Write-Host "Error! $_" -ForegroundColor Red -BackgroundColor Black
            
        }
        
    }
    
    # Write a blank line for aesthetics
    Write-Host ""
    
}

### Function: Connect-Office365
### Version: 1.1
### Updated: 27/01/2017

function Connect-Office365 {
    
    <#
    .Synopsis
        Creates a connection to Office 365 for PowerShell remote administration.
        
    .Description
        Creates a connection to Office 365 for PowerShell remote administration.
        
    .Example
        Connect-Office365
    
    #>
    
    # Write a message to say we're testing connectivity
    Write-Host "Checking Office 365 connectivity ... " -NoNewLine
    
    # Start error handling
    try {
        
        # Test if we have a command called Get-Mailbox
        # If we do, we've already connected in this session
        $connCheck = Get-Command Get-Mailbox -ErrorAction Stop
        
        # Check if we returned a $true result
        if ($connCheck) {
            
            # Write a message to say we're already connected
            Write-Host "Already connected!" -ForegroundColor Green
            
            # Kill the function
            Return
            
        }
    
    # Catch any errors    
    } catch [System.Exception] {
        
        # If we caught an error, we're not connected.
        # Write a yellow message to say we're not connected
        Write-Host "Not connected!" -ForegroundColor Yellow -BackgroundColor Black
        
        # Write a message to tell us we're trying to connect
        Write-Host "Connecting to Office 365 ... " -NoNewLine
        
        # Start error handling
        try {
            
            # Prompt the user for credentials
            $UserCredential = Get-Credential -Credential $null -ErrorAction Stop
        
            # Create an Exchange session to https://outlook.office365.com/powershell-liveid/
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
        
            # Import the session
            $StartSession = Import-PSSession $Session -ErrorAction Stop
        
        } catch [System.Exception] {
            
            # Write red error message to the console
            Write-Host "Error! $_" -ForegroundColor Red -BackgroundColor Black
            
            # Kill the function
            Return
            
        }
        # Start error handling
        try {
            
            # Check again if we have the Get-Mailbox command to prove we connected OK
            $connCheck2 = Get-Command Get-Mailbox -ErrorAction Stop
            
            # Check if we returned a $true result
            if ($connCheck2) {
                
                # Write a green message to say we're OK
                Write-Host "Connected!" -ForegroundColor Green
                
                # Kill the function
                Return
                
            }
        
        # Catch any errors    
        } catch [System.Exception] {
            
            # Write a red message to state the error
            Write-Host "Unable to connect! $_" -ForegroundColor Red -BackgroundColor Black
            
            # Kill the function
            Return
            
        }
        
    }
        
}
### Function: Disable-RDP
### Version 1.0
### Updated: 27/01/2017

function Disable-RDP {
    
        <#
    .Synopsis
        Disables the remote desktop protocol on the specified machine.
        
    .Description
        Disables the remote desktop protocol on the specified machine.
    
    .Parameter ComputerName
        The name of the target computer
                
    .Example
        Disable-RDP -ComputerName hostname
    
    #>
    
    # Set some avaialble parameters
    param (
        
        [Parameter(Mandatory=$true,Position=0)]     # Set the following parameter to be mandatory & position 0
        [string]$ComputerName                       # -ComputerName: What is the name of the computer we are targeting?
    
    )
    
    # Firstly, set a variable to 0. We will use this later if we need to start the "Remote Registry" service
    $RRServStopped = 0
    
    # Start error handling
    try {
        
        # Tell us what we're about to do
        Write-Host "Disabling RDP on $ComputerName ... " -NoNewLine
        
        # Get the status of the "Remote Registry" service
        $RRService = Get-Service -Name "Remote Registry" -ComputerName $ComputerName -ErrorAction Stop
        
        # Check if the service is stopped
        if ($RRService.Status -ne "Running") {
            
            # Start the service
            $RRService | Set-Service -Status Running -ErrorAction Stop
            
            # Increase the value of $RRServStopped to 1 so that we know we had to start it
            $RRServStopped = 1
            
        }
        
        # Connect to the registry on the remote computer & open the HKLM hive
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)
        
        # Open the "Terminal Server" key
        $regKey = $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server", $true)
        
        # Check the current value of "fDenyTSConnections"
        # 0= Enabled; 1= Disabled
        $fDenyTSConnections = $regKey.GetValue("fDenyTSConnections")
        
        # Check if RDP is already disabled
        if ($fDenyTSConnections -eq 1) {
            
            # Write a yellow message to say we're already enabled
            Write-Host "RDP is already disabled on this machine!" -ForegroundColor Yellow -BackgroundColor Black
        
        # Otherwise, we assume its enabled (or not correctly set!)    
        } else {
            
            # Set the DWORD value to 1 (disabled)
            $regKey.SetValue("fDenyTSConnections", 1)
            
            # Write a green message to say we're all OK
            Write-Host "RDP disabled" -ForegroundColor Green
            
        }
        
        # Check if we had to start the "Remote Registry" service earlier
        if ($RRServStopped -eq 1) {
            
            # Stop the service again. It was likely disabled for a reason so we don't want to leave it running
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Stop-Service -Name "Remote Registry" -ErrorAction Stop
            }
            
            # Set $RRServStopped back to 0 in case we need to use it again later
            $RRServStopped = 0
            
        }
    
    # Catch any errors  
    } catch [System.Exception] {
        
        # Write a red error message to the console
        Write-Host "Error! $_" -ForegroundColor Red -BackgroundColor Black
        
    }
    
}

### Function: Enable-RDP
### Version 1.0
### Updated: 27/01/2017

function Enable-RDP {
    
        <#
    .Synopsis
        Enables the remote desktop protocol on the specified machine.
        
    .Description
        Enables the remote desktop protocol on the specified machine.
    
    .Parameter ComputerName
        The name of the target computer
                
    .Example
        Enable-RDP -ComputerName hostname
    
    #>
    
    # Set some avaialble parameters
    param (
        
        [Parameter(Mandatory=$true,Position=0)]     # Set the following parameter to be mandatory & position 0
        [string]$ComputerName                       # -ComputerName: What is the name of the computer we are targeting?
    
    )
    
    # Firstly, set a variable to 0. We will use this later if we need to start the "Remote Registry" service
    $RRServStopped = 0
    
    # Start error handling
    try {
        
        # Tell us what we're about to do
        Write-Host "Enabling RDP on $ComputerName ... " -NoNewLine
        
        # Get the status of the "Remote Registry" service
        $RRService = Get-Service -Name "Remote Registry" -ComputerName $ComputerName -ErrorAction Stop
        
        # Check if the service is stopped
        if ($RRService.Status -ne "Running") {
            
            # Start the service
            $RRService | Set-Service -Status Running -ErrorAction Stop
            
            # Increase the value of $RRServStopped to 1 so that we know we had to start it
            $RRServStopped = 1
            
        }
        
        # Connect to the registry on the remote computer & open the HKLM hive
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)
        
        # Open the "Terminal Server" key
        $regKey = $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server", $true)
        
        # Check the current value of "fDenyTSConnections"
        # 0= Enabled; 1= Disabled
        $fDenyTSConnections = $regKey.GetValue("fDenyTSConnections")
        
        # Check if RDP is already enabled
        if ($fDenyTSConnections -eq 0) {
            
            # Write a yellow message to say we're already enabled
            Write-Host "RDP is already enabled on this machine!" -ForegroundColor Yellow -BackgroundColor Black
        
        # Otherwise, we assume its disabled (or not correctly set!)    
        } else {
            
            # Set the DWORD value to 0 (enabled)
            $regKey.SetValue("fDenyTSConnections", 0)
            
            # Write a green message to say we're all OK
            Write-Host "RDP enabled" -ForegroundColor Green
            
        }
        
        # Check if we had to start the "Remote Registry" service earlier
        if ($RRServStopped -eq 1) {
            
            # Stop the service again. It was likely disabled for a reason so we don't want to leave it running
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Stop-Service -Name "Remote Registry" -ErrorAction Stop
            }
            
            # Set $RRServStopped back to 0 in case we need to use it again later
            $RRServStopped = 0
            
        }
    
    # Catch any errors  
    } catch [System.Exception] {
        
        # Write a red error message to the console
        Write-Host "Error! $_" -ForegroundColor Red -BackgroundColor Black
        
    }
    
}

### Function: Export-ADGroup
### Version: 1.1
### Updated: 27/01/2017

function Export-ADGroup {
    
    <#
    .Synopsis
        Exports members of a specified group within Active Directory to a CSV file
        
    .Description
        Exports members of a specified group within Active Directory to a CSV file
    
    .Parameter GroupName
        The name of the group you would like to export
        
    .Parameter FileName
        The filename you would like to export the list to
        
    .Parameter NoDisabled
        Exclude disabled users from the results
        
    .Example
        Export-ADGroup -Group "Beck_Desktop Support" -FileName adexport.csv
    
    #>
    
    # Set some available parameters
    param (
        
        [Parameter(Mandatory=$true,Position=0)]     # Set the following parameter to be mandatory & position 0
        [string]$GroupName,                         # -GroupName: What AD group are we looking for?
        
        [Parameter(Mandatory=$true,Position=1)]     # Set the following parameter to be mandatory & position 1
        [string]$FileName,                          # -FileName: What file are we exporting the list to?
        
        [switch]$NoDisabled = $false                # -NoDisabled: Exclude disabled users
        
    )
    
    # Write a message to tell us what we're doing
    Write-Host "Exporting group members for: " -ForegroundColor Yellow -NoNewLine
    Write-Host "$GroupName`r`n"
    
    # Start error handling
    try {
        
        # Grab a list of group members for $groupName, sort them alphabetically by name and create an array
        $GroupMembers = Get-AdGroupMember -Identity $GroupName -ErrorAction Stop| sort name
    
    # Catch any errors    
    } catch [System.Exception] {
        
        # Write a red message to tell us the error
        Write-Host "Error! $_" -ForegroundColor Red -ForegroundColor Black
        
        # Kill the function
        Return
        
    }
    
    # Write a header for the members list
    Write-Host "Members:`r`n" -ForegroundColor Cyan
    
    # Create an empty array to store the formatted list of members
    $memberObjs = @()
    
    # Start a loop to run through each member we found
    foreach ($Member in $GroupMembers) {
        
        # Using the samAccountName value, find the AD user
        $adUser = Get-ADUser $member.samAccountName
        
        # Check if the user is disabled. Also check if we asked not to display disabled users
        # If we asked not to show disabled users, this whole section will essentially be ignored
        if ( ($adUser.Enabled -eq $false) -and (!$noDisabled) ) {

            # Display the user's name & samAccountName
            Write-Host "$($adUser.Name) ($($adUser.samAccountName))" -NoNewLine
            # Add a red [Disabled] tag
            Write-Host " [Disabled]" -ForegroundColor Red
            
            # Create a new object
            $memberObj = New-Object PSObject
           
            # Add the member to our object
            $memberObj | Add-Member -MemberType NoteProperty -Name "Name" -Value "$($adUser.Name) ($($adUser.samAccountName)) [Disabled]"
        
        # Otherwise, we expect the user is enabled            
        } elseif ($adUser.Enabled -eq $true) {
            
            # Display the user's name & samAccountName
            Write-Host "$($adUser.Name) ($($adUser.samAccountName))"
            
            # Create a new object
            $memberObj = New-Object PSObject
            
            # Add the member to our object
            $memberObj | Add-Member -memberType NoteProperty -name "Name" -value "$($adUser.Name) ($($adUser.samAccountName))"
                        
        }
        
        # Add the object to our array
        $memberObjs+= $memberObj
        
    }
    
    # Select the "Name" value from our object array & export it to a CSV file
    $memberObjs | Select-Object Name | Export-CSV $FileName -NoTypeInformation
    
}

### Function: Export-SecurePassword
### Version: 1.0
### Updated: 26/01/2017

function Export-SecurePassword {

    <# 
    .Synopsis
        Converts a password to a SecureString, then outputs the text equivalent.

    .Description
        Converts a password to a SecureString, then outputs the text equivalent.
        Note: The SecureString can only be used by the user who generates it, on the computer
              they generated it on. It cannot be transferred to other users or computers. 

    .Parameter Password
        The plain-text password to convert.

    .Parameter File
        The file you should like to output your SecureString text to.
        
    .Parameter OutString
        Switch to output the final result to the console.
  
    .Example
        # Convert a password to a SecureString, then output the text equivalent to file.
        Export-SecurePassword -Password ThisIsAPassword -File my-secure-password.txt
        
    .Example
        # Convert a password to a SecureString, then output the text equivalent to file & console.
        Export-SecurePassword -Password ThisIsAPassword -File my-secure-password.txt -OutString

    #>
        
    # Set some avaialble paramters.
    param (
	    [Parameter(Position=1,Mandatory=$true)]     # Set the following parameter to be mandatory & make it the assumed position 1 parameter
	    [string]$Password,                          # -password: What is the password we want to convert to a SecureString?
        
        [Parameter(Position=2)]                     # Make the following parameter to be the assumed position 2 parameter
	    [string]$File = "passwd.txt",               # -file: What file name are we exporting the SecureString password to? If nothing supplied, assume "passwd.txt"
        
        [Parameter(Position=3)]                     # Make the following parameter to be the assumed position 3 parameter
        [switch]$OutString = $False                 # -OutString: Do you want to see the final string on the console?
    )

    # Tell us what we're doing
    Write-Host "Converting password to SecureString ... " -NoNewLine

    # Start error handling
    try {
        
        # Take the value of $password and convert it to a SecureString
        $securePassword = $password | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop | ConvertFrom-SecureString -ErrorAction Stop
        # Export the new $securePassword to file
        $securePassword | Out-File $file -ErrorAction Stop
       
        # Tell us everything was OK!
        Write-Host "OK!" -ForegroundColor green
        
        # Check if we need to display the string on the console
        if ($outString) {
            
            # Output the string to the console
            Write-Host "`r`nString: $securePassword"
            
        }
    
    # Catch any errors
    } catch [System.Exception] {
        
        # Output an error message 
        Write-Host "$_" -ForegroundColor Red -BackgroundColor Black   
    }

    # Write a blank line for aesthetics
    Write-Host ""

}

### Function: Get-GroupMembers
### Version: 1.3
### Updated: 27/01/2017

function Get-GroupMembers {
    
    <# 
    .Synopsis
        Gets a list of accounts that are members of the specified local group

    .Description
        Gets a list of accounts that are members of the specified local group

    .Parameter ComputerName
        The hostname of the computer we are targeting

    .Parameter GroupName
        The name of the local group we are targeting
        
    .Example
        Get-GroupMembers Administrators Hostname

    #>
    
    # Set some avaialble parameters
    param (
        
        [Parameter(Mandatory=$true,Position=0)]     # Set this parameter to be mandatory & position 0
        [string]$GroupName,                         # -GroupName: Which local group do we want to get members from?
        
        [Parameter(Mandatory=$true,Position=1)]     # Set this parameter to be mandatory & position 1
        [string]$ComputerName,                      # -ComputerName: What is the hostname of the machine we are targeting?
        
        [Parameter(Mandatory=$false,Position=2)]    # Set this parameter to be position 2, but not mandatory
        [string]$OutFile                            # -OutFile: Do you want to output data to a file? If so, what file?
        
    )
        
}


### Function: Restart-UptimeWeb
### Version: 1.0
### Updated: 27/01/2017

function Restart-UptimeWeb {
   
    <#
    .Synopsis
        Restarts "Uptime Web Server" service on specified host
        
    .Description
        Restarts "Uptime Web Server" service on specified host
    
    .Parameter ComputerName
        The hostname of the computer hosting the Uptime services
        
    .Example
        Restart-UptimeWeb -ComputerName hostname
    
    #>
    
    # Set some available parameters
    param (
        
        [Parameter(Mandatory=$true)]    # Set the following parameter to be mandatory
        [string]$ComputerName           # -ComputerName: What is the name of the computer hosting Uptime?
    
    )
    
    # Get the state of the service, then force it to restart
    Get-Service -name "Uptime Web Server" -ComputerName $ComputerName | Restart-Service -Force
    
    # Kill the function
    Return    
    
}

### Function: Set-UptimePassword
### Version: 1.3
### Updated: 27/01/2017

function Set-UptimePassword {

    <# 
    .Synopsis
        Sets the Uptime agent password on the specified machine(s)

    .Description
        Sets the Uptime agent password on the specified machine(s). Some Uptime service monitors
        require a password to be set on the agent. This cmdlet can be used to set the password on
        a single server or multiple servers depending on the use of the -Server or -Servers parameter

    .Parameter Password
        The password you would like to set

    .Parameter Server
        The hostname of the server. Cannot be used in conjuction with -Servers.
        
    .Parameter Servers
        The path to a text file storing your server hostnames. This file should specify one server
        per line. Cannot be used in conjuction with -Server.
  
    .Example
        # Sets the Uptime agent password on one specified machine
        Set-UptimePassword -Password ThisIsAPassword -Server ServerHostname
        
    .Example
        # Convert a password to a SecureString, then output the text equivalent to file & console.

    #>
    
    # Set some avaialble parameters.
    param (
        
        [Parameter(Mandatory=$true)]        # Set the following parameter to be mandatory
        [string]$Password,                  # -Password: What password do you want to set?
        
        [string]$Server,                    # -Server: What server do you want to apply the password to?
        [string]$Servers,                   # -Servers: Where is your list of servers?
        [switch]$LogAll = $false            # -LogAll: Do we want to log all messages, or just OK?
                
    )
    
    # Before we start doing anything, let's start an error counter.
    $errCount = 0
    
    # Also, let's set a value to 0 for the "Remote Registry" service.
    # If we need to stop the service later, we'll set this to 1 as a reference.
    $RRServStopped = 0
    
    # Set a log file name. By default, only errors will be logged. If -LogAll is specified, everything gets logged
    $logFile = "Set-UptimePassword_$(Get-Date -Format yyyyMMdd-hhmm).log"
    
    # Check if we asked for just one server
    if ($Server) {
        
        # Start error logging
        try {
            
            # Write a message to tell us what we're doing
            Write-Host "Setting password on $Server ... " -NoNewLine
            
            # Find out if the "Remote Registry" service is stopped or started
            $RRService = Get-Service -Name "Remote Registry" -ComputerName $Server -ErrorAction Stop
            
            # If the service is stopped...
            if ($RRService.Status -ne "Running") {
                
                # Start the service
                $RRService | Set-Service -Status Running -ErrorAction Stop
                
                # Set $RRServStopped to 1 so that we know we stopped it
                $RRServStopped = 1
            }
            
            # Connect to the remote registry of the requested server & open the HKLM hive
            $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Server)
            
            # Open the key that stores the password.
            # We'll try the 32-bit location on a 64-bit machine first as it's easier to capture errors
            # HKLM\SOFTWARE\Wow6432Node\uptime software\up.time agent
            $regKey = $reg.OpenSubKey("SOFTWARE\\Wow6432Node\\uptime software\\up.time agent", $true)
            
            # Set the value of "CmdsPassword" to the specified password
            $regKey.SetValue("CmdsPassword", "$Password", "String")
            
            # Check if we had to start the "Remote Registry" service earlier
            if ($RRServStopped -eq 1) {
                
                # Stop the service as it was probably stopped for a reason
                Invoke-Command -ComputerName $Server -ScriptBlock {
                    Stop-Service -Name "Remote Registry" -ErrorAction Stop
                }
                
                # Set $RRservStopped back to 0 in case we need to use it again later
                $RRServStopped = 0
                
            }
            
            # Write a green status message to tell us it went OK
            Write-Host "OK!" -ForegroundColor Green
            
            # Check if we asked to log all messages
            if ($LogAll) {
                
                # If we did, set an OK message and write it to $logFile
                $logMessage = "$($Server): OK!"
                $logMessage | Out-File $logFile -Append
                
            }
            
        # Catch any errors
        } catch [System.Exception] {
            
            # Check if the error say "You cannot call a method on a null-valued expression"
            # If it did, it means we asked it to set the value in the Wow6432Node key, but 
            # no key existed. Chances are, we either have a 64-bit agent installed, or we're
            # trying to apply it to a 32-bit machine where Wow6432Node doesn't exist
            if ($_ -match "You cannot call a method.*") {
                
                # Let's try again
                try {
                    
                    # Write a message to tell us what we're doing
                    Write-Host "Setting password on $Server ... " -NoNewLine
                
                    # Find out if the "Remote Registry" service is stopped or started
                    $RRService = Get-Service -Name "Remote Registry" -ComputerName $Server -ErrorAction Stop
            
                    # If the service is stopped...
                    if ($RRService.Status -ne "Running") {
                
                        # Start the service
                        $RRService | Set-Service -Status Running -ErrorAction Stop
                
                        # Set $RRServStopped to 1 so that we know we stopped it
                        $RRServStopped = 1
    
                    }
            
                    # Connect to the remote registry of the requested server & open the HKLM hive
                    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Server)
            
                    # Open the key that stores the password.
                    # We'll try the standard location instead this time
                    # HKLM\SOFTWARE\uptime software\up.time agent
                    $regKey = $reg.OpenSubKey("SOFTWARE\\uptime software\\up.time agent", $true)
            
                    # Set the value of "CmdsPassword" to the specified password
                    $regKey.SetValue("CmdsPassword", "$Password", "String")
            
                    # Check if we had to start the "Remote Registry" service earlier
                    if ($RRServStopped -eq 1) {
                
                        # Stop the service as it was probably stopped for a reason
                        Invoke-Command -ComputerName $Server -ScriptBlock {
                            Stop-Service -Name "Remote Registry" -ErrorAction Stop
                        }
                
                        # Set $RRservStopped back to 0 in case we need to use it again later
                        $RRServStopped = 0
                
                    }
            
                    # Write a green status message to tell us it went OK
                    Write-Host "OK!" -ForegroundColor Green
            
                    # Check if we asked to log all messages
                    if ($LogAll) {
                
                        # If we did, set an OK message and write it to $logFile
                        $logMessage = "$($Server): OK!"
                        $logMessage | Out-File $logFile -Append
                
                    }
                    
                # If we still caught an errors...    
                } catch [System.Exception] {
                    
                    # Write a red message to tell us what the error was
                    Write-Host "ERROR! $_" -ForegroundColor Red -BackgroundColor Black
                    
                    # Write the error to the log file
                    $logMessage = "$($Server): ERROR! $_"
                    $logMessage | Out-File $logFile -Append
                    
                    # Increase the number of errors encountered by 1
                    $errVal++
                    
                } 
            
            # If that wasn't the error, check for another error. "Service 'Remote Registry (RemoteRegistry)'
            # cannot be configured due to the following error: Access is denied"
            # This is likely because we couldn't startt he remote registry service    
            } elseif ($_ -match "Service \'Remote Registry \(RemoteRegistry\)\' cannot be configured due to the following error: Access is denied") {
                
                # Write a red message to state we couldn't start the "Remote Registry" service
                Write-Host "ERROR! Failed to start Remote Registry service. Access is denied" -ForegroundColor Red -BackgroundColor Black
                
                # Write the error to the log file
                $logMessage = "$($Server): ERROR! Failed to start Remote Registry service. Access is denied"
                $logMessage | Out-File $logFile -Append
                
                # Increase the number of errors encountered by 1
                $errVal++
                
            # We've handled the common errors, so if we still haven't handled it, let's just kill it here    
            } else {
                
                # Write a red message stating what the error was
                Write-Host "ERROR! $_" -ForegroundColor Red -BackgroundColor Black
                
                # Write the error to the log file
                $logMessage = "$($Server): ERROR! $_"
                $logMessage | Out-File $logFile -Append
                
                # Increase the number of errors encountered by 1
                $errVal++
                
            }
            
        }
        
        # Check if we encountered an error
        if ($errVal -eq 1) {
            
            # Write a red message to say we hit an error
            Write-Host "`r`nCompleted with $errVal error!" -ForegroundColor Red -BackgroundColor Black
            
        # Check if we encountered more than one error
        } elseif ($errVal -gt 1) {
            
            # Write a red message to say we hit multiple errors
            Write-Host "`r`nCompleted with $errVal errors!" -ForegroundColor Red -BackgroundColor Black
        
        # But if everything was OK...    
        } else {
            
            # Write a green message to confirm we're all OK
            Write-Host "`r`nCompleted with no errors!" -ForegroundColor Green
            
        }
    
    # If we didn't ask for just one server, did we supply a list of servers?    
    } elseif ($Servers) {
        
        # Start error handling
        try {
            
            # Import the list of servers supplied
            $listOfServers = Get-Content $Servers -ErrorAction Stop
            
        # Catch any errors. Most likely to be that the file doesn't exist    
        } catch [System.Exception] {
            
            # Write a red message stating the error
            Write-Host "ERROR! $_" -ForegroundColor Red -BackgroundColor Black
            Write-Host "`r`nCompleted with 1 error!" -ForegroundColor Red -BackgroundColor Black
            
            # Write the error to the log file
            $logMessage = "ERROR! $_`r`n`r`nScript completed with 1 error!"
            $logMessage | Out-File $logFile -Append
            
            # Kill the script, we don't want to go any further
            Return
            
        }
        
        # Now that we've got a list of servers, let's do something with each one
        foreach ($Svr in $listOfServers) {
            
            # Start error logging
            try {
            
                # Write a message to tell us what we're doing
                Write-Host "Setting password on $Svr ... " -NoNewLine
            
                # Find out if the "Remote Registry" service is stopped or started
                $RRService = Get-Service -Name "Remote Registry" -ComputerName $Svr -ErrorAction Stop
            
                # If the service is stopped...
                if ($RRService.Status -ne "Running") {
                
                    # Start the service
                    $RRService | Set-Service -Status Running -ErrorAction Stop
                
                    # Set $RRServStopped to 1 so that we know we stopped it
                    $RRServStopped = 1
                
                }
            
                # Connect to the remote registry of the requested server & open the HKLM hive
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Svr)
            
                # Open the key that stores the password.
                # We'll try the 32-bit location on a 64-bit machine first as it's easier to capture errors
                # HKLM\SOFTWARE\Wow6432Node\uptime software\up.time agent
                $regKey = $reg.OpenSubKey("SOFTWARE\\Wow6432Node\\uptime software\\up.time agent", $true)
            
                # Set the value of "CmdsPassword" to the specified password
                $regKey.SetValue("CmdsPassword", "$Password", "String")
            
                # Check if we had to start the "Remote Registry" service earlier
                if ($RRServStopped -eq 1) {
                
                    # Stop the service as it was probably stopped for a reason
                    Invoke-Command -ComputerName $Svr -ScriptBlock {
                        Stop-Service -Name "Remote Registry" -ErrorAction Stop
                    }
                
                    # Set $RRservStopped back to 0 in case we need to use it again later
                    $RRServStopped = 0
                
                }
            
                # Write a green status message to tell us it went OK
                Write-Host "OK!" -ForegroundColor Green
            
                # Check if we asked to log all messages
                if ($LogAll) {
                
                    # If we did, set an OK message and write it to $logFile
                    $logMessage = "$($Svr): OK!"
                    $logMessage | Out-File $logFile -Append
                
                }
            
            # Catch any errors
            } catch [System.Exception] {
            
                # Check if the error say "You cannot call a method on a null-valued expression"
                # If it did, it means we asked it to set the value in the Wow6432Node key, but 
                # no key existed. Chances are, we either have a 64-bit agent installed, or we're
                # trying to apply it to a 32-bit machine where Wow6432Node doesn't exist
                if ($_ -match "You cannot call a method.*") {
                
                    # Let's try again
                    try {
                    
                        # Write a message to tell us what we're doing
                        Write-Host "Setting password on $Svr ... " -NoNewLine
                
                        # Find out if the "Remote Registry" service is stopped or started
                        $RRService = Get-Service -Name "Remote Registry" -ComputerName $Svr -ErrorAction Stop
            
                        # If the service is stopped...
                        if ($RRService.Status -ne "Running") {
                
                            # Start the service
                            $RRService | Set-Service -Status Running -ErrorAction Stop
                
                            # Set $RRServStopped to 1 so that we know we stopped it
                            $RRServStopped = 1
    
                        }
            
                        # Connect to the remote registry of the requested server & open the HKLM hive
                        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Svr)
            
                        # Open the key that stores the password.
                        # We'll try the standard location instead this time
                        # HKLM\SOFTWARE\uptime software\up.time agent
                        $regKey = $reg.OpenSubKey("SOFTWARE\\uptime software\\up.time agent", $true)
            
                        # Set the value of "CmdsPassword" to the specified password
                        $regKey.SetValue("CmdsPassword", "$Password", "String")
            
                        # Check if we had to start the "Remote Registry" service earlier
                        if ($RRServStopped -eq 1) {
                
                            # Stop the service as it was probably stopped for a reason
                            Invoke-Command -ComputerName $Svr -ScriptBlock {
                                Stop-Service -Name "Remote Registry" -ErrorAction Stop
                            }
                
                            # Set $RRservStopped back to 0 in case we need to use it again later
                            $RRServStopped = 0
                
                        }
            
                        # Write a green status message to tell us it went OK
                        Write-Host "OK!" -ForegroundColor Green
            
                        # Check if we asked to log all messages
                        if ($LogAll) {
                
                            # If we did, set an OK message and write it to $logFile
                            $logMessage = "$($Svr): OK!"
                            $logMessage | Out-File $logFile -Append
                
                        }
                    
                    # If we still caught an errors...    
                    } catch [System.Exception] {
                    
                        # Write a red message to tell us what the error was
                        Write-Host "ERROR! $_" -ForegroundColor Red -BackgroundColor Black
                    
                        # Write the error to the log file
                        $logMessage = "$($Svr): ERROR! $_"
                        $logMessage | Out-File $logFile -Append
                    
                        # Increase the number of errors encountered by 1
                        $errVal++
                    
                    } 
            
                # If that wasn't the error, check for another error. "Service 'Remote Registry (RemoteRegistry)'
                # cannot be configured due to the following error: Access is denied"
                # This is likely because we couldn't startt he remote registry service    
                } elseif ($_ -match "Service \'Remote Registry \(RemoteRegistry\)\' cannot be configured due to the following error: Access is denied") {
                
                    # Write a red message to state we couldn't start the "Remote Registry" service
                    Write-Host "ERROR! Failed to start Remote Registry service. Access is denied" -ForegroundColor Red -BackgroundColor Black
                
                    # Write the error to the log file
                    $logMessage = "$($Svr): ERROR! Failed to start Remote Registry service. Access is denied"
                    $logMessage | Out-File $logFile -Append
                
                    # Increase the number of errors encountered by 1
                    $errVal++
                
                # We've handled the common errors, so if we still haven't handled it, let's just kill it here    
                } else {
                
                    # Write a red message stating what the error was
                    Write-Host "ERROR! $_" -ForegroundColor Red -BackgroundColor Black
                
                    # Write the error to the log file
                    $logMessage = "$($Svr): ERROR! $_"
                    $logMessage | Out-File $logFile -Append
                
                    # Increase the number of errors encountered by 1
                    $errVal++

                }
            
            }
            
        }
        
        # Check if we encountered an error
        if ($errVal -eq 1) {
            
            # Write a red message to say we hit an error
            Write-Host "`r`nCompleted with $errVal error!" -ForegroundColor Red -BackgroundColor Black
            
        # Check if we encountered more than one error
        } elseif ($errVal -gt 1) {
            
            # Write a red message to say we hit multiple errors
            Write-Host "`r`nCompleted with $errVal errors!" -ForegroundColor Red -BackgroundColor Black
        
        # But if everything was OK...    
        } else {
            
            # Write a green message to confirm we're all OK
            Write-Host "`r`nCompleted with no errors!" -ForegroundColor Green
            
        }
        
    # If we haven't specified a server or a list of servers, then what did you want me to do?    
    } else {
        
        # Write red message to state you haven't specified anything
        Write-Host "ERROR! No -Server or -Servers parameter specified. Nothing to do!" -ForegroundColor Red -BackgroundColor Black
        
        # Write the error to the log file
        $logMessage = "ERROR! No -Server or -Servers parameter specified. Nothing to do!`r`n`r`nCompleted with 1 error!"
        $logMessage | Out-File $logFile -Append
        
        # Kill the script, we don't want to do anything else
        Return
        
    }
    
}

### Export functions

Export-ModuleMember -Function "Compare-UptimePassword"
Export-ModuleMember -Function "Connect-Office365"
Export-ModuleMember -Function "Disable-RDP"
Export-ModuleMember -Function "Enable-RDP"
Export-ModuleMember -Function "Export-ADGroup"
Export-ModuleMember -Function "Export-SecurePassword"
Export-ModuleMember -Function "Restart-UptimeWeb"
Export-ModuleMember -Function "Set-UptimePassword"