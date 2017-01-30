### nimraynnTools PowerShell Module Pack

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