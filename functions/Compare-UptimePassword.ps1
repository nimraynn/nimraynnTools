### nimraynnTools PowerShell Module Pack

### Function: Compare-UptimePassword
### Version: 1.1
### Updated: 26.01.17

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