### nimraynnTools PowerShell Module Pack

### Function: Disable-RDP
### Version 1.0
### Updated: 27.01.17

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