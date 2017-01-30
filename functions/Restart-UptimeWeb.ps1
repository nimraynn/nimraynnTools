### nimraynnTools PowerShell Module Pack

### Function: Restart-UptimeWeb
### Version: 1.0
### Updated: 27.01.17

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