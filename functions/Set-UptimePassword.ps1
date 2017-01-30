### nimraynnTools PowerShell Module Pack

### Function: Set-UptimePassword
### Version: 1.3
### Updated: 27.01.17

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